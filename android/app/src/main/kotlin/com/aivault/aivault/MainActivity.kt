package com.aivault.aivault

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 小组件后台自动刷新：App 打开时确保 30 分钟周期任务在册
        WidgetAutoRefresh.ensurePeriodic(applicationContext)
    }
}
