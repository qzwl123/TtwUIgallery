import QtQuick
import QtQuick.Controls

import Ttw.UI

Control {
    id: control
    default property alias contentData: container.data

    property bool accentBarVisible: false
    property bool highlighted: false
    property color accentBarColor: Theme.accentMain
    property color surfaceColor: Theme.controlSolid
    property color surfaceBorderColor: Theme.borderRest
    property color tintColor: Theme.mode === Theme.Mode.Light
                              ? Qt.rgba(1, 1, 1, highlighted ? 0.52 : 0.34)
                              : Qt.rgba(1, 1, 1, highlighted ? 0.06 : 0.03)

    padding: 20
    implicitWidth: Math.max(240, container.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(72, container.implicitHeight + topPadding + bottomPadding)

    background: Rectangle {
        radius: Theme.radiusBase * 3
        color: control.surfaceColor
        border.width: 1
        border.color: control.surfaceBorderColor

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(0, parent.radius - 1)
            color: control.tintColor
        }

        Rectangle {
            visible: control.accentBarVisible
            width: 4
            radius: width / 2
            color: control.accentBarColor
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 12
        }
    }

    contentItem: Item {
        id: container
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
