import QtQuick
import miuix.Core

// Ports miuix basic/NumberPicker.kt: a vertical wheel whose items fade out away
// from the centre.
//
// Only `visibleItemCount + 2` slots exist regardless of the range, and the whole
// strip is moved by a single binding: the slots sit at fixed offsets inside it and
// only change their label when the wheel crosses an item. Profiling a drag showed
// ~55 JS binding evaluations per pointer move when every slot bound its own
// position and opacity to the live offset, which is what made the wheel stutter.
//
// qml4j divergence: upstream fades and scales each item against the live drag
// offset. Here the fade is fixed per slot -- the slots keep their row inside the
// moving strip, so it costs nothing per move and still tracks the wheel within half
// an item. There is no per-item scaling, and the wheel snaps on release.
Item {
    id: numberPickerRoot

    property int value: from
    property var range: [0, 10]
    property int from: range.length > 0 ? Number(range[0]) : 0
    property int to: range.length > 1 ? Number(range[1]) : 10
    property bool wrapAround: false
    property int visibleItemCount: 5
    property real itemHeight: 45
    property var label: null
    property color selectedTextColor: Theme.color.onSurfaceColor

    // Scroll offset in pixels, measured from the first item in the range.
    property real _contentOffset: 0
    property real _dragStartOffset: 0
    property real _pressY: 0
    property bool _dragging: false

    // Item index at the centre. Changes only when the wheel crosses an item, so the
    // per-slot label bindings stay idle during a drag.
    readonly property int _rounded: Math.round(_contentOffset / itemHeight)
    readonly property int _half: Math.floor(visibleItemCount / 2)

    implicitWidth: 72
    implicitHeight: visibleItemCount * itemHeight
    clip: true

    function _itemCount() {
        return Math.max(1, to - from + 1)
    }

    function _textFor(number) {
        if (typeof label === "function") return label(number)
        return String(number)
    }

    function _wrapIndex(index) {
        var count = _itemCount()
        if (wrapAround) return ((index % count) + count) % count
        return Math.max(0, Math.min(count - 1, index))
    }

    function _inRange(index) {
        return wrapAround || (index >= 0 && index < _itemCount())
    }

    function _settle() {
        var index = Math.round(_contentOffset / itemHeight)
        if (!wrapAround) index = Math.max(0, Math.min(_itemCount() - 1, index))
        _contentOffset = index * itemHeight
        var next = from + _wrapIndex(index)
        if (next !== value) value = next
    }

    onValueChanged: {
        if (_dragging) return
        var index = Math.max(from, Math.min(to, value)) - from
        if (Math.round(_contentOffset / itemHeight) !== index) {
            _contentOffset = index * itemHeight
        }
    }

    Component.onCompleted: _contentOffset = (Math.max(from, Math.min(to, value)) - from) * itemHeight

    // The single binding that moves during a drag: the strip slides by the
    // sub-item remainder, and the labels re-map when _rounded ticks over.
    Item {
        id: strip
        width: numberPickerRoot.width
        height: numberPickerRoot.itemHeight
        y: numberPickerRoot.height / 2 - numberPickerRoot.itemHeight / 2
            - (numberPickerRoot._contentOffset - numberPickerRoot._rounded * numberPickerRoot.itemHeight)

        Repeater {
            model: numberPickerRoot.visibleItemCount + 2

            delegate: Item {
                id: slot
                property int slotOffset: index - (numberPickerRoot._half + 1)
                width: numberPickerRoot.width
                height: numberPickerRoot.itemHeight
                y: slotOffset * numberPickerRoot.itemHeight
                visible: numberPickerRoot._inRange(numberPickerRoot._rounded + slotOffset)

                Text {
                    anchors.centerIn: parent
                    width: parent.width
                    text: numberPickerRoot._textFor(numberPickerRoot.from
                        + numberPickerRoot._wrapIndex(numberPickerRoot._rounded + slot.slotOffset))
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Theme.typography.titleMedium.family
                    font.pixelSize: Theme.typography.titleMedium.size
                    font.weight: slot.slotOffset === 0 ? Font.Bold : Font.Normal
                    color: numberPickerRoot.selectedTextColor
                    // Static: slotOffset never changes, so the fade costs nothing
                    // while the wheel spins.
                    opacity: {
                        var d = Math.abs(slot.slotOffset) / (numberPickerRoot._half + 0.5)
                        return (1 - d) * (1 - d * 0.5)
                    }
                }
            }
        }
    }

    // A wheel owns vertical drags outright: preventStealing keeps the enclosing
    // page from taking the gesture at the 10px threshold.
    MouseArea {
        anchors.fill: parent
        preventStealing: true

        onPressed: (mouse) => {
            numberPickerRoot._dragging = true
            numberPickerRoot._dragStartOffset = numberPickerRoot._contentOffset
            numberPickerRoot._pressY = mouse.y
        }
        onPositionChanged: (mouse) => {
            if (!pressed) return
            var next = numberPickerRoot._dragStartOffset - (mouse.y - numberPickerRoot._pressY)
            if (!numberPickerRoot.wrapAround) {
                var maxOffset = (numberPickerRoot._itemCount() - 1) * numberPickerRoot.itemHeight
                next = Math.max(0, Math.min(maxOffset, next))
            }
            numberPickerRoot._contentOffset = next
        }
        onReleased: {
            numberPickerRoot._dragging = false
            numberPickerRoot._settle()
        }
        onCanceled: {
            numberPickerRoot._dragging = false
            numberPickerRoot._settle()
        }
    }
}
