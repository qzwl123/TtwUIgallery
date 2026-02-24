import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Ttw.UI

Rectangle {
    id: root

    // 暴露给外部的属性
    property string title: ""
    property Window targetWindow: Window.window

    // Win11 标准标题栏高度一般为 32
    implicitHeight: 32
    color: "transparent" // 融入底层背景

    // ==========================================
    // 1. 跨平台窗口控制逻辑
    // ==========================================
    // 双击标题栏最大化/还原
    TapHandler {
        onTapped: if (tapCount === 2) toggleMaximized()
        gesturePolicy: TapHandler.DragThreshold
    }

    // 拖拽标题栏移动窗口 (Ubuntu 和 Windows 通用)
    DragHandler {
        onActiveChanged: if (active) targetWindow.startSystemMove()
    }

    // ==========================================
    // 2. UI 布局
    // ==========================================
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // 左侧留白或放置 App Logo (可选)
        // Item { Layout.preferredWidth: 16 }

        // 标题文本
        Text {
            Layout.leftMargin: 16
            Layout.fillWidth: true
            text: root.title
            font: Theme.fontBody
            color: Theme.textSecondary // 标题栏文字通常偏弱一点，不抢正文风头
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }

        // ==========================================
        // 3. 窗口控制按钮 (三大金刚键)
        // WinUI 规范：宽度 46px，高度占满
        // ==========================================

        // --- 最小化按钮 ---
        Rectangle {
            Layout.preferredWidth: 46
            Layout.fillHeight: true
            color: tapMin.pressed ? Theme.controlFillPress : (hoverMin.hovered ? Theme.controlFillHover : "transparent")
            Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

            Text {
                anchors.centerIn: parent
                text: Icons.remove // 借用你 Icons.qml 里的减号
                font.family: Theme.iconFontFamily
                font.pixelSize: 12
                color: Theme.textPrimary
                renderType: Text.NativeRendering
            }
            HoverHandler { id: hoverMin }
            TapHandler { id: tapMin; onTapped: targetWindow.showMinimized() }
        }

        // --- 最大化/还原按钮 ---
        Rectangle {
            Layout.preferredWidth: 46
            Layout.fillHeight: true
            color: tapMax.pressed ? Theme.controlFillPress : (hoverMax.hovered ? Theme.controlFillHover : "transparent")
            Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

            Text {
                anchors.centerIn: parent
                // \uE922 是 Fluent Icons 的最大化方块，\uE923 是还原的双层方块
                text: targetWindow.visibility === Window.Maximized ? Icons.windowRestore : Icons.windowMaximize
                font.family: Theme.iconFontFamily
                font.pixelSize: 12
                color: Theme.textPrimary
                renderType: Text.NativeRendering
            }
            HoverHandler { id: hoverMax }
            TapHandler { id: tapMax; onTapped: toggleMaximized() }
        }

        // --- 关闭按钮 (WinUI 专属逻辑：红底白字) ---
        Rectangle {
            Layout.preferredWidth: 46
            Layout.fillHeight: true
            // 覆盖默认主题，强制使用危险色
            color: tapClose.pressed ? "#F0605C" : (hoverClose.hovered ? "#E81123" : "transparent")
            Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

            Text {
                anchors.centerIn: parent
                text: Icons.cancel // 使用你 Icons.qml 里的 X
                font.family: Theme.iconFontFamily
                font.pixelSize: 12
                // 悬浮时强制变为纯白色，否则跟随主题色
                color: hoverClose.hovered ? "#FFFFFF" : Theme.textPrimary
                renderType: Text.NativeRendering
            }
            HoverHandler { id: hoverClose }
            TapHandler { id: tapClose; onTapped: targetWindow.close() }
        }
    }

    // 辅助函数：切换最大化状态
    function toggleMaximized() {
        if (targetWindow.visibility === Window.Maximized) {
            targetWindow.showNormal()
        } else {
            targetWindow.showMaximized()
        }
    }
}
