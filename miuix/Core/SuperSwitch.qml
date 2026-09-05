import QtQuick
import QtQuick.Layouts
import miuix.Core
Item {
    id: control
    property string title: ""
    property string summary: ""
    property bool checked: false
    property bool enabled: true
    signal clicked()

    anchors.left: parent.left
    anchors.right: parent.right
    height: 56

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: titleClick.pressed ? 0.10 : (titleClick.containsMouse ? 0.06 : 0)
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            MouseArea {
                id: titleClick
                anchors.fill: parent
                enabled: control.enabled
                hoverEnabled: true
                onClicked: {
                    control.checked = !control.checked
                    control.clicked()
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 2
                Text {
                    text: control.title
                    font.pixelSize: 17
                    font.weight: 57
                    color: control.enabled ? Theme.color.onBackground : Theme.color.disabledOnSecondaryVariant
                    width: parent.width
                }
                Text {
                    text: control.summary
                    visible: control.summary.length > 0
                    font.pixelSize: 14
                    color: Theme.color.onSurfaceVariantSummary
                    width: parent.width
                }
            }
        }

        Switch {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 49
            Layout.preferredHeight: 28
            checked: control.checked
            toggleOnClick: false
            enabled: control.enabled
            onClicked: {
                control.checked = !control.checked
                control.clicked()
            }
        }
    }
}
