package io.github.timer_err.qml4j.demo;

import io.github.timer_err.qml4j.render.QmlView;
import io.github.timer_err.qml4j.render.items.core.Item;
import io.github.timer_err.qml4j.runtime.color.StyleManager;
import java.nio.file.Files;
import java.nio.file.Path;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

import static io.github.timer_err.qml4j.demo.MiuixChecks.*;

/** Rail expansion, badge bounds and desktop/phone preview checks. */
final class MiuixRailChecks {
    static void run(Path project, Path output) throws Exception {
        ((StyleManager) StyleManager.__instance()).isDarkTheme.set(false);
        expansion();
        scrolling();
        customSlots();
        badges(output);
        previews(project);
    }

    private static QmlView railScene(int height) {
        return scene("NavigationRail { height: " + height + "; property int clicks: 0; property int choice: -1;"
            + " model: [{icon: \"home\", text: \"Home\"}, {icon: \"search\", text: \"Explore your collection\"}, {icon: \"settings\", text: \"Settings\", enabled: false}];"
            + " onItemClicked: (index, itemData) => { clicks += 1; choice = index }"
            + " footer: Component { Item { implicitHeight: 40 } } }");
    }

    private static void expansion() throws Exception {
        QmlView view = railScene(480);
        try {
            check(view.root().width.peekDouble() == 80, "rail starts at collapsed width");
            Item toggle = view.findByObjectName("miuixRailToggle");
            click(view, coordinate(toggle, true) + 28, coordinate(toggle, false) + 28);
            render(view, 240, 480, null);
            check(view.root().width.peekDouble() == 240, "built-in rail toggle expands to 240 px");
            Item icon = view.findByObjectName("miuixRailIcon1");
            Item label = view.findByObjectName("miuixRailLabel1");
            Item item = view.findByObjectName("miuixRailItem1");
            Item indicator = view.findByObjectName("miuixRailIndicator1");
            check(icon.width.peekDouble() == 28 && label.x.peekDouble() == 70, "expanded rail uses upstream icon size and label inset");
            check(label.x.peekDouble() + label.width.peekDouble() <= item.width.peekDouble() - 26, "long expanded label stays within content padding");
            check(indicator.height.peekDouble() == 56 && indicator.width.peekDouble() == item.width.peekDouble() - 24, "expanded indicator fits item margins");
            click(view, coordinate(label, true) + 20, coordinate(label, false) + 8);
            check(number(view.root(), "currentIndex") == 1 && number(view.root(), "clicks") == 1, "rail label selects once");
            set(view.root(), "selectOnClick", false);
            click(view, 40, coordinate(view.findByObjectName("miuixRailItem0"), false) + 28);
            check(number(view.root(), "currentIndex") == 1 && number(view.root(), "choice") == 0, "controlled rail reports intent without changing index");
            click(view, 40, coordinate(view.findByObjectName("miuixRailItem2"), false) + 28);
            check(number(view.root(), "clicks") == 2, "disabled rail entry ignores click");
            set(view.root(), "expandedWidth", 40);
            render(view, 240, 480, null);
            check(view.root().width.peekDouble() == 80, "expanded width cannot undercut collapsed minimum");
            set(view.root(), "expandable", false);
            render(view, 80, 480, null);
            check(view.root().width.peekDouble() == 80 && "transparent".equals(get(indicator, "color")), "classic rail has no selection pill");
        } finally { view.dispose(); }
    }

    private static void scrolling() throws Exception {
        QmlView view = railScene(230);
        try {
            Item viewport = view.findByObjectName("miuixRailViewport");
            Item footer = view.findByObjectName("miuixRailFooter");
            double footerY = footer.y.peekDouble();
            check(number(viewport, "contentHeight") > viewport.height.peekDouble(), "short rail scrolls menu content");
            drag(view, 40, 160, 40, 40);
            check(number(viewport, "contentY") > 0 && footer.y.peekDouble() == footerY, "rail scroll keeps footer fixed");
            check(number(view.root(), "clicks") == 0, "scroll gesture does not activate rail entry");
        } finally { view.dispose(); }
    }

