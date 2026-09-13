package io.github.timer_err.qml4j.demo;

import io.github.timer_err.qml4j.render.QmlView;
import io.github.timer_err.qml4j.render.items.core.Item;
import io.github.timer_err.qml4j.runtime.color.StyleManager;
import java.nio.file.Path;
import java.nio.file.Files;
import java.util.Map;
import static io.github.timer_err.qml4j.demo.MiuixChecks.*;

/** Dynamic palettes, interrupted overlays, refresh gestures and input boundaries. */
final class MiuixCompletionChecks {
    static void run(Path project, Path output) throws Exception {
        monet();
        appBar();
        keyboard();
        feedback();
        menu();
        progress();
        numberPicker();
        colorPicker();
        colorSpaces();
        refresh();
        previews(project);
    }

    private static void monet() throws Exception {
        StyleManager manager = (StyleManager) StyleManager.__instance();
        Object seed = manager.seedColor.get();
        manager.isDarkTheme.set(false);
        QmlView view = scene("Item { width: 320; height: 180; property bool dynamic: false;"
            + " property color primary: Theme.color.primary; property color disabled: Theme.color.disabledPrimary;"
            + " property color surface: Theme.color.surface; property color textColor: Theme.color.onPrimary;"
            + " property bool dark: Theme.dark; onDynamicChanged: Theme.dynamicColors = dynamic;"
            + " Button { objectName: \"button\"; text: \"Monet\" } }");
        try {
            Object original = get(view.root(), "primary");
            set(view.root(), "dynamic", true);
            settle(view);
            check(get(view.root(), "primary").equals(((Map<?, ?>) manager.lightScheme.get()).get("primary")), "Monet primary comes from native StyleManager");
            Object before = get(view.root(), "primary");
            Object disabled = get(view.root(), "disabled");
            manager.seedColor.set("#109868");
            settle(view);
            check(!before.equals(get(view.root(), "primary")), "changing native seed updates active primary");
            check(!disabled.equals(get(view.root(), "disabled")), "seed regenerates Miuix disabled roles");
            check(get(view.findByObjectName("button"), "containerColor").equals(get(view.root(), "primary")), "existing button follows dynamic palette");
            Object lightSurface = get(view.root(), "surface");
            manager.isDarkTheme.set(true);
            settle(view);
            check(Boolean.TRUE.equals(get(view.root(), "dark")) && !lightSurface.equals(get(view.root(), "surface")), "native dark switch updates Miuix surfaces");
            check(!get(view.root(), "textColor").equals(get(view.root(), "primary")), "dynamic foreground is a separate contrast role");
            manager.isDarkTheme.set(false);
            set(view.root(), "dynamic", false);
            settle(view);
            check(original.equals(get(view.root(), "primary")), "disabling Monet restores original Miuix blue");
        } finally { view.dispose(); manager.seedColor.set(seed); manager.isDarkTheme.set(false); }
    }

    private static void appBar() throws Exception {
        QmlView view = scene("Item { width: 320; height: 400; TopAppBar { objectName: \"bar\"; title: \"A long page title that needs clipping\"; subtitle: \"Details\" } }");
        try {
            Item bar = view.findByObjectName("bar");
            double expanded = bar.height.peekDouble();
            check(expanded > 90, "large app bar reserves title and subtitle height");
            set(bar, "scrollOffset", 1000);
            render(view, 320, 400, "appbar-collapsed");
            check(bar.height.peekDouble() == 52 && number(bar, "collapsedFraction") == 1, "scroll collapses to upstream 52 px height");
            set(bar, "scrollOffset", -30);
            settle(view);
            check(bar.height.peekDouble() == expanded, "overscroll does not over-expand title");
            set(bar, "large", false);
            set(bar, "subtitle", "");
            settle(view);
            check(bar.height.peekDouble() == 52, "small app bar remains fixed");
        } finally { view.dispose(); }
    }

