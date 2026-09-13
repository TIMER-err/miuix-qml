import QtQuick
import miuix.Core

Rectangle {
    id: showcase
    width: 1040
    height: 900
    color: Theme.color.surface
    property bool wide: width >= 760
    property int buttonCount: 0
    property string feedback: "All changes are local to this preview"

    Item {
        id: header
        width: Math.min(parent.width - 48, 1000)
        height: 110
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            x: 4
            y: 24
            text: "Miuix"
            font.pixelSize: 32
            font.weight: 63
            color: Theme.color.onSurfaceColor
        }
        Text {
            x: 4
            y: 68
            text: "A familiar feel, in every detail."
            font.pixelSize: 14
            color: Theme.color.onSurfaceVariantSummary
        }
        IconButton {
            objectName: "themeToggle"
            anchors.right: parent.right
            y: 31
            icon: Theme.dark ? "light_mode" : "dark_mode"
            onClicked: Theme.dark = !Theme.dark
        }
    }
    Flickable {
        id: viewport
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: parent.width
        contentWidth: width
        contentHeight: body.height + 28
        flickableDirection: "VerticalFlick"
        clip: true

        Column {
            id: body
            width: Math.min(viewport.width - 24, 1024)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            SearchBar {
                width: parent.width - 24
                x: 12
                placeholderText: "Search settings"
                onAccepted: showcase.feedback = text.length > 0 ? "Search: " + text : "Enter a search term"
            }
            Item {
                width: parent.width
                height: showcase.wide ? Math.max(settingsColumn.height, controlsColumn.height)
                    : settingsColumn.height + controlsColumn.height + 8
                Column {
                    id: settingsColumn
                    width: showcase.wide ? (parent.width - 8) / 2 : parent.width
                    SmallTitle { text: "CONNECTIONS"; width: parent.width }
                    Card {
                        x: 12
                        width: parent.width - 24
                        height: connections.height
                        Column {
                            id: connections
                            width: parent.width
                            SuperSwitch {
                                objectName: "wifiPreference"
                                title: "Wi-Fi"
                                summary: checked ? "Connected to Home" : "Not connected"
                                checked: true
                            }
                            SuperSwitch { title: "Bluetooth"; summary: checked ? "Visible to nearby devices" : "Off" }
                            SuperArrow {
                                title: "Mobile network"
                                rightText: "5G"
                                onClicked: showcase.feedback = "Mobile network settings selected"
                            }
                        }
                    }
                    SmallTitle { text: "PERSONALIZATION"; width: parent.width }
                    Card {
                        x: 12
                        width: parent.width - 24
                        height: appearance.height
                        Column {
                            id: appearance
                            width: parent.width
                            SuperDropdown {
                                objectName: "appearancePreference"
                                title: "Appearance"
                                summary: "Choose your preferred color scheme"
                                items: ["Light", "Dark"]
                                currentIndex: Theme.dark ? 1 : 0
                                selectOnClick: false
                                onActivated: Theme.dark = index === 1
                            }
                            SuperArrow { title: "Wallpaper"; rightText: "Default"; onClicked: showcase.feedback = "Wallpaper settings selected" }
                            SuperSwitch {
                                title: "Sync across devices"
                                summary: "Keep your preferences in sync on all devices signed in to your account."
                                checked: true
                            }
                        }
                    }
                    SmallTitle { text: "SOUND & HAPTICS"; width: parent.width }
                    Card {
                        x: 12
                        width: parent.width - 24
                        height: soundContent.height + 32
                        Column {
                            id: soundContent
                            x: 16
                            y: 16
                            width: parent.width - 32
                            spacing: 14
                            Item {
                                width: parent.width
                                height: 24
                                Text { text: "Media volume"; font.pixelSize: 17; color: Theme.color.onBackground }
                                Text {
                                    anchors.right: parent.right
                                    text: Math.round(volumeControl.value) + "%"
                                    font.pixelSize: 14
                                    color: Theme.color.onSurfaceVariantActions
                                }
                            }
                            Slider {
                                id: volumeControl
                                objectName: "volumeControl"
                                width: parent.width
                                from: 0
                                to: 100
                                value: 42
                            }
                            Text {
                                text: "Quiet hours · " + Math.round(quietHours.firstValue) + ":00 – " + Math.round(quietHours.secondValue) + ":00"
                                font.pixelSize: 14
                                color: Theme.color.onSurfaceVariantSummary
                            }
                            Slider {
                                id: quietHours
                                width: parent.width
                                rangeMode: true
                                from: 0
                                to: 24
                                firstValue: 6
                                secondValue: 18
                                stepSize: 3
                                tickMarksEnabled: true
                            }
                        }
                    }
                }
                Column {
                    id: controlsColumn
                    x: showcase.wide ? settingsColumn.width + 8 : 0
                    y: showcase.wide ? 0 : settingsColumn.height + 8
                    width: settingsColumn.width
                    SmallTitle { text: "BUTTONS"; width: parent.width }
                    Card {
                        x: 12
                        width: parent.width - 24
                        height: buttons.height + 32
                        Column {
                            id: buttons
                            x: 16
                            y: 16
                            width: parent.width - 32
                            spacing: 12
                            Row {
                                width: parent.width
                                spacing: 12
                                Button {
                                    width: (parent.width - 12) / 2
                                    text: "Confirm"
                                    onClicked: { showcase.buttonCount += 1; showcase.feedback = "Confirmed " + showcase.buttonCount + " time(s)" }
                                }
                                Button { width: (parent.width - 12) / 2; text: "Cancel"; type: "filledTonal"; onClicked: showcase.feedback = "Canceled" }
                            }
                            Row {
                                width: parent.width
                                spacing: 12
                                Button { width: (parent.width - 12) / 2; text: "Confirm"; enabled: false }
                                Button { width: (parent.width - 12) / 2; text: "Cancel"; type: "filledTonal"; enabled: false }
                            }
                        }
                    }
                    SmallTitle { text: "SELECTION"; width: parent.width }
                    Card {
                        x: 12
                        width: parent.width - 24
                        height: selection.height
                        Column {
                            id: selection
                            width: parent.width
                            SuperCheckbox { title: "Remember me"; summary: "Keep this device signed in"; checked: true }
                            SuperCheckbox { title: "Product updates"; summary: "Get notified when something new arrives" }
                            SuperCheckbox { title: "Managed preference"; summary: "This setting is controlled by your organization"; checked: true; enabled: false }
                            SuperSwitch { title: "Unavailable"; summary: "Disabled switch"; enabled: false }
                        }
                    }
                    SmallTitle { text: "NAVIGATION & ICONS"; width: parent.width }
                    Card {
                        x: 12
                        width: parent.width - 24
                        height: navigation.height + 32
                        Column {
                            id: navigation
                            x: 16
                            y: 16
                            width: parent.width - 32
                            spacing: 16
                            TabRow {
                                width: parent.width
                                tabs: ["Overview", "Activity", "Storage"]
                                backgroundColor: "transparent"
                                selectedBackgroundColor: Theme.color.secondaryVariant
                                onTabSelected: showcase.feedback = "Selected " + tabs[index]
                            }
                            Row {
                                spacing: 12
                                IconButton { icon: "favorite"; type: "filled"; onClicked: showcase.feedback = "Added to favorites" }
                                IconButton { icon: "settings"; onClicked: showcase.feedback = "Settings selected" }
                                IconButton { icon: "mail"; onClicked: showcase.feedback = "No new messages" }
                                IconButton { icon: "search"; onClicked: showcase.feedback = "Search settings above" }
                            }
                            Button {
                                width: parent.width
                                type: "filledTonal"
                                text: "Preview dialog"
                                onClicked: sampleDialog.open()
                            }
                            Text {
                                width: parent.width
                                text: showcase.feedback
                                wrapMode: Text.WordWrap
                                font.pixelSize: 13
                                color: Theme.color.onSurfaceVariantSummary
                            }
                        }
                    }
                }
            }
        }
    }
    Dialog {
        id: sampleDialog
        title: "Reset preferences?"
        text: "Your connection and sound settings will return to their defaults. You can change them again at any time."
        acceptText: "Reset"
        rejectText: "Cancel"
        onAccepted: showcase.feedback = "Preferences reset"
    }
}
