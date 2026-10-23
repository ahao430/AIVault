package com.aivault.aivault

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import es.antonborri.home_widget.HomeWidgetBackgroundWorker
import io.flutter.FlutterInjector

/**
 * 桌面看板小组件：读取 home_widget 写入的 HomeWidgetPreferences，
 * 展示前 4 个供应商的额度/余额 + 重置倒计时。
 * 数据键与 lib/services/widget_sync.dart 对应：updated / t0..t3 / v0..v3。
 *
 * 刷新链路（手动 + 自动，详见 WidgetAutoRefresh）：
 * - 刷新按钮（ACTION_REFRESH）→ 显示「刷新中…」→ 后台拉取 → 重绘
 * - 自动：30 分钟 WorkManager 周期任务 / 开机补刷 / onUpdate 节流静默拉取
 * - 其余 APPWIDGET_UPDATE（系统/桌面发起）只重绘已存数据：
 *   部分桌面（MIUI 等）会频繁发送更新广播，拉取由节流逻辑统一把关
 * - Dart 侧 sync 的 updateWidget 广播带 triggeredFromHomeWidget=true → 重绘
 */
open class AIVaultWidgetProvider : AppWidgetProvider() {

    /// 布局资源：HyperOS 专用变体（HyperOsWidgetProvider）覆写
    protected open val layoutRes: Int = R.layout.aivault_widget

    override fun onReceive(context: Context, intent: Intent) {
        val fromSelfSync = intent.getBooleanExtra(EXTRA_TRIGGERED_FROM_HOME_WIDGET, false)
        Log.d(TAG, "onReceive action=${intent.action} fromSelfSync=$fromSelfSync")
        if (intent.action == ACTION_REFRESH) {
            // 刷新按钮：先立刻给可见反馈，再走后台拉取（唯一拉取入口）
            redraw(context, updatedLabel = "刷新中…")
            triggerBackgroundFetch(context, intent.data)
            super.onReceive(context, intent)
            return
        }
        // 其余更新只重绘（super → onUpdate），不再后台拉取
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        drawWidgets(context, appWidgetManager, appWidgetIds, updatedLabel = null)
        // 系统 30 分钟周期（updatePeriodMillis）与部分桌面的重绘广播都会进这里：
        // 节流 15 分钟静默拉取（不显示「刷新中…」，不闪烁），见 WidgetAutoRefresh
        WidgetAutoRefresh.maybeFetchNow(context, "update")
    }

    /// 重绘本 Provider 的全部实例（用 javaClass，子类变体各自维护实例集）；
    /// [updatedLabel] 非空时用于临时覆盖头部时间戳（如「刷新中…」）
    private fun redraw(context: Context, updatedLabel: String?) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, javaClass))
        drawWidgets(context, manager, ids, updatedLabel)
    }

    private fun drawWidgets(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        updatedLabel: String?
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val launch = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        // 刷新按钮：发给自己（不走 home_widget 的接收器，见类注释；
        // 用 javaClass 让 HyperOS 变体的按钮广播回自身）
        val refreshIntent = Intent(context, javaClass).apply {
            action = ACTION_REFRESH
            data = Uri.parse("aivault://widget/refresh")
        }
        val refresh = PendingIntent.getBroadcast(
            context, 1, refreshIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val rowIds = listOf(
            Triple(R.id.row0, R.id.row0_title, R.id.row0_value),
            Triple(R.id.row1, R.id.row1_title, R.id.row1_value),
            Triple(R.id.row2, R.id.row2_title, R.id.row2_value),
            Triple(R.id.row3, R.id.row3_title, R.id.row3_value)
        )

        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutRes)
            views.setTextViewText(
                R.id.updated,
                updatedLabel ?: prefs.getString("updated", "AIVault 看板")
            )

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

    private fun triggerBackgroundFetch(context: Context, data: Uri?) {
        Log.d(TAG, "triggerBackgroundFetch")
        try {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(context)
            loader.ensureInitializationComplete(context, null)
            // 直接以 REPLACE 入队插件的 Worker（不走其接收器的 APPEND 路径）：
            // APPEND 下历史任务只要失败过一次，唯一链永久失效、后续点击全被丢弃
            val workData = Data.Builder()
                .putString(WORK_DATA_KEY, data?.toString() ?: "")
                .build()
            val request = OneTimeWorkRequestBuilder<HomeWidgetBackgroundWorker>()
                .setInputData(workData)
                .build()
            WorkManager.getInstance(context).enqueueUniqueWork(
                WORK_NAME, ExistingWorkPolicy.REPLACE, request
            )
        } catch (e: Exception) {
            Log.e(TAG, "后台刷新入队失败", e)
            redraw(context, updatedLabel = "刷新失败")
        }
    }

    private companion object {
        const val TAG = "AIVaultWidget"
        const val ACTION_REFRESH = "com.aivault.aivault.action.WIDGET_REFRESH"
        const val EXTRA_TRIGGERED_FROM_HOME_WIDGET = "triggeredFromHomeWidget"
        const val WORK_NAME = "home_widget_background"
        const val WORK_DATA_KEY = "uri_data"
    }
}
