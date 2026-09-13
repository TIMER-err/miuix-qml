import QtQuick
import miuix.Core

Rectangle {
    id: railDemo
    width: 1040
    height: 800
    color: Theme.color.surface
    property int notifications: 7
    property string selection: "Home"
    NavigationRail {
        id: rail
        objectName: "showcaseRail"
        height: parent.height
        extended: railDemo.width >= 760
        sectionLabel: "LIBRARY"
        model: [
            { icon: "home", text: "Home" },
            { icon: "search", text: "Explore", badge: "" },
            { icon: "favorite", text: "Favorites", badge: String(railDemo.notifications) },
            { icon: "download", text: "Downloads", badge: "99+" },
            { icon: "queue_music", text: "Playlists" },
            { icon: "folder", text: "Local folders" },
            { icon: "cloud", text: "Cloud library", enabled: false },
            { icon: "settings", text: "Settings" }
        ]
        onItemClicked: (index, itemData) => { railDemo.selection = itemData.text }
        header: Component {
            Item {
                implicitHeight: 28
                Text { anchors.centerIn: parent; text: "MIUIX"; font.pixelSize: 17; font.weight: 63; color: Theme.color.onSurfaceColor }
            }
        }
        footer: Component {
            Item {
                implicitHeight: 64
                IconButton {
                    anchors.centerIn: parent
                    icon: Theme.dark ? "light_mode" : "dark_mode"
                    onClicked: Theme.dark = !Theme.dark
                }
            }
        }
    }
    Text {
        x: rail.width + 24
        y: 28
        text: "Rail & badges"
        font.pixelSize: 26
        font.weight: 63
        color: Theme.color.onSurfaceColor
    }
    Flickable {
        x: rail.width + 24
        y: 92
        width: Math.max(0, parent.width - x - 24)
        height: parent.height - y - 24
        contentWidth: width
        contentHeight: examples.height
        flickableDirection: "VerticalFlick"
        clip: true
        Column {
            id: examples
            width: parent.width
            spacing: 20
            Text { text: railDemo.selection; width: parent.width; font.pixelSize: 20; font.weight: 57; color: Theme.color.onSurfaceColor }
            Text { text: "Expand or collapse the sidebar using its top button. Long menus scroll while the theme action stays at the bottom."; width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 16; color: Theme.color.onSurfaceVariantSummary }
            Button { text: rail.expandable ? "Use classic rail" : "Use expandable rail"; onClicked: rail.expandable = !rail.expandable }
            SmallTitle { text: "BADGES"; width: parent.width }
            Row {
                spacing: 20
                BadgedBox {
                    width: 40; height: 40
                    Icon { width: 40; height: 40; name: "notifications" }
                    badge: Component { Badge {} }
                }
                BadgedBox {
                    width: 40; height: 40
                    Icon { width: 40; height: 40; name: "mail" }
                    badge: Component { Badge { text: String(railDemo.notifications) } }
                }
                BadgedBox {
                    width: 40; height: 40
                    Icon { width: 40; height: 40; name: "download" }
                    badge: Component { Badge { text: "99+" } }
                }
            }
            Button { text: "Add notification"; onClicked: railDemo.notifications += 1 }
            Text { text: "Dot badges are 6 px. Number badges start at 16 px and grow to fit their content. Navigation badges stay inside their item bounds."; width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 16; color: Theme.color.onSurfaceVariantSummary }
            NavigationBar {
                width: parent.width
                height: 100
                model: [{icon: "home", text: "Home"}, {icon: "mail", text: "Inbox", badge: String(railDemo.notifications)}, {icon: "download", text: "Downloads", badge: "99+"}]
            }
        }
    }
}
