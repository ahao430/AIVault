package com.aivault.aivault

/**
 * HyperOS（小米澎湃 OS / MIUI）专用小组件变体。
 *
 * 与通用版的差异集中在布局层（R.layout.aivault_widget_hyperos）：
 * - MIUI/HyperOS 桌面会按系统圆角对组件整体裁切，自绘大圆角会在四角
 *   露出底色（双重圆角问题），故自绘背景改为小圆角 + 满幅深色底；
 * - 字号整体 +1sp、行距加大，匹配 HyperOS 卡片的排版密度；
 * - 品牌蓝紫改为 HyperOS 常用的强调色对比度更高的配色。
 *
 * 数据与刷新链路完全复用 AIVaultWidgetProvider（同一套 HomeWidgetPreferences
 * 键值、同一个 WorkManager 后台拉取），在组件选择器里作为
 * 「AIVault 看板 · HyperOS」出现，由用户按设备选择。
 */
class HyperOsWidgetProvider : AIVaultWidgetProvider() {
    override val layoutRes: Int = R.layout.aivault_widget_hyperos
}
