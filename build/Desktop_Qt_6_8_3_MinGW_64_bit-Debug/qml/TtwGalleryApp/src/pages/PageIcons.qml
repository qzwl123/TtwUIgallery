import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Ttw.UI

Page {
    id: root
    title: "Icons.qml 映射浏览器"
    background: Rectangle { color: Theme.bgMain }

    ListModel { id: iconModel }

    Component.onCompleted: {
        for (var prop in Icons) {
            var val = Icons[prop];
            if (typeof val === "string" && prop !== "objectName" && prop !== "toString") {
                iconModel.append({ "name": prop, "code": val });
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部提示
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: Theme.controlFillRest

            RowLayout {
                anchors.centerIn: parent
                Text {
                    text: "点击直接复制变量名 (如 Icons.home)"
                    font: Theme.fontBody
                    color: Theme.textSecondary
                }
            }
        }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            clip: true
            cellWidth: 110; cellHeight: 110
            model: iconModel
            ScrollBar.vertical: ScrollBar { }

            delegate: Rectangle {
                width: 100; height: 100
                radius: Theme.radiusBase
                color: {
                    if (mouseArea.pressed) return Theme.controlFillPress
                    if (mouseArea.containsMouse) return Theme.controlFillHover
                    return Theme.controlFillRest
                }
                border.color: Theme.borderRest; border.width: 1

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var copyStr = "Icons." + model.name
                        clipboardHelper.copyText(copyStr)
                        toast.show("已复制: " + copyStr)
                        console.log("Copied:", copyStr)
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    width: parent.width - 10

                    // 1. 图标显示
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: model.code
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 32
                        color: Theme.textPrimary
                        renderType: Text.NativeRendering
                    }

                    // 2. 属性名显示 (这里是刚才报错的地方)
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: model.name
                        color: Theme.textPrimary
                        elide: Text.ElideMiddle

                        // 【✅ 核心修复】不要直接写 font: Theme.fontBody
                        // 而是只提取它的 family，然后单独设置 size
                        font.family: Theme.fontBody.family
                        font.pixelSize: 12
                    }

                    // 3. Unicode 提示
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (model.code.charCodeAt(0).toString(16).toUpperCase())
                        font.family: "Consolas"
                        font.pixelSize: 10
                        color: Theme.textDisabled
                    }
                }
            }
        }
    }

    TextEdit {
        id: clipboardHelper
        visible: false
        function copyText(str) { text = str; selectAll(); copy() }
    }

    Rectangle {
        id: toast
        width: 240; height: 40; radius: 20
        color: Theme.textPrimary
        anchors.bottom: parent.bottom; anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0; z: 999

        Text {
            id: toastText
            anchors.centerIn: parent
            color: Theme.bgMain
            font: Theme.fontBody
        }

        function show(msg) { toastText.text = msg; toastAnim.restart() }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toast; property: "opacity"; to: 0.9; duration: 200 }
            PauseAnimation { duration: 1500 }
            NumberAnimation { target: toast; property: "opacity"; to: 0; duration: 500 }
        }
    }
}