    private static void keyboard() throws Exception {
        QmlView view = scene("Item { width: 320; height: 400; property int clicks: 0;"
            + " Button { id: trigger; objectName: \"trigger\"; text: \"Open dialog\"; onClicked: { clicks += 1; modal.open() } }"
            + " Dialog { id: modal; objectName: \"modal\"; closeOnScrim: false; title: \"Keyboard dialog\" } }");
        try {
            view.dispatchKey(QmlView.KEY_TAB, null, true);
            view.dispatchKey(QmlView.KEY_ENTER, null, true);
            render(view, 320, 400, null);
            check(number(view.root(), "clicks") == 1, "Tab and Enter activate button once");
            check(Boolean.TRUE.equals(get(view.findByObjectName("modal"), "opened")), "keyboard button opens dialog");
            view.dispatchKey(QmlView.KEY_ESCAPE, null, true);
            render(view, 320, 400, null);
            check(Boolean.FALSE.equals(get(view.findByObjectName("modal"), "opened")), "Escape dismissal is independent of scrim policy");
            check(Boolean.TRUE.equals(view.findByObjectName("trigger").activeFocus.get()), "dialog restores triggering keyboard focus");
        } finally { view.dispose(); }
    }

    private static void feedback() throws Exception {
        QmlView view = scene("Item { width: 240; height: 360; property int closedCount: 0; property int actions: 0;"
            + " property bool showing: false; property bool hiding: false;"
            + " onShowingChanged: { snack.open(); tip.open() } onHidingChanged: { snack.close(); tip.close() }"
            + " Snackbar { id: snack; objectName: \"snack\"; timeout: 0; text: \"Long notification text that wraps on small windows\"; actionText: \"Undo\"; onClosed: closedCount += 1; onActionClicked: actions += 1 }"
            + " Rectangle { id: anchor; x: 220; y: 8; width: 20; height: 20 }"
            + " ToolTip { id: tip; objectName: \"tip\"; timeout: 0; anchorItem: anchor; placement: \"above\"; text: \"A longer tooltip that should wrap inside the window\"; onClosed: closedCount += 1 } }");
        try {
            set(view.root(), "showing", true);
            render(view, 240, 360, "feedback-small");
            Item tip = view.findByObjectName("tip");
            check(tip.x.peekDouble() >= 8 && tip.x.peekDouble() + tip.width.peekDouble() <= 232, "tooltip clamps against right window edge");
            check(tip.y.peekDouble() >= 28 && tip.height.peekDouble() > 32, "tooltip flips below top anchor and wraps");
            set(view.root(), "hiding", true);
            set(view.root(), "showing", false);
            render(view, 240, 360, null);
            check(Boolean.TRUE.equals(tip.visible.get()) && number(view.root(), "closedCount") == 0, "reopening interrupts pending tooltip and snackbar close");
            Item action = view.findByObjectName("miuixSnackbarAction");
            click(view, coordinate(action, true) + 15, coordinate(action, false) + 13);
            render(view, 240, 360, null);
            check(number(view.root(), "actions") == 1 && number(view.root(), "closedCount") == 1, "snackbar action closes exactly once");
            set(view.root(), "hiding", false);
            render(view, 240, 360, null);
            check(number(view.root(), "closedCount") == 2, "closing an already hidden snackbar is idempotent");
        } finally { view.dispose(); }
    }

    private static void menu() throws Exception {
        QmlView view = scene("Item { width: 220; height: 320; property bool show: false; property int choices: 0;"
            + " onShowChanged: menu.open(anchor, 0, 30); Rectangle { id: anchor; width: 30; height: 30 }"
            + " Menu { id: menu; objectName: \"menu\"; model: [{text: \"Disabled\", enabled: false}, {text: \"More\", subItems: [{text: \"Choose\", action: function() { choices += 1 }}]}] } }");
        try {
            set(view.root(), "show", true);
            render(view, 220, 320, "menu-small");
            view.dispatchKey(QmlView.KEY_DOWN, null, true);
            settle(view);
            check(number(view.findByObjectName("menu"), "currentIndex") == 1, "menu keyboard skips disabled entries");
            view.dispatchKey(QmlView.KEY_ENTER, null, true);
            render(view, 220, 320, null);
            view.dispatchKey(QmlView.KEY_DOWN, null, true);
            view.dispatchKey(QmlView.KEY_ENTER, null, true);
            render(view, 220, 320, null);
            check(number(view.root(), "choices") == 1, "nested menu loads Miuix module and activates via keyboard");
            check(Boolean.FALSE.equals(get(view.findByObjectName("menu"), "opened")), "submenu choice closes parent chain");
            set(view.root(), "show", false);
            render(view, 220, 320, null);
            view.dispatchKey(QmlView.KEY_ESCAPE, null, true);
            render(view, 220, 320, null);
            check(Boolean.FALSE.equals(get(view.findByObjectName("menu"), "opened")), "Escape closes menu");
        } finally { view.dispose(); }
    }

