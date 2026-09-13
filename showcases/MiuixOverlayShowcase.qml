import QtQuick
import miuix.Core

Rectangle {
    id: overlayDemo
    width: 1040
    height: 800
    color: Theme.color.surface
    property string result: "Choose a component to preview"
    property string preview: "none"
    onPreviewChanged: {
        if (preview === "dialog") confirmDialog.open()
        if (preview === "longDialog") longDialog.open()
        if (preview === "dropdown") quality.openMenu()
    }
    Text {
        x: 28
        y: 28
        text: "Dialogs & menus"
        font.pixelSize: 28
        font.weight: 63
        color: Theme.color.onBackground
    }
    IconButton {
        x: parent.width - 64
        y: 28
        icon: Theme.dark ? "light_mode" : "dark_mode"
        onClicked: Theme.dark = !Theme.dark
    }
    Column {
        x: 12
        y: 92
        width: parent.width - 24
        spacing: 16
        Card {
            width: parent.width
            height: options.height
            Column {
                id: options
                width: parent.width
                SuperArrow {
                    title: "Confirmation dialog"
                    summary: "Bottom-aligned on phones, centered on large screens"
                    onClicked: confirmDialog.open()
                }
                SuperArrow {
                    title: "Scrollable dialog"
                    summary: "Long content scrolls while actions remain visible"
                    onClicked: longDialog.open()
                }
                SuperDropdown {
                    id: quality
                    objectName: "qualityPreference"
                    title: "Audio quality"
                    summary: "Choose the quality for downloads"
                    currentIndex: 2
                    items: [
                        { text: "Data saver", summary: "Uses less mobile data" },
                        { text: "Balanced", summary: "Recommended for mobile networks" },
                        { text: "High quality", summary: "Best for Wi-Fi downloads" },
                        { text: "Lossless", summary: "Available with a subscription", enabled: false },
                        { text: "Automatic", summary: "Adapts to your connection" },
                        { text: "Custom", summary: "Use a custom bitrate for each download" }
                    ]
                    onActivated: overlayDemo.result = "Selected " + currentValue
                }
            }
        }
        Text { x: 16; width: parent.width - 32; text: overlayDemo.result; wrapMode: Text.Wrap; font.pixelSize: 14; color: Theme.color.onSurfaceVariantSummary }
        SmallTitle { text: "CONTINUOUS CORNERS"; width: parent.width }
        Row {
            x: 16
            spacing: 12
            Button { text: "Primary"; width: 130; onClicked: overlayDemo.result = "Primary pressed" }
            Button { text: "Secondary"; type: "filledTonal"; width: 130; onClicked: overlayDemo.result = "Secondary pressed" }
        }
    }
    Dialog {
        id: confirmDialog
        objectName: "confirmDialog"
        title: "Download over mobile data?"
        text: "This album is 128 MB. You can download it now or wait until you are connected to Wi-Fi."
        acceptText: "Download"
        rejectText: "Not now"
        onAccepted: overlayDemo.result = "Download started"
        onRejected: overlayDemo.result = "Download postponed"
    }
    Dialog {
        id: longDialog
        objectName: "longDialog"
        title: "About your privacy"
        text: "Your preferences stay on this device."
        acceptText: "Got it"
        showRejectButton: false
        Column {
            width: parent.width
            spacing: 16
            Repeater {
                model: 12
                delegate: Text {
                    width: parent.width
                    text: "We use your saved preferences to personalize playback and downloads. You can review or reset these settings at any time."
                    wrapMode: Text.Wrap
                    font.pixelSize: 16
                    color: Theme.color.onSurfaceSecondary
                }
            }
        }
    }
}
