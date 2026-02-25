import QtQuick
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as Basic // 用来借用默认的右键菜单逻辑(可选)
import Ttw.UI

T.TextField {
    id: control

    // --- 尺寸与基础配置 ---
    implicitWidth: 50
    implicitHeight: 32 // Win11 标准高度

    // 字体配置
    font: Theme.fontBody
    color: enabled ? Theme.textPrimary : Theme.textDisabled

    // 选中后的背景色 (Win11 默认是品牌色)
    selectionColor: Theme.accentMain
    selectedTextColor: Theme.textOnAccent

    // 占位符颜色
    placeholderTextColor: Theme.textSecondary

    // 文本对齐方式
    verticalAlignment: TextInput.AlignVCenter
    leftPadding: 10
    rightPadding: 10

    // 允许鼠标选中
    selectByMouse: true

    // --- 背景层 (核心视觉) ---
    background: Rectangle {
            id: bgRect
            radius: Theme.radiusBase

            // 1. 背景色逻辑
            color: {
                if (!control.enabled) return Theme.controlFillDisabled
                if (control.activeFocus) return Theme.controlSolid // 聚焦纯白
                if (control.hovered) return Theme.controlFillHover
                return Theme.controlFillRest
            }

            // 【核心修复 A】 只有在“非聚焦”状态下才启用动画
            // 效果：
            // 点击聚焦 -> activeFocus 为真 -> enabled 为假 -> 动画关闭 -> 瞬间变白 (干脆！)
            // 失去焦点 -> activeFocus 为假 -> enabled 为真 -> 动画开启 -> 慢慢变灰 (优雅！)
            // Behavior on color {
            //     enabled: !control.activeFocus
            //     ColorAnimation { duration: Theme.fastAnim }
            // }

            // 2. 边框逻辑
            border.width: 1
            border.color: {
                if (!control.enabled) return "transparent"
                if (control.activeFocus) return Theme.controlSolid // 聚焦时边框也变白(隐藏)
                if (control.hovered) return Theme.borderHover
                return Theme.borderRest
            }

            // 【核心修复 B】 边框颜色动画同理，聚焦瞬间同步变白，防止边框滞后
            // Behavior on border.color {
            //     enabled: !control.activeFocus
            //     ColorAnimation { duration: Theme.fastAnim }
            // }

            // 3. 底部高亮条
            Rectangle {
                id: bottomLine
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                // 底部条的高度动画可以保留，看起来像“长出来”的，很生动
                height: control.activeFocus ? 2 : 1
                radius: parent.radius

                color: {
                    if (!control.enabled) return "transparent"
                    if (control.activeFocus) return Theme.accentMain
                    return Theme.borderRest
                }

                Behavior on height { NumberAnimation { duration: Theme.fastAnim } }
                Behavior on color  { ColorAnimation { duration: Theme.fastAnim } }
            }
        }

}
