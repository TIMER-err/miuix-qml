import QtQuick
import QtQuick.Layouts
import miuix.Core
Rectangle {
    id: root

    property string title: "Title"
    property bool showNavigationIcon: true
    property alias navigationIcon: navIcon
    default property alias actions: actionsLayout.data
    signal navigationIconClicked()

    implicitWidth: parent ? parent.width : 640
    implicitHeight: 52
    color: Theme.color.surface

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        IconButton {
            id: navIcon
            icon: "arrow_back"
            visible: root.showNavigationIcon
            type: "standard"
            onClicked: root.navigationIconClicked()
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            font.family: Theme.typography.headlineSmall.family
            font.pixelSize: 20
            font.weight: 57
            color: Theme.color.onSurfaceColor
            elide: Text.ElideRight
        }

        RowLayout {
            id: actionsLayout
            Layout.fillHeight: true
            spacing: 0
        }
    }
}
