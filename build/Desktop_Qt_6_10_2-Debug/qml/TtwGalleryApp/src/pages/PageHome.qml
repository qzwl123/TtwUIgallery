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



    FoldingLineChart {
        Layout.fillWidth: true
        Layout.preferredHeight: 350

        title: "多系统资源占用对比"
        // xLabels: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]

        // 注入多条数据源！
        series: [
            {
                name: "CPU负载",
                color: "#005FB8", // WinUI 蓝
                data: [20, 45, 88, 55, 30, 10, 5]
            },
            {
                name: "内存使用率",
                color: "#107C10", // Xbox 绿
                data: [40, 42, 45, 60, 65, 50, 48]
            },
            {
                name: "磁盘 I/O",
                color: "#E81123", // 警告红
                data: [5, 10, 15, 8, 12, 5, 2]
            }
        ]

        showFill: true  // 开启填充（多线叠在一起会形成漂亮的半透明混合效果）
        showLine: true  // 开启 带线
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
