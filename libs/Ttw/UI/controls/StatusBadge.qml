import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Ttw.UI

/**
 * 状态徽章 (StatusBadge) 组件
 * 用于展示具有不同语义状态（如就绪、忙碌、离线、错误等）的胶囊状状态标签。
 * 支持根据全局主题 (Theme.mode) 自动适配深色/浅色模式。
 */
Control {
    id: control

    // ==========================================
    // 1. 公共属性 (Public API)
    // ==========================================

    // 徽章上显示的文本内容
    property string text: ""
    // 徽章的语义色调 (可选值: "ready" 默认, "busy", "offline", "reserved", "error")
    property string tone: "ready"

    // ==========================================
    // 2. 响应式颜色计算 (Reactive Colors)
    // readonly property 会自动根据 tone 和 Theme.mode 的变化重新计算
    // ==========================================

    // 背景填充色：采用不同基础色加上一定的透明度，以适配深/浅色模式
    readonly property color fillColor: {
        switch (tone) {
        case "busy":
            return Qt.rgba(0.98, 0.66, 0.14, Theme.mode === Theme.Mode.Light ? 0.18 : 0.24)
        case "offline":
            return Qt.rgba(0.77, 0.16, 0.16, Theme.mode === Theme.Mode.Light ? 0.16 : 0.24)
        case "reserved":
            return Qt.rgba(0.36, 0.36, 0.36, Theme.mode === Theme.Mode.Light ? 0.12 : 0.22)
        case "error":
            return Qt.rgba(0.77, 0.16, 0.16, Theme.mode === Theme.Mode.Light ? 0.20 : 0.28)
        default: // "ready" 或其他未定义状态，默认使用绿色
            return Qt.rgba(0.06, 0.55, 0.21, Theme.mode === Theme.Mode.Light ? 0.16 : 0.22)
        }
    }

    // 边框基础色：使用纯色来保证边框和内部指示器的高对比度
    readonly property color strokeColor: {
        switch (tone) {
        case "busy":      return "#F5A524" // 橙色
        case "offline":   return "#C42B1C" // 红色
        case "reserved":  return Theme.textSecondary // 跟随主题的次级文本色
        case "error":     return "#C42B1C" // 红色
        default:          return "#107C10" // 绿色
        }
    }

    // 前景色：用于文本和状态圆点
    readonly property color foregroundColor: {
        switch (tone) {
        case "reserved":
            return Theme.textSecondary // 保留状态下使用较暗的文本色
        default:
            return strokeColor         // 其他状态与边框基础色保持一致
        }
    }

    // ==========================================
    // 3. 尺寸与边距 (Metrics & Sizing)
    // ==========================================

    // 设置内部内容的内边距
    leftPadding: 12
    rightPadding: 12
    topPadding: 7
    bottomPadding: 7

    // 隐式宽高 (推荐做法)：根据内部内容 (badgeContent) 的大小加上 padding 自动撑开
    implicitWidth: badgeContent.implicitWidth + leftPadding + rightPadding
    // 保证最小高度为 28，防止文本过小时徽章显得太扁
    implicitHeight: Math.max(28, badgeContent.implicitHeight + topPadding + bottomPadding)

    // ==========================================
    // 4. 背景渲染 (Background)
    // ==========================================
    background: Rectangle {
        // 高度的一半，形成完美的“胶囊”形状 (Pill shape)
        radius: height / 2
        color: control.fillColor
        border.width: 1
        // 边框颜色复用 strokeColor，但加上 28% 的不透明度，使视觉更柔和
        border.color: Qt.rgba(control.strokeColor.r, control.strokeColor.g, control.strokeColor.b, 0.28)
    }

    // ==========================================
    // 5. 内部内容渲染 (Content Item)
    // ==========================================
    contentItem: RowLayout {
        id: badgeContent
        spacing: 8 // 圆点和文字之间的间距

        // 左侧的小圆点指示器
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 6
            implicitHeight: 6
            radius: 3 // 宽高为 6，radius 为 3 就是一个正圆
            color: control.foregroundColor
        }

        // 右侧的文本
        Text {
            text: control.text
            color: control.foregroundColor
            font.pixelSize: 12
            font.bold: true
            // 启用原生渲染，提高小字号在非高分屏下的文字清晰度 (非常关键的细节)
            renderType: Text.NativeRendering
        }
    }
}
