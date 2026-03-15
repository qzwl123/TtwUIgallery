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

    TtwNavigationView {
        anchors.fill: parent

        model: [
            {
                title: "Home",
                icon: "\uE80F",
                page: Qt.resolvedUrl("src/pages/PageHome.qml")
            },
            {
                title: "Charts",
                icon: "\uE80F",
                page: Qt.resolvedUrl("src/pages/PageChart.qml")
            },
            {
                title: "gRPC",
                icon: "\uE968",
                page: Qt.resolvedUrl("src/pages/PageGrpc.qml")
            },
            {
                title: "Icons",
                icon: "\uE946",
                page: Qt.resolvedUrl("src/pages/PageIcons.qml")
            }
        ]

        Component.onCompleted: {
            if (model.length > 0) {
                contentLoader.source = model[0].page
            }
        }
    }
}
