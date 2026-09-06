import QtQuick
import miuix.Core

Item {
    id: tabRowRoot

    property var tabs: []
    property int selectedTabIndex: 0
    property bool contour: false
    property real minWidth: contour ? 62 : 76
    property real maxWidth: contour ? 84 : 98
    property real itemSpacing: contour ? 5 : 9
    property real cornerRadius: contour ? 8 : 12
    property color backgroundColor: Theme.color.surface
    property color contentColor: Theme.color.onSurfaceVariantSummary
    property color selectedBackgroundColor: Theme.color.surfaceContainer
    property color selectedContentColor: Theme.color.onBackground
    property bool selectOnClick: true
    signal tabSelected(int index)

    readonly property real _contourPadding: contour ? 5 : 0
    readonly property real _tabWidth: _calculateTabWidth()
    readonly property real _tabsWidth: tabs.length > 0
        ? tabs.length * _tabWidth + (tabs.length - 1) * itemSpacing
        : 0

    implicitWidth: 320
    implicitHeight: contour ? 45 : 42

    function _calculateTabWidth() {
        var count = tabs.length
        if (count === 0) return minWidth
        var available = Math.max(0, width - _contourPadding * 2)
        var contentWidth = available - (count - 1) * itemSpacing
        if (contentWidth <= 0) return minWidth
        var ideal = contentWidth / count
        if (ideal < minWidth) return minWidth
        if (ideal > maxWidth) {
            var totalMax = maxWidth * count + (count - 1) * itemSpacing
            return totalMax < available ? ideal : maxWidth
        }
        return ideal
    }

    function _select(index) {
        if (selectOnClick) selectedTabIndex = index
        tabSelected(index)
        _ensureSelected()
    }

    function _ensureSelected() {
        if (tabs.length === 0) return
        var index = Math.max(0, Math.min(selectedTabIndex, tabs.length - 1))
        var target = _contourPadding + index * (_tabWidth + itemSpacing)
            - (width - _tabWidth) / 2
        var maxScroll = Math.max(0, viewport.contentWidth - viewport.width)
        viewport.contentX = Math.max(0, Math.min(maxScroll, target))
    }

    onSelectedTabIndexChanged: _ensureSelected()
    onWidthChanged: settleTimer.restart()
    onTabsChanged: settleTimer.restart()

    Rectangle {
        anchors.fill: parent
        radius: tabRowRoot.contour ? tabRowRoot.cornerRadius + tabRowRoot._contourPadding : 0
        color: tabRowRoot.backgroundColor
    }

    Flickable {
        id: viewport
        anchors.fill: parent
        clip: true
        interactive: contentWidth > width
        contentWidth: Math.max(width, tabRowRoot._tabsWidth + tabRowRoot._contourPadding * 2)
        contentHeight: height

        Item {
            id: tabContent
            x: 0
            y: tabRowRoot._contourPadding
            width: viewport.contentWidth
            height: Math.max(0, viewport.height - tabRowRoot._contourPadding * 2)

            Rectangle {
                x: tabRowRoot._contourPadding
                    + tabRowRoot.selectedTabIndex * (tabRowRoot._tabWidth + tabRowRoot.itemSpacing)
                y: 0
                width: tabRowRoot._tabWidth
                height: parent.height
                radius: tabRowRoot.cornerRadius
                color: tabRowRoot.selectedBackgroundColor
                Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InOutSine } }
            }

            Row {
                id: tabsRow
                x: tabRowRoot._contourPadding
                width: tabRowRoot._tabsWidth
                height: parent.height
                spacing: tabRowRoot.itemSpacing

                Repeater {
                    model: tabRowRoot.tabs
                    delegate: Item {
                        width: tabRowRoot._tabWidth
                        height: tabsRow.height

                        Rectangle {
                            anchors.fill: parent
                            radius: tabRowRoot.cornerRadius
                            color: "transparent"
                            border.width: tabRowRoot.contour || index === tabRowRoot.selectedTabIndex ? 0 : 1
                            border.color: Theme.color.outline
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Theme.typography.bodyMedium.family
                            font.pixelSize: Theme.typography.bodyMedium.size
                            font.weight: index === tabRowRoot.selectedTabIndex ? Font.Bold : Font.Normal
                            color: index === tabRowRoot.selectedTabIndex
                                ? tabRowRoot.selectedContentColor : tabRowRoot.contentColor
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: tabRowRoot._select(index)
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: settleTimer
        interval: 40
        repeat: false
        onTriggered: tabRowRoot._ensureSelected()
    }
}
