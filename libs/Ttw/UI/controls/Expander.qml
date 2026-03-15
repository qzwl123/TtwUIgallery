import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Ttw.UI


Item {
    id: root

    // ==========================================
    // 1. 公开 API
    // ==========================================
    property string title: "标题"
    property string iconText: "</>"
    property bool isExpanded: false
    property bool autoToggle: true

    // 🌟【新增智能属性】：只要传入字符串，它就会自动变成带复制功能的“代码面板”
    property string codeText: ""
    // 直接传入文件路径，自动读取内容！
    property url codeSource: ""
    signal headerClicked()

    // 允许外部塞入通用组件
    default property alias contentData: customContent.data

    // 动态计算总高度：头部高度 + 展开的内容高度
    implicitHeight: header.height + contentContainer.height

    // 监听传入的路径，一旦赋值就去读文件
    onCodeSourceChanged: {
        if (codeSource.toString() === "") {
            root.codeText = "";
            return;
        }

        // 🌟 因为 FileIO 已经注册在 Ttw.UI 里，这里直接调用完美生效！
        root.codeText = FileIO.readTextFile(codeSource);
    }

    // 外边框
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.borderRest || "#EAEAEA"
        border.width: 1
        radius: Theme.radiusBase || 8
        clip: true
    }

    // ==========================================
    // 2. 头部区域 (Header)
    // ==========================================
    ItemDelegate {
        id: header
        width: parent.width
        height: 50

        background: Rectangle {
            color: header.hovered ? (Theme.controlFillHover || "#09000000") : "transparent"
            radius: Theme.radiusBase || 8
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text { visible: root.iconText !== ""; text: root.iconText; font.pixelSize: 16; font.bold: true; color: Theme.textSecondary || "#666666" }
            Text { text: root.title; font.pixelSize: 14; color: Theme.textPrimary || "#000000"; Layout.fillWidth: true }
            Text {
                text: "▼"
                font.pixelSize: 12; color: Theme.textSecondary || "#666666"
                rotation: root.isExpanded ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
            }
        }
        onClicked: {
            if (root.autoToggle)
                root.isExpanded = !root.isExpanded
            root.headerClicked()
        }
    }

    // ==========================================
    // 3. 动态折叠内容区 (智能双模)
    // ==========================================
    Item {
        id: contentContainer
        width: parent.width
        y: header.height

        // 🌟【核心判断】：如果有代码就用代码区的高度，没有代码就用通用区的高度
        height: root.isExpanded ? (root.codeText !== "" ? codeModeBg.implicitHeight : customContent.implicitHeight) : 0
        clip: true
        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

        // 分割线
        Rectangle { width: parent.width; height: 1; color: Theme.borderRest || "#EAEAEA" }

        // ------------------------------------------
        // 【模式 A】：代码展示模式 (自带复制按钮)
        // ------------------------------------------
        Rectangle {
            id: codeModeBg
            width: parent.width
            // 只有当传入了 codeText 时才显示
            visible: root.codeText !== ""
            implicitHeight: root.codeText !== "" ? Math.max(codeTextArea.contentHeight + 32, 50) : 0
            color: Theme.controlFillRest || "#F9F9F9"

            TextArea {
                id: codeTextArea
                anchors.fill: parent
                anchors.margins: 16
                anchors.rightMargin: 48 // 给复制按钮留空间
                readOnly: true
                selectByMouse: true
                wrapMode: Text.NoWrap
                text: root.codeText // 直接绑定外部传入的文本
                font.family: "Consolas"
                font.pixelSize: 13
                color: Theme.textPrimary || "#333333"
                background: null
                textFormat: Text.PlainText // 强制声明为纯文本！拒绝 QML 引擎吞噬空格和换行
            }

            // 内置一键复制按钮
            Rectangle {
                id: copyBtn
                width: 32; height: 32
                anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 8
                radius: 4
                color: copyMouse.pressed ? (Theme.controlFillPress || "#E5E5E5") : (copyMouse.containsMouse ? (Theme.controlFillHover || "#F0F0F0") : "transparent")

                property bool isCopied: false

                Text {
                    anchors.centerIn: parent
                    text: copyBtn.isCopied ? "✔" : "📋"
                    font.pixelSize: 14
                    color: copyBtn.isCopied ? "#107C10" : (Theme.textSecondary || "#666666")
                }

                ToolTip.visible: copyMouse.containsMouse
                ToolTip.text: copyBtn.isCopied ? "已复制" : "复制代码"
                ToolTip.delay: 300

                MouseArea {
                    id: copyMouse
                    anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        codeTextArea.selectAll()
                        codeTextArea.copy()
                        codeTextArea.deselect()
                        copyBtn.isCopied = true
                        resetTimer.restart()
                    }
                }
                Timer { id: resetTimer; interval: 2000; onTriggered: copyBtn.isCopied = false }
            }
        }

        // ------------------------------------------
        // 【模式 B】：通用容器模式
        // ------------------------------------------
        Control {
            id: customContent
            width: parent.width
            // 如果传了代码，就隐藏通用容器区
            visible: root.codeText === ""
            padding: 0
            background: null
        }
    }
}
