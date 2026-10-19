package com.aivault.aivault

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

/**
 * 桌面看板小组件：读取 home_widget 写入的 HomeWidgetPreferences，
 * 展示前 4 个供应商的额度/余额 + 重置倒计时。
 * 数据键与 lib/services/widget_sync.dart 对应：updated / t0..t3 / v0..v3。
 *
 * 刷新链路（防循环）：
 * - 刷新按钮 → HomeWidgetBackgroundIntent → 后台 Dart 回调拉取数据
 * - 系统周期 APPWIDGET_UPDATE（updatePeriodMillis）→ 同样触发后台拉取
 * - Dart 侧 sync 完成的 updateWidget 广播带 triggeredFromHomeWidget=true
 *   → 只重绘、不再拉取，避免「拉取→刷新→再拉取」死循环
 */
class AIVaultWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        val fromSelfSync = intent.getBooleanExtra(EXTRA_TRIGGERED_FROM_HOME_WIDGET, false)
        super.onReceive(context, intent)
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE && !fromSelfSync) {
            // 系统周期刷新（非我们自己的 sync 触发）→ 后台拉取最新数据
            triggerBackgroundFetch(context)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val launch = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        // 刷新按钮：后台 Dart 回调拉数据（不打开 App）
        val refresh = HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("aivault://widget/refresh")
        )

        val rowIds = listOf(
            Triple(R.id.row0, R.id.row0_title, R.id.row0_value),
            Triple(R.id.row1, R.id.row1_title, R.id.row1_value),
            Triple(R.id.row2, R.id.row2_title, R.id.row2_value),
            Triple(R.id.row3, R.id.row3_title, R.id.row3_value)
        )

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.aivault_widget)
            views.setTextViewText(R.id.updated, prefs.getString("updated", "AIVault 看板"))

            var visibleRows = 0
            for (i in rowIds.indices) {
                val title = prefs.getString("t$i", "") ?: ""
                val value = prefs.getString("v$i", "") ?: ""
                val (containerId, titleId, valueId) = rowIds[i]
                if (title.isEmpty()) {
                    views.setViewVisibility(containerId, View.GONE)
                } else {
                    views.setViewVisibility(containerId, View.VISIBLE)
                    views.setTextViewText(titleId, title)
                    views.setTextViewText(valueId, value)
                    visibleRows++
                }
            }
            if (visibleRows == 0) {
                views.setViewVisibility(R.id.empty_hint, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.empty_hint, View.GONE)
            }

            views.setOnClickPendingIntent(R.id.widget_root, launch)
            views.setOnClickPendingIntent(R.id.refresh_btn, refresh)
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun triggerBackgroundFetch(context: Context) {
        val intent = Intent(context, Class.forName(BACKGROUND_RECEIVER)).apply {
            action = BACKGROUND_ACTION
            data = Uri.parse("aivault://widget/refresh")
        }
        context.sendBroadcast(intent)
    }

    private companion object {
        const val EXTRA_TRIGGERED_FROM_HOME_WIDGET = "triggeredFromHomeWidget"
        const val BACKGROUND_RECEIVER =
            "es.antonborri.home_widget.HomeWidgetBackgroundReceiver"
        const val BACKGROUND_ACTION = "es.antonborri.home_widget.action.BACKGROUND"
    }
}
