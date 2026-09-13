package io.github.timer_err.qml4j.demo;

import io.github.timer_err.qml4j.render.QmlView;
import io.github.timer_err.qml4j.render.items.core.Item;
import io.github.timer_err.qml4j.runtime.color.StyleManager;
import java.nio.file.Files;
import java.nio.file.Path;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

import static io.github.timer_err.qml4j.demo.MiuixChecks.*;

/** Navigation interactions and layout checks against the current host engine. */
final class MiuixNavigationChecks {
    static void run(Path project, Path output) throws Exception {
        ((StyleManager) StyleManager.__instance()).isDarkTheme.set(false);
        navigation();
        tabs();
        contentSizedTabs();
        previews(project, output);
    }

    private static void navigation() throws Exception {
        QmlView view = scene("NavigationBar { width: 320; height: 240; property int hits: 0; property int choice: -1;"
            + " model: [{icon: \"home\", text: \"Home\"}, {icon: \"search\", text: \"Explore\"}, {icon: \"settings\", text: \"Settings\", enabled: false}];"
            + " onActivated: (index) => { hits += 1; choice = index }"
            + " Rectangle { objectName: \"page0\"; color: \"white\" }"
            + " Rectangle { objectName: \"page1\"; color: \"#eeeeee\" } Item { objectName: \"page2\" } }");
        try {
            Item bar = view.findByObjectName("miuixNavigationBar");
            Item pages = view.findByObjectName("miuixNavigationPages");
            check(bar.height.peekDouble() == 65 && pages.height.peekDouble() == 175, "navigation reserves 64 px items and divider");
            click(view, 160, 205);
            check(number(view.root(), "currentIndex") == 1 && number(view.root(), "hits") == 1, "navigation selects page with one callback");
            check(!view.findByObjectName("page0").visible.peek() && view.findByObjectName("page1").visible.peek(), "navigation switches content visibility");
            click(view, 267, 205);
            check(number(view.root(), "currentIndex") == 1 && number(view.root(), "hits") == 1, "disabled navigation entry ignores clicks");
            set(view.root(), "selectOnClick", false);
            click(view, 53, 205);
            check(number(view.root(), "currentIndex") == 1 && number(view.root(), "choice") == 0, "controlled navigation reports intent without changing selection");
            set(view.root(), "currentIndex", 0);
            settle(view);
            check(view.findByObjectName("page0").visible.peek(), "external selection updates navigation content");
            modes(view, pages);
            set(view.root(), "enabled", false);
            settle(view);
            click(view, 160, 205);
            check(number(view.root(), "hits") == 2, "disabled navigation ignores all entries");
        } finally { view.dispose(); }
    }

    private static void modes(QmlView view, Item pages) throws Exception {
        set(view.root(), "mode", "iconOnly");
        render(view, 320, 240, null);
        check(number(view.findByObjectName("miuixNavigationLabel0"), "opacity") == 0
            && view.findByObjectName("miuixNavigationIcon0").y.peekDouble() == 19, "icon-only mode hides label and centers icon");
        set(view.root(), "mode", "iconWithSelectedLabel");
        render(view, 320, 240, null);
        check(number(view.findByObjectName("miuixNavigationLabel0"), "opacity") == 1
            && number(view.findByObjectName("miuixNavigationLabel1"), "opacity") == 0, "selected-label mode reveals only current label");
        check(pages.height.peekDouble() == 175, "changing navigation mode does not shift page height");
        set(view.root(), "bottomInset", 20);
        set(view.root(), "showDivider", false);
        settle(view);
        check(pages.height.peekDouble() == 156, "navigation insets reserve content space");
        view.root().width.set(210);
        settle(view);
        check(view.findByObjectName("miuixNavigationItem2").width.peekDouble() == 70, "navigation divides narrow window evenly");
    }

