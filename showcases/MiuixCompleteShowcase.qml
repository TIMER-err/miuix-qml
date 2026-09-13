import QtQuick
import miuix.Core

Rectangle {
    id: app
    width: 1040
    height: 860
    color: Theme.color.surface
    property bool wide: width >= 760
    property string selectedSeed: "#109868"
    property string status: "Your preferences are up to date"
    Component.onCompleted: { Theme.dynamicColors = true; Theme.setSeedColor(selectedSeed) }
    onSelectedSeedChanged: Theme.setSeedColor(selectedSeed)

    TopAppBar {
        id: topBar
        title: "Personalization"
        subtitle: "Make yourself at home"
        showNavigationIcon: false
        scrollOffset: page.scrollOffset
        IconButton { icon: "dark_mode"; onClicked: Theme.setDark(!Theme.dark) }
        IconButton { id: help; icon: "help"; onClicked: hint.open() }
    }
    PullToRefresh {
        id: page
        x: 0; y: topBar.height
        width: app.width
        height: app.height - y
        contentHeight: columns.height + 48
        onRefreshRequested: { refreshing = true; refreshTimer.restart() }
        Item {
            id: columns
            x: 24; y: 16
            width: page.width - 48
            height: app.wide ? Math.max(left.height, right.height) : left.height + right.height + 24
            Column {
                id: left
                width: app.wide ? (columns.width - 24) / 2 : columns.width
                spacing: 16
                SmallTitle { text: "COLOR & APPEARANCE" }
                Card {
                    width: parent.width
                    height: appearance.height
                    Column {
                        id: appearance
                        width: parent.width
                        SuperSwitch { title: "Monet colors"; summary: "A palette inspired by your favorite color"; checked: Theme.dynamicColors; onClicked: Theme.dynamicColors = checked }
                        SuperSwitch { title: "Dark appearance"; checked: Theme.dark; onClicked: Theme.setDark(checked) }
                        Item {
                            width: parent.width; height: 64
                            Row {
                                x: 16; y: 8; spacing: 12
                                Repeater {
                                    model: ["#109868", "#6750A4", "#DE6937", "#3482FF"]
                                    delegate: Rectangle {
                                        width: 40; height: 40; radius: 20; color: modelData
                                        border.width: app.selectedSeed === modelData ? 3 : 0
                                        border.color: Theme.color.onSurfaceColor
                                        Ripple { anchors.fill: parent; clipRadius: 20; onClicked: app.selectedSeed = modelData }
                                    }
                                }
                            }
                        }
                        Item {
                            width: parent.width; height: picker.implicitHeight + 32
                            ColorPicker {
                                id: picker
                                x: 16; y: 16; width: parent.width - 32
                                color: app.selectedSeed
                                onColorSelected: (newColor) => app.selectedSeed = String(newColor)
                            }
                        }
                    }
                }
                SmallTitle { text: "ACTIONS & FEEDBACK" }
                Card {
                    width: parent.width
                    height: actions.height + 32
                    Column {
                        id: actions
                        x: 16; y: 16; width: parent.width - 32; spacing: 16
                        Button { text: "Save preferences"; onClicked: { notice.text = "Your preferences have been saved"; notice.open() } }
                        Row {
                            spacing: 16
                            FAB { icon: "add"; onClicked: { notice.text = "A new collection is ready"; notice.open() } }
                            FloatingToolbar {
                                Row {
                                    IconButton { icon: "favorite"; onClicked: { notice.text = "Added to favorites"; notice.open() } }
                                    IconButton { icon: "share"; onClicked: hint.open() }
                                    IconButton { id: menuAnchor; icon: "more_horiz"; onClicked: options.open(menuAnchor, 0, menuAnchor.height) }
                                }
                            }
                        }
                    }
                }
            }
            Column {
                id: right
                x: app.wide ? left.width + 24 : 0
                y: app.wide ? 0 : left.height + 24
                width: left.width
                spacing: 16
                SmallTitle { text: "PROGRESS & SELECTION" }
                Card {
                    width: parent.width
                    height: progressControls.height + 32
                    Column {
                        id: progressControls
                        x: 16; y: 16; width: parent.width - 32; spacing: 18
                        Text { text: app.status; width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 16; color: Theme.color.onSurfaceColor }
                        LinearProgress { width: parent.width; value: 0.62 }
                        LinearProgress { width: parent.width; indeterminate: true }
                        Row {
                            spacing: 24
                            CircularProgress { value: 0.7 }
                            CircularProgress { indeterminate: true }
                            LoadingIndicator { y: 5 }
                        }
                        Divider { width: parent.width }
                        Row {
                            spacing: 24
                            NumberPicker { width: 76; range: [0, 23]; value: 9 }
                            NumberPicker { width: 76; range: [0, 59]; value: 41; wrapAround: true; label: function(value) { return value < 10 ? "0" + value : String(value) } }
                        }
                    }
                }
                SmallTitle { text: "YOUR PALETTE" }
                Card {
                    width: parent.width; height: palette.implicitHeight + 32
                    ColorPalette { id: palette; x: 16; y: 16; width: parent.width - 32; color: app.selectedSeed; onColorSelected: (newColor) => app.selectedSeed = String(newColor) }
                }
                Text {
                    text: "Pull down to refresh. Your content stays interactive while browsing."
                    width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 14; color: Theme.color.onSurfaceVariantSummary
                }
            }
        }
    }
    Timer {
        id: refreshTimer; interval: 1800
        onTriggered: { app.status = "Everything is up to date"; page.refreshing = false }
    }
    Snackbar { id: notice; actionText: "Undo"; onActionClicked: app.status = "Previous preferences restored" }
    ToolTip { id: hint; anchorItem: help; title: "Your own colors"; text: "Choose a color to update the entire palette. Try dark appearance to see the matching night colors."; timeout: 5000 }
    Menu {
        id: options
        model: [
            {text: "Reset color", action: function() { app.selectedSeed = "#3482FF" }},
            {text: "Appearance", subItems: [
                {text: "Light", action: function() { Theme.setDark(false) }},
                {text: "Dark", action: function() { Theme.setDark(true) }}
            ]},
            {type: "separator"},
            {text: "Unavailable action", enabled: false}
        ]
    }
}
