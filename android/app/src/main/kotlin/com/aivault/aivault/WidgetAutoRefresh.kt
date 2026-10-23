package com.aivault.aivault

import android.content.Context
import android.util.Log
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import es.antonborri.home_widget.HomeWidgetBackgroundWorker
import io.flutter.FlutterInjector
import java.util.concurrent.TimeUnit

/**
 * 小组件后台自动刷新（Android 8+ 限制下的折中方案）：
 *
 * 1. 周期任务：WorkManager 每 30 分钟跑一次插件的 Dart 后台拉取
 *    （复用刷新按钮链路；WorkManager 任务跨重启持久化）
 * 2. 开机补刷：BOOT_COMPLETED 后立即拉一次（见 WidgetBootReceiver），
 *    避免重启后组件长时间显示旧数据
 * 3. 系统/桌面 poke：appwidget-provider 的 updatePeriodMillis=30min 与部分
 *    桌面主动发送的 APPWIDGET_UPDATE 都会进 onUpdate，配合 15 分钟节流
 *    静默拉取，不显示「刷新中…」避免闪烁
 *
 * 说明：Android 8.0 起 ACTION_USER_PRESENT / SCREEN_ON 等解锁广播不允许
 * manifest 注册（implicit broadcast 限制，豁免名单里没有），运行时注册又
 * 依赖进程存活，因此「每次解锁必刷」没有可靠的公开 API；
 * 上述三条链路可保证数据至多落后约 30 分钟，且常见场景（开机、桌面重绘、
 * 周期）都会触发补刷。
 */
object WidgetAutoRefresh {
    private const val TAG = "AIVaultAutoRefresh"
    private const val PERIODIC_NAME = "aivault-widget-periodic"
    private const val ONESHOT_NAME = "home_widget_background"
    private const val PREFS = "aivault_widget_auto"
    private const val KEY_LAST_FETCH = "lastAutoFetchMs"

    /// 两次自动拉取的最小间隔（毫秒）：各触发源合并去抖
    private const val THROTTLE_MS = 15 * 60_000L

    /// 记录一次拉取时间（自动与手动共用，避免手动刷新刚结束
    /// 又被 onUpdate 的静默拉取立即重复触发一次）
    fun markFetched(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putLong(KEY_LAST_FETCH, System.currentTimeMillis()).apply()
    }

    fun ensurePeriodic(context: Context) {
        try {
            val request = PeriodicWorkRequestBuilder<HomeWidgetBackgroundWorker>(
                30, TimeUnit.MINUTES
            )
                .setInputData(Data.Builder().putString("uri_data", "aivault://widget/auto/periodic").build())
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                PERIODIC_NAME, ExistingPeriodicWorkPolicy.KEEP, request
            )
            Log.d(TAG, "periodic 已确保注册")
        } catch (e: Exception) {
            Log.e(TAG, "注册周期刷新失败", e)
        }
    }

    /**
     * 节流触发一次后台拉取（静默：不覆盖时间戳为「刷新中…」，
     * 拉取完成后 Dart 侧 sync(force) 会自然更新时间戳）。
     */
    fun maybeFetchNow(context: Context, source: String) {
        try {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val now = System.currentTimeMillis()
            if (now - prefs.getLong(KEY_LAST_FETCH, 0L) < THROTTLE_MS) {
                return
            }
            prefs.edit().putLong(KEY_LAST_FETCH, now).apply()

            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(context)
            loader.ensureInitializationComplete(context, null)
            val workData = Data.Builder()
                .putString("uri_data", "aivault://widget/auto/$source")
                .build()
            val request = OneTimeWorkRequestBuilder<HomeWidgetBackgroundWorker>()
                .setInputData(workData)
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .build()
            WorkManager.getInstance(context).enqueueUniqueWork(
                ONESHOT_NAME, ExistingWorkPolicy.REPLACE, request
            )
            Log.d(TAG, "自动刷新已入队（$source）")
        } catch (e: Exception) {
            Log.e(TAG, "自动刷新入队失败", e)
        }
    }
}
