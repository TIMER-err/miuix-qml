import QtQuick
import miuix.Core

// The shared capsule slider behind every miuix color control (ColorPicker.kt's
// private ColorSlider): a gradient track with a white ring indicator.
//
// qml4j divergence: upstream insets the gradient by half the track height so the
// end colors sit under the indicator's rest positions; a QML Gradient always spans
// the full item, so the track is painted edge to edge.
Item {
    id: colorSliderRoot

    property real value: 0
    // The full HSV hue sweep; otherwise the track runs startColor -> endColor.
    property bool hue: false
    property color startColor: "#00000000"
    property color endColor: "#ffffffff"
    property bool checkerboard: false
    property real indicatorSize: 20
    signal moved(real newValue)

    implicitWidth: 240
    implicitHeight: 26

    readonly property real _trackRadius: height / 2
    // Upstream keeps the indicator centre inside the capsule: the usable travel is
    // the track width minus one track height.
    readonly property real _effectiveWidth: Math.max(1, width - height)

    // GradientStop.color is a string in qml4j, so bindings feed it #AARRGGBB.
    function _hex(value) {
        function part(channel) {
            var n = Math.round(Math.max(0, Math.min(1, channel)) * 255)
            return (n < 16 ? "0" : "") + n.toString(16)
        }
        return "#" + part(value.a) + part(value.r) + part(value.g) + part(value.b)
    }

    function _valueAt(x) {
        var half = height / 2
        var clamped = Math.max(half, Math.min(width - half, x))
        return Math.max(0, Math.min(1, (clamped - half) / _effectiveWidth))
    }

    onCheckerboardChanged: checkerboardCanvas.requestPaint()
    onWidthChanged: checkerboardCanvas.requestPaint()
    onHeightChanged: checkerboardCanvas.requestPaint()

    Canvas {
        id: checkerboardCanvas
        anchors.fill: parent
        visible: colorSliderRoot.checkerboard

        onPaint: {
            const ctx = getContext("2d")
            const w = width
            const h = height
            ctx.clearRect(0, 0, w, h)
            if (w <= 0 || h <= 0) return

            // Clip to the capsule, otherwise the squares show outside the rounded ends.
            const r = Math.min(h / 2, w / 2)
            ctx.save()
            ctx.beginPath()
            ctx.moveTo(r, 0)
            ctx.arcTo(w, 0, w, h, r)
            ctx.arcTo(w, h, 0, h, r)
            ctx.arcTo(0, h, 0, 0, r)
            ctx.arcTo(0, 0, w, 0, r)
            ctx.clip()

            const cell = h / 4
            ctx.fillStyle = "#ffffff"
            ctx.fillRect(0, 0, w, h)
            ctx.fillStyle = "#d0d0d0"
            for (let y = 0; y * cell < h; y++) {
                for (let x = 0; x * cell < w; x++) {
                    if ((x + y) % 2 === 0) continue
                    ctx.fillRect(x * cell, y * cell, cell, cell)
                }
            }
            ctx.restore()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: colorSliderRoot._trackRadius
        visible: colorSliderRoot.hue
        // Solid fallback: Rectangle.fill() prefers the gradient, so this is only
        // ever seen if the gradient shader does not paint.
        color: "#ff0000"
        // orientation 1 is Gradient.Horizontal.
        gradient: Gradient {
            orientation: 1
            GradientStop { position: 0.0000; color: "#ffff0000" }
            GradientStop { position: 0.1667; color: "#ffffff00" }
            GradientStop { position: 0.3333; color: "#ff00ff00" }
            GradientStop { position: 0.5000; color: "#ff00ffff" }
            GradientStop { position: 0.6667; color: "#ff0000ff" }
            GradientStop { position: 0.8333; color: "#ffff00ff" }
            GradientStop { position: 1.0000; color: "#ffff0000" }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: colorSliderRoot._trackRadius
        visible: !colorSliderRoot.hue
        color: colorSliderRoot.endColor
        gradient: Gradient {
            orientation: 1
            GradientStop { position: 0; color: colorSliderRoot._hex(colorSliderRoot.startColor) }
            GradientStop { position: 1; color: colorSliderRoot._hex(colorSliderRoot.endColor) }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: colorSliderRoot._trackRadius
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.1)
    }

    // Upstream draws a white ring with a soft dark glow around it.
    Item {
        width: colorSliderRoot.indicatorSize
        height: colorSliderRoot.indicatorSize
        anchors.verticalCenter: parent.verticalCenter
        x: colorSliderRoot.value * colorSliderRoot._effectiveWidth
            + colorSliderRoot.height / 2 - colorSliderRoot.indicatorSize / 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.25)
        }
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 3
            border.color: "#ffffff"
        }
    }

    // Upstream drives the track with draggable(Orientation.Horizontal), so the value
    // only moves once the gesture is a horizontal drag. Pressing (or scrolling the
    // page through the slider) must not change the color: no drag.target is used
    // either, which is what lets an enclosing Flickable steal a vertical drag.
    property real _pressX: 0
    property real _pressY: 0
    property bool _dragActive: false

    MouseArea {
        anchors.fill: parent
        // Open at press so a vertical flick still scrolls the page; closed once this
        // is a horizontal drag, so drifting off-axis cannot hand it to the Flickable.
        preventStealing: colorSliderRoot._dragActive

        onPressed: (mouse) => {
            colorSliderRoot._pressX = mouse.x
            colorSliderRoot._pressY = mouse.y
            colorSliderRoot._dragActive = false
        }
        onPositionChanged: (mouse) => {
            if (!pressed) return
            if (!colorSliderRoot._dragActive) {
                var dx = mouse.x - colorSliderRoot._pressX
                var dy = mouse.y - colorSliderRoot._pressY
                if (Math.abs(dx) < 8 || Math.abs(dx) <= Math.abs(dy)) return
                colorSliderRoot._dragActive = true
            }
            colorSliderRoot.moved(colorSliderRoot._valueAt(mouse.x))
        }
        onReleased: colorSliderRoot._dragActive = false
        onCanceled: colorSliderRoot._dragActive = false
    }
}
