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

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ==========================================
        // 左侧：导航栏 (Sidebar)
        // ==========================================
        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: Theme.mode === Theme.Mode.Light ? "#F3F3F3" : "#202020" // 侧边栏通常颜色稍浅/深

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                // 标题
                Text {
                    text: "Ttw Gallery"
                    font: Theme.fontTitle
                    color: Theme.textPrimary
                    Layout.leftMargin: 10
                    Layout.bottomMargin: 10
                }

                // 导航列表
                ListView {
                    id: navList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    // 定义菜单数据
                    model: ListModel {
                        ListElement { title: "基础控件"; iconName: "home"; pageIndex: 0 }
                        ListElement { title: "图标库";   iconName: "emoji"; pageIndex: 1 } // emoji 对应 Icons.puncuation 等，这里暂用 text
                    }

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 40
                        radius: 4
                        // 选中态逻辑：Win11 样式
                        // 选中：背景变色，且左侧有指示条(可选)
                        // 悬停：背景微变
                        color: {
                            if (navList.currentIndex === index) return Theme.controlFillPress
                            if (mouseArea.containsMouse) return Theme.controlFillHover
                            return "transparent"
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: navList.currentIndex = index
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 12

                            // 动态获取图标
                            Text {
                                // 简单的逻辑：根据 index 判断用哪个图标
                                // 实际项目中建议把图标代码写在 model 里
                                text: index === 0 ? Icons.home : Icons.heart
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
            color: "transparent" // 透明，显示 Window 的背景
            clip: true

            // StackLayout 用于页面堆叠切换
            StackLayout {
                id: contentStack
                anchors.fill: parent
                anchors.margins: 20 // 内容区的内边距

                // 绑定到左侧列表的选中项
                currentIndex: navList.currentIndex

                // [Index 0] 首页
                PageHome {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // [Index 1] 图标页
                PageIcons {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}