    private static void progress() throws Exception {
        QmlView view = scene("Item { width: 240; height: 100; LinearProgress { objectName: \"line\"; width: 200; value: -2 } CircularProgress { objectName: \"circle\"; y: 20; value: 2 } LoadingIndicator { objectName: \"loading\"; x: 60; y: 20 } }");
        try {
            check(view.findByObjectName("line").height.peekDouble() == 6, "linear progress uses 6 px track");
            check(view.findByObjectName("miuixLinearProgressFill").width.peekDouble() == 6, "zero progress retains upstream minimum dot");
            check(number(view.findByObjectName("circle"), "progress") == 1 && view.findByObjectName("circle").width.peekDouble() == 30, "circular progress clamps value at 30 px size");
            check(view.findByObjectName("loading").width.peekDouble() == 20, "loading indicator uses 20 px orbit");
            set(view.findByObjectName("line"), "indeterminate", true);
            render(view, 240, 100, null);
            set(view.findByObjectName("line"), "indeterminate", false);
            set(view.findByObjectName("line"), "value", 2);
            settle(view);
            check(view.findByObjectName("miuixLinearProgressFill").width.peekDouble() == 200, "progress mode switch follows latest bounded value");
        } finally { view.dispose(); }
    }

    private static void numberPicker() throws Exception {
        QmlView view = scene("NumberPicker { width: 100; range: [0, 1000000]; value: 10 }");
        try {
            render(view, 100, 225, null);
            set(view.root(), "value", 41);
            settle(view);
            check(number(view.root(), "_contentOffset") == 41 * 45, "external wheel value is preserved after initial range layout");
            Item slot = view.findByObjectName("miuixNumberSlot3");
            check(slot != null && view.findByObjectName("miuixNumberSlot7") == null, "million-item wheel uses seven delegates");
            view.dispatchPointerDown(50, 112);
            view.dispatchPointerMove(50, 92);
            settle(view);
            check(slot.scale.peekDouble() < 1 && slot.opacity.peekDouble() < 1, "wheel scale and fade follow fractional drag");
            view.dispatchPointerUp(50, 67);
            render(view, 100, 225, "number-wheel");
            view.dispatchKey(QmlView.KEY_DOWN, null, true);
            settle(view);
            check(number(view.root(), "value") >= 11, "wheel supports keyboard stepping after drag");
            set(view.root(), "to", 4);
            settle(view);
            check(number(view.root(), "value") == 4, "shrinking range clamps selected value");
            set(view.root(), "enabled", false);
            drag(view, 50, 112, 50, 50);
            check(number(view.root(), "value") == 4, "disabled wheel ignores drag");
        } finally { view.dispose(); }
    }

    private static void colorPicker() throws Exception {
        QmlView view = scene("ColorPicker { width: 320; color: \"#40ff0000\"; property int changes: 0; onColorSelected: changes += 1 }");
        try {
            check(Math.abs(number(view.root(), "_alpha") - 64.0 / 255) < 0.01, "picker adopts external alpha");
            drag(view, 50, 50, 230, 50);
            check(number(view.root(), "changes") > 0, "color hue drag emits selection");
            set(view.root(), "color", "#ff00ff00");
            settle(view);
            check(Math.abs(number(view.root(), "_hue") - 120) < 1, "external color resynchronizes picker channels");
            set(view.root(), "enabled", false);
            double changes = number(view.root(), "changes");
            drag(view, 50, 50, 230, 50);
            check(number(view.root(), "changes") == changes, "disabled color picker ignores drag");
        } finally { view.dispose(); }
    }