    private static void tabs() throws Exception {
        QmlView view = scene("Item { width: 240; height: 100; property int hits: 0; property int choice: -1; property bool empty: false;"
            + " TabRowWithContour { objectName: \"tabs\"; width: parent.width; selectedTabIndex: 5;"
            + " tabs: empty ? [] : [\"One\", \"Two\", \"Three\", \"Four\", \"Five\", \"Six\"];"
            + " onTabSelected: (index) => { hits += 1; choice = index } } }");
        try {
            Item tabs = view.findByObjectName("tabs");
            Item viewport = view.findByObjectName("miuixTabViewport");
            render(view, 240, 100, null);
            check(number(viewport, "contentX") > 0, "initial last tab is revealed after layout");
            set(tabs, "selectedTabIndex", 0);
            render(view, 240, 100, null);
            check(number(viewport, "contentX") == 0, "external first-tab selection resets scroll");
            click(view, 100, 22);
            check(number(tabs, "selectedTabIndex") == 1 && number(view.root(), "hits") == 1, "tab selects once on click");
            set(tabs, "selectOnClick", false);
            click(view, 166, 22);
            check(number(tabs, "selectedTabIndex") == 1 && number(view.root(), "choice") == 2, "controlled tab reports selection without mutating state");
            set(tabs, "enabled", false);
            settle(view);
            click(view, 32, 22);
            check(number(view.root(), "hits") == 2, "disabled tabs ignore clicks");
            set(tabs, "selectedTabIndex", 5);
            view.root().width.set(180);
            render(view, 180, 100, null);
            check(number(viewport, "contentX") + viewport.width.peekDouble() <= number(viewport, "contentWidth") + 1, "tab scroll remains bounded after resize");
            set(view.root(), "empty", true);
            render(view, 180, 100, null);
            check(!view.findByObjectName("miuixTabIndicator").visible.peek() && number(viewport, "contentX") == 0, "empty tabs hide indicator and reset scrolling");
            set(view.root(), "empty", false);
            set(tabs, "enabled", true);
            set(tabs, "selectedTabIndex", 0);
            render(view, 180, 100, null);
            drag(view, 155, 22, 25, 22);
            check(number(viewport, "contentX") > 0 && number(view.root(), "hits") == 2, "dragging tabs scrolls without selecting a tab");
        } finally { view.dispose(); }
    }

    private static void contentSizedTabs() throws Exception {
        QmlView view = scene("TabRow { width: 240; height: 42; tabs: [\"For you\", \"Following\", \"New releases\", \"Downloaded\"] }");
        try {
            render(view, 240, 42, null);
            Item first = view.findByObjectName("miuixTabItem0");
            Item last = view.findByObjectName("miuixTabItem3");
            Item viewport = view.findByObjectName("miuixTabViewport");
            double firstWidth = first.width.peekDouble();
            double lastWidth = last.width.peekDouble();
            check(lastWidth > firstWidth, "standard tabs measure each label instead of using equal widths");
            check(number(viewport, "contentWidth") > viewport.width.peekDouble(), "full labels create horizontal overflow");
            for (int index = 0; index < 4; index++) {
                Item label = view.findByObjectName("miuixTabLabel" + index);
                check(label.width.peekDouble() >= label.implicitWidth.peekDouble(), "standard tab reserves enough width for complete label");
            }
            set(view.root(), "selectedTabIndex", 3);
            render(view, 240, 42, null);
            check(first.width.peekDouble() == firstWidth && last.width.peekDouble() == lastWidth, "selection weight does not change tab widths");
            double left = last.x.peekDouble() - number(viewport, "contentX");
            check(left >= 0 && left + lastWidth <= viewport.width.peekDouble() + 1, "last variable-width tab is fully revealed");
            Item indicator = view.findByObjectName("miuixTabIndicator");
            check(indicator.x.peekDouble() == last.x.peekDouble() && indicator.width.peekDouble() == lastWidth, "indicator follows selected tab's measured bounds");
            set(view.root(), "equalWidth", true);
            render(view, 240, 42, null);
            check(first.width.peekDouble() == last.width.peekDouble(), "equal-width upstream layout remains available");
        } finally { view.dispose(); }
    }

    private static void previews(Path project, Path output) throws Exception {
        for (boolean dark : new boolean[] {false, true}) {
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
            QmlView view = scene(Files.readString(project.resolve("showcases/MiuixNavigationShowcase.qml")));
            try {
                for (int width : new int[] {1040, 390}) {
                    view.root().width.set(width);
                    settle(view);
                    String name = "navigation-" + width + (dark ? "-dark" : "-light");
                    render(view, width, 860, name);
                    BufferedImage pixels = ImageIO.read(output.resolve(name + ".png").toFile());
                    int background = pixels.getRGB(5, 810);
                    check(pixels.getRGB(width / 8 - 25, 820) == background, "selected navigation icon has no capsule background");
                }
                set(view.findByObjectName("modeTabs"), "selectedTabIndex", 2);
                render(view, 390, 860, "navigation-selected-label" + (dark ? "-dark" : "-light"));
            } finally { view.dispose(); }
        }
    }
}
