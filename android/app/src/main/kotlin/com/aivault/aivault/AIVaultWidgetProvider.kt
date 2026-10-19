package com.aivault.aivault

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

/**
 * 桌面看板小组件：读取 home_widget 写入的 HomeWidgetPreferences，
 * 展示前 4 个供应商的额度/余额 + 重置倒计时。
 * 数据键与 lib/services/widget_sync.dart 对应：updated / t0..t3 / v0..v3。
 */
class AIVaultWidgetProvider : AppWidgetProvider() {

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
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
