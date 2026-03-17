import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Ttw.UI
import MygRPC

Item {
    id: root
    anchors.fill: parent

    function rpcTone() {
          if (GrpcClient.busy)
              return "busy"
          if (!GrpcClient.channelReady)
              return "offline" //
          return GrpcClient.lastStatusCode === 0 ? "ready" : "error"
    }

    function rpcLabel() {
        if (GrpcClient.busy)
            return "Request Running"
        if (!GrpcClient.channelReady)
            return "Channel Offline"
        return GrpcClient.lastStatusCode === 0 ? "Ready" : "Reply Error"
    }



    // 页面主滚动视图（防止屏幕太小显示不全）
    ScrollView {
        anchors.fill: parent
        anchors.margins: 30
        clip: true
        contentWidth: availableWidth

        ColumnLayout {    
            width: parent.width
            spacing: 24

            Text {
                text: "gRPC Workbench"
                font.pixelSize: 28
                font.bold: true
                color: Theme.textPrimary
                Layout.fillWidth: true
            }

            Text {
                text: "gRPC Client Request/Response 一元、服务器流、客户端流、双向流，GrpcTool工具类的使用！ "
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }



            SurfaceCard {
                Layout.fillWidth: true
                // highlighted: true
                accentBarVisible: true

                Column {
                    spacing: 8
                    width: parent.width

                    Label {
                        text: "使用 GrpcTool 工具类的流程"
                        font.pixelSize: 18
                        font.bold: true
                        // 核心修改：让该组件在其父级 (Column) 中水平居中
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        text: "这是一个最简单的卡片示例，没有强调条，也没有特殊的高亮状态。适合用来展示常规信息。"
                        wrapMode: Text.WordWrap
                        padding: 30
                        width: parent.width
                        color: "#666666"
                    }
                }

            }

            RowLayout {
                // Layout.fillWidth: true
                spacing: 12
                Layout.alignment: Qt.AlignCenter

                StatusBadge {
                     text: GrpcClient.endpoint
                     tone: "reserved"
                }

                StatusBadge {
                      text: root.rpcLabel()
                      tone: root.rpcTone()
                }

            }

            GroupBox {
                id: rpc_unaryCall
                title: "gRPC 一元"
                Layout.fillWidth: true

                GridLayout {
                    width: parent.width
                    columns: 5
                    rowSpacing: 5
                    columnSpacing: 12

                    Button {
                        text: "onsayHello"
                        onClicked: GrpcClient.onsayHello(proto_Unary_id.text, proto_Unary_data.text)
                         // console.log("Standard clicked")
                    }

                    Label { text: "id:"; Layout.alignment: Qt.AlignRight }
                    TextField { id:proto_Unary_id; placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Label { text: "data:"; Layout.alignment: Qt.AlignRight }
                    TextField { id:proto_Unary_data; placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Expander {
                        Layout.topMargin: 20
                        Layout.fillWidth: true
                        // 让按钮横跨两列并居中（如果你想让它在右边，可以改用 Qt.AlignRight）
                        Layout.columnSpan: 5
                        Layout.alignment: Qt.AlignHCenter
                        title: "一元 RPC Source"
                        iconText: "</>"
                        isExpanded: false
                        codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcSnippet.txt")
                    }
                }
            }


            GroupBox {
                id: rpc_serverStreaming
                title: "gRPC 服务器流"
                Layout.fillWidth: true

                GridLayout {
                    width: parent.width
                    columns: 5
                    rowSpacing: 5
                    columnSpacing: 12

                    Button {
                        text: "Standard Button"
                        onClicked: GrpcClient.onsayHello(proto_id.text, proto_data.text)
                         // console.log("Standard clicked")
                    }

                    Label { text: "id:"; Layout.alignment: Qt.AlignRight }
                    TextField {  placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Label { text: "data:"; Layout.alignment: Qt.AlignRight }
                    TextField { placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Expander {
                        Layout.topMargin: 20
                        Layout.fillWidth: true
                        // 让按钮横跨两列并居中（如果你想让它在右边，可以改用 Qt.AlignRight）
                        Layout.columnSpan: 5
                        Layout.alignment: Qt.AlignHCenter
                        title: "一元 RPC Source"
                        iconText: "</>"
                        isExpanded: false
                        codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcSnippet.txt")
                    }
                }
            }

            GroupBox {
                id: rpc_clientStreaming
                title: "gRPC 客户端流"
                Layout.fillWidth: true

                GridLayout {
                    width: parent.width
                    columns: 5
                    rowSpacing: 5
                    columnSpacing: 12

                    Button {
                        text: "Standard Button"
                        onClicked: GrpcClient.onsayHello(proto_id.text, proto_data.text)
                         // console.log("Standard clicked")
                    }

                    Label { text: "id:"; Layout.alignment: Qt.AlignRight }
                    TextField {  placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Label { text: "data:"; Layout.alignment: Qt.AlignRight }
                    TextField { placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Expander {
                        Layout.topMargin: 20
                        Layout.fillWidth: true
                        // 让按钮横跨两列并居中（如果你想让它在右边，可以改用 Qt.AlignRight）
                        Layout.columnSpan: 5
                        Layout.alignment: Qt.AlignHCenter
                        title: "一元 RPC Source"
                        iconText: "</>"
                        isExpanded: false
                        codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcSnippet.txt")
                    }
                }
            }

            GroupBox {
                id: rpc_bidirectionalStreaming
                title: "gRPC 服务器流"
                Layout.fillWidth: true

                GridLayout {
                    width: parent.width
                    columns: 5
                    rowSpacing: 5
                    columnSpacing: 12

                    Button {
                        text: "Standard Button"
                        onClicked: GrpcClient.onsayHello(proto_id.text, proto_data.text)
                         // console.log("Standard clicked")
                    }

                    Label { text: "id:"; Layout.alignment: Qt.AlignRight }
                    TextField {  placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Label { text: "data:"; Layout.alignment: Qt.AlignRight }
                    TextField { placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Expander {
                        Layout.topMargin: 20
                        Layout.fillWidth: true
                        // 让按钮横跨两列并居中（如果你想让它在右边，可以改用 Qt.AlignRight）
                        Layout.columnSpan: 5
                        Layout.alignment: Qt.AlignHCenter
                        title: "一元 RPC Source"
                        iconText: "</>"
                        isExpanded: false
                        codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcSnippet.txt")
                    }
                }
            }


            DebugConsole {
                id: grpcLogConsole
                title: "gRPC 通信日志"
                Layout.fillWidth: true
                Layout.fillHeight: true // 自动撑满底部剩余空间
            }

            // // ==========================================
            // // 模拟测试：如何在操作时写入日志
            // // ==========================================
            // Button {
            //     text: "发送请求"
            //     onClicked: {
            //         // 1. 记录发送日志
            //         grpcLogConsole.appendLog("TX", "发送数据给服务端: " + proto_data.text)

            //         // 2. 假设这里调用 C++
            //         GrpcClient.fetchGreeting(proto_data.text)
            //     }
            // }

            // // 假设我们监听了 C++ 的某个属性或信号来接收返回值
            // Connections {
            //     target: GrpcClient

            //     function onLastMessageChanged() {
            //         // 3. 记录接收日志
            //         grpcLogConsole.appendLog("RX", "收到服务端响应: " + GrpcClient.lastMessage)
            //     }

            //     function onLastStatusTextChanged() {
            //         if (GrpcClient.lastStatusCode !== 0) {
            //             // 4. 记录错误日志
            //             grpcLogConsole.appendLog("ERR", "请求失败: " + GrpcClient.lastStatusText)
            //         }
            //     }
            // }


            Item { Layout.fillHeight: true }
        }



    }
}
