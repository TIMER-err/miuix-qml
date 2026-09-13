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
| `basic/TabRow.kt` | 16 px normal tabs, 14 px contour tabs |
| `icon/basic/{Search,Check,ArrowRight,ArrowUpDown}.kt` | Original path coordinates rendered with QML Shape/PathCubic; geometry scales as a whole |

`BasicComponent` shares the preference layout used by the Super controls. It reserves action space and wraps the remaining text; trailing content is limited to 40% of the available width. This is a practical QML layout, not a port of Compose's intrinsic-measure algorithm.

## Current engine integration

The accompanying qml4j changes preserve Row/Column width and height bindings during layout. Positioners publish implicit content size and resize only axes they own. This fixes buttons collapsing during initial layout and content failing to resize with its parent. Three engine regressions cover responsive rows, wrapped columns, and shrinking after children are hidden.

The desktop host and screenshot tool now configure the same fonts. Project-supplied files take priority over the host's bundled faces. Basic Miuix icons use native vector geometry; remaining icon names require the host's Material Symbols font.

## Continuous corners and overlays

`SmoothRectangle.qml` ports the four cubic segments from `miuix-squircle/.../SquirclePath.kt`: extension 1.1 and control ratio 0.643. It updates the path only when geometry changes using standard QML `Shape`, `ShapePath`, `PathLine`, and `PathCubic`. Buttons and dialogs use this silhouette; no new engine primitive is needed. A raster regression checks the corner exterior, fill, inset border, resize, and color invalidation.

Card content keeps the existing rounded-rectangle mask. The current engine's `layer.effect` mask shortcut only recognizes Rectangle geometry; replacing that mask with Shape would silently remove clipping. This pass deliberately keeps the working mask instead of extending the engine or allowing children to bleed outside cards.

Dialogs now use the upstream adaptive placement, centered text, theme-specific dimming, and button colors. Content scrolls independently of the actions. Small-window actions stack according to the actual label widths. Dropdown popups clamp to the window, scroll long lists, render summaries and disabled rows, and reveal the selected entry on opening.

The overlay changes were verified using the committed engine source at `c6f374c`, without modifying qml4j. `showcases/MiuixOverlayShowcase.qml` exposes the new states for desktop review; `tools/verify.sh` exports phone and desktop images in both themes.

## Remaining differences

- Continuous corners use the upstream cubic path, rather than its SDF shader implementation. Card content still uses circular clipping as explained above.
- Animations use QML cubic easing; the upstream spring physics, overscroll, and haptic feedback are not reproduced.
- The current engine resolves ordinary and medium/bold text through its host font APIs, so typography is close rather than pixel-identical to Android system fonts.
- The legacy MD3-compatible components have not all been individually compared against the current upstream library. This pass focuses on settings rows, common controls, theme states, and a responsive showcase.
- Native Android execution was not tested in this pass. Validation uses the current desktop engine and its Skia raster backend.

## Reproduce

Run `./tools/verify.sh`. Generated images and compiled check classes live under ignored `build/`. Committed light/dark previews show the 1040 px layout. The default showcase also supports live theme switching, preference toggles, dropdown selection, search/clear, button feedback, and slider dragging.
