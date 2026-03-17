import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15 as Basic
import Ttw.UI

import  MygRPC

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
            onClicked: GrpcClient.onsayHello(1, "ttw")
             // console.log("Standard clicked")
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
    TextField {
        id:proto_data
       placeholderText: "请输入内容..."
       Layout.fillWidth: true
       Layout.maximumWidth: 400

    }


    // 放置在页面底部，占据剩余的所有空间
    DebugConsole {
        id: grpcLogConsole
        title: "gRPC 通信日志"
        Layout.fillWidth: true
        Layout.fillHeight: true // 自动撑满底部剩余空间
    }

    // ==========================================
    // 模拟测试：如何在操作时写入日志
    // ==========================================

    // 测试调用
    Button {
        text: "发送 gRPC"
        onClicked: {
            grpcLogConsole.appendLog("GrpcClient", "fetchGreeting", "TX", "发送数据: " +proto_data.text)
        }
    }

    // 假设我们监听了 C++ 的某个属性或信号来接收返回值
    Connections {
        target: GrpcClient

        function onLastMessageChanged() {
            // 3. 记录接收日志
            grpcLogConsole.appendLog("RX", "收到服务端响应: " + GrpcClient.lastMessage)
        }

        function onLastStatusTextChanged() {
            if (GrpcClient.lastStatusCode !== 0) {
                // 4. 记录错误日志
                grpcLogConsole.appendLog("ERR", "请求失败: " + GrpcClient.lastStatusText)
            }
        }
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
