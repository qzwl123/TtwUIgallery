import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15 as Basic
import Ttw.UI

// 这是一个内容页面
ColumnLayout {
    spacing: 20

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
        onCheckedChanged: Theme.mode = checked ? Theme.Mode.Dark : Theme.Mode.Light
    }

    // 弹簧，把内容顶上去
    Item { Layout.fillHeight: true }
}
