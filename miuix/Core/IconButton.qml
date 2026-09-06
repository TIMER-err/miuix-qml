import QtQuick
import miuix.Core
Item {
    id: control

    property string icon: ""
    property string type: "standard"
    property bool enabled: true
    // IconButtonDefaults.CornerRadius is 40dp, clamped to a circle at the 40dp
    // default size.
    property real cornerRadius: 40
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
        radius: Math.min(control.cornerRadius, Math.min(width, height) / 2)
        color: containerColor
        border.width: type === "outlined" ? 1 : 0
        border.color: _colors.outline

        // MiuixIndication: a flat overlay in onBackground, +0.06 hovered / +0.10
        // pressed, clipped to the button's own shape.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: _colors.onBackground
            opacity: control.pressed ? 0.10 : (control.hovered ? 0.06 : 0)
            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
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
