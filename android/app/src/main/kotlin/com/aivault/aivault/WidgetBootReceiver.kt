package com.aivault.aivault

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * 开机补刷：BOOT_COMPLETED 后确保周期任务在册，并立即拉一次数据
 * （重启后 WorkManager 周期任务自动恢复，但下一次触发可能要等最多 30 分钟，
 * 先手动补一次让桌面组件尽快恢复新鲜数据）。
 */
class WidgetBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        WidgetAutoRefresh.ensurePeriodic(context)
        WidgetAutoRefresh.maybeFetchNow(context, "boot")
    }
}