    private static void customSlots() throws Exception {
        QmlView view = scene("NavigationRail { height: 320; extended: true; showToggle: false; property int clicks: 0;"
            + " model: [{text: \"Custom entry\"}]; onItemClicked: clicks += 1;"
            + " header: Component { Item { implicitHeight: 20 } }"
            + " headerActions: Component { Item { implicitHeight: 20 } }"
            + " footer: Component { Item { implicitHeight: 40 } }"
            + " delegate: Component { Text { objectName: \"customRailLabel\"; text: parent.itemData.text; font.pixelSize: 16 } } }");
        try {
            render(view, 240, 320, null);
            Item custom = view.findByObjectName("customRailLabel");
            check(custom != null && "Custom entry".equals(get(custom, "text")), "rail custom delegate receives its entry alongside header and footer slots");
            Item row = view.findByObjectName("miuixRailItem0");
            click(view, 40, coordinate(row, false) + 20);
            check(number(view.root(), "clicks") == 1, "custom rail delegate retains row activation");
        } finally { view.dispose(); }
    }

    private static void badges(Path output) throws Exception {
        QmlView view = scene("Rectangle { width: 180; height: 100; color: \"white\";"
            + " Badge { objectName: \"dot\" } Badge { objectName: \"number\"; x: 20; text: \"99+\" }"
            + " Badge { objectName: \"custom\"; x: 70; Rectangle { width: 28; height: 24; color: \"white\" } }"
            + " BadgedBox { x: 120; y: 40; width: 28; height: 28; badgeBounds: ({x: -10, y: 0, width: 48, height: 60});"
            + " badge: Component { Badge { text: \"999+\" } } Icon { name: \"mail\"; width: 28; height: 28 } } }");
        try {
            render(view, 180, 100, "badge-sizing");
            Item dot = view.findByObjectName("dot");
            Item number = view.findByObjectName("number");
            Item custom = view.findByObjectName("custom");
            check(dot.width.peekDouble() == 6 && dot.height.peekDouble() == 6, "empty badge uses 6 px dot");
            check(number.width.peekDouble() > 16 && number.height.peekDouble() == 16, "number badge grows horizontally with 16 px height");
            check(custom.width.peekDouble() == 36 && custom.height.peekDouble() == 24, "custom badge content contributes width and height");
            check("#ffffff".equalsIgnoreCase(String.valueOf(get(number, "contentColor"))), "badge uses valid on-error text color");
            Item placement = view.findByObjectName("miuixBadgePlacement");
            check(placement.x.peekDouble() + placement.width.peekDouble() <= 38 && placement.y.peekDouble() >= 0, "badge clamps to supplied top and end bounds");
            BufferedImage image = ImageIO.read(output.resolve("badge-sizing.png").toFile());
            int lightPixels = 0;
            for (int y = 4; y < 12; y++) {
                for (int x = 25; x < 40; x++) {
                    int color = image.getRGB(x, y);
                    if ((color & 255) > 200 && ((color >> 8) & 255) > 200) lightPixels++;
                }
            }
            check(lightPixels > 4, "badge number paints light glyphs on error background");
        } finally { view.dispose(); }
    }

    private static void previews(Path project) throws Exception {
        for (boolean dark : new boolean[] {false, true}) {
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
            QmlView view = scene(Files.readString(project.resolve("showcases/MiuixRailShowcase.qml")));
            try {
                for (int width : new int[] {1040, 390}) {
                    view.root().width.set(width);
                    settle(view);
                    render(view, width, 800, "rail-" + width + (dark ? "-dark" : "-light"));
                    check(view.findByObjectName("showcaseRail").width.peekDouble() == (width > 760 ? 240 : 80), "rail showcase adapts to window width");
                    check("99+".equals(get(view.findByObjectName("miuixRailBadge3"), "text")), "rail badge retains its entry count inside the component slot");
                    check("7".equals(get(view.findByObjectName("miuixNavigationBadge1"), "text")), "navigation badge retains its entry count");
                }
                set(view.root(), "notifications", 42);
                render(view, 390, 800, null);
                check("42".equals(get(view.findByObjectName("miuixRailBadge2"), "text"))
                    && "42".equals(get(view.findByObjectName("miuixNavigationBadge1"), "text")), "notification updates reach both navigation badge slots");
            } finally { view.dispose(); }
        }
    }
}
