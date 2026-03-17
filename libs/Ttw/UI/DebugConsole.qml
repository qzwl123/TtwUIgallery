import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Ttw.UI

Rectangle {
    id: control

    // ==========================================
    // 1. 公共属性与接口（Public API）
    // ==========================================
    property string title: "调试控制台"
    property int maxLines: 1000
    property bool autoScroll: true

    // 内部状态：序号与最近一条日志时间
    property int _sequenceId: 0
    property string _lastTimestamp: "--"

    // ==========================================
    // 2. 布局度量（统一表头与行内容的列基准）
    // ==========================================
    readonly property bool hasLogs: logModel.count > 0
    readonly property int lineCount: logModel.count
    // 为滚动条预留统一宽度，避免表头与内容列错位
    readonly property int scrollBarReserve: 14
    readonly property int colPadding: 12
    readonly property int colSpacing: width < 720 ? 8 : 10
    readonly property int wSeq: width < 720 ? 42 : 54
    readonly property int wType: width < 720 ? 58 : 70
    readonly property int wTime: width < 720 ? 168 : 196
    // 收窄 Source 列，给 Message 留出更多空间
    readonly property int wSource: Math.max(118, Math.min(186, Math.floor(width * 0.18)))

    // ==========================================
    // 3. 视觉参数（跟随主题）
    // ==========================================
    readonly property color panelFill: Theme.mode === Theme.Mode.Light ? Qt.rgba(0, 0, 0, 0.03) : Qt.rgba(1, 1, 1, 0.06)
    readonly property color altPanelFill: Theme.mode === Theme.Mode.Light ? Qt.rgba(0, 0, 0, 0.018) : Qt.rgba(1, 1, 1, 0.04)
    readonly property color rowHoverFill: Theme.mode === Theme.Mode.Light ? Qt.rgba(0, 103, 192, 0.06) : Qt.rgba(0, 103, 192, 0.14)
    readonly property string monospaceFamily: Qt.platform.os === "windows" ? "Consolas" : "Monospace"

    // 日志数据模型
    ListModel {
        id: logModel
    }

    // 将空值归一化，避免 QML Text 里出现 undefined/null
    function normalizeText(value, fallbackValue) {
        if (value === undefined || value === null || value === "")
            return fallbackValue

        return String(value)
    }

    function typeColor(type) {
        switch (type) {
        case "TX":
            return "#107C10"
        case "RX":
            return "#0078D4"
        case "ERR":
            return "#C42B1C"
        case "INFO":
            return "#F5A524"
        default:
            return Theme.textPrimary || "#333333"
        }
    }

    function typeFill(type) {
        switch (type) {
        case "TX":
            return Theme.mode === Theme.Mode.Light ? Qt.rgba(0.06, 0.49, 0.06, 0.10) : Qt.rgba(0.06, 0.49, 0.06, 0.22)
        case "RX":
            return Theme.mode === Theme.Mode.Light ? Qt.rgba(0.00, 0.47, 0.83, 0.10) : Qt.rgba(0.00, 0.47, 0.83, 0.22)
        case "ERR":
            return Theme.mode === Theme.Mode.Light ? Qt.rgba(0.77, 0.17, 0.11, 0.10) : Qt.rgba(0.77, 0.17, 0.11, 0.22)
        case "INFO":
            return Theme.mode === Theme.Mode.Light ? Qt.rgba(0.96, 0.65, 0.14, 0.12) : Qt.rgba(0.96, 0.65, 0.14, 0.24)
        default:
            return Theme.mode === Theme.Mode.Light ? Qt.rgba(0, 0, 0, 0.045) : Qt.rgba(1, 1, 1, 0.08)
        }
    }

    function typeBorder(type) {
        switch (type) {
        case "TX":
            return Qt.rgba(0.06, 0.49, 0.06, Theme.mode === Theme.Mode.Light ? 0.24 : 0.40)
        case "RX":
            return Qt.rgba(0.00, 0.47, 0.83, Theme.mode === Theme.Mode.Light ? 0.24 : 0.40)
        case "ERR":
            return Qt.rgba(0.77, 0.17, 0.11, Theme.mode === Theme.Mode.Light ? 0.28 : 0.45)
        case "INFO":
            return Qt.rgba(0.96, 0.65, 0.14, Theme.mode === Theme.Mode.Light ? 0.28 : 0.45)
        default:
            return Theme.borderRest || "#EAEAEA"
        }
    }

    function messageColor(type) {
        if (type === "ERR")
            return typeColor(type)

        return Theme.textPrimary || "#333333"
    }

    function clearLogs() {
        logModel.clear()
        control._sequenceId = 0
        control._lastTimestamp = "--"
    }

    // 兼容 2/3/4 参数调用：
    // appendLog(type, message)
    // appendLog(className, type, message)
    // appendLog(className, funcName, type, message)
    function appendLog(className, funcName, type, message) {
        let entryClass = className
        let entryFunc = funcName
        let entryType = type
        let entryMessage = message

        if (arguments.length === 2) {
            entryClass = "-"
            entryFunc = "-"
            entryType = className
            entryMessage = funcName
        } else if (arguments.length === 3) {
            entryClass = className
            entryFunc = "-"
            entryType = funcName
            entryMessage = type
        }

        entryClass = normalizeText(entryClass, "-")
        entryFunc = normalizeText(entryFunc, "-")
        entryType = normalizeText(entryType, "INFO")
        entryMessage = normalizeText(entryMessage, "")

        let timeStamp = new Date().toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm:ss.zzz")

        control._sequenceId += 1
        control._lastTimestamp = timeStamp

        logModel.append({
            "seq": control._sequenceId,
            "time": timeStamp,
            "className": entryClass,
            "funcName": entryFunc,
            "type": entryType,
            "message": entryMessage,
            "msgColor": typeColor(entryType)
        })

        if (logModel.count > control.maxLines)
            logModel.remove(0, logModel.count - control.maxLines)

        if (control.autoScroll)
            listView.positionViewAtEnd()
    }

    Menu {
        id: rightClickMenu

        MenuItem {
            text: "清除日志"
            onTriggered: control.clearLogs()
        }

        MenuItem {
            text: control.autoScroll ? "暂停跟随" : "恢复跟随"
            onTriggered: control.autoScroll = !control.autoScroll
        }
    }

    // 右键弹出菜单，不影响左键在 TextEdit 中选中文字
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: function(mouse) {
            rightClickMenu.popup(mouse.x, mouse.y)
        }
    }

    color: Theme.controlSolid || "#FFFFFF"
    border.color: Theme.borderRest || "#EAEAEA"
    border.width: 1
    radius: Theme.radiusBase * 3 || 12
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 3
        color: Theme.accentMain || "#0067C0"
        opacity: 0.9
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerContent.implicitHeight + 24
            radius: Theme.radiusBase * 2 || 8
            color: control.panelFill
            border.width: 1
            border.color: Theme.borderRest || "#EAEAEA"

            ColumnLayout {
                id: headerContent
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            text: control.title
                            font.pixelSize: 16
                            font.bold: true
                            color: Theme.textPrimary || "#333333"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Label {
                            text: control.hasLogs
                                  ? "最新日志时间：" + control._lastTimestamp + "  |  右键可快速操作。"
                                  : "等待日志输出中，右键可清空日志或切换跟随模式。"
                            color: Theme.textSecondary || "#666666"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    StatusBadge {
                        text: control.lineCount + " 行"
                        tone: "reserved"
                    }

                    StatusBadge {
                        text: control.autoScroll ? "跟随开启" : "跟随关闭"
                        tone: control.autoScroll ? "ready" : "reserved"
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 38
            radius: Theme.radiusBase * 2 || 8
            color: control.panelFill
            border.width: 1
            border.color: Theme.borderRest || "#EAEAEA"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: control.colPadding
                // 表头右侧预留滚动条宽度
                anchors.rightMargin: control.colPadding + control.scrollBarReserve
                spacing: control.colSpacing

                Label {
                    text: "#"
                    font.bold: true
                    color: Theme.textSecondary || "#666666"
                    horizontalAlignment: Text.AlignRight
                    Layout.minimumWidth: control.wSeq
                    Layout.preferredWidth: control.wSeq
                    Layout.maximumWidth: control.wSeq
                }

                Label {
                    text: "来源"
                    font.bold: true
                    color: Theme.textSecondary || "#666666"
                    Layout.minimumWidth: control.wSource
                    Layout.preferredWidth: control.wSource
                    Layout.maximumWidth: control.wSource
                }

                Label {
                    text: "类型"
                    font.bold: true
                    color: Theme.textSecondary || "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.minimumWidth: control.wType
                    Layout.preferredWidth: control.wType
                    Layout.maximumWidth: control.wType
                }

                Label {
                    text: "时间"
                    font.bold: true
                    color: Theme.textSecondary || "#666666"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.minimumWidth: control.wTime
                    Layout.preferredWidth: control.wTime
                    Layout.maximumWidth: control.wTime
                }

                Label {
                    text: "消息"
                    font.bold: true
                    color: Theme.textSecondary || "#666666"
                    Layout.fillWidth: true
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                visible: control.hasLogs
                model: logModel
                spacing: 8
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                footer: Item {
                    width: 1
                    height: 2
                }

                delegate: Rectangle {
                    // 行内容和表头统一预留滚动条宽度，列才能严格对齐
                    width: ListView.view.width - control.scrollBarReserve
                    height: contentRow.implicitHeight + 14
                    radius: Theme.radiusBase * 2 || 8
                    color: rowHover.hovered ? control.rowHoverFill : (index % 2 === 0 ? control.altPanelFill : control.panelFill)
                    border.width: 1
                    border.color: rowHover.hovered ? (Theme.borderHover || "#D0D0D0") : (Theme.borderRest || "#EAEAEA")

                    Rectangle {
                        width: 4
                        radius: width / 2
                        color: model.msgColor
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 6
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                    }

                    RowLayout {
                        id: contentRow
                        anchors.fill: parent
                        // 与表头完全一致，确保列严格对齐
                        anchors.leftMargin: control.colPadding
                        anchors.rightMargin: control.colPadding
                        anchors.topMargin: 7
                        anchors.bottomMargin: 7
                        spacing: control.colSpacing

                        Text {
                            text: model.seq
                            color: Theme.textSecondary || "#888888"
                            font.family: control.monospaceFamily
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignTop
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: control.wSeq
                            Layout.preferredWidth: control.wSeq
                            Layout.maximumWidth: control.wSeq
                        }

                        ColumnLayout {
                            // 强约束 Source 宽度，防止它挤占 Message 列
                            Layout.minimumWidth: control.wSource
                            Layout.preferredWidth: control.wSource
                            Layout.maximumWidth: control.wSource
                            Layout.alignment: Qt.AlignTop
                            spacing: 2

                            Text {
                                // Source 第一行：类名
                                text: model.className
                                color: Theme.textPrimary || "#333333"
                                font.bold: true
                                elide: Text.ElideMiddle
                                clip: true
                                Layout.fillWidth: true
                            }

                            Text {
                                // Source 第二行：函数名（如果有）
                                visible: model.funcName !== "-" && model.funcName !== ""
                                text: model.funcName
                                color: Theme.textSecondary || "#666666"
                                font.pixelSize: 12
                                elide: Text.ElideMiddle
                                clip: true
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            Layout.minimumWidth: control.wType
                            Layout.preferredWidth: control.wType
                            Layout.maximumWidth: control.wType
                            Layout.alignment: Qt.AlignVCenter
                            implicitHeight: typeText.implicitHeight + 10
                            radius: implicitHeight / 2
                            color: control.typeFill(model.type)
                            border.width: 1
                            border.color: control.typeBorder(model.type)

                            Text {
                                id: typeText
                                anchors.centerIn: parent
                                text: model.type
                                color: model.msgColor
                                font.bold: true
                                font.family: control.monospaceFamily
                                font.pixelSize: 12
                            }
                        }

                        Text {
                            text: model.time
                            color: Theme.textSecondary || "#888888"
                            font.family: control.monospaceFamily
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignTop
                            Layout.alignment: Qt.AlignVCenter
                            Layout.minimumWidth: control.wTime
                            Layout.preferredWidth: control.wTime
                            Layout.maximumWidth: control.wTime
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            // Message 至少保留可读宽度，避免看不见内容
                            Layout.minimumWidth: 220
                            Layout.alignment: Qt.AlignVCenter
                            implicitHeight: messageText.contentHeight + 12
                            radius: Theme.radiusBase * 2 || 8
                            color: control.typeFill(model.type)
                            border.width: 1
                            border.color: control.typeBorder(model.type)

                            TextEdit {
                                id: messageText
                                anchors.fill: parent
                                anchors.margins: 6
                                text: model.message
                                color: control.messageColor(model.type)
                                font.family: control.monospaceFamily
                                wrapMode: TextEdit.WrapAnywhere
                                readOnly: true
                                cursorVisible: false
                                selectByMouse: true
                                textFormat: TextEdit.PlainText
                                selectionColor: Theme.accentMain || "#0067C0"
                                selectedTextColor: Theme.textOnAccent || "#FFFFFF"
                            }
                        }
                    }

                    HoverHandler {
                        id: rowHover
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: !control.hasLogs

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: control.panelFill
                    border.width: 1
                    border.color: Theme.borderRest || "#EAEAEA"

                    Text {
                        anchors.centerIn: parent
                        text: ">"
                        color: Theme.accentMain || "#0067C0"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }

                Label {
                    text: "暂无日志"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.textPrimary || "#333333"
                    font.bold: true
                }

                Label {
                    text: "有新日志时会自动显示在这里。"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.textSecondary || "#666666"
                }
            }
        }
    }
}

