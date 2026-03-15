import QtQuick
import QtQuick.Controls 2.15 as Basic
import QtQuick.Layouts

import Ttw.UI
import MygRPC 1.0

Item {
    id: root
    anchors.fill: parent
    property string expandedMode: "unary"

    function normalizedId() {
        const parsed = parseInt(idField.text, 10)
        return isNaN(parsed) ? 1 : parsed
    }

    function toggleMode(modeName) {
        expandedMode = expandedMode === modeName ? "" : modeName
    }

    function rpcTone() {
        if (GrpcClient.busy)
            return "busy"
        if (!GrpcClient.channelReady)
            return "offline"
        return GrpcClient.lastStatusCode === 0 ? "ready" : "error"
    }

    function rpcLabel() {
        if (GrpcClient.busy)
            return "Request Running"
        if (!GrpcClient.channelReady)
            return "Channel Offline"
        return GrpcClient.lastStatusCode === 0 ? "Ready" : "Reply Error"
    }

    function useSample() {
        idField.text = "1001"
        dataField.text = "hello from PageGrpc"
    }

    // Use the aliased Qt Quick Controls type to avoid collisions with TtwUI controls.
    Basic.ScrollView {
        anchors.fill: parent
        anchors.margins: 28
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20

            Text {
                text: "gRPC Workbench"
                font.pixelSize: 28
                font.bold: true
                color: Theme.textPrimary
                Layout.fillWidth: true
            }

            Text {
                text: "This page keeps unary sayHello active today and reserves full WinUI-style scaffolding for server, client, and bidirectional streaming."
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            SurfaceCard {
                Layout.fillWidth: true
                accentBarVisible: true
                highlighted: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Channel Overview"
                                color: Theme.textPrimary
                                font.pixelSize: 18
                                font.bold: true
                            }

                            Text {
                                text: "Use the unary panel for live verification. The three stream panels below are reserved and intentionally disabled."
                                color: Theme.textSecondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }

                        StatusBadge {
                            text: root.rpcLabel()
                            tone: root.rpcTone()
                        }

                        StatusBadge {
                            text: "3 Reserved Modes"
                            tone: "reserved"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "Endpoint"
                            color: Theme.textSecondary
                            font: Theme.fontBody
                        }

                        Text {
                            text: GrpcClient.endpoint
                            color: Theme.textPrimary
                            font.family: "Consolas"
                            font.pixelSize: 13
                            Layout.fillWidth: true
                            elide: Text.ElideMiddle
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        StatusBadge {
                            text: GrpcClient.channelReady ? "Channel Ready" : "Channel Missing"
                            tone: GrpcClient.channelReady ? "ready" : "offline"
                        }

                        StatusBadge {
                            text: GrpcClient.busy ? "Busy" : "Idle"
                            tone: GrpcClient.busy ? "busy" : "ready"
                        }

                        StatusBadge {
                            text: "sayHello Enabled"
                            tone: "ready"
                        }
                    }
                }
            }

            Expander {
                Layout.fillWidth: true
                title: "Unary Call - sayHello"
                iconText: "1"
                autoToggle: false
                isExpanded: root.expandedMode === "unary"
                onHeaderClicked: root.toggleMode("unary")

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    GridLayout {
                        Layout.fillWidth: true
                        columns: width > 920 ? 2 : 1
                        columnSpacing: 16
                        rowSpacing: 16

                        SurfaceCard {
                            Layout.fillWidth: true

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 14

                                Text {
                                    text: "Request Composer"
                                    color: Theme.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                }

                                Text {
                                    text: "Send one sayHello request and keep the latest payload visible on the page."
                                    color: Theme.textSecondary
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: width > 520 ? 2 : 1
                                    columnSpacing: 12
                                    rowSpacing: 12

                                    ColumnLayout {
                                        spacing: 6
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Request ID"
                                            color: Theme.textSecondary
                                        }

                                        TextBox {
                                            id: idField
                                            text: "1"
                                            placeholderText: "Enter an integer id"
                                            validator: IntValidator { bottom: 0 }
                                            Layout.fillWidth: true
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 6
                                        Layout.fillWidth: true

                                        Text {
                                            text: "Payload"
                                            color: Theme.textSecondary
                                        }

                                        TextBox {
                                            id: dataField
                                            text: "ttw"
                                            placeholderText: "Enter request payload"
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Button {
                                        text: GrpcClient.busy ? "Sending..." : "Send sayHello"
                                        isAccent: true
                                        enabled: GrpcClient.channelReady && !GrpcClient.busy
                                        onClicked: GrpcClient.onsayHello(root.normalizedId(), dataField.text)
                                    }

                                    Button {
                                        text: "Use Sample"
                                        enabled: !GrpcClient.busy
                                        onClicked: root.useSample()
                                    }

                                    Button {
                                        text: "Clear"
                                        enabled: !GrpcClient.busy
                                        onClicked: {
                                            root.useSample()
                                            GrpcClient.clearState()
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    // Keep the stock busy control aliased so the page stays type-safe.
                                    Basic.BusyIndicator {
                                        running: GrpcClient.busy
                                        visible: running
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }

                                Text {
                                    text: GrpcClient.channelReady
                                          ? "Unary mode is ready to call the shared Core gRPC helper."
                                          : "The channel is unavailable. Check the server endpoint before retrying."
                                    color: Theme.textSecondary
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        SurfaceCard {
                            Layout.fillWidth: true

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 14

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: "Latest Result"
                                        color: Theme.textPrimary
                                        font.pixelSize: 18
                                        font.bold: true
                                        Layout.fillWidth: true
                                    }

                                    StatusBadge {
                                        text: root.rpcLabel()
                                        tone: root.rpcTone()
                                    }
                                }

                                SurfaceCard {
                                    Layout.fillWidth: true
                                    padding: 16
                                    surfaceColor: Theme.controlFillHover

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 12

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 4

                                                Text {
                                                    text: "Status"
                                                    color: Theme.textSecondary
                                                }

                                                Text {
                                                    text: GrpcClient.lastStatusText
                                                    color: Theme.textPrimary
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                }
                                            }

                                            StatusBadge {
                                                text: "Code " + GrpcClient.lastStatusCode
                                                tone: root.rpcTone()
                                            }
                                        }

                                        SurfaceCard {
                                            Layout.fillWidth: true
                                            padding: 14
                                            surfaceColor: Theme.bgMain

                                            Text {
                                                anchors.fill: parent
                                                text: GrpcClient.lastMessage.length > 0
                                                      ? GrpcClient.lastMessage
                                                      : "No response body yet."
                                                color: GrpcClient.lastMessage.length > 0
                                                       ? Theme.textPrimary
                                                       : Theme.textSecondary
                                                wrapMode: Text.WordWrap
                                                verticalAlignment: Text.AlignTop
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "The response panel always reflects the latest unary reply and final gRPC status."
                                    color: Theme.textSecondary
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            Expander {
                Layout.fillWidth: true
                title: "Server Streaming - ListFeatures"
                iconText: "S"
                autoToggle: false
                isExpanded: root.expandedMode === "server"
                onHeaderClicked: root.toggleMode("server")

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    SurfaceCard {
                        Layout.fillWidth: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "Reserved Server Stream Workbench"
                                    color: Theme.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                StatusBadge {
                                    text: "Reserved"
                                    tone: "reserved"
                                }
                            }

                            Text {
                                text: "This section is intentionally scaffold-only. Future wiring can stream ListFeatures events into the result panel below."
                                color: Theme.textSecondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: width > 520 ? 2 : 1
                                columnSpacing: 12
                                rowSpacing: 12
                                opacity: 0.75

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "Request ID"
                                        color: Theme.textSecondary
                                    }

                                    TextBox {
                                        text: "42"
                                        enabled: false
                                        Layout.fillWidth: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "Watch Filter"
                                        color: Theme.textSecondary
                                    }

                                    TextBox {
                                        text: "recent-features"
                                        enabled: false
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                opacity: 0.75

                                Button {
                                    text: "Start Stream"
                                    isAccent: true
                                    enabled: false
                                }

                                Button {
                                    text: "Stop Stream"
                                    enabled: false
                                }
                            }

                            SurfaceCard {
                                Layout.fillWidth: true
                                padding: 16
                                surfaceColor: Theme.controlFillHover

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 8

                                    Text {
                                        text: "Incoming Messages"
                                        color: Theme.textSecondary
                                    }

                                    Text {
                                        text: "Reserved placeholder for server-pushed records, item counters, and end-of-stream status."
                                        color: Theme.textPrimary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Expander {
                Layout.fillWidth: true
                title: "Client Streaming - RecordRoute"
                iconText: "C"
                autoToggle: false
                isExpanded: root.expandedMode === "client"
                onHeaderClicked: root.toggleMode("client")

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    SurfaceCard {
                        Layout.fillWidth: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "Reserved Client Stream Workbench"
                                    color: Theme.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                StatusBadge {
                                    text: "Reserved"
                                    tone: "reserved"
                                }
                            }

                            Text {
                                text: "This future panel is prepared for queued outbound messages, commit controls, and a final aggregated response."
                                color: Theme.textSecondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: width > 520 ? 2 : 1
                                columnSpacing: 12
                                rowSpacing: 12
                                opacity: 0.75

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "Batch Name"
                                        color: Theme.textSecondary
                                    }

                                    TextBox {
                                        text: "weekday-route"
                                        enabled: false
                                        Layout.fillWidth: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "Queued Payload"
                                        color: Theme.textSecondary
                                    }

                                    TextBox {
                                        text: "point-001"
                                        enabled: false
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                opacity: 0.75

                                Button {
                                    text: "Queue Item"
                                    enabled: false
                                }

                                Button {
                                    text: "Commit Stream"
                                    isAccent: true
                                    enabled: false
                                }

                                Button {
                                    text: "Reset Queue"
                                    enabled: false
                                }
                            }

                            SurfaceCard {
                                Layout.fillWidth: true
                                padding: 16
                                surfaceColor: Theme.controlFillHover

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 8

                                    Text {
                                        text: "Queued Outbound Messages"
                                        color: Theme.textSecondary
                                    }

                                    Text {
                                        text: "Reserved placeholder for buffered client messages, upload progress, and the final response summary."
                                        color: Theme.textPrimary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Expander {
                Layout.fillWidth: true
                title: "Bidirectional Streaming - RouteChat"
                iconText: "B"
                autoToggle: false
                isExpanded: root.expandedMode === "bidi"
                onHeaderClicked: root.toggleMode("bidi")

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    SurfaceCard {
                        Layout.fillWidth: true

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: "Reserved Bidirectional Stream Workbench"
                                    color: Theme.textPrimary
                                    font.pixelSize: 18
                                    font.bold: true
                                    Layout.fillWidth: true
                                }

                                StatusBadge {
                                    text: "Reserved"
                                    tone: "reserved"
                                }
                            }

                            Text {
                                text: "Future wiring can attach a persistent session here, stream outbound chat messages, and render inbound updates live."
                                color: Theme.textSecondary
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                columns: width > 520 ? 2 : 1
                                columnSpacing: 12
                                rowSpacing: 12
                                opacity: 0.75

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "Channel Name"
                                        color: Theme.textSecondary
                                    }

                                    TextBox {
                                        text: "route-room-alpha"
                                        enabled: false
                                        Layout.fillWidth: true
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Text {
                                        text: "Outbound Message"
                                        color: Theme.textSecondary
                                    }

                                    TextBox {
                                        text: "hello from bidirectional mode"
                                        enabled: false
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                opacity: 0.75

                                Button {
                                    text: "Connect"
                                    isAccent: true
                                    enabled: false
                                }

                                Button {
                                    text: "Send Message"
                                    enabled: false
                                }

                                Button {
                                    text: "Close Session"
                                    enabled: false
                                }
                            }

                            SurfaceCard {
                                Layout.fillWidth: true
                                padding: 16
                                surfaceColor: Theme.controlFillHover

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 8

                                    Text {
                                        text: "Conversation Timeline"
                                        color: Theme.textSecondary
                                    }

                                    Text {
                                        text: "Reserved placeholder for alternating inbound and outbound stream events, connection state, and close status."
                                        color: Theme.textPrimary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Expander {
                Layout.fillWidth: true
                title: "View PageGrpc Source"
                iconText: "</>"
                isExpanded: false
                codeSource: Qt.resolvedUrl("snippets/grpc/PageGrpcSnippet.txt")
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
