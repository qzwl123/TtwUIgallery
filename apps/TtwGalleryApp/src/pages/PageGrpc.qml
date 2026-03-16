import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Ttw.UI
import MygRPC 1.0

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
                id: control
                title: "gRPC 一元"
                Layout.fillWidth: true

                GridLayout {
                    width: parent.width
                    columns: 2
                    rowSpacing: 16
                    columnSpacing: 12

                    Label { text: "服务端点:"; Layout.alignment: Qt.AlignRight }
                    TextField { text: GrpcClient.endpoint; enabled: false; Layout.fillWidth: true }

                    Label { text: "请求参数:"; Layout.alignment: Qt.AlignRight }
                    TextField { placeholderText: "输入内容..."; Layout.fillWidth: true }

                    Button {
                        text: "Standard Button"
                        onClicked: GrpcClient.onsayHello(1, "ttw")
                         // console.log("Standard clicked")
                    }

                    Expander {
                        Layout.fillWidth: true
                        title: "View PageGrpc Source"
                        iconText: "</>"
                        isExpanded: false
                        codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcSnippet.txt")
                    }
                }

            }



            Expander {
                Layout.fillWidth: true
                title: "Mode Notes"
                iconText: "i"
                isExpanded: false
                codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcUsage.txt")
            }

            Item { Layout.fillHeight: true }
        }
    }
}
