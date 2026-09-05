import QtQuick
import QtQuick.Layouts
import miuix.Core
Item {
    id: control
    property string title: ""
    property string summary: ""
    property string rightText: ""
    property bool enabled: true
    signal clicked()

    anchors.left: parent.left
    anchors.right: parent.right
    height: 56

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: pressArea.pressed ? 0.10 : (pressArea.containsMouse ? 0.06 : 0)
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: pressArea
        anchors.fill: parent
        enabled: control.enabled
        hoverEnabled: true
        onClicked: control.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
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

        Text {
            visible: control.rightText.length > 0
            Layout.alignment: Qt.AlignVCenter
            text: control.rightText
            font.pixelSize: 14
            color: Theme.color.onSurfaceVariantActions
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "chevron_right"
            font.family: Theme.iconFont.name
            font.pixelSize: 18
            color: Theme.color.onSurfaceVariantActions
        }
    }
}