    private static void colorSpaces() throws Exception {
        for (String mode : new String[]{"OKHSV", "OKLAB", "OKLCH"}) {
            QmlView view = scene("ColorPicker { width: 320; colorSpace: \"" + mode + "\"; color: \"#8040a070\" }");
            try {
                check(colorDistance(get(view.root(), "color"), get(view.root(), "_selectedColor")) <= 3, mode + " round trips external RGB and alpha");
                set(view.root(), "color", "#ff000000");
                settle(view);
                check(colorDistance(get(view.root(), "color"), get(view.root(), "_selectedColor")) <= 1, mode + " handles black without NaN");
                set(view.root(), "color", "#ffffffff");
                settle(view);
                check(colorDistance(get(view.root(), "color"), get(view.root(), "_selectedColor")) <= 1, mode + " handles white without NaN");
                render(view, 320, 200, "picker-" + mode.toLowerCase());
            } finally { view.dispose(); }
        }
    }

    private static int colorDistance(Object first, Object second) {
        long a = Long.parseLong(first.toString().substring(1), 16);
        long b = Long.parseLong(second.toString().substring(1), 16);
        int distance = 0;
        for (int shift = 0; shift <= 24; shift += 8)
            distance = Math.max(distance, Math.abs((int) (a >> shift & 255) - (int) (b >> shift & 255)));
        return distance;
    }

    private static void previews(Path project) throws Exception {
        String source = Files.readString(project.resolve("showcases/MiuixCompleteShowcase.qml"));
        for (boolean dark : new boolean[]{false, true}) {
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
            QmlView view = scene(source.substring(source.indexOf("Rectangle {")));
            try {
                render(view, 1040, 860, dark ? "complete-dark" : "complete-light");
                view.root().width.set(390);
                view.root().height.set(844);
                render(view, 390, 844, dark ? "complete-phone-dark" : "complete-phone-light");
            } finally { view.dispose(); }
        }
        ((StyleManager) StyleManager.__instance()).isDarkTheme.set(false);
    }

    private static void refresh() throws Exception {
        QmlView view = scene("PullToRefresh { width: 320; height: 300; property int requests: 0; property int clicks: 0;"
            + " onRefreshRequested: { requests += 1; refreshing = true }"
            + " Column { width: 320; Button { text: \"Content action\"; onClicked: clicks += 1 } Rectangle { width: 320; height: 600; color: Theme.color.surface } } }");
        try {
            render(view, 320, 300, null);
            check(number(view.root(), "pullDistance") == 0, "refresh header starts hidden");
            render(view, 320, 300, "refresh-before");
            click(view, 40, 24);
            check(number(view.root(), "clicks") == 1, "refresh container preserves child clicks");
            drag(view, 150, 100, 150, 220);
            render(view, 320, 300, "refresh-active");
            check(number(view.root(), "requests") == 1 && Boolean.TRUE.equals(get(view.root(), "refreshing")), "threshold pull requests refresh once");
            render(view, 320, 300, null);
            check(number(view.root(), "requests") == 1, "active refresh does not duplicate requests");
            set(view.root(), "refreshing", false);
            render(view, 320, 300, null);
            render(view, 320, 300, null);
            check(number(view.root(), "pullDistance") < 1, "refresh completion hides header");
            view.dispatchPointerDown(150, 100);
            view.dispatchPointerMove(150, 110);
            Thread.sleep(150);
            view.dispatchPointerUp(150, 110);
            render(view, 320, 300, null);
            check(number(view.root(), "requests") == 1 && number(view.root(), "pullDistance") < 1, "short pull cancels without refreshing");
            set(view.root(), "refreshing", true);
            render(view, 320, 300, null);
            check(number(view.root(), "requests") == 1 && number(view.root(), "pullDistance") > 60, "programmatic refresh shows indicator without requesting again");
        } finally { view.dispose(); }
    }
}
