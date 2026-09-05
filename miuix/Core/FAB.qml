import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import miuix.Core
Item {
    id: root

    property string icon: "add"
    property string text: ""
    property string type: "standard"
    property color containerColor: Theme.color.primary
    property color contentColor: Theme.color.onPrimary
    signal clicked()

    property int fabSize: {
        switch (type) {
            case "small": return 40
            case "large": return 72
            default: return 60
        }
    }
    property int fabRadius: fabSize / 2
    property int iconSize: type === "large" ? 32 : 24
    property int elevationLevel: 4

    implicitWidth: type === "extended" ? (rowLayout.implicitWidth + 32) : fabSize
    implicitHeight: fabSize

    Rectangle {
        id: shadowSource
        anchors.fill: parent
        radius: root.fabRadius
        color: root.containerColor
        visible: false
    }

    MultiEffect {
        anchors.fill: shadowSource
        source: shadowSource
        visible: true
        z: -1
        shadowEnabled: true
        shadowColor: Theme.color.shadow
        shadowBlur: 0.8
        shadowVerticalOffset: 4
        shadowOpacity: 0.18
    }

    Rectangle {
        anchors.fill: parent
        radius: root.fabRadius
        color: root.containerColor

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "#000000"
            opacity: mouseArea.pressed ? 0.10 : 0
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8
        Text {
            visible: root.icon !== ""
            text: root.icon
            font.family: Theme.iconFont.name
            font.pixelSize: root.iconSize
            color: root.contentColor
        }
        Text {
            visible: root.type === "extended" && root.text !== ""
            text: root.text
            font.pixelSize: 17
            color: root.contentColor
        }
    }
}
