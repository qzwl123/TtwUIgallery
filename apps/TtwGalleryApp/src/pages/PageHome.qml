import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15 as Basic
import Ttw.UI

// 这是一个内容页面
ColumnLayout {
    spacing: 20

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 92
        radius: Theme.radiusLarge
        color: Theme.controlSolid
        border.width: 1
        border.color: Theme.borderRest

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "WinUI 3 Gallery"
                    font: Theme.fontTitle
                    color: Theme.textPrimary
                }

                Text {
                    text: "基于 Qt 6 + QML 的 Fluent 风格控件示例"
                    font: Theme.fontBody
                    color: Theme.textSecondary
                }
            }

            Button {
                text: "主题切换"
                isAccent: true
                iconSource: Icons.edit
                onClicked: Theme.mode = Theme.mode === Theme.Mode.Light ? Theme.Mode.Dark : Theme.Mode.Light
            }
        }
    }

    Text {
        text: "基础控件展示"
        font: Theme.fontTitle
        color: Theme.textPrimary
    }

    // --- 按钮展示区 ---
    RowLayout {
        spacing: 10
        Button {
            text: "Standard Button"
            onClicked: console.log("Standard clicked")
        }

        Button {
            text: "Send Email"
            isAccent: true
            iconSource: Icons.send
        }

        Button {
            text: "Disabled"
            enabled: false
            iconSource: Icons.settings
        }
    }

    // --- 输入框展示区 ---
    TextBox {
       placeholderText: "请输入内容..."
       Layout.fillWidth: true
       Layout.maximumWidth: 400
    }

    // --- 主题切换 ---
    Basic.Switch {
        text: "深色模式 (Dark Mode)"
        palette.windowText: Theme.textPrimary
        checked: Theme.mode === Theme.Mode.Dark
        onCheckedChanged: Theme.mode = checked ? Theme.Mode.Dark : Theme.Mode.Light
    }

    // 弹簧，把内容顶上去
    Item { Layout.fillHeight: true }
}
