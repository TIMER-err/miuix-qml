import QtQuick
import miuix.Core

Item {
    id: badgeRoot

    property string text: ""
    property color containerColor: Theme.color.error
    property color contentColor: Theme.color.onError
    default property alias content: contentContainer.data

    readonly property bool _hasContent: text.length > 0 || contentContainer.children.length > 0
    readonly property real _contentWidth: text.length > 0
        ? badgeText.implicitWidth
        : Math.max(0, contentContainer.childrenRect.width)

    implicitWidth: _hasContent ? Math.max(16, _contentWidth + 8) : 6
    implicitHeight: _hasContent ? 16 : 6

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: badgeRoot.containerColor
    }

    Item {
        id: contentContainer
        anchors.fill: parent
        visible: badgeRoot._hasContent
    }

    Text {
        id: badgeText
        anchors.centerIn: parent
        visible: badgeRoot.text.length > 0
        text: badgeRoot.text
        font.family: Theme.typography.labelSmall.family
        font.pixelSize: Theme.typography.labelSmall.size
        font.weight: Theme.typography.labelSmall.weight
        color: badgeRoot.contentColor
    }
}
