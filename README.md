# miuix-qml

HyperOS / MIUIX components running on [qml4j](https://github.com/TIMER-err/qml4j), with visual tokens and geometry adapted from [compose-miuix-ui/miuix](https://github.com/compose-miuix-ui/miuix).

![Miuix QML light showcase](docs/preview-light.png)

## Run with the current engine

Keep the two checkouts alongside each other:

```text
projects/
  qml4j/
  miuix-qml/
```

From this repository:

```bash
./run.sh
QML4J_DARK=true ./run.sh
./run.sh showcases/MiuixGalleryShowcase.qml
./run.sh showcases/MiuixOverlayShowcase.qml
./run.sh showcases/MiuixInputShowcase.qml
./run.sh showcases/MiuixNavigationShowcase.qml
./run.sh showcases/MiuixRailShowcase.qml
./run.sh showcases/MiuixCompleteShowcase.qml
```

Set `QML4J_DIR=/path/to/qml4j` for another location. The launcher rebuilds the local engine and places its compiled classes before Maven dependencies, so it runs the current source. The default showcase switches between one and two columns at 760 px, and the sun/moon action changes the theme live.

The companion desktop launcher prefers native Wayland in a Linux Wayland session and defaults NVIDIA driver threaded optimizations to off for that process, with vsync on. This combination avoided the captured old-frame reversals on the tested NVIDIA/KDE machine (1287 recorded frames with no submission-counter decrease). Set `QML4J_PLATFORM=x11` to select X11 or `QML4J_PLATFORM=auto` to use GLFW's selection policy; an explicit `__GL_THREADED_OPTIMIZATIONS` value is preserved. `QML4J_FRAME_STAMP=true ./run.sh` enables the optional submission counter for further diagnosis.

In a Wayland session, X11 now defaults to an EGL context. Raw OpenGL comparisons and the actual showcase showed no reversal on this path with driver threading disabled, including when unfocused. `QML4J_GL_CONTEXT=native QML4J_PLATFORM=x11` restores GLX for diagnosis. These Linux observations do not establish a Windows fix.

The baseline engine integration includes desktop/raster font setup (`HostFonts`) and Row/Column size-binding preservation (`PositionerSizing`) from the previous alignment pass. Use that source build for the showcase and checks; these changes are not yet in a released engine artifact. The desktop host uses project `fonts/` overrides when supplied, otherwise its bundled Roboto and Material Symbols fonts.

## Use components

Point the engine's resource loader at this repository, then `import miuix.Core`. Public names retain the existing `md3.Core` conventions where they overlap, including `Button`, `Switch`, and `Theme.color.primary`.

```qml
import QtQuick
import miuix.Core

Rectangle {
    width: 390
    height: 700
    color: Theme.color.surface
    Column {
        width: parent.width
        SmallTitle { text: "Network"; width: parent.width }
        Card {
            x: 12
            width: parent.width - 24
            height: rows.height
            Column {
                id: rows
                width: parent.width
                SuperSwitch { title: "Wi-Fi"; summary: "Home"; checked: true }
                SuperSwitch { title: "Bluetooth" }
            }
        }
    }
}
```

Preference rows wrap their text and compute their height from content plus 16 px padding. Use a `Column` and its measured height for a group of rows instead of fixed `y: 56` offsets.

## Updated components

| Component | Behavior |
| --- | --- |
| `BasicComponent` | Shared preference layout with `title`, `summary`, `startAction` / `endAction` components, padding, disabled state, and `clicked()` |
| `SuperSwitch`, `SuperCheckbox` | Clickable whole rows, single toggle notification, wrapped summaries, disabled state; checkbox also supports `indeterminate` |
| `SuperArrow`, `SuperDropdown` | Bounded trailing text and upstream arrow geometry; dropdown exposes `menuOpen` and `selectOnClick` |
| `SearchBar` | Visible placeholder, input focus, optional clear button, `clear()` and `cleared()` |
| `Button` | Content-based height honoring `verticalPadding`, configurable `cornerRadius`, correct disabled primary-button colors |
| `Slider` | Single/range selection, stepped dragging, optional ticks/value label, reverse direction, separate handle callbacks |
| `Icon` | Native upstream paths for `search`, `check`, `chevron_right`, `unfold_more`; other names use the host's icon font |
| `Dialog` | Phone bottom sheet / desktop centered presentation, 420 px max width, centered text, scrollable body with fixed actions, safe interrupted transitions |
| `SmoothRectangle` | Upstream continuous-corner path, responsive geometry and inset border, implemented with existing `Shape` / `PathCubic` |
| `Ripple` | Flat Miuix indication with additive hover/focus/press alpha; existing long-press and corner APIs retained |
| `TextField` | Continuous background, 2 px focus border, internal 17/10 px label, password/clear actions and wrapping helper text |
| `RadioButton` | Upstream 26 px vector check with animated drawing and press feedback; selection remains controlled by the caller |
| `NavigationBar` | 64 px items with 26 px icons and 12 px labels, three display modes, optional divider/inset, controlled selection and disabled entries |
| `NavigationRail` | Synchronized 80/240 px expansion, 28 px icons, 12/16 px labels, scrollable menu, fixed footer and configurable content slots |
| `Badge`, `BadgedBox` | 6 px dots, 16 px minimum number badges, 11 px white labels, measured custom content and optional top/end bounds |
| `TabRow`, `TabRowWithContour` | Continuous corners and outlines, automatic selection reveal, horizontal scrolling, empty/disabled states |
| `Theme` | Mutable `dark`, shared `metrics`, dedicated disabled button/switch/slider colors |

The overlay showcase demonstrates confirmation and long-content dialogs, plus a dropdown with summaries and disabled entries. `Dialog` accepts `maxWidth`, `cornerRadius`, `padding`, `outsideMargin`, `topInset`, `bottomInset`, and a `largeScreen` override. By default it centers when the window is at least 840 × 480; otherwise it slides up from the bottom. Two actions stack when their labels cannot fit side by side. Repeated `open()` / `close()` calls are guarded, and reopening cancels a pending close.

Dropdown entries may be strings or `{ text, summary, enabled }` objects. `popupWidth` defaults to 288 and `popupMaxHeight` to 420; both are capped to the visible window. Long lists scroll, selected entries are revealed on opening, and the popup follows its anchor during resize.

`TextField` keeps its label inline while empty, including when focused. With text, the label shrinks inside the field; `useLabelAsPlaceholder: true` hides it instead. `cornerRadius`, `horizontalPadding`, `verticalPadding`, `backgroundColor`, `labelColor`, and `borderColor` customize the chrome. The existing `type: "outlined"` option adds a resting outline. `clearButtonEnabled`, `clear()`, `cleared()`, and `focusInput()` control the clear action and focus. Password, custom trailing action, error indicator, and clear action share one slot. Supporting/error text wraps and contributes to `implicitHeight`.

`RadioButton.checked` is controlled: update it in `onClicked`, or bind it to a shared selected value. Clicking the marker, label, or space between them emits one signal. Long labels wrap within the assigned width.

`NavigationBar` retains its content stack: supply `{ icon, text, enabled, badge }` entries in `model` and corresponding content children. `mode` accepts `"iconAndText"`, `"iconOnly"`, or `"iconWithSelectedLabel"`. `showDivider` defaults to true; `bottomInset` reserves any host-provided safe area. For external state, set `selectOnClick: false`, bind `currentIndex`, and handle `activated(index)`. The bar uses Miuix icon/label emphasis without a selected capsule background.

`NavigationRail` uses the same entry format. It is expandable by default: `extended` controls expansion, and `showToggle` controls the built-in button. Set `expandable: false` for the upstream classic rail without a selection pill or toggle. `minWidth` and `expandedWidth` default to 80 and 240; all morphing geometry follows one animation progress. `header`, `headerActions`, `footer`, `sectionLabel`, and `delegate` remain available. The footer stays fixed while the menu scrolls. A custom delegate can read `parent.itemData`, `parent.itemIndex`, and `parent.selected`. Controlled selection uses `selectOnClick: false` and `itemClicked(index, itemData)`.

For navigation badges, omit `badge` or use `null` to hide it, `""` for a dot, or a short string/number for content. `BadgedBox.badgeBounds` optionally supplies `{ x, y, width, height }` in anchor coordinates; badges clamp to its top and right edges. Navigation supplies these bounds automatically. `Badge.text` supplies its own 11 px label styling; custom content sets its own colors and fonts and contributes its measured size.

Both tab rows support `selectOnClick: false` with `tabSelected(index)`. Standard tabs default to content-sized widths so category names remain complete and overflow scrolls horizontally. Width measurement reserves the bold selected state, avoiding shifts when selection changes. Set `equalWidth: true` for the upstream equal-width/eliding layout; contour tabs keep that mode by default. `minWidth` applies in both modes; `maxWidth` participates only in equal-width calculation. The selected tab is revealed on initial layout and after external state or size changes; subsequent selections animate scrolling. Dragging scrolls the strip without selecting a tab. Empty lists hide the indicator and reset scrolling.

For a controlled dropdown, set `selectOnClick: false`, bind `currentIndex` to application state, and update that state in `onActivated`. This preserves the binding when another control changes the selected value.

```qml
Slider {
    width: 300
    from: 0
    to: 100
    rangeMode: true
    firstValue: 20
    secondValue: 80
    stepSize: 10
    tickMarksEnabled: true
    onFirstMoved: console.log(firstValue)
    onSecondMoved: console.log(secondValue)
}
```

Sliders capture a gesture after horizontal intent is established. Tapping leaves the value unchanged; vertical drags can scroll a surrounding `Flickable`. `stepSize > 0` snaps drag values. `firstMoved()` / `secondMoved()` identify the active range handle; `editingFinished()` fires once at the end of a drag. Endpoints clamp rather than cross. Use `from < to` and ordered initial range values.

## Monet colors

Miuix uses qml4j's built-in `StyleManager` for HCT seed generation. Enable the mapped palette explicitly; the original Miuix light/dark colors remain the default:

```qml
Component.onCompleted: {
    Theme.dynamicColors = true
    Theme.setSeedColor("#109868")
    Theme.setDark(false)
}
```

`StyleManager.seedColor` and `StyleManager.setSeedColorHct(hue, chroma, tone)` also update the library reactively. `StyleManager.isDarkTheme` drives `Theme.dark` unless the application has assigned its own binding/value to `Theme.dark`; `Theme.setDark()` updates both. The mapping includes foreground contrast roles, layered surfaces, errors, disabled controls and slider colors, following upstream `theme/MonetMapping.kt`. This uses supplied seed colors: the engine's `setSourceImage()` currently does not extract a wallpaper color.

The [complete showcase](showcases/MiuixCompleteShowcase.qml) connects color swatches, `ColorPicker` and `ColorPalette` to the native seed and provides a live dynamic-color switch.

## App bars, feedback and refresh

`TopAppBar` defaults to the large 32 px title with a 52 px collapsed bar. Bind `flickable` to a scrolling page, or bind `scrollOffset` yourself. `large: false` provides the small bar. `subtitle`, `largeTitle`, `titlePadding` and `topInset` customize the layout. When combining with `PullToRefresh`, bind `scrollOffset` to its logical `scrollOffset`, not to the reserved header offset of its internal Flickable.

`Snackbar` supports a wrapped message, a primary action pill and optional `withDismissAction`. `ToolTip` supports plain/rich content (`title`, `text`, `actionText`), `anchorItem`, four placements, edge clamping and vertical/horizontal flipping. `timeout: 0` makes either persistent; `open()`/`close()` tolerate interrupted transitions. Menu entries retain their action/submenu API, with keyboard navigation and disabled-item skipping. Dialog `closeOnEscape` is independent of `closeOnScrim`, and closing restores the earlier focus.

`LinearProgress` uses a 6 px track, `CircularProgress` uses a 30 px circle with 4 px stroke, and `LoadingIndicator` uses the upstream 20 px ring/orbiting dot. Values clamp to 0–1. The optional wavy progress style remains a QML extension.

`NumberPicker` renders a bounded strip regardless of range size, with 32 px text, continuous fade/scale/color, release velocity, animated snapping and arrow-key stepping. `ColorPicker.colorSpace` supports `HSV`, `OKHSV`, `OKLAB` and `OKLCH`. External colors and alpha synchronize across modes; slider gradients place endpoint colors under the indicator centers. OKLAB/OKLCH follow the reference library's channel conversion; OKHSV finds the gamut boundary numerically and samples its displayed gradients.

```qml
PullToRefresh {
    id: refresh
    anchors.fill: parent
    onRefreshRequested: {
        refreshing = true
        // Start the application's asynchronous reload here.
    }
    Column {
        width: refresh.width
        // Scrollable content, including interactive controls.
    }
}
```

Set `refreshing = false` when the reload finishes. Raising it programmatically shows the indicator without emitting `refreshRequested`. The component owns its Flickable and exposes `flickable`, `contentHeight`, `scrollOffset`, `progress`, `pullDistance` and `refreshState`. Use its default content slot for the page instead of wrapping another full-page Flickable. The implementation reserves scroll space for the refresh indicator because the current engine does not implement native overscroll; it is not Compose's nested-scroll/spring physics.

## Verification

Requires Maven and JDK 11 or newer for the check runner:

```bash
./tools/verify.sh
./tools/verify.sh gpu  # requires a working desktop OpenGL session
mvn -f ../qml4j/pom.xml -pl qml4j-demo-desktop -am verify
```

This alignment pass changes only the component library. It uses the existing engine primitives; card content retains its working rounded-rectangle mask because generic Shape masks in `layer.effect` are not supported by the current engine.

The integration runner loads every exported component, dispatches pointer and keyboard events, checks resizing and theme updates, and writes light/dark previews at 390 and 1040 px to `build/previews/`. It uses the current qml4j compiler, layout engine, input dispatcher, and Skia renderer.

See [visual alignment notes](docs/visual-alignment.md) for source references and remaining differences. Previews: [Monet light](docs/complete-light.png), [Monet dark](docs/complete-dark.png), [Monet phone](docs/complete-phone-dark.png), [dark showcase](docs/preview-dark.png), [phone dialog](docs/dialog-phone-light.png), [desktop dialog](docs/dialog-desktop-dark.png), [dropdown](docs/dropdown-phone-light.png), [inputs light](docs/inputs-light.png), [inputs dark](docs/inputs-dark.png), [phone navigation](docs/navigation-light.png), [desktop navigation](docs/navigation-dark.png), [expanded rail](docs/rail-light.png), [collapsed rail](docs/rail-dark.png).

## License

Apache-2.0. Upstream design, tokens, and basic vector paths are attributed in [NOTICE.md](NOTICE.md).
