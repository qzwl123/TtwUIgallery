import QtQuick
import QtQuick.Templates 2.15 as T
import Ttw.UI

T.GroupBox {
    id: control

    // ==========================================
    // 0. 尺寸计算 (Templates 必须的骨架逻辑)
    // 保证组件能根据内部的 contentItem 自动撑开大小
    // ==========================================
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            implicitLabelWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    // ==========================================
    // 1. 边距控制 (Padding)
    // ==========================================
    padding: 16
    // 顶部边距：基础边距 + 标题高度的一半，确保内部的内容绝对不会顶到文字上
    topPadding: padding + (control.label ? control.label.height / 2 : 0)

    // ==========================================
    // 2. 标题标签 (Label) - 包含“橡皮擦”遮罩魔法
    // ==========================================
    label: Rectangle {
        // 让标题的左侧缩进与内容的 leftPadding 保持完美的垂直对齐
        x: control.leftPadding
        y: 0

        // 宽度比文字稍微宽一点，留出呼吸感
        width: titleText.implicitWidth + 12
        height: titleText.implicitHeight + 4

        // 【核心橡皮擦】：背景色必须与您整个页面的大背景色一致，用于切断边框线
        color: Theme.bgMain || "#FFFFFF"

        Text {
            id: titleText
            anchors.centerIn: parent
            text: control.title
            color: Theme.textPrimary || "#333333"
            font.pixelSize: 14
            font.bold: true
            renderType: Text.NativeRendering
        }
    }

    // ==========================================
    // 3. 边框背景 (Background) - 垂直下沉半个身位
    // ==========================================
    background: Rectangle {
        // 【核心对齐】：向下偏移标签高度的一半，让顶边框精准穿过文字的水平中轴线
        y: control.label ? control.label.height / 2 : 0
        width: control.width
        height: control.height - y

        color: "transparent" // 必须透明，否则会遮挡底层的页面或组件
        border.color: Theme.borderRest || "#EAEAEA"
        border.width: 1
        radius: Theme.radiusBase || 8
    }
}
