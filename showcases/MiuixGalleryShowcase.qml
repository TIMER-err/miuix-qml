import QtQuick
import miuix.Core

Scaffold {
    id: root
    x: 0
    y: 0
    containerColor: Theme.color.surface

    property int taps: 0
    property int tabIndex: 0
    property int contourTabIndex: 0
    property int hourValue: 16
    property int minuteValue: 30
    property color pickedColor: Theme.color.primary
    property color paletteColor: Theme.color.primary

    function rgbaText(value) {
        return "RGBA: " + Math.round(value.r * 255) + ", " + Math.round(value.g * 255)
            + ", " + Math.round(value.b * 255) + ", " + (Math.round(value.a * 100) / 100)
    }

    topBar: Component {
        TopAppBar {
            title: "MIUIX"
            showNavigationIcon: false
        }
    }

    floatingActionButton: Component {
        FAB { icon: "add" }
    }

    Flickable {
        id: scroller
        anchors.fill: parent
        anchors.topMargin: root.contentTopPadding
        anchors.bottomMargin: root.contentBottomPadding
        contentWidth: width
        contentHeight: col.height + 24
        clip: true
        flickableDirection: "VerticalFlick"
        // No `interactive: !slider.pressed` workaround: Slider now waits for a
        // horizontal drag, so the Flickable can steal a vertical one from it.

        Column {
            id: col
            x: 0
            y: 0
            width: root.width
            spacing: 0

            Item { width: 1; height: 8 }

            SearchBar {
                width: parent.width - 24
                height: 45
                x: 12
                placeholderText: "Search"
            }

            SmallTitle { text: "Network"; width: parent.width }

            Card {
                x: 12
                width: parent.width - 24
                height: 112
                SuperSwitch {
                    id: wifiSwitch
                    title: "Wi-Fi"
                    summary: "Connected to Home"
                    checked: true
                }
                SuperSwitch {
                    id: btSwitch
                    y: 56
                    title: "Bluetooth"
                    checked: false
                }
            }

            SmallTitle { text: "Badge"; width: parent.width }

            // The badge hangs above the anchor's top edge, so the row needs headroom.
            Item { width: 1; height: 10 }

            Row {
                x: 16
                width: parent.width - 32
                spacing: 24

                BadgedBox {
                    width: 40
                    height: 40
                    badge: Component { Badge {} }
                    IconButton { anchors.fill: parent; icon: "chat"; type: "standard" }
                }

                BadgedBox {
                    width: 40
                    height: 40
                    badge: Component { Badge { text: "8" } }
                    IconButton { anchors.fill: parent; icon: "mail"; type: "standard" }
                }

                BadgedBox {
                    width: 40
                    height: 40
                    badge: Component { Badge { text: "99+" } }
                    IconButton { anchors.fill: parent; icon: "settings"; type: "standard" }
                }

                BadgedBox {
                    width: 40
                    height: 40
                    badge: Component { Badge { text: "5" } }
                    IconButton { anchors.fill: parent; icon: "favorite"; type: "standard" }
                }
            }

            SmallTitle { text: "Controls"; width: parent.width }

            Card {
                x: 12
                width: parent.width - 24
                height: 280
                SuperArrow {
                    id: aboutRow
                    title: "About"
                    summary: "Version 0.9.3"
                }
                Divider { y: 56; width: parent.width - 32; x: 16 }
                SuperCheckbox {
                    id: rememberRow
                    y: 57
                    title: "Remember me"
                    summary: "Keep signed in"
                    checked: true
                }
                Divider { y: 113; width: parent.width - 32; x: 16 }
                SuperDropdown {
                    id: darkRow
                    y: 114
                    title: "Dark mode"
                    items: ["System", "Light", "Dark"]
                    currentIndex: 1
                }
                Row {
                    y: 178
                    x: 16
                    spacing: 12
                    Button { type: "filled"; text: "OK"; width: 96; height: 40 }
                    Button { type: "filledTonal"; text: "Cancel"; width: 96; height: 40 }
                }
                Slider {
                    id: volumeSlider
                    y: 230
                    x: 16
                    width: parent.width - 32
                    height: 28
                    from: 0
                    to: 100
                    value: 42
                }
            }

            SmallTitle { text: "Surface"; width: parent.width }

            Row {
                x: 16
                width: parent.width - 32
                spacing: 12

                Surface {
                    width: (parent.width - 24) / 3
                    height: 64
                    radius: 16
                    color: Theme.color.surfaceContainer
                    Text {
                        anchors.centerIn: parent
                        text: "plain"
                        font.pixelSize: 14
                        color: Theme.color.onSurfaceContainer
                    }
                }

                Surface {
                    width: (parent.width - 24) / 3
                    height: 64
                    radius: 16
                    color: Theme.color.surfaceContainer
                    borderWidth: 1
                    borderColor: Theme.color.outline
                    Text {
                        anchors.centerIn: parent
                        text: "border"
                        font.pixelSize: 14
                        color: Theme.color.onSurfaceContainer
                    }
                }

                Surface {
                    width: (parent.width - 24) / 3
                    height: 64
                    radius: 16
                    color: Theme.color.surfaceContainer
                    shadowElevation: 4
                    clickable: true
                    onClicked: root.taps = root.taps + 1
                    Text {
                        anchors.centerIn: parent
                        text: "taps " + root.taps
                        font.pixelSize: 14
                        color: Theme.color.onSurfaceContainer
                    }
                }
            }

            SmallTitle { text: "FloatingToolbar"; width: parent.width }

            FloatingToolbar {
                x: 16
                width: parent.width - 32
                // Capsule = height - 2 * outSidePaddingVertical, so 72 leaves a
                // 56dp bar with 8dp of breathing room around the 40dp buttons.
                height: 72
                showDivider: true
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    IconButton { width: 40; height: 40; icon: "format_bold"; type: "standard" }
                    IconButton { width: 40; height: 40; icon: "format_italic"; type: "standard" }
                    IconButton { width: 40; height: 40; icon: "link"; type: "standard" }
                    IconButton { width: 40; height: 40; icon: "more_horiz"; type: "standard" }
                }
            }

            SmallTitle { text: "TabRow"; width: parent.width }

            TabRow {
                x: 12
                width: parent.width - 24
                tabs: ["Tab 1", "Tab 2", "Tab 3"]
                selectedTabIndex: root.tabIndex
                onTabSelected: root.tabIndex = index
            }

            Item { width: 1; height: 8 }

            TabRowWithContour {
                x: 12
                width: parent.width - 24
                tabs: ["One", "Two", "Three", "Four", "Five", "Six"]
                selectedTabIndex: root.contourTabIndex
                onTabSelected: root.contourTabIndex = index
            }

            SmallTitle { text: "NumberPicker"; width: parent.width }

            Card {
                x: 12
                width: parent.width - 24
                height: 248
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    // One-way on purpose: binding `value` back to a property the
                    // handler also writes makes the two fight.
                    NumberPicker {
                        width: 80
                        height: 225
                        range: [0, 23]
                        value: 16
                        wrapAround: true
                        label: function(value) { return value < 10 ? "0" + value : "" + value }
                        onValueChanged: root.hourValue = value
                    }
                    Text {
                        text: ":"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: Theme.color.onSurfaceColor
                    }
                    NumberPicker {
                        width: 80
                        height: 225
                        range: [0, 59]
                        value: 30
                        wrapAround: true
                        label: function(value) { return value < 10 ? "0" + value : "" + value }
                        onValueChanged: root.minuteValue = value
                    }
                }
            }

            SmallTitle { text: "ColorPicker"; width: parent.width }

            // Deliberately not inside a Card: Card clips through a layer effect,
            // which is one of the things being ruled out for the color controls.
            Text {
                x: 16
                text: root.rgbaText(root.pickedColor)
                font.pixelSize: 14
                color: Theme.color.onBackground
            }

            Item { width: 1; height: 8 }

            ColorPicker {
                x: 16
                width: parent.width - 32
                color: Theme.color.primary
                onColorSelected: (newColor) => root.pickedColor = newColor
            }

            SmallTitle { text: "ColorPalette"; width: parent.width }

            Text {
                x: 16
                text: root.rgbaText(root.paletteColor)
                font.pixelSize: 14
                color: Theme.color.onBackground
            }

            Item { width: 1; height: 8 }

            ColorPalette {
                x: 16
                width: parent.width - 32
                color: Theme.color.primary
                onColorSelected: (newColor) => root.paletteColor = newColor
            }

            SmallTitle { text: "Buttons"; width: parent.width }

            Row {
                x: 16
                spacing: 16
                IconButton { width: 40; height: 40; icon: "favorite"; type: "filled" }
                IconButton { width: 40; height: 40; icon: "settings"; type: "standard" }
                IconButton { width: 40; height: 40; icon: "search"; type: "outlined" }
                FAB { width: 60; height: 60; icon: "add" }
            }

            Item { width: 1; height: 24 }
        }
    }
}
