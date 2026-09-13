import QtQuick
import miuix.Core

Rectangle {
    id: inputDemo
    width: 1040
    height: 860
    color: Theme.color.surface
    property int selected: 1
    property bool focusPreview: false
    onFocusPreviewChanged: if (focusPreview) nameField.focusInput()
    Text {
        x: 28
        y: 28
        text: "Inputs & selection"
        font.pixelSize: 28
        font.weight: 63
        color: Theme.color.onSurfaceColor
    }
    IconButton {
        x: parent.width - 64
        y: 28
        icon: Theme.dark ? "light_mode" : "dark_mode"
        onClicked: Theme.dark = !Theme.dark
    }
    Flickable {
        y: 92
        width: parent.width
        height: parent.height - y
        contentWidth: width
        contentHeight: Math.max(fields.y + fields.height, states.y + states.height) + 24
        clip: true
        flickableDirection: "VerticalFlick"
        Column {
            id: fields
            x: 28
            width: inputDemo.width >= 760 ? (inputDemo.width - 84) / 2 : inputDemo.width - 56
            spacing: 16
            SmallTitle { text: "TEXT FIELDS"; width: parent.width }
            TextField {
                id: nameField
                objectName: "nameField"
                width: parent.width
                label: "Display name"
                supportingText: "The label stays inside the field when you type."
            }
            TextField { width: parent.width; label: "Email address"; text: "hello@example.com" }
            TextField { width: parent.width; label: "Search your library"; useLabelAsPlaceholder: true; leadingIcon: "search" }
            TextField { width: parent.width; label: "Password"; text: "miuix-qml"; isPassword: true }
            TextField { width: parent.width; label: "Download folder"; text: "/Music/Downloads"; readOnly: true; supportingText: "Read-only values can be selected and copied." }
            TextField { width: parent.width; label: "Account"; text: "Unavailable"; enabled: false }
        }
        Column {
            id: states
            x: inputDemo.width >= 760 ? fields.x + fields.width + 28 : 28
            y: inputDemo.width >= 760 ? 0 : fields.height + 24
            width: fields.width
            spacing: 16
            SmallTitle { text: "VALIDATION & OPTIONS"; width: parent.width }
            TextField {
                width: parent.width
                label: "Email address"
                text: "hello@"
                errorText: "Enter a complete email address to continue."
            }
            TextField { width: parent.width; label: "Optional note"; type: "outlined"; supportingText: "An optional outline is available for existing integrations." }
            SmallTitle { text: "DOWNLOAD QUALITY"; width: parent.width }
            Card {
                width: parent.width
                height: choices.height + 32
                Column {
                    id: choices
                    x: 16
                    y: 16
                    width: parent.width - 32
                    spacing: 20
                    RadioButton { width: parent.width; text: "Data saver"; checked: inputDemo.selected === 0; onClicked: inputDemo.selected = 0 }
                    RadioButton { width: parent.width; text: "High quality"; checked: inputDemo.selected === 1; onClicked: inputDemo.selected = 1 }
                    RadioButton { width: parent.width; text: "Automatic quality based on your connection"; checked: inputDemo.selected === 2; onClicked: inputDemo.selected = 2 }
                    RadioButton { width: parent.width; text: "Lossless (unavailable)"; checked: true; enabled: false }
                }
            }
            Text { width: parent.width; text: "Choose one option. The checkmark follows your selection."; wrapMode: Text.Wrap; font.pixelSize: 14; color: Theme.color.onSurfaceVariantSummary }
        }
    }
}
