import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Ttw.UI

Control {
    id: control

    property string text: ""
    property string tone: "ready"

    readonly property color fillColor: {
        switch (tone) {
        case "busy":
            return Qt.rgba(0.98, 0.66, 0.14, Theme.mode === Theme.Mode.Light ? 0.18 : 0.24)
        case "offline":
            return Qt.rgba(0.77, 0.16, 0.16, Theme.mode === Theme.Mode.Light ? 0.16 : 0.24)
        case "reserved":
            return Qt.rgba(0.36, 0.36, 0.36, Theme.mode === Theme.Mode.Light ? 0.12 : 0.22)
        case "error":
            return Qt.rgba(0.77, 0.16, 0.16, Theme.mode === Theme.Mode.Light ? 0.20 : 0.28)
        default:
            return Qt.rgba(0.06, 0.55, 0.21, Theme.mode === Theme.Mode.Light ? 0.16 : 0.22)
        }
    }

    readonly property color strokeColor: {
        switch (tone) {
        case "busy":
            return "#F5A524"
        case "offline":
            return "#C42B1C"
        case "reserved":
            return Theme.textSecondary
        case "error":
            return "#C42B1C"
        default:
            return "#107C10"
        }
    }

    readonly property color foregroundColor: {
        switch (tone) {
        case "reserved":
            return Theme.textSecondary
        default:
            return strokeColor
        }
    }

    leftPadding: 12
    rightPadding: 12
    topPadding: 7
    bottomPadding: 7
    implicitWidth: badgeContent.implicitWidth + leftPadding + rightPadding
    implicitHeight: Math.max(28, badgeContent.implicitHeight + topPadding + bottomPadding)

    background: Rectangle {
        radius: height / 2
        color: control.fillColor
        border.width: 1
        border.color: Qt.rgba(control.strokeColor.r, control.strokeColor.g, control.strokeColor.b, 0.28)
    }

    contentItem: RowLayout {
        id: badgeContent
        spacing: 8

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 6
            implicitHeight: 6
            radius: 3
            color: control.foregroundColor
        }

        Text {
            text: control.text
            color: control.foregroundColor
            font.pixelSize: 12
            font.bold: true
            renderType: Text.NativeRendering
        }
    }
}
