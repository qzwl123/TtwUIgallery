pragma Singleton
import QtQuick

QtObject {
    id: theme

    // ====================
    // 1. 核心配置
    // ====================
    enum Mode { Light, Dark }
    property int mode: Theme.Mode.Light

    // 动画速度
    property int fastAnim: 83
    property int mediumAnim: 167

    // 圆角
    property int radiusBase: 4

    // ====================
    // 2. 字体加载 (Ubuntu/跨平台关键)
    // ====================
    property FontLoader iconFontLoader: FontLoader {
        // 确保 CMake 里已经把 fonts/FluentIcons.ttf 加到了 RESOURCES
        source: "qrc:/qt/qml/Ttw/UI/fonts/FluentIcons.ttf"
    }

    // 获取加载后的真实字体名称
    property string iconFontFamily: iconFontLoader.name
    property font fontBody: Qt.font({ family: "Segoe UI Variable Text", pixelSize: 14 })
    property font fontTitle: Qt.font({ family: "Segoe UI Variable Display", pixelSize: 20, weight: Font.DemiBold })

    // ====================
    // 3. 辅助函数
    // ====================
    function c(lightColor, darkColor) {
        return mode === Theme.Mode.Light ? lightColor : darkColor
    }

    // ====================
    // 4. 色彩系统
    // ====================
    property color accentMain: "#0067C0"
    property color accentLight: Qt.lighter(accentMain, 1.1)
    property color accentDark: Qt.darker(accentMain, 1.1)
    property color textOnAccent: "#FFFFFF"

    property color bgMain: c("#F3F3F3", "#202020")
    property color controlSolid: c("#FFFFFF", "#1E1E1E")

    // 控件填充色
    property color controlFillRest:   c("transparent",  Qt.rgba(1,1,1,0.06))
    property color controlFillHover:  c(Qt.rgba(0,0,0,0.04), Qt.rgba(1,1,1,0.09))
    property color controlFillPress:  c(Qt.rgba(0,0,0,0.07), Qt.rgba(1,1,1,0.12))
    property color controlFillDisabled: c(Qt.rgba(0,0,0,0.04), Qt.rgba(1,1,1,0.04))

    // 强调填充色
    property color accentFillRest:    accentMain
    property color accentFillHover:   accentLight
    property color accentFillPress:   accentDark
    property color accentFillDisabled: Qt.rgba(accentMain.r, accentMain.g, accentMain.b, 0.4)

    // 边框色
    property color borderRest:   c(Qt.rgba(0,0,0,0.15), Qt.rgba(1,1,1,0.15))
    property color borderHover:  c(Qt.rgba(0,0,0,0.25), Qt.rgba(1,1,1,0.25))

    // 文本色
    property color textPrimary:   c("#1A1A1A", "#FFFFFF")
    property color textSecondary: c(Qt.rgba(0,0,0,0.6), Qt.rgba(1,1,1,0.8))
    property color textDisabled:  c(Qt.rgba(0,0,0,0.36), Qt.rgba(1,1,1,0.36))

    // ====================
    // 5. 初始化日志 (合并到这一个块里)
    // ====================
    Component.onCompleted: {
        // 打印主题状态
        console.log("✅ Theme Singleton Loaded. Mode:", mode === Theme.Mode.Light ? "Light" : "Dark")

        // 打印字体状态
        console.log("✅ Icon Font Status:", iconFontLoader.status === FontLoader.Ready ? "Ready" : "Loading/Error")
        console.log("✅ Icon Font Name:", iconFontLoader.name)

        if (iconFontLoader.status === FontLoader.Error) {
            console.error("❌ 字体加载失败，请检查 CMake 的 RESOURCES 和文件路径！")
        }
    }
}
