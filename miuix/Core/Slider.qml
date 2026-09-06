import QtQuick
import miuix.Core
Item {
    id: control

    property real from: 0.0
    property real to: 1.0
    property real value: 0.0
    property real stepSize: 0.0
    property bool snapMode: false
    property bool enabled: true
    property bool tickMarksEnabled: false
    property bool valueLabelEnabled: false
    property bool rangeMode: false
    property real firstValue: from
    property real secondValue: to
    readonly property alias pressed: mouseArea.pressed
    readonly property alias hovered: mouseArea.containsMouse

    signal moved()
    signal firstMoved()
    signal secondMoved()
    signal editingFinished()

    implicitWidth: 200
    implicitHeight: 28

    property var _colors: Theme.color
    property real _range: to - from
    property real _fraction: _range === 0 ? 0 : Math.max(0, Math.min(1, (value - from) / _range))
    property real _thumbRadius: height / 2
    property real _centerX: _thumbRadius + _fraction * Math.max(0, width - 2 * _thumbRadius)
    property real _thumbScale: (mouseArea.pressed || mouseArea.containsMouse) ? 1.127 : 1
    property real _pressX: 0
    property real _pressY: 0
    property bool _dragActive: false

    function setValue(v) {
        var newValue = Math.max(from, Math.min(to, v))
        if (stepSize > 0) {
            var steps = Math.round((newValue - from) / stepSize)
            newValue = from + (steps * stepSize)
            newValue = Math.max(from, Math.min(to, newValue))
        }
        if (control.value !== newValue) {
            control.value = newValue
            control.moved()
        }
    }

    function valueFromX(px) {
        var avail = Math.max(1, width - 2 * _thumbRadius)
        var f = Math.max(0, Math.min(1, (px - _thumbRadius) / avail))
        return from + f * _range
    }

    Item {
        anchors.fill: parent
        clip: true

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: control.enabled ? _colors.sliderBackground : _colors.disabledSecondaryVariant
        }

        Rectangle {
            x: 0
            y: 0
            width: control._centerX + control._thumbRadius
            height: parent.height
            radius: height / 2
            color: control.enabled ? _colors.primary : _colors.disabledPrimary
        }

        Rectangle {
            width: control.height * 0.72 * control._thumbScale
            height: width
            radius: width / 2
            x: control._centerX - width / 2
            anchors.verticalCenter: parent.verticalCenter
            color: control.enabled ? _colors.onPrimary : _colors.disabledOnPrimary
            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }
    }

    // Upstream drives the track with draggable(Orientation.Horizontal): the value
    // follows only once the gesture is a horizontal drag, so a press -- or a page
    // scroll that happens to start on the slider -- leaves it alone.
    //
    // Deliberately no drag.target: a MouseArea that drags its own target keeps the
    // gesture for good, which stopped an enclosing Flickable from ever scrolling
    // when the finger landed on a slider.
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: control.enabled
        hoverEnabled: true
        // Open at press so a vertical flick still scrolls the page; closed once this
        // is a horizontal drag, so drifting off-axis cannot hand it to the Flickable.
        preventStealing: control._dragActive

        onPressed: (mouse) => {
            control._pressX = mouse.x
            control._pressY = mouse.y
            control._dragActive = false
        }
        onPositionChanged: (mouse) => {
            if (!pressed) return
            if (!control._dragActive) {
                var dx = mouse.x - control._pressX
                var dy = mouse.y - control._pressY
                if (Math.abs(dx) < 8 || Math.abs(dx) <= Math.abs(dy)) return
                control._dragActive = true
            }
            control.setValue(control.valueFromX(mouse.x))
        }
        onReleased: {
            if (control._dragActive) control.editingFinished()
            control._dragActive = false
        }
        onCanceled: control._dragActive = false
    }
}
