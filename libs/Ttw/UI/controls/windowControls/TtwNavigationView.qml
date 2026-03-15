import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Ttw.UI // 引入你的主题和图标系统

Item {
    id: root

    // ==========================================
    // 1. 公开 API
    // ==========================================
    property bool isExpanded: true
    readonly property int expandedWidth: 240
    readonly property int collapsedWidth: 48 // WinUI 标准折叠宽度通常较窄

    // 数据模型与当前选中项
    property alias model: navList.model
    property int currentIndex: navList.currentIndex

    // 内容加载器，供外部访问当前加载的页面
    property alias contentLoader: loader_content

    // ==========================================
    // 2. 左侧导航栏 (Sidebar)
    // ==========================================
    Rectangle {
        id: sidebar
        width: root.isExpanded ? root.expandedWidth : root.collapsedWidth
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        color: "transparent" // 背景透明，融入 TtwWindow
        clip: true

        // 丝滑的折叠动画
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

        ColumnLayout {
            anchors.fill: parent
            spacing: 2 // 菜单项之间的微小间距

            // --- 2.1 汉堡按钮 ---
            ItemDelegate {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.topMargin: 4
                Layout.leftMargin: 4
                Layout.rightMargin: 4

                background: Rectangle {
                    radius: Theme.radiusBase || 4
                    color: parent.pressed ? (Theme.controlFillPress || "#19000000") :
                          (parent.hovered ? (Theme.controlFillHover || "#09000000") : "transparent")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12 // 汉堡图标的固定缩进
                    spacing: 16

                    Text {
                        text: Icons.menu || "≡" // 使用你的图标单例
                        font.family: Theme.iconFontFamily
                        font.pixelSize: 16
                        color: Theme.textPrimary || "#000000"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: root.isExpanded = !root.isExpanded
            }

            // --- 2.2 主菜单列表 ---
            ListView {
                id: navList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                interactive: false
                currentIndex: 0

                delegate: ItemDelegate {
                    id: delegateItem
                    width: navList.width
                    height: 40
                    highlighted: ListView.isCurrentItem

                    // [WinUI 灵魂] 左侧蓝色短竖线指示器 (Pill)
                    Rectangle {
                        width: 3
                        height: 16
                        radius: 1.5
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        // 建议 Theme.accentColor，这里用默认 WinUI 蓝兜底
                        color: Theme.accentColor || "#005FB8"
                        visible: parent.highlighted
                    }

                    // [WinUI 灵魂] 圆角选中背景
                    background: Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 4 // 给左侧蓝线留出一点空间
                        radius: Theme.radiusBase || 4
                        color: delegateItem.highlighted ? (Theme.controlFillPress || "#19000000") :
                              (delegateItem.hovered ? (Theme.controlFillHover || "#09000000") : "transparent")
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 12
                        spacing: 16

                        Text {
                            // text: model.icon || "•"
                            text: modelData.icon || "•"
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 16
                            color: Theme.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            // text: model.title
                            text: modelData.title
                            font: Theme.fontBody // 使用你的主题字体
                            color: Theme.textPrimary
                            anchors.verticalCenter: parent.verticalCenter
                            visible: sidebar.width > 100
                            opacity: sidebar.width > 100 ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    // onClicked: {
                    //     navList.currentIndex = index
                    //     if(model.page) {
                    //         loader_content.source = model.page
                    //     }
                    // }

                    onClicked: {
                        navList.currentIndex = index
                        if(modelData.page) {
                            loader_content.source = modelData.page
                        }
                    }
                }
            }

            // --- 2.3 底部固定设置按钮 ---
            ItemDelegate {
                id: settingsBtn
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.bottomMargin: 8
                Layout.leftMargin: 4
                Layout.rightMargin: 4

                // 设置按钮高亮逻辑（当 ListView 取消选中时，代表选了设置）
                property bool isSelected: navList.currentIndex === -1

                Rectangle {
                    width: 3; height: 16; radius: 1.5
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    color: Theme.accentColor || "#005FB8"
                    visible: settingsBtn.isSelected
                }

                background: Rectangle {
                    anchors.fill: parent; anchors.leftMargin: 4; radius: Theme.radiusBase || 4
                    color: settingsBtn.isSelected ? (Theme.controlFillPress || "#19000000") :
                          (settingsBtn.hovered ? (Theme.controlFillHover || "#09000000") : "transparent")
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    spacing: 16
                    Text { text: Icons.settings || "⚙"; font.family: Theme.iconFontFamily; font.pixelSize: 16; color: Theme.textPrimary; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: "设置"
                        font: Theme.fontBody
                        color: Theme.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: sidebar.width > 100 ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }

                onClicked: {
                    navList.currentIndex = -1 // 取消主列表高亮
                    loader_content.source = "SettingsPage.qml" // 替换为你的设置页路径
                }
            }
        }
    }

    // ==========================================
    // 3. 右侧内容区加载器
    // ==========================================
    // 使用 Item 包装 Loader，利用其自适应右侧剩余空间
    Item {
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        // 左侧画一条极细的分割线，区分导航和内容 (WinUI 规范)
        Rectangle {
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: Theme.borderRest || "#1A000000"
        }

        Loader {
            id: loader_content
            anchors.fill: parent
            anchors.leftMargin: 1 // 避开分割线
            // QML 动画：页面切换时的渐现效果
            Behavior on source {
                SequentialAnimation {
                    NumberAnimation { target: loader_content.item; property: "opacity"; to: 0; duration: 100 }
                    PropertyAction { target: loader_content; property: "source" }
                    NumberAnimation { target: loader_content.item; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
