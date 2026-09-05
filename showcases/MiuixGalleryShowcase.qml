import QtQuick
import miuix.Core

Scaffold {
    id: root
    x: 0
    y: 0
    containerColor: Theme.color.surface

    property int taps: 0

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
        interactive: !volumeSlider.pressed

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
