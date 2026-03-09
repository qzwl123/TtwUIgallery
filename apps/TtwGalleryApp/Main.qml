import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

import TtwGalleryApp
import Ttw.UI

TtwWindow {
    id: mainWindow
    visible: true
    width: 1024
    height: 768
    // titleText: 已经有默认绑定，无需重复写

    TtwNavigationView {
        anchors.fill: parent // 直接填满 TtwWindow 的内容区

        // 直接给 model 赋一个 JS 数组
        model: [
            {
                title: "首页",
                icon: "\uE80F",
                // 这里尽情使用 Qt.resolvedUrl，因为它是原生 JS 对象
                page: Qt.resolvedUrl("src/pages/PageHome.qml")
            },
            {
                title: "图表",
                icon: "\uE80F",
                page: Qt.resolvedUrl("src/pages/PageChart.qml")
            },
            {
                title: "图标库",
                icon: "\uE946",
                page: Qt.resolvedUrl("src/pages/PageIcons.qml")
            }
        ]

        // 初始化时自动加载第一页
        Component.onCompleted: {
            // 注意：JS 数组必须使用 .length 和 [索引]
            if (model.length > 0) {
                contentLoader.source = model[0].page
            }
        }

    }
}
