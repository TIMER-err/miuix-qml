package io.github.timer_err.qml4j.demo;

import io.github.humbleui.skija.Canvas;
import io.github.humbleui.skija.Bitmap;
import io.github.humbleui.skija.Image;
import io.github.humbleui.skija.DirectContext;
import io.github.humbleui.skija.EncodedImageFormat;
import io.github.humbleui.skija.ImageInfo;
import io.github.humbleui.skija.Surface;
import io.github.humbleui.skija.SurfaceOrigin;
import io.github.timer_err.qml4j.engine.QmlEngine;
import io.github.timer_err.qml4j.runtime.color.StyleManager;
import io.github.timer_err.qml4j.render.QmlView;
import io.github.timer_err.qml4j.render.items.core.Item;
import io.github.timer_err.qml4j.render.SurfaceBackend;
import org.lwjgl.glfw.GLFW;
import org.lwjgl.opengl.GL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

@SuppressWarnings("deprecation")
public final class MiuixGpuChecks {
    public static void main(String[] args) throws Exception {
        Path project = Path.of(args[0]);
        String source = Files.readString(project.resolve("showcases/MiuixCompleteShowcase.qml"));
        source = source.replace("height: 860", "height: 1000");
        GlfwPlatform.configure();
        if (!GLFW.glfwInit()) throw new IllegalStateException("GLFW init failed");
        GlfwContext.configure();
        GLFW.glfwWindowHint(GLFW.GLFW_VISIBLE, GLFW.GLFW_FALSE);
        long window = GLFW.glfwCreateWindow(800, 500, "Miuix GPU verification", 0, 0);
        if (window == 0) throw new IllegalStateException("GLFW window failed");
        GLFW.glfwMakeContextCurrent(window);
        GL.createCapabilities();
        try (DirectContext context = DirectContext.makeGL()) {
            for (float scale : new float[] {1, 1.25f, 1.5f, 2})
                renderScene(context, project, source, scale);
        }
        GL.setCapabilities(null);
        GLFW.glfwMakeContextCurrent(0);
        GLFW.glfwDestroyWindow(window);
        GLFW.glfwTerminate();
        System.out.println("PASS: GPU theme/glyph checks and previews at 1, 1.25, 1.5 and 2x");

    }

    private static void renderScene(DirectContext context, Path project, String source, float scale) throws Exception {
        int width = Math.round(1040 * scale), height = Math.round(1000 * scale);
        try (Surface surface = Surface.makeRenderTarget(context, true, ImageInfo.makeN32Premul(width, height), 0, SurfaceOrigin.BOTTOM_LEFT, null)) {
            DirResourceLoader resources = new DirResourceLoader(project);
            QmlView view = QmlView.withStockTypes(new QmlEngine()).resources(resources);
            HostFonts.configure(view, resources);
            ((StyleManager) StyleManager.__instance()).isDarkTheme.set(false);
            view.load(source);
            try {
                SurfaceBackend backend = new ProbeBackend(surface, context, width, height, scale);
                // Keep the render target alive across theme changes and view disposal.
                for (boolean dark : new boolean[] {false, true}) {
                    ((StyleManager) StyleManager.__instance()).isDarkTheme.set(dark);
                    for (int frame = 0; frame < 45; frame++) {
                        view.renderFrame(backend);
                        Thread.sleep(10);
                    }
                    save(surface, width, height, view, scale, project.resolve("build/previews/complete-gpu-" + (dark ? "dark-" : "light-") + scale + ".png"));
                }
            } finally { view.dispose(); }
        }
    }

    private static void save(Surface surface, int width, int height, QmlView view, float scale, Path path) throws Exception {
        try (Bitmap bitmap = new Bitmap()) {
            bitmap.allocN32Pixels(width, height);
            if (!surface.readPixels(bitmap, 0, 0)) throw new IllegalStateException("GPU readback failed");
            try (var image = Image.makeRasterFromBitmap(bitmap); var data = image.encodeToData(EncodedImageFormat.PNG)) {
                Files.write(path, data.getBytes());
            }
            checkToolbar(bitmap, view, scale);
        }
    }

    private static void checkToolbar(Bitmap bitmap, QmlView view, float scale) {
        Item toolbar = view.findByObjectName("miuixFloatingToolbar");
        Map<String, Object> position = view.root().mapFromItem(toolbar, 12, 8);
        int left = Math.round(((Number) position.get("x")).floatValue() * scale);
        int top = Math.round(((Number) position.get("y")).floatValue() * scale);
        int width = Math.round((toolbar.width.peekFloat() - 24) * scale);
        int height = Math.round((toolbar.height.peekFloat() - 16) * scale);
        Map<?, ?> scheme = (Map<?, ?>) ((StyleManager) StyleManager.__instance()).currentScheme.get();
        int expected = Integer.parseInt(scheme.get("onSurfaceColor").toString().substring(1), 16);
        int glyphPixels = 0;
        for (int y = top; y < top + height; y++) {
            for (int x = left; x < left + width; x++) {
                int actual = bitmap.getColor(x, y);
                int distance = Math.abs((actual >> 16 & 255) - (expected >> 16 & 255))
                    + Math.abs((actual >> 8 & 255) - (expected >> 8 & 255))
                    + Math.abs((actual & 255) - (expected & 255));
                if (distance < 60) glyphPixels++;
            }
        }
        if (glyphPixels < 12 * scale * scale)
            throw new AssertionError("Toolbar glyphs disappeared after GPU theme change at " + scale + "x");
    }

    private static final class ProbeBackend implements SurfaceBackend {
        final Surface surface;
        final DirectContext context;
        final int width, height;
        final float scale;
        ProbeBackend(Surface surface, DirectContext context, int width, int height, float scale) {
            this.surface = surface; this.context = context; this.width = width; this.height = height; this.scale = scale;
        }
        public Canvas acquireCanvas() {
            Canvas canvas = surface.getCanvas();
            canvas.restoreToCount(1); canvas.clear(0); canvas.save(); canvas.scale(scale, scale);
            return canvas;
        }
        public DirectContext recordingContext() { return context; }
        public void present() { context.flushAndSubmit(surface); }
        public int width() { return width; }
        public int height() { return height; }
        public void init(int w, int h) {}
        public void resize(int w, int h) {}
        public void dispose() {}
    }
}
