import QtQuick
import QtQuick.Layouts
import miuix.Core
Item {
    id: control

    property bool checked: false
    property string text: ""
    property bool enabled: true
    signal clicked()

    property var _colors: Theme.color

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Math.max(26, rowLayout.implicitHeight)

    RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: 12

        Item {
            implicitWidth: 26
            implicitHeight: 26
            width: 26
            height: 26

            Text {
                anchors.centerIn: parent
                text: "check"
                font.family: Theme.iconFont.name
                font.pixelSize: 18
                color: control.enabled ? _colors.primary : _colors.disabledPrimary
                opacity: control.checked ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 80 } }
            }

            MouseArea {
                anchors.fill: parent
                enabled: control.enabled
                onClicked: control.clicked()
            }
        }

        Text {
            text: control.text
            visible: control.text.length > 0
            font.family: Theme.typography.labelLarge.family
            font.pixelSize: 17
            color: control.enabled ? _colors.onSurfaceColor : _colors.disabledOnSecondaryVariant
            MouseArea {
                anchors.fill: parent
                enabled: control.enabled
                onClicked: control.clicked()
            }
        }
    }
}
