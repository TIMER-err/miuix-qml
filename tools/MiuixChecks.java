package io.github.timer_err.qml4j.demo;

import io.github.humbleui.skija.Canvas;
import io.github.humbleui.skija.EncodedImageFormat;
import io.github.humbleui.skija.Surface;
import io.github.timer_err.qml4j.engine.QmlEngine;
import io.github.timer_err.qml4j.engine.binding.Property;
import io.github.timer_err.qml4j.render.QmlView;
import io.github.timer_err.qml4j.render.SurfaceBackend;
import io.github.timer_err.qml4j.render.items.core.Item;
import io.github.timer_err.qml4j.runtime.color.StyleManager;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/** Integration checks using the sibling qml4j source build, including real pointer input. */
public final class MiuixChecks {
    private static Path project;
    private static Path output;
    private static int checks;

    public static void main(String[] args) throws Exception {
        project = Paths.get(args[0]);
        output = project.resolve("build/previews");
        Files.createDirectories(output);
        smokeComponents();
        preferences();
        search();
        sliders();
        dropdown();
        scrolling();
        previews();
        System.out.println("PASS: " + checks + " assertions; previews in " + output);
    }

    private static QmlView scene(String body) {
        DirResourceLoader resources = new DirResourceLoader(project);
        QmlView view = QmlView.withStockTypes(new QmlEngine()).resources(resources);
        HostFonts.configure(view, resources);
        view.load("import QtQuick\nimport miuix.Core\n" + body);
        settle(view);
        return view;
    }

    private static void settle(QmlView view) {
        view.dirtyQueue().install();
        try {
            for (int i = 0; i < 8; i++) {
                view.dirtyQueue().flush();
                view.renderer().layoutOnly(view.root());
            }
            view.dirtyQueue().flush();
        } finally {
            view.dirtyQueue().uninstall();
        }
    }

    private static Object get(Item item, String name) throws Exception {
        return ((Property<?>) item.getClass().getField(name).get(item)).get();
    }

    @SuppressWarnings("unchecked")
    private static void set(Item item, String name, Object value) throws Exception {
        ((Property<Object>) item.getClass().getField(name).get(item)).set(value);
    }

    private static double number(Item item, String name) throws Exception {
        return ((Number) get(item, name)).doubleValue();
    }

