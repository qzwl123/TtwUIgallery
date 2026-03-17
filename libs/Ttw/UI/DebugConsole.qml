import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Ttw.UI

Rectangle {
    id: control

    // ==========================================
    // 1. 公共属性与接口 (Public API)
    // ==========================================
    property string title: "调试控制台"
    property int maxLines: 1000
    property bool autoScroll: true

    // 内部序号计数器
    property int _sequenceId: 0

    // 【列宽配置】：统一管理列宽，保证表头和列表内容绝对对齐
    readonly property int wSeq: 50
    readonly property int wClass: 120
    readonly property int wFunc: 120
    readonly property int wType: 60
    readonly property int wTime: 90
    // 最后一列“信息”自动撑满剩余空间

    // 【核心接口更新】：增加了 className 和 funcName
    function appendLog(className, funcName, type, message) {
        let timeStr = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss.zzz")

        let typeColor = Theme.textPrimary || "#333333"
        if (type === "TX") typeColor = "#107C10"
        else if (type === "RX") typeColor = "#0078D4"
        else if (type === "ERR") typeColor = "#C42B1C"
        else if (type === "INFO") typeColor = "#F5A524"

        _sequenceId++ // 序号累加

        logModel.append({
            "seq": _sequenceId,
            "time": timeStr,
            "className": className,
            "funcName": funcName,
            "type": type,
            "message": message,
            "msgColor": typeColor
        })

        if (logModel.count > control.maxLines) {
            logModel.remove(0, 1)
        }

        if (control.autoScroll) {
            listView.positionViewAtEnd()
        }
    }

    // ==========================================
    // 2. 右键菜单 (Context Menu)
    // ==========================================
    Menu {
        id: rightClickMenu
        MenuItem {
            text: "清除日志"
            icon.name: "edit-clear" // 如果系统有图标会显示
            onTriggered: {
                logModel.clear()
                control._sequenceId = 0 // 重置序号
            }
        }
        MenuItem {
            text: "自动滚动到底部"
            checkable: true
            checked: control.autoScroll
            onTriggered: control.autoScroll = !control.autoScroll
        }
    }

    // 拦截右键点击，弹出菜单（且不影响左键选中文字）
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: (mouse) => {
            rightClickMenu.popup(mouse.x, mouse.y)
        }
    }

    // ==========================================
    // 3. 界面外观 (UI)
    // ==========================================
    color: Theme.bgMain || "#FFFFFF"
    border.color: Theme.borderRest || "#EAEAEA"
    border.width: 1
    radius: Theme.radiusBase || 8
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 0 // 去掉默认间距，让我们自己精确控制

        // --- 顶部标题 ---
        Label {
            text: control.title
            font.bold: true
            color: Theme.textPrimary || "#333333"
            Layout.fillWidth: true
            Layout.bottomMargin: 8
        }

        // --- 信息表头 (Header) ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: Theme.bgHover || "#F3F3F3" // 表头底色

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 5
                anchors.rightMargin: 15 // 给右侧滚动条留出一点空间
                spacing: 10

                Label { text: "序号"; font.bold: true; Layout.preferredWidth: control.wSeq }
                Label { text: "类名"; font.bold: true; Layout.preferredWidth: control.wClass }
                Label { text: "功能名称"; font.bold: true; Layout.preferredWidth: control.wFunc }
                Label { text: "类别"; font.bold: true; Layout.preferredWidth: control.wType }
                Label { text: "时间戳"; font.bold: true; Layout.preferredWidth: control.wTime }
                Label { text: "信息"; font.bold: true; Layout.fillWidth: true }
            }
        }

        // 分割线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderRest || "#EAEAEA"
            Layout.bottomMargin: 5
        }

        // --- 核心列表 (ListView) ---
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 【核心修复】：必须加 clip，否则超长报文向上滚动时会溢出盖住表头和 Title！
            clip: true

            model: ListModel { id: logModel }
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}

            // 单行数据渲染
            delegate: RowLayout {
                width: ListView.view.width - 15 // 减去滚动条的宽度
                spacing: 10

                // 给每行加一点上下边距，防止太挤
                Layout.topMargin: 4
                Layout.bottomMargin: 4

                // 1. 序号
                Text { text: model.seq; color: Theme.textSecondary || "#888888"; Layout.preferredWidth: control.wSeq }

                // 2. 类名 (太长自动省略)
                Text { text: model.className; color: Theme.textPrimary || "#333333"; elide: Text.ElideRight; Layout.preferredWidth: control.wClass }

                // 3. 功能名称 (太长自动省略)
                Text { text: model.funcName; color: Theme.textPrimary || "#333333"; elide: Text.ElideRight; Layout.preferredWidth: control.wFunc }

                // 4. 信息类别 (TX/RX 等)
                Text { text: model.type; color: model.msgColor; font.bold: true; Layout.preferredWidth: control.wType }

                // 5. 时间戳
                Text { text: model.time; color: Theme.textSecondary || "#888888"; font.family: "Monospace"; Layout.preferredWidth: control.wTime }

                // 6. 核心信息 (TextEdit 允许选中和换行)
                TextEdit {
                    text: model.message
                    color: model.msgColor
                    font.family: "Monospace"

                    // 【核心功能】：允许鼠标选中和复制！
                    selectByMouse: true
                    readOnly: true // 禁止修改

                    // 【核心修复】：超长无空格的数据也会强制换行，绝对不会撑爆布局
                    wrapMode: TextEdit.WrapAnywhere

                    Layout.fillWidth: true

                    // 选中时的背景色和文字色
                    selectionColor: Theme.primary || "#0078D4"
                    selectedTextColor: "#FFFFFF"
                }
            }
        }
    }
}
