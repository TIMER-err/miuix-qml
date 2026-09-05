import QtQuick
import miuix.Core
Item {
    id: control

    property string text: ""
    property string icon: ""
    property string type: "filled"
    property bool enabled: true
    property real horizontalPadding: type === "text" ? 12 : 16
    property real verticalPadding: 13
    property real spacing: 8
    property bool hovered: enabled && pressArea.containsMouse
    property bool pressed: enabled && pressArea.pressed
    property bool focused: enabled && activeFocus
    property Item contentItem
    signal clicked()

    property var _colors: Theme.color

    implicitWidth: Math.max((contentItem ? contentItem.implicitWidth : contentRow.width) + horizontalPadding * 2, 58)
    implicitHeight: 40

    onContentItemChanged: {
        if (contentItem) {
            contentItem.parent = backgroundRect
            contentItem.anchors.centerIn = backgroundRect
        }
    }

    property color containerColor: {
        if (!enabled) {
            if (type === "filled" || type === "elevated") return _colors.disabledPrimary
            return _colors.disabledSecondaryVariant
        }
        switch (type) {
            case "elevated": return _colors.surfaceContainer
            case "filled": return _colors.primary
            case "filledTonal": return _colors.secondaryVariant
            case "outlined": return "transparent"
            case "text": return "transparent"
            default: return _colors.primary
        }
    }

    property color contentColor: {
        if (!enabled) {
            if (type === "filled" || type === "elevated") return _colors.disabledOnPrimary
            return _colors.disabledOnSecondaryVariant
        }
        switch (type) {
            case "elevated": return _colors.primary
            case "filled": return _colors.onPrimary
            case "filledTonal": return _colors.onSecondaryVariant
            case "outlined": return _colors.primary
            case "text": return _colors.onSecondaryVariant
            default: return _colors.onPrimary
        }
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        radius: 16
        color: containerColor
        border.width: type === "outlined" ? 1 : 0
        border.color: enabled ? _colors.outline : _colors.disabledSecondaryVariant

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "#000000"
            opacity: control.pressed ? 0.10 : (control.hovered ? 0.06 : 0)
        }

        Row {
            id: contentRow
            visible: !control.contentItem
            anchors.centerIn: parent
            spacing: control.spacing

            Text {
                text: control.icon
                font.family: Theme.iconFont.name
                font.pixelSize: 18
                color: contentColor
                visible: control.icon !== ""
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: control.text
                font.family: Theme.typography.labelLarge.family
                font.pixelSize: 17
                font.weight: 57
                color: contentColor
                anchors.verticalCenter: parent.verticalCenter
            }
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