    private static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        checks++;
    }

    private static void click(QmlView view, float x, float y) {
        view.dispatchPointerDown(x, y);
        view.dispatchPointerUp(x, y);
        settle(view);
    }

    private static void drag(QmlView view, float x, float y, float endX, float endY) {
        view.dispatchPointerDown(x, y);
        for (int step = 1; step <= 4; step++) {
            view.dispatchPointerMove(x + (endX - x) * step / 4, y + (endY - y) * step / 4);
        }
        view.dispatchPointerUp(endX, endY);
        settle(view);
    }

    private static void smokeComponents() throws Exception {
        for (String line : Files.readAllLines(project.resolve("miuix/Core/qmldir"))) {
            if (line.trim().isEmpty() || line.startsWith("singleton")) continue;
            String type = line.split(" ")[0];
            QmlView view = scene("Item { width: 400; height: 900; " + type + " {} }");
            try {
                check(view.root().children.size() == 1, type + " loads");
            } finally {
                view.dispose();
            }
        }
    }

    private static void preferences() throws Exception {
        QmlView view = scene("Item { width: 320; height: 600; property int clicks: 0;"
            + " Column { width: parent.width;"
            + " SuperSwitch { objectName: \"wifi\"; title: \"Wi-Fi\"; checked: true; onClicked: clicks += 1 }"
            + " SuperCheckbox { objectName: \"check\"; title: \"Remember\"; checked: true; onClicked: clicks += 1 }"
            + " SuperSwitch { objectName: \"long\"; title: \"Sync devices\"; summary: \"Keep your preferences in sync on every device signed in to your account, including tablets and computers.\" }"
            + " } }");
        try {
            Item wifi = view.findByObjectName("wifi");
            Item box = view.findByObjectName("check");
            Item longRow = view.findByObjectName("long");
            check(Boolean.TRUE.equals(get(wifi, "checked")), "initial switch state");
            click(view, 4, 28);
            check(Boolean.FALSE.equals(get(wifi, "checked")), "row padding toggles switch");
            click(view, 280, 28);
            check(Boolean.TRUE.equals(get(wifi, "checked")), "thumb toggles switch");
            click(view, 30, (float) (wifi.height.peekDouble() + 28));
            check(Boolean.FALSE.equals(get(box, "checked")), "checkbox toggles from its glyph");
            check(number(view.root(), "clicks") == 3, "exactly one signal for each toggle");
            set(wifi, "enabled", false);
            settle(view);
            click(view, 280, 28);
            check(number(view.root(), "clicks") == 3, "disabled preference ignores input");
            double previousHeight = longRow.height.peekDouble();
            view.root().width.set(220);
            settle(view);
            check(longRow.height.peekDouble() > previousHeight, "long summary grows when narrowing");
            check(wifi.width.peekDouble() == 220, "preference follows resized container");
        } finally {
            view.dispose();
        }
    }

    private static void search() throws Exception {
        QmlView view = scene("Item { width: 320; height: 100; property string query: \"\"; property int clears: 0;"
            + " SearchBar { objectName: \"search\"; width: 320; onTextChanged: query = text; onCleared: clears += 1 } }");
        try {
            click(view, 100, 20);
            view.dispatchKey(0, "miuix", true);
            settle(view);
            check("miuix".equals(get(view.root(), "query")), "search accepts keyboard input");
            click(view, 298, 22);
            check("".equals(get(view.root(), "query")), "clear button empties search");
            check(number(view.root(), "clears") == 1, "clear signal emitted once");
        } finally {
            view.dispose();
        }
    }

    private static void sliders() throws Exception {
        QmlView view = scene("Item { width: 320; height: 180; property int ends: 0;"
            + " Slider { objectName: \"single\"; width: 300; from: 0; to: 100; value: 25; stepSize: 10; onEditingFinished: ends += 1 }"
            + " Slider { objectName: \"range\"; y: 70; width: 300; from: 0; to: 100; rangeMode: true; firstValue: 20; secondValue: 80; stepSize: 10; tickMarksEnabled: true } }");
        try {
            Item single = view.findByObjectName("single");
            Item range = view.findByObjectName("range");
            click(view, 240, 14);
            check(number(single, "value") == 25, "tap does not jump slider");
            drag(view, 82, 14, 180, 14);
            check(number(single, "value") == 60, "horizontal drag snaps to step");
            check(number(view.root(), "ends") == 1, "drag completion emitted once");
            drag(view, 68, 84, 120, 84);
            check(number(range, "firstValue") == 40 && number(range, "secondValue") == 80, "first range handle moves independently");
            drag(view, 232, 84, 286, 84);
            check(number(range, "secondValue") == 100, "second range handle reaches endpoint");
            drag(view, 123, 84, 319, 84);
            check(number(range, "firstValue") <= number(range, "secondValue"), "range handles cannot cross");
            set(single, "enabled", false);
            settle(view);
            drag(view, 180, 14, 40, 14);
            check(number(single, "value") == 60, "disabled slider ignores drag");
        } finally {
            view.dispose();
        }
    }

    private static void dropdown() throws Exception {
        QmlView view = scene("Item { width: 320; height: 300; property int selection: -1;"
            + " SuperDropdown { objectName: \"menu\"; title: \"Appearance\"; items: [\"Light\", \"Dark\"]; onActivated: selection = index } }");
        try {
            Item menu = view.findByObjectName("menu");
            click(view, 100, 25);
            check(Boolean.TRUE.equals(get(menu, "menuOpen")), "dropdown opens");
            render(view, 320, 300, null);
            click(view, 160, (float) menu.height.peekDouble() + 80);
            check(number(menu, "currentIndex") == 1, "dropdown selects second option");
            check(number(view.root(), "selection") == 1, "dropdown callback carries index");
            render(view, 320, 300, null);
            check(Boolean.FALSE.equals(get(menu, "menuOpen")), "dropdown closes after selection");
        } finally {
            view.dispose();
        }
    }

    private static void scrolling() throws Exception {
        QmlView view = scene("Item { width: 320; height: 160; Flickable { objectName: \"scroll\"; anchors.fill: parent;"
            + " contentWidth: width; contentHeight: 700; flickableDirection: \"VerticalFlick\";"
            + " Slider { objectName: \"slider\"; y: 60; width: 300; value: 0.5 } } }");
        try {
            drag(view, 150, 74, 150, 15);
            check(number(view.findByObjectName("slider"), "value") == 0.5, "vertical scroll preserves slider value");
            check(number(view.findByObjectName("scroll"), "contentY") > 0, "page can scroll from slider");
        } finally {
            view.dispose();
        }
    }

    private static void previews() throws Exception {
        for (boolean dark : new boolean[] {false, true}) {
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
            String source = Files.readString(project.resolve("showcases/MiuixShowcase.qml"), StandardCharsets.UTF_8);
            DirResourceLoader resources = new DirResourceLoader(project);
            QmlView view = QmlView.withStockTypes(new QmlEngine()).resources(resources);
            HostFonts.configure(view, resources);
            view.load(source);
            try {
                for (int width : new int[] {1040, 390}) {
                    view.root().width.set(width);
                    view.root().height.set(1000);
                    settle(view);
                    render(view, width, 1000, "showcase-" + width + (dark ? "-dark" : "-light"));
                    check(view.findByObjectName("volumeControl").width.peekDouble() > width / (width > 760 ? 3.0 : 2.0), "slider fills responsive card");
                }
                click(view, 334, 51);
                render(view, 390, 1000, "showcase-live-toggle-" + dark);
                check(!String.valueOf(get(view.root(), "color")).equalsIgnoreCase(dark ? "#000000" : "#F7F7F7"), "live theme switch updates surface");
            } finally {
                view.dispose();
            }
        }
    }

    @SuppressWarnings("deprecation")
    private static void render(QmlView view, int width, int height, String name) throws Exception {
        try (Surface surface = Surface.makeRasterN32Premul(width, height)) {
            SurfaceBackend backend = new RasterBackend(surface, width, height);
            for (int i = 0; i < 24; i++) {
                surface.getCanvas().clear(0);
                view.renderFrame(backend);
                Thread.sleep(10);
            }
            if (name != null) {
                try (var snapshot = surface.makeImageSnapshot();
                     var data = snapshot.encodeToData(EncodedImageFormat.PNG)) {
                    Files.write(output.resolve(name + ".png"), data.getBytes());
                }
            }
        }
    }

    private static final class RasterBackend implements SurfaceBackend {
        private final Surface surface;
        private final int width;
        private final int height;
        RasterBackend(Surface surface, int width, int height) {
            this.surface = surface;
            this.width = width;
            this.height = height;
        }
        public void init(int width, int height) {}
        public Canvas acquireCanvas() { return surface.getCanvas(); }
        public void present() {}
        public void resize(int width, int height) {}
        public void dispose() {}
        public int width() { return width; }
        public int height() { return height; }
    }
}
