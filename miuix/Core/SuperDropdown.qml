import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import miuix.Core
Item {
    id: superDropdownRoot
    property string title: ""
    property string summary: ""
    property var items: []
    property int currentIndex: 0
    property bool enabled: true
    property bool selectOnClick: true
    readonly property bool menuOpen: overlayLayer.visible
    readonly property string currentValue: {
        if (currentIndex < 0 || currentIndex >= items.length) return ""
        var item = items[currentIndex]
        return (typeof item === "string") ? item : (item.text || "")
    }
    signal clicked()
    signal activated(int index)

    width: parent ? parent.width : 320
    implicitHeight: preference.implicitHeight

    property int _count: items.length
    property real _panelWidth: 216
    property real _panelHeight: _count <= 0 ? 0 : (_count * 48 + 16)

    function itemText(item) {
        return (typeof item === "string") ? item : (item.text || "")
    }

    function select(index) {
        if (!superDropdownRoot.enabled || index < 0 || index >= superDropdownRoot.items.length) return
        if (superDropdownRoot.selectOnClick) superDropdownRoot.currentIndex = index
        superDropdownRoot.activated(index)
        closeMenu()
    }

    function openMenu() {
        if (!superDropdownRoot.enabled || superDropdownRoot.items.length === 0) return
        var root = superDropdownRoot
        while (root.parent) root = root.parent
        if (!root) return
        overlayLayer.parent = root
        overlayLayer.z = 99999
        overlayLayer.anchors.fill = root
        var pos = root.mapFromItem(superDropdownRoot, 0, 0)
        var px = pos.x + superDropdownRoot.width - _panelWidth
        var py = pos.y + superDropdownRoot.height
        if (px < 8) px = 8
        if (px + _panelWidth > root.width - 8) px = root.width - _panelWidth - 8
        if (py + _panelHeight > root.height - 8) py = pos.y - _panelHeight
        if (py < 8) py = 8
        popupContainer.x = px
        popupContainer.y = py
        exitAnim.stop()
        enterAnim.stop()
        popupContainer.scale = 0.8
        popupContainer.opacity = 0
        overlayLayer.visible = true
        enterAnim.start()
    }

    function closeMenu() {
        enterAnim.stop()
        exitAnim.start()
    }

    SuperArrow {
        id: preference
        anchors.fill: parent
        title: superDropdownRoot.title
        summary: superDropdownRoot.summary
        rightText: superDropdownRoot.currentValue
        indicator: "unfold_more"
        enabled: superDropdownRoot.enabled
        onClicked: {
            superDropdownRoot.openMenu()
            superDropdownRoot.clicked()
        }
    }

    Item {
        id: overlayLayer
        visible: false

        MouseArea {
            anchors.fill: parent
            z: -1
            onPressed: superDropdownRoot.closeMenu()
        }

        Item {
            id: popupContainer
            width: superDropdownRoot._panelWidth
            height: superDropdownRoot._panelHeight
            scale: 0.8
            opacity: 0
            transformOrigin: Item.TopRight

            ParallelAnimation {
                id: enterAnim
                NumberAnimation { target: popupContainer; property: "scale"; from: 0.8; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { target: popupContainer; property: "opacity"; from: 0; to: 1; duration: 150 }
            }
            ParallelAnimation {
                id: exitAnim
                onFinished: {
                    overlayLayer.visible = false
                    overlayLayer.parent = superDropdownRoot
                }
                NumberAnimation { target: popupContainer; property: "opacity"; from: 1; to: 0; duration: 150 }
                NumberAnimation { target: popupContainer; property: "scale"; from: 1; to: 0.8; duration: 150; easing.type: Easing.InCubic }
            }

            Rectangle {
                id: shadowSource
                anchors.fill: parent
                radius: 16
                color: Theme.color.surfaceContainer
                visible: false
            }
            MultiEffect {
                anchors.fill: shadowSource
                source: shadowSource
                shadowEnabled: true
                shadowColor: Theme.color.shadow
                shadowBlur: 1.0
                shadowVerticalOffset: 6
                shadowOpacity: 0.2
            }
            Rectangle {
                id: menuBackground
                z: 1
                anchors.fill: parent
                radius: 16
                color: Theme.color.surfaceContainer
                clip: true

                Column {
                    id: list
                    width: parent.width
                    y: 8
                    Repeater {
                        model: superDropdownRoot.items
                        delegate: Item {
                            width: list.width
                            height: 48
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                x: 20
                                text: superDropdownRoot.itemText(modelData)
                                font.pixelSize: 17
                                color: index === superDropdownRoot.currentIndex ? Theme.color.primary : Theme.color.onSurfaceContainer
                            }
                            Text {
                                visible: index === superDropdownRoot.currentIndex
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                text: "check"
                                font.family: Theme.iconFont.name
                                font.pixelSize: 20
                                color: Theme.color.primary
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: superDropdownRoot.select(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
