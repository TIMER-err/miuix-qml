import QtQuick
import QtQuick.Layouts
import miuix.Core
Item {
    id: control

    property bool checked: false
    property string text: ""
    property bool enabled: true
    property bool showIcon: false
    property string icon: "check"

    signal clicked()

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Math.max(28, rowLayout.implicitHeight)

    property var _colors: Theme.color

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 12

        Item {
            implicitWidth: 49
            implicitHeight: 28

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: {
                    if (!control.enabled)
                        return control.checked ? _colors.disabledPrimary : _colors.secondaryContainer
                    return control.checked ? _colors.primary : _colors.secondary
                }
                Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
            }

            Rectangle {
                id: thumb
                width: 20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                x: control.checked ? 25 : 4
                scale: hit.pressed && control.enabled ? 1.127 : 1
                color: {
                    if (!control.enabled)
                        return control.checked ? _colors.disabledOnPrimary : "#FCFCFC"
                    return "#ffffff"
                }
                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 180 } }
            }

            MouseArea {
                id: hit
                anchors.fill: parent
                enabled: control.enabled
                onClicked: {
                    control.checked = !control.checked
                    control.clicked()
                }
            }
        }

        Text {
            text: control.text
            visible: control.text.length > 0
            font.family: Theme.typography.labelLarge.family
            font.pixelSize: Theme.typography.labelLarge.size
            font.weight: Theme.typography.labelLarge.weight
            color: control.enabled ? _colors.onSurfaceColor : _colors.disabledOnSecondaryVariant
            Layout.fillWidth: true

            MouseArea {
                anchors.fill: parent
                enabled: control.enabled
                onClicked: {
                    control.checked = !control.checked
                    control.clicked()
                }
            }
        }
    }
}
