import QtQuick
import miuix.Core

Rectangle {
    id: navigationDemo
    width: 1040
    height: 860
    color: Theme.color.surface
    property int section: 0
    property int filter: 0
    Text {
        x: 28
        y: 28
        text: "Navigation & tabs"
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
    TabRowWithContour {
        id: modeTabs
        objectName: "modeTabs"
        x: 28
        y: 90
        width: parent.width - 56
        tabs: ["Icon & text", "Icons only", "Selected label"]
        backgroundColor: Theme.color.secondaryContainer
    }
    NavigationBar {
        id: navigation
        objectName: "navigation"
        y: 160
        width: parent.width
        height: parent.height - y
        mode: modeTabs.selectedTabIndex === 0 ? "iconAndText" : modeTabs.selectedTabIndex === 1 ? "iconOnly" : "iconWithSelectedLabel"
        model: [
            { icon: "home", text: "Home" },
            { icon: "search", text: "Explore" },
            { icon: "favorite", text: "Favorites" },
            { icon: "settings", text: "Settings", enabled: false }
        ]
        Flickable {
            objectName: "homePage"
            clip: true
            contentWidth: width
            contentHeight: examples.height + 32
            flickableDirection: "VerticalFlick"
            Column {
                id: examples
                x: 28
                width: parent.width - 56
                spacing: 18
                SmallTitle { text: "STANDARD TABS"; width: parent.width }
                TabRow {
                    objectName: "categoryTabs"
                    width: parent.width
                    tabs: ["For you", "Following", "Popular", "New releases", "Downloaded", "Podcasts"]
                    selectedTabIndex: navigationDemo.section
                    selectOnClick: false
                    onTabSelected: (index) => { navigationDemo.section = index }
                }
                Text { width: parent.width; text: "Swipe horizontally to browse more categories."; wrapMode: Text.Wrap; font.pixelSize: 14; color: Theme.color.onSurfaceVariantSummary }
                SmallTitle { text: "CONTOUR TABS"; width: parent.width }
                TabRowWithContour {
                    objectName: "filterTabs"
                    width: parent.width
                    tabs: ["All", "Music", "Albums", "Artists"]
                    backgroundColor: Theme.color.secondaryContainer
                    selectedTabIndex: navigationDemo.filter
                    selectOnClick: false
                    onTabSelected: (index) => { navigationDemo.filter = index }
                }
                Card {
                    width: parent.width
                    height: details.height + 32
                    Column {
                        id: details
                        x: 16
                        y: 16
                        width: parent.width - 32
                        spacing: 12
                        Text { width: parent.width; text: "Your collection"; font.pixelSize: 20; font.weight: 57; color: Theme.color.onSurfaceColor }
                        Text { width: parent.width; text: "Category " + (navigationDemo.section + 1) + " · Filter " + (navigationDemo.filter + 1); font.pixelSize: 16; color: Theme.color.onSurfaceSecondary }
                        Text { width: parent.width; text: "Tabs use continuous corners. The bottom navigation changes pages; its selection is shown through icon and label emphasis."; wrapMode: Text.Wrap; font.pixelSize: 16; color: Theme.color.onSurfaceVariantSummary }
                    }
                }
                Button { text: "Reveal last category"; onClicked: navigationDemo.section = 5 }
            }
        }
        Rectangle {
            objectName: "explorePage"
            color: Theme.color.surface
            Text { anchors.centerIn: parent; text: "Explore"; font.pixelSize: 28; color: Theme.color.onSurfaceColor }
        }
        Rectangle {
            objectName: "favoritesPage"
            color: Theme.color.surface
            Text { anchors.centerIn: parent; text: "Favorites"; font.pixelSize: 28; color: Theme.color.onSurfaceColor }
        }
        Item { objectName: "settingsPage" }
    }
}
