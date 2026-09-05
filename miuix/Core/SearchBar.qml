import QtQuick
import miuix.Core
Item {
    id: control
    property alias text: field.text
    property string placeholderText: "Search"
    property bool enabled: true
    signal accepted()

    implicitWidth: parent ? parent.width : 320
    implicitHeight: 45
    height: 45

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.color.surfaceContainerHigh
    }

    Text {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        text: "search"
        font.family: Theme.iconFont.name
        font.pixelSize: 20
        color: Theme.color.onSurfaceContainerHigh
    }

    Text {
        x: 44
        anchors.verticalCenter: parent.verticalCenter
        z: -1
        text: control.placeholderText
        font.pixelSize: 17
        font.weight: 57
        color: Theme.color.onSurfaceContainerHigh
        visible: field.text.length === 0
    }

    TextInput {
        id: field
        x: 44
        y: 0
        width: Math.max(0, control.width - 60)
        height: control.height
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 17
        font.weight: 57
        color: Theme.color.onSurfaceContainer
        enabled: control.enabled
        onAccepted: control.accepted()
    }

    MouseArea {
        anchors.fill: parent
        enabled: control.enabled && !field.activeFocus
        onClicked: field.forceActiveFocus()
    }
}
