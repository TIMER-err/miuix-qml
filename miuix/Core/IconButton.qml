import QtQuick
import miuix.Core
Item {
    id: control

    property string icon: ""
    property string type: "standard"
    property bool enabled: true
    property bool hovered: enabled && pressArea.containsMouse
    property bool pressed: enabled && pressArea.pressed
    property bool focused: enabled && activeFocus
    signal clicked()

    property var _colors: Theme.color

    implicitWidth: 40
    implicitHeight: 40

    property color containerColor: {
        if (!enabled) return type === "filled" || type === "filledTonal" ? _colors.disabledPrimary : "transparent"
        switch (type) {
            case "filled": return _colors.primary
            case "filledTonal": return _colors.secondaryVariant
            default: return "transparent"
        }
    }

    property color contentColor: {
        if (!enabled) return _colors.disabledOnSecondaryVariant
        switch (type) {
            case "filled": return _colors.onPrimary
            case "filledTonal": return _colors.onSecondaryVariant
            default: return _colors.onSurfaceColor
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: containerColor
        border.width: type === "outlined" ? 1 : 0
        border.color: _colors.outline

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "#000000"
            opacity: control.pressed ? 0.10 : (control.hovered ? 0.06 : 0)
        }

        Text {
            anchors.centerIn: parent
            text: control.icon
            font.family: Theme.iconFont.name
            font.pixelSize: 24
            color: contentColor
        }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        enabled: control.enabled
        hoverEnabled: true
        onClicked: control.clicked()
    }
}
