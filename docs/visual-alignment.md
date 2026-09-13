# Visual alignment

Reference: compose-miuix-ui/miuix commit [`5157b503`](https://github.com/compose-miuix-ui/miuix/tree/5157b503e86e2bfc2db61db00fff5df41326394a).

## Source mapping

All paths below are relative to `miuix-ui/src/commonMain/kotlin/top/yukonga/miuix/kmp/` in the reference tree.

| Source | QML adaptation |
| --- | --- |
| `theme/Colors.kt` | Light/dark surfaces, primary, separate disabled button/switch/slider roles, slider key-point colors |
| `theme/TextStyles.kt` | 17 px preference titles/buttons, 14 px summaries, 32 px showcase title |
| `basic/Component.kt` | 56 px minimum preference height, 16 px content padding, measured multiline text |
| `basic/Button.kt` | 58 × 40 minimum, 16 px corner radius, 16/13 px horizontal/vertical padding |
| `basic/Switch.kt` | 49 × 28 track, 20 px thumb, offsets 4/25, pressed thumb scale 1.127 |
| `basic/Slider.kt` | 28 px track, 0.72 thumb ratio, 3.855 px key-point radius, horizontal gesture capture |
| `basic/Card.kt` | 16 px radius, surface-container background |
| `layout/DialogContentLayout.kt` | 420 px max width, 32 px corners, 12/24 px outside/inside margins, 18 px title, 16 px summary, phone bottom / desktop center |
| `basic/Dropdown.kt` | 16 px option titles, 14 px summaries, 20 px outer / 12 px middle row padding, 20 px checkmark, disabled entries |
| `utils/MiuixIndication.kt` | Flat indication, additive 0.06 hover / 0.08 focus / 0.10 press alpha |
| `basic/TextField.kt` | Secondary-container background, 16 px corners/padding, 2 px focused border, 17/10 px inline/floating label, content-driven label state |
| `basic/RadioButton.kt` | 26 px mark, original 56 px path and 7 px stroke, animated two-segment drawing and 0.85 pressed scale |
| `basic/TabRow.kt` | 16/14 px text, 42/45 px height, 12/8 px continuous corners, 5 px contour inset, selected-item scrolling |
| `basic/NavigationBar.kt` | 64 px items, 26 px icons, 12 px labels, 8 px icon top padding, 0.4 unselected / 0.5 selected-pressed / 0.6 unselected-pressed alpha |
| `basic/NavigationRail.kt` | 80/240 px widths, 24 px outer/header spacing, 28 px icons, 12/16 px labels, 16 px indicator radius, synchronized expansion geometry |
| `basic/Badge.kt` | 6/16 px minimum sizes, 4 px horizontal padding, 11 px labels, 6/6 dot and 12/14 content offsets, top/end bounds |
| `icon/basic/{Search,Check,ArrowRight,ArrowUpDown}.kt` | Original path coordinates rendered with QML Shape/PathCubic; geometry scales as a whole |

`BasicComponent` shares the preference layout used by the Super controls. It reserves action space and wraps the remaining text; trailing content is limited to 40% of the available width. This is a practical QML layout, not a port of Compose's intrinsic-measure algorithm.

## Current engine integration

The accompanying qml4j changes preserve Row/Column width and height bindings during layout. Positioners publish implicit content size and resize only axes they own. This fixes buttons collapsing during initial layout and content failing to resize with its parent. Three engine regressions cover responsive rows, wrapped columns, and shrinking after children are hidden.

The desktop host and screenshot tool now configure the same fonts. Project-supplied files take priority over the host's bundled faces. Basic Miuix icons use native vector geometry; remaining icon names require the host's Material Symbols font.

## Continuous corners and overlays

`SmoothRectangle.qml` ports the four cubic segments from `miuix-squircle/.../SquirclePath.kt`: extension 1.1 and control ratio 0.643. It updates the path only when geometry changes using standard QML `Shape`, `ShapePath`, `PathLine`, and `PathCubic`. Buttons and dialogs use this silhouette; no new engine primitive is needed. A raster regression checks the corner exterior, fill, inset border, resize, and color invalidation.

Borders use an even-odd filled ring with explicit inner/outer contours. This avoids the curved-stroke rendering path and its closing caps, while preserving transparent interiors. It adds no offscreen texture or supersampling pass. GPU comparisons at 1, 1.25, 1.5, and 2× cover the thin red error border; raster checks cover antialiased corner coverage and removal when border width becomes zero.

Card content keeps the existing rounded-rectangle mask. The current engine's `layer.effect` mask shortcut only recognizes Rectangle geometry; replacing that mask with Shape would silently remove clipping. This pass deliberately keeps the working mask instead of extending the engine or allowing children to bleed outside cards.

Dialogs now use the upstream adaptive placement, centered text, theme-specific dimming, and button colors. Content scrolls independently of the actions. Small-window actions stack according to the actual label widths. Dropdown popups clamp to the window, scroll long lists, render summaries and disabled rows, and reveal the selected entry on opening.

The overlay changes were verified using the committed engine source at `c6f374c`, without modifying qml4j. `showcases/MiuixOverlayShowcase.qml` exposes the new states for desktop review; `tools/verify.sh` exports phone and desktop images in both themes.

## Remaining differences

- Continuous corners use the upstream cubic path, rather than its SDF shader implementation. Card content still uses circular clipping as explained above.
- Animations use QML cubic easing; the upstream spring physics, overscroll, and haptic feedback are not reproduced.
- The current engine resolves ordinary and medium/bold text through its host font APIs, so typography is close rather than pixel-identical to Android system fonts.
- Legacy API extensions (including wavy progress, charts and data tables) are retained. They are not all direct equivalents of upstream Miuix components.
- Native Android execution was not tested. No device is connected; the installed emulator is x86_64 while the frozen Android shell packages ARM64 Skija natives. Validation covers the current desktop engine with raster and OpenGL rendering.
- TextField remains a single-line QML TextInput. Compose multiline text, input/output transformations, and platform keyboard options are not ported. Error/supporting text, auto-clear, password actions, disabled colors, and the optional resting outline retain the QML library's API extensions.

## Inputs and selection

The input pass also uses qml4j `c6f374c` without engine changes. TextField aliases the underlying input value so keyboard edits, external assignments, and clearing share a single value. Empty labels remain inline on focus and float only when content exists. Password and error actions occupy the same reserved trailing slot; read-only inputs hide clear and disabled fields reject interaction. Helper/error text contributes its measured height instead of reserving a fixed single line.

RadioButton draws the upstream path directly, without the host icon font. The two line segments are trimmed by path length during selection, while deselection fades and pressing scales to 0.85. QML cubic easing approximates upstream spring/easing behavior. String enum values for ShapePath cap/join styles use the existing engine's supported syntax.

`showcases/MiuixInputShowcase.qml` provides responsive examples in both themes. Integration checks exercise keyboard input, programmatic replacement, clearing and retyping, password/disabled/read-only states, acceptance, error wrapping, controlled radio selection, and marker pixels.

Inline labels and placeholders center their measured line height explicitly. The current host does not apply `Text.verticalAlignment` during drawing, so setting that property alone leaves them too high. The component computes `y` from `implicitHeight`, and a raster regression compares the actual glyph bands of labels, placeholders, and typed text. See the [GPU before/after comparison](input-polish-gpu.png).

## Reproduce

`showcases/MiuixRailShowcase.qml` covers collapsed/expanded rails, classic mode, fixed footer, scrolling, dot/count badges and dynamic notification updates. Unlike upstream's nullable state default, the QML rail is expandable by default to retain its existing `extended` API; `expandable: false` selects the classic appearance. Footer, section labels and custom delegates are QML extensions. The public rail delegates rendering to a separate body component so caller-provided header/footer factories cannot replace internal menu factories in the current compiler. No engine modification is needed.

Badge labels use the existing `onErrorColor` token and measured vertical centering. Custom content can increase badge height, and bounded placement follows the upstream top/end constraints. Nested navigation slots reference their owning entry explicitly so badges keep their numeric values instead of falling back to dots. Custom content does not inherit Compose's ambient typography/color automatically.

`showcases/MiuixNavigationShowcase.qml` covers navigation display modes, content switching, controlled tab selection, and narrow-window scrolling. The NavigationBar content-stack API is retained; only the bar chrome follows upstream. Disabled entries use a reduced 0.2 opacity as a QML extension. System safe-area insets must be supplied through `bottomInset`; the component does not query platform insets. Navigation icons continue to use `Icon` and its host-font fallback where no upstream vector path is available.

Normal tabs switch their indicator position directly; contour tabs use the upstream 200 ms linear slide. Automatic horizontal scrolling uses QML cubic easing. User presses cancel pending automatic movement so dragging remains direct. The navigation pass leaves qml4j source unchanged.

Standard TabRow now defaults to measuring each full title plus 24 px horizontal padding, with the bold width reserved before selection. This deliberately differs from upstream's equal-width/eliding policy: long category names remain readable in a horizontally scrolling strip. `equalWidth: true` restores that policy and remains the contour default. Indicator placement and selected-item scrolling use actual delegate bounds in both modes.

Run `./tools/verify.sh`. Generated images and compiled check classes live under ignored `build/`. Committed light/dark previews show the 1040 px layout. The default showcase also supports live theme switching, preference toggles, dropdown selection, search/clear, button feedback, and slider dragging.

## Completion pass and Monet

This pass uses qml4j `c6f374caf17387b45c89d7a20f3a297dddd85843` without engine source changes. The upstream HEAD was rechecked at `5157b503e86e2bfc2db61db00fff5df41326394a`.

- `MonetScheme.qml` maps native `StyleManager.lightScheme` / `darkScheme` through upstream `theme/MonetMapping.kt`. Alpha-derived disabled and secondary roles are composited over the appropriate surfaces. The light primary-container 90/10 tone pair supplies fixed primary roles. `Theme.dynamicColors` opts in, and native seed or HCT updates propagate to existing controls. Original Miuix colors remain available. Wallpaper extraction is not supplied by the current native `setSourceImage()` implementation.
- TopAppBar adds the 32 px large title, subtitle, 52 px collapsed bar, 26 px title padding and scroll-driven geometry. FAB keeps the upstream 60 px default circle and uses shared indication; FloatingToolbar uses continuous outer corners while preserving its working circular content mask. Its shadow source is declared directly rather than inside a Loader; this prevents the toolbar disappearing during a GPU theme switch.
- Snackbar uses a 16 px continuous corner, 12 px padding and a primary action pill. ToolTip adds plain/rich content, 200/320 px limits, 12/16 px corners, anchored placement and edge flipping. Interrupted transitions remain safe. Menu fixes its module-relative submenu path and uses a component-owned popup registry instead of writing undeclared properties on application roots.
- Progress uses upstream 6 px linear tracks, 30/4 px circular geometry, 1250 ms linear sweeps, 1000/1600 ms circular rotation/sweep and the 20 px, 800 ms loading ring/orbit. The standard zero-progress indicators retain the upstream minimum mark.
- NumberPicker restores 32 px semibold labels, fractional fade/scale/color, bounded release travel and animated snapping. Seven delegates cover the default five-row viewport even with a million-item range. External values and shrinking ranges synchronize without losing initial values during construction.
- ColorSlider places gradient endpoints under the thumb centers. ColorPicker supports HSV, OKHSV, OKLAB and OKLCH with alpha and external-state synchronization. Matrices follow `color/core/Transforms.kt`; the OkHSV cusp is solved numerically, and non-HSV displayed gradients use thirteen samples. Black and white conversions are checked explicitly.
- PullToRefresh supplies controlled refresh state, programmatic refresh, completion feedback and a stretching ring. It reserves a header inside its own Flickable, allowing native child hit testing without changing qml4j's unimplemented overscroll. Its gesture coordination and cubic settling are adaptations rather than Compose's nested-scroll spring simulation.
- Buttons and selection controls gain keyboard activation, tabs and pickers gain arrow navigation, and menus skip disabled entries. Dialog Escape policy is independent of scrim dismissal; closing restores the earlier keyboard focus.

`./tools/verify.sh` passes **294 assertions**, including 55 completion checks covering dynamic palette propagation, keyboard/dialog focus, anchored feedback, submenu actions, picker edge cases and refresh lifecycles. Desktop and phone previews cover both themes. `./tools/verify.sh gpu` generates OpenGL readbacks at 1, 1.25, 1.5 and 2× in both themes and checks that toolbar glyph pixels survive live theme changes; it uses the same NVIDIA driver-threading default as the desktop launcher. The complete showcase also loads successfully in the native Wayland host.

A local drag-update microbenchmark (1,000 measured pointer moves after warmup, including binding/layout settling) measured the continuously styled wheel at approximately 0.33 ms median and 0.78 ms P95, versus 0.08/0.76 ms for the previous fixed-style strip. This measures update cost, not end-to-end frame latency, and is machine-specific.

See [Monet light](complete-light.png), [Monet dark](complete-dark.png), and [phone dark](complete-phone-dark.png). Launch `./run.sh showcases/MiuixCompleteShowcase.qml` for live seed colors, theme switching, app-bar scrolling, menus and refresh.
