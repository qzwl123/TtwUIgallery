import QtQuick
import QtQuick.Templates 2.15 as T
import QtQuick.Layouts
import Ttw.UI

T.Button {
    id: control

    implicitWidth: Math.max(120, contentLayout.implicitWidth + 24)
    implicitHeight: 32

    property bool isAccent: false
    property string iconSource: ""

    font: Theme.fontBody

    // --- 背景层 (保持不变) ---
    background: Rectangle {
        id: bgRect
        radius: Theme.radiusBase
        color: {
             if (!control.enabled) return control.isAccent ? Theme.accentFillDisabled : Theme.controlFillDisabled
             if (control.isAccent) {
                 if (control.down) return Theme.accentFillPress
                 if (control.hovered) return Theme.accentFillHover
                 return Theme.accentFillRest
             } else {
                 if (control.down) return Theme.controlFillPress
                 if (control.hovered) return Theme.controlFillHover
                 return Theme.controlFillRest
             }
        }
        Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: (!control.isAccent && !control.down && control.enabled) ? (control.hovered ? Theme.borderHover : Theme.borderRest) : "transparent"
            border.width: 1
            Behavior on border.color { ColorAnimation { duration: Theme.fastAnim } }
        }
    }

    // --- 内容层 (核心修改) ---
    contentItem: Item {
        // 【优化1】 包裹一个 Item，确保内容层填满整个按钮
        anchors.fill: parent

        RowLayout {
            id: contentLayout
            // 【优化2】 强制 Layout 位于父容器的正中心
            anchors.centerIn: parent
            spacing: 6 // Win11 的间距通常比较紧凑

            // 图标
            Text {
                visible: control.iconSource !== ""
                text: control.iconSource
                font.family: Theme.iconFontFamily
                font.pixelSize: 16
                color: control.isAccent ? Theme.textOnAccent : Theme.textPrimary
                opacity: control.enabled ? 1.0 : 0.6

                // 【优化3】 显式设置垂直对齐
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignVCenter

                // 让图标渲染更清晰 (Windows 专用)
                renderType: Text.NativeRendering
            }

            // 文字
            Text {
                text: control.text
                font: control.font
                color: control.isAccent ? Theme.textOnAccent : Theme.textPrimary
                opacity: control.enabled ? 1.0 : 0.6

                elide: Text.ElideRight

                // 【优化3】 显式设置垂直对齐 + 渲染模式
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignVCenter

                // 【关键技巧】NativeRendering 能让字体度量更符合 Windows 系统标准
                // 解决 Qt 默认渲染导致文字偏高的问题
                renderType: Text.NativeRendering

                // 如果您觉得 NativeRendering 还是偏高，可以打开下面这行微调
                // topPadding: 1
            }
        }
    }
}
