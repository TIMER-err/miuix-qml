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

import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

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
        if (args.length > 1 && "completion".equals(args[1])) {
            MiuixCompletionChecks.run(project, output);
            System.out.println("PASS: " + checks + " completion assertions");
            return;
        }
        smokeComponents();
        preferences();
        search();
        textFields();
        textFieldBaselines();
        radioButtons();
        sliders();
        dropdown();
        scrolling();
        smoothGeometry();
        flatIndication();
        dialogs();
        longDropdown();
        previews();
        overlayPreviews();
        inputPreviews();
        MiuixNavigationChecks.run(project, output);
        MiuixRailChecks.run(project, output);
        MiuixCompletionChecks.run(project, output);
        System.out.println("PASS: " + checks + " assertions; previews in " + output);
    }

    static QmlView scene(String body) {
        DirResourceLoader resources = new DirResourceLoader(project);
        QmlView view = QmlView.withStockTypes(new QmlEngine()).resources(resources);
        HostFonts.configure(view, resources);
        view.load("import QtQuick\nimport miuix.Core\n" + body);
        settle(view);
        return view;
    }

    static void settle(QmlView view) {
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

    static Object get(Item item, String name) throws Exception {
        return ((Property<?>) item.getClass().getField(name).get(item)).get();
    }

    @SuppressWarnings("unchecked")
    static void set(Item item, String name, Object value) throws Exception {
        ((Property<Object>) item.getClass().getField(name).get(item)).set(value);
    }

    static double number(Item item, String name) throws Exception {
        return ((Number) get(item, name)).doubleValue();
    }

    static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
        checks++;
    }

    static void click(QmlView view, float x, float y) {
        view.dispatchPointerDown(x, y);
        view.dispatchPointerUp(x, y);
        settle(view);
    }

    static void drag(QmlView view, float x, float y, float endX, float endY) {
        view.dispatchPointerDown(x, y);
        for (int step = 1; step <= 4; step++) {
            view.dispatchPointerMove(x + (endX - x) * step / 4, y + (endY - y) * step / 4);
        }
        view.dispatchPointerUp(endX, endY);
        settle(view);
    }

    private static void smokeComponents() throws Exception {
        for (String line : Files.readAllLines(project.resolve("miuix/Core/qmldir"))) {
            if (line.trim().isEmpty() || line.startsWith("singleton") || line.startsWith("MonetScheme ")) continue;
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

    private static void textFields() throws Exception {
        QmlView view = scene("Rectangle { width: 320; height: 160; color: \"white\"; property int commits: 0; property int clears: 0; property int actions: 0;"
            + " TextField { objectName: \"field\"; width: parent.width; label: \"Display name\";"
            + " onAccepted: commits += 1; onCleared: clears += 1; onTrailingIconClicked: actions += 1 } }");
        try {
            Item field = view.findByObjectName("field");
            Item input = view.findByObjectName("miuixTextFieldInput");
            Item action = view.findByObjectName("miuixTextFieldAction");
            Item label = view.findByObjectName("miuixTextFieldLabel");
            click(view, 100, 26);
            render(view, 320, 160, "field-empty-focused");
            check(Boolean.TRUE.equals(get(field, "focused")), "text field takes focus on click");
            check(Boolean.FALSE.equals(get(field, "isFloating")), "empty focused label remains inline");
            check(Math.abs(label.y.peekDouble() + label.height.peekDouble() / 2
                - input.y.peekDouble() - input.height.peekDouble() / 2) < 0.1, "empty label and editor share the same vertical center");
            BufferedImage focused = ImageIO.read(output.resolve("field-empty-focused.png").toFile());
            check((focused.getRGB(160, 0) & 0xffffff) == 0x3482ff, "focused field has primary top border");
            view.dispatchKey(0, "Miuix", true);
            settle(view);
            render(view, 320, 160, null);
            check("Miuix".equals(get(field, "text")), "text field exposes keyboard edits");
            check(label.y.peekDouble() >= 0 && label.y.peekDouble() + label.height.peekDouble() <= input.y.peekDouble(), "floating label stays inside and above input");
            set(field, "text", "Replacement");
            settle(view);
            check("Replacement".equals(get(input, "text")), "programmatic value replaces edited text");
            clickCenter(view, action);
            check("".equals(get(field, "text")) && number(view.root(), "clears") == 1, "clear action empties input and emits once");
            view.dispatchKey(0, "Again", true);
            settle(view);
            check("Again".equals(get(field, "text")), "typing continues after clear");
            set(field, "useLabelAsPlaceholder", true);
            settle(view);
            check(!label.visible.peek() && Boolean.FALSE.equals(get(field, "isFloating")), "placeholder label hides once text exists");
            set(field, "isPassword", true);
            settle(view);
            check(number(input, "echoMode") == 2, "password starts masked");
            clickCenter(view, action);
            check(Boolean.TRUE.equals(get(field, "passwordVisible")) && number(input, "echoMode") == 0, "password action toggles visibility");
            set(field, "enabled", false);
            settle(view);
            clickCenter(view, action);
            view.dispatchKey(0, "blocked", true);
            settle(view);
            check("Again".equals(get(field, "text")) && Boolean.TRUE.equals(get(field, "passwordVisible")), "disabled field ignores input and password toggle");
            set(field, "enabled", true);
            set(field, "isPassword", false);
            set(field, "readOnly", true);
            settle(view);
            click(view, 100, 26);
            view.dispatchKey(0, "blocked", true);
            settle(view);
            check("Again".equals(get(field, "text")) && !action.visible.peek(), "read-only input preserves value and hides clear");
            set(field, "readOnly", false);
            set(field, "trailingIcon", "search");
            settle(view);
            clickCenter(view, action);
            check(number(view.root(), "actions") == 1 && "Again".equals(get(field, "text")), "custom trailing action emits without clearing");
            set(field, "trailingIcon", "");
            set(field, "errorText", "Enter a complete email address before continuing to the next step.");
            view.root().width.set(210);
            settle(view);
            Item support = view.findByObjectName("miuixTextFieldSupport");
            check(field.height.peekDouble() >= support.y.peekDouble() + support.height.peekDouble(), "narrow field reserves wrapped error text height");
            check(coordinate(input, true) + input.width.peekDouble() <= coordinate(action, true), "narrow input leaves room for trailing action");
            click(view, 70, 26);
            view.dispatchKey(QmlView.KEY_ENTER, null, true);
            settle(view);
            check(number(view.root(), "commits") == 1, "Enter emits accepted once");
            set(field, "text", "");
            set(field, "label", "");
            set(field, "placeholderText", "Email address");
            set(field, "verticalPadding", 24);
            settle(view);
            Item placeholder = view.findByObjectName("miuixTextFieldPlaceholder");
            check(Math.abs(placeholder.y.peekDouble() + placeholder.height.peekDouble() / 2
                - input.y.peekDouble() - input.height.peekDouble() / 2) < 0.1
                && input.y.peekDouble() + input.height.peekDouble() / 2 == number(field, "fieldHeight") / 2,
                "placeholder and editor remain centered with custom padding");
        } finally {
            view.dispose();
        }
    }

    private static void textFieldBaselines() throws Exception {
        QmlView view = scene("Rectangle { width: 300; height: 220; color: \"white\";"
            + " TextField { width: 300; label: \"Email address\" }"
            + " TextField { y: 80; width: 300; placeholderText: \"Email address\" }"
            + " TextField { y: 160; width: 300; text: \"Email address\"; clearButtonEnabled: false } }");
        try {
            render(view, 300, 220, "input-baselines");
            BufferedImage pixels = ImageIO.read(output.resolve("input-baselines.png").toFile());
            int labelBand = textBand(pixels, 0);
            int placeholderBand = textBand(pixels, 80);
            int inputBand = textBand(pixels, 160);
            check(Math.abs(labelBand - inputBand) <= 2 && Math.abs(placeholderBand - inputBand) <= 2,
                "label, placeholder and typed glyphs have matching raster baselines");
        } finally {
            view.dispose();
        }
    }

    private static int textBand(BufferedImage pixels, int top) {
        int first = 56, last = -1;
        for (int y = 4; y < 52; y++) {
            for (int x = 20; x < 180; x++) {
                int rgb = pixels.getRGB(x, top + y);
                if (((rgb >> 16) & 255) < 160 && ((rgb >> 8) & 255) < 160 && (rgb & 255) < 160) {
                    first = Math.min(first, y);
                    last = Math.max(last, y);
                }
            }
        }
        check(last >= first, "text alignment fixture paints glyphs");
        return first + last;
    }

    private static void radioButtons() throws Exception {
        QmlView view = scene("Rectangle { width: 240; height: 150; color: \"white\"; property int chosen: 0; property int clicks: 0;"
            + " RadioButton { objectName: \"first\"; width: 240; text: \"First\"; checked: chosen === 0; onClicked: { chosen = 0; clicks += 1 } }"
            + " RadioButton { objectName: \"second\"; y: 50; width: 240; text: \"A long option which wraps on narrow screens\"; checked: chosen === 1; onClicked: { chosen = 1; clicks += 1 } } }");
        try {
            Item first = view.findByObjectName("first");
            Item second = view.findByObjectName("second");
            render(view, 240, 150, "radio-initial");
            BufferedImage initial = ImageIO.read(output.resolve("radio-initial.png").toFile());
            check((initial.getRGB(20, 9) & 0xffffff) != 0xffffff, "selected radio renders vector check");
            check((initial.getRGB(13, 65) & 0xffffff) == 0xffffff, "unselected radio has no ring or fill");
            click(view, 90, 65);
            render(view, 240, 150, "radio-selected");
            check(Boolean.FALSE.equals(get(first, "checked")) && Boolean.TRUE.equals(get(second, "checked")), "radio label click updates controlled selection");
            check(number(view.root(), "clicks") == 1, "radio emits one callback");
            set(second, "enabled", false);
            settle(view);
            click(view, 13, 65);
            check(number(view.root(), "clicks") == 1, "disabled radio ignores clicks");
            double oldHeight = second.height.peekDouble();
            second.width.set(140);
            settle(view);
            check(second.height.peekDouble() > oldHeight, "radio label wraps and increases row height");
        } finally {
            view.dispose();
        }
    }

    private static void inputPreviews() throws Exception {
        for (boolean dark : new boolean[] {false, true}) {
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
            QmlView view = scene(Files.readString(project.resolve("showcases/MiuixInputShowcase.qml"), StandardCharsets.UTF_8));
            try {
                for (int width : new int[] {1040, 390}) {
                    view.root().width.set(width);
                    view.root().height.set(860);
                    settle(view);
                    render(view, width, 860, "inputs-" + width + (dark ? "-dark" : "-light"));
                    check(view.findByObjectName("nameField").width.peekDouble() >= width / 3.0, "input showcase fits resized columns");
                }
                set(view.root(), "focusPreview", true);
                render(view, 390, 860, "inputs-focused-390" + (dark ? "-dark" : "-light"));
            } finally {
                view.dispose();
            }
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

    static float coordinate(Item item, boolean horizontal) {
        float value = 0;
        for (Item current = item; current != null; current = current.parent.peek()) {
            value += horizontal ? current.x.peekFloat() : current.y.peekFloat();
        }
        return value;
    }

    private static void clickCenter(QmlView view, Item item) {
        click(view, coordinate(item, true) + item.width.peekFloat() / 2,
            coordinate(item, false) + item.height.peekFloat() / 2);
    }

    private static Item visibleItem(Item item, String name) {
        if (!item.isVisible()) return null;
        if (name.equals(item.objectName.peek())) return item;
        for (Item child : item.children) {
            Item found = visibleItem(child, name);
            if (found != null) return found;
        }
        return null;
    }

    private static void smoothGeometry() throws Exception {
        QmlView view = scene("Rectangle { width: 140; height: 100; color: \"#ffffff\";"
            + " SmoothRectangle { objectName: \"smooth\"; anchors.fill: parent; radius: 32; borderWidth: 2; borderColor: \"#ff0000\"; color: \"#3482ff\" } }");
        try {
            Item shape = view.findByObjectName("smooth");
            render(view, 140, 100, "smooth-geometry");
            BufferedImage first = ImageIO.read(output.resolve("smooth-geometry.png").toFile());
            check((first.getRGB(0, 0) & 0xffffff) == 0xffffff, "continuous corner leaves exterior transparent");
            check((first.getRGB(70, 50) & 0xffffff) == 0x3482ff, "continuous shape fills interior");
            check((first.getRGB(70, 0) & 0xffffff) == 0xff0000, "continuous shape retains inset border");
            view.root().width.set(90);
            set(shape, "color", "#00aa00");
            settle(view);
            render(view, 90, 100, "smooth-resized");
            BufferedImage resized = ImageIO.read(output.resolve("smooth-resized.png").toFile());
            check((resized.getRGB(89, 99) & 0xffffff) == 0xffffff, "continuous geometry follows resize");
            check((resized.getRGB(45, 50) & 0xffffff) == 0x00aa00, "shape color change invalidates cached rendering");
            set(shape, "color", "transparent");
            settle(view);
            render(view, 90, 100, "smooth-border-only");
            BufferedImage borderOnly = ImageIO.read(output.resolve("smooth-border-only.png").toFile());
            check((borderOnly.getRGB(45, 50) & 0xffffff) == 0xffffff, "filled border ring preserves transparent interior");
            int blended = 0;
            for (int y = 0; y < 32; y++) {
                for (int x = 0; x < 32; x++) {
                    int pixel = borderOnly.getRGB(x, y) & 0xffffff;
                    if (pixel != 0xffffff && pixel != 0xff0000) blended++;
                }
            }
            check(blended > 20, "border corner has antialiased coverage instead of a binary edge");
            set(shape, "borderWidth", 0);
            settle(view);
            render(view, 90, 100, "smooth-border-hidden");
            BufferedImage hidden = ImageIO.read(output.resolve("smooth-border-hidden.png").toFile());
            check((hidden.getRGB(45, 0) & 0xffffff) == 0xffffff, "border clears when its width becomes zero");
        } finally {
            view.dispose();
        }
    }

    private static void flatIndication() throws Exception {
        QmlView view = scene("Rectangle { width: 160; height: 100; color: \"#ffffff\"; property int holds: 0;"
            + " Ripple { objectName: \"feedback\"; anchors.fill: parent; clipRadius: 16; rippleColor: \"#000000\"; longPressEnabled: true; longPressMs: 100; onLongPressed: holds += 1 } }");
        try {
            view.dispatchPointerMove(80, 50);
            view.dispatchPointerDown(80, 50);
            render(view, 160, 100, "flat-indication");
            BufferedImage pressed = ImageIO.read(output.resolve("flat-indication.png").toFile());
            int center = pressed.getRGB(80, 50) & 0xffffff;
            check(center == (pressed.getRGB(25, 25) & 0xffffff) && center < 0xffffff, "press applies uniform indication, without radial wave");
            check((pressed.getRGB(0, 0) & 0xffffff) == 0xffffff, "flat indication respects corner clipping");
            check(number(view.root(), "holds") == 1, "long-press signal remains supported");
            view.dispatchPointerUp(80, 50);
            set(view.findByObjectName("feedback"), "enabled", false);
            settle(view);
            render(view, 160, 100, "flat-indication-disabled");
            BufferedImage disabled = ImageIO.read(output.resolve("flat-indication-disabled.png").toFile());
            check((disabled.getRGB(80, 50) & 0xffffff) == 0xffffff, "disabled indication clears hover and press feedback");
        } finally {
            view.dispose();
        }
    }

    private static void dialogs() throws Exception {
        QmlView view = scene("Item { width: 390; height: 780; property int command: 0; property int accepts: 0; property int closes: 0;"
            + " onCommandChanged: { if (command === 1 || command === 3) popup.open(); else popup.close() }"
            + " Dialog { id: popup; objectName: \"dialog\"; title: \"Download this album?\"; text: \"Use your mobile connection to download these songs.\"; onAccepted: accepts += 1; onClosed: closes += 1 } }");
        try {
            Item modal = view.findByObjectName("dialog");
            set(view.root(), "command", 1);
            settle(view);
            render(view, 390, 780, null);
            Item panel = view.findByObjectName("miuixDialogPanel");
            check(Boolean.TRUE.equals(get(modal, "opened")), "dialog opens");
            check(Math.abs(panel.width.peekDouble() - 366) < 1, "phone dialog has 12 px outer margins");
            check(Math.abs(panel.y.peekDouble() + panel.height.peekDouble() - 768) < 1, "phone dialog sits at bottom");
            clickCenter(view, view.findByObjectName("miuixDialogAccept"));
            render(view, 390, 780, null);
            check(number(view.root(), "accepts") == 1, "dialog acceptance emits once");
            check(number(view.root(), "closes") == 1 && Boolean.FALSE.equals(get(modal, "opened")), "dialog closes after acceptance");
            set(view.root(), "command", 3);
            settle(view);
            set(view.root(), "command", 2);
            settle(view);
            set(view.root(), "command", 1);
            settle(view);
            render(view, 390, 780, null);
            check(Boolean.TRUE.equals(get(modal, "opened")) && number(view.root(), "closes") == 1, "reopening cancels pending close");
            view.root().width.set(1040);
            view.root().height.set(800);
            settle(view);
            render(view, 1040, 800, null);
            check(Math.abs(panel.width.peekDouble() - 420) < 1, "large dialog caps width at 420");
            check(Math.abs(panel.y.peekDouble() + panel.height.peekDouble() / 2 - 400) < 1, "large dialog centers after resize");
            set(modal, "acceptText", "Download album");
            view.root().width.set(280);
            settle(view);
            render(view, 280, 800, null);
            check(Boolean.TRUE.equals(get(modal, "compactActionLayout")), "narrow dialog stacks actions by measured label width");
            Item accept = visibleItem(view.root(), "miuixDialogAccept");
            Item reject = visibleItem(view.root(), "miuixDialogReject");
            check(coordinate(accept, false) >= coordinate(reject, false) + reject.height.peekFloat(), "stacked actions do not overlap");
            view.root().width.set(1040);
            settle(view);
            render(view, 1040, 800, null);
            set(modal, "closeOnScrim", false);
            settle(view);
            click(view, 5, 5);
            render(view, 1040, 800, null);
            check(Boolean.TRUE.equals(get(modal, "opened")), "closeOnScrim false keeps dialog open");
            set(modal, "closeOnScrim", true);
            settle(view);
            click(view, 5, 5);
            render(view, 1040, 800, null);
            check(number(view.root(), "closes") == 2, "scrim dismisses once");
        } finally {
            view.dispose();
        }
    }

    private static void longDropdown() throws Exception {
        QmlView view = scene("Item { width: 260; height: 260; property int choice: -1;"
            + " SuperDropdown { objectName: \"longMenu\"; y: 180; title: \"Quality\";"
            + " items: [{text: \"Unavailable\", enabled: false}, {text: \"A long option title that must wrap without covering the checkmark\", summary: \"With additional context\"}, \"Three\", \"Four\", \"Five\", \"Six\", \"Seven\", \"Eight\"];"
            + " onActivated: choice = index } }");
        try {
            Item menu = view.findByObjectName("longMenu");
            clickCenter(view, menu);
            render(view, 260, 260, null);
            Item panel = view.findByObjectName("miuixDropdownPanel");
            Item viewport = view.findByObjectName("miuixDropdownViewport");
            check(panel.x.peekDouble() >= 8 && panel.x.peekDouble() + panel.width.peekDouble() <= 252, "dropdown fits narrow window horizontally");
            check(panel.y.peekDouble() >= 8 && panel.y.peekDouble() + panel.height.peekDouble() <= 252, "dropdown fits short window vertically");
            check(number(viewport, "contentHeight") > viewport.height.peekDouble(), "long dropdown scrolls internally");
            click(view, coordinate(viewport, true) + 35, coordinate(viewport, false) + 30);
            check(number(view.root(), "choice") == -1 && Boolean.TRUE.equals(get(menu, "menuOpen")), "disabled dropdown option ignores clicks");
            float px = coordinate(viewport, true) + 100;
            float py = coordinate(viewport, false) + 180;
            drag(view, px, py, px, py - 120);
            check(number(viewport, "contentY") > 0, "drag scrolls dropdown list");
            view.root().width.set(210);
            view.root().height.set(230);
            settle(view);
            render(view, 210, 230, null);
            check(panel.x.peekDouble() + panel.width.peekDouble() <= 202 && panel.y.peekDouble() + panel.height.peekDouble() <= 222, "open popup follows resize constraints");
            set(menu, "enabled", false);
            settle(view);
            render(view, 210, 230, null);
            check(Boolean.FALSE.equals(get(menu, "menuOpen")), "disabling preference closes popup");
        } finally {
            view.dispose();
        }
    }

    private static void overlayPreviews() throws Exception {
        for (boolean dark : new boolean[] {false, true}) {
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
            DirResourceLoader resources = new DirResourceLoader(project);
            QmlView view = QmlView.withStockTypes(new QmlEngine()).resources(resources);
            HostFonts.configure(view, resources);
            view.load(Files.readString(project.resolve("showcases/MiuixOverlayShowcase.qml")));
            try {
                for (String preview : new String[] {"dialog", "dropdown", "longDialog"}) {
                    for (int width : new int[] {390, 1040}) {
                        view.root().width.set(width);
                        view.root().height.set(800);
                        set(view.root(), "preview", preview);
                        settle(view);
                        render(view, width, 800, preview + "-" + width + (dark ? "-dark" : "-light"));
                        if (!preview.equals("dropdown")) {
                            Item panel = visibleItem(view.root(), "miuixDialogPanel");
                            check(panel != null && panel.height.peekDouble() <= 776, "visible dialog bounds remain on screen");
                            if (preview.equals("longDialog")) {
                                Item scroll = visibleItem(view.root(), "miuixDialogViewport");
                                Item accept = visibleItem(view.root(), "miuixDialogAccept");
                                float actionY = coordinate(accept, false);
                                check(number(scroll, "contentHeight") > scroll.height.peekDouble(), "long dialog body has scrollable overflow");
                                drag(view, coordinate(scroll, true) + 100, coordinate(scroll, false) + 200,
                                    coordinate(scroll, true) + 100, coordinate(scroll, false) + 40);
                                check(number(scroll, "contentY") > 0 && coordinate(accept, false) == actionY, "dialog content scrolls while actions stay fixed");
                            }
                        }
                    }
                    click(view, 5, 5);
                    render(view, 1040, 800, null);
                    set(view.root(), "preview", "none");
                    settle(view);
                }
            } finally {
                view.dispose();
            }
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
    static void render(QmlView view, int width, int height, String name) throws Exception {
        try (Surface surface = Surface.makeRasterN32Premul(width, height)) {
            SurfaceBackend backend = new RasterBackend(surface, width, height);
            for (int i = 0; i < 42; i++) {
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
