import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import miuix.Core
Item {
    id: control
    property string title: ""
    property string summary: ""
    property var items: []
    property int currentIndex: 0
    property bool enabled: true
    readonly property string currentValue: {
        if (currentIndex < 0 || currentIndex >= items.length) return ""
        var item = items[currentIndex]
        return (typeof item === "string") ? item : (item.text || "")
    }
    signal clicked()
    signal activated(int index)

    anchors.left: parent.left
    anchors.right: parent.right
    height: 56

    property int _count: items.length
    property real _panelWidth: 216
    property real _panelHeight: _count <= 0 ? 0 : (_count * 48 + 16)

    function itemText(item) {
        return (typeof item === "string") ? item : (item.text || "")
    }

    function select(index) {
        control.currentIndex = index
        control.activated(index)
        closeMenu()
    }

    function openMenu() {
        var root = control
        while (root.parent) root = root.parent
        if (!root) return
        overlayLayer.parent = root
        overlayLayer.z = 99999
        overlayLayer.anchors.fill = root
        var pos = root.mapFromItem(control, 0, 0)
        var px = pos.x + control.width - _panelWidth
        var py = pos.y + control.height
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
        onClicked: {
            openMenu()
            control.clicked()
        }
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
            Layout.alignment: Qt.AlignVCenter
            text: control.currentValue
            font.pixelSize: 14
            color: Theme.color.onSurfaceVariantActions
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: "unfold_more"
            font.family: Theme.iconFont.name
            font.pixelSize: 16
            color: Theme.color.onSurfaceVariantActions
        }
    }

    Item {
        id: overlayLayer
        visible: false

        MouseArea {
            anchors.fill: parent
            z: -1
            onPressed: control.closeMenu()
        }

        Item {
            id: popupContainer
            width: control._panelWidth
            height: control._panelHeight
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
                    overlayLayer.parent = control
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
                        model: control.items
                        delegate: Item {
                            width: list.width
                            height: 48
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                x: 20
                                text: control.itemText(modelData)
                                font.pixelSize: 17
                                color: index === control.currentIndex ? Theme.color.primary : Theme.color.onSurfaceContainer
                            }
                            Text {
                                visible: index === control.currentIndex
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
                                onClicked: control.select(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
