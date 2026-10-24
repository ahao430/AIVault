package com.aivault.aivault

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 小组件后台自动刷新：App 打开时确保 30 分钟周期任务在册
        WidgetAutoRefresh.ensurePeriodic(applicationContext)
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        // 远程开发：Tailscale 未开启时一键拉起 Tailscale App
        MethodChannel(engine.dartExecutor.binaryMessenger, "aivault/tailscale")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openApp" -> {
                        try {
                            val pm = packageManager
                            val intent: Intent? =
                                pm.getLaunchIntentForPackage("com.tailscale.ipn")
                            if (intent == null) {
                                result.success(false)
                            } else {
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
