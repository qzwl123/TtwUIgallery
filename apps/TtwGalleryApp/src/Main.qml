import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls 2.15

import TtwGalleryApp
import Ttw.UI

TtwWindow {
    id: mainWindow
    width: 1024; height: 768
    visible: true
    title: "Ttw UI for Qt Gallery"
    color: Theme.bgMain // 全局背景

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusLarge
        color: Theme.bgLayer
        border.width: 1
        border.color: Theme.borderRest

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ==========================================
            // 左侧：导航栏 (Sidebar)
            // ==========================================
            Rectangle {
                Layout.preferredWidth: 240
                Layout.fillHeight: true
                color: Theme.bgSubtle

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // 标题
                    Text {
                        text: "Ttw Gallery"
                        font: Theme.fontTitle
                        color: Theme.textPrimary
                        Layout.leftMargin: 10
                        Layout.topMargin: 8
                    }

                    Text {
                        text: "WINUI 3 STYLE"
                        font.family: Theme.fontBody.family
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Theme.textSecondary
                        Layout.leftMargin: 10
                        Layout.bottomMargin: 4
                    }

                    // 导航列表
                    ListView {
                        id: navList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 2

                        // 定义菜单数据
                        model: ListModel {
                            ListElement { title: "基础控件"; iconCode: "\uE80F"; pageIndex: 0 }
                            ListElement { title: "图标库"; iconCode: "\uE8FD"; pageIndex: 1 }
                        }

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 40
                            radius: Theme.radiusBase
                            color: {
                                if (navList.currentIndex === index) return Theme.controlFillPress
                                if (mouseArea.containsMouse) return Theme.controlFillHover
                                return "transparent"
                            }
                            Behavior on color { ColorAnimation { duration: Theme.fastAnim } }

                            Rectangle {
                                visible: navList.currentIndex === index
                                width: 3
                                radius: 2
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 2
                                height: parent.height - 12
                                color: Theme.accentMain
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: navList.currentIndex = index
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                spacing: 12

                                Text {
                                    text: iconCode
                                    font.family: Theme.iconFontFamily
                                    font.pixelSize: 16
                                    color: Theme.textPrimary
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: title
                                    font: Theme.fontBody
                                    color: Theme.textPrimary
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // 分割线
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Theme.borderRest
            }

            // ==========================================
            // 右侧：内容区 (Content)
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                clip: true

                StackLayout {
                    id: contentStack
                    anchors.fill: parent
                    anchors.margins: 20

                    currentIndex: navList.currentIndex

                    PageHome {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    PageIcons {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
