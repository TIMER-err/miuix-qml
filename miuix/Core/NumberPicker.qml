import QtQuick
import miuix.Core

// Ports miuix basic/NumberPicker.kt: a vertical wheel whose items fade and shrink
// away from the centre.
//
// Like upstream, only `visibleItemCount + 2` slots exist no matter how large the
// range is: each slot resolves which number it shows from the current scroll
// position, so a 0..59 wrap-around wheel is still seven items.
Item {
    id: numberPickerRoot

    property int value: from
    property var range: [0, 10]
    property int from: range.length > 0 ? Number(range[0]) : 0
    property int to: range.length > 1 ? Number(range[1]) : 10
    property bool enabled: true
    property bool wrapAround: false
    property int visibleItemCount: 5
    property real itemHeight: 45
    property var label: null
    property color selectedTextColor: Theme.color.onSurfaceColor
    property color unselectedTextColor: Theme.color.onSurfaceVariantColor
    property color disabledSelectedTextColor: Theme.color.disabledOnSecondaryVariant
    property color disabledUnselectedTextColor: Theme.color.disabledOnSecondaryVariant

    readonly property int _itemCount: Math.max(1, to - from + 1)
    readonly property int _halfVisible: Math.floor(visibleItemCount / 2)

    // Scroll position in items, relative to `from`.
    property real _position: 0
    readonly property int _rounded: Math.round(_position)
    readonly property real _fraction: _position - _rounded

    property real _dragStartPosition: 0
    property real _pressY: 0
    property bool _dragging: false
    property bool _syncing: false
    property real _snapTarget: 0

    implicitWidth: 72
    implicitHeight: visibleItemCount * itemHeight
    clip: true

    function _textFor(number) {
        if (typeof label === "function") return label(number)
        return String(number)
    }

    function _wrapIndex(index) {
        if (wrapAround) return ((index % _itemCount) + _itemCount) % _itemCount
        return Math.max(0, Math.min(_itemCount - 1, index))
    }

    function _inRange(index) {
        return wrapAround || (index >= 0 && index < _itemCount)
    }

    function _commit(index) {
        var next = from + _wrapIndex(index)
        if (next === value) return
        _syncing = true
        value = next
        _syncing = false
    }

    function _settle() {
        var target = Math.round(_position)
        if (!wrapAround) target = Math.max(0, Math.min(_itemCount - 1, target))
        _commit(target)
        _snapTarget = target
        snapAnimation.restart()
    }

    function _syncToValue() {
        if (_dragging || _syncing) return
        _snapTarget = Math.max(from, Math.min(to, value)) - from
        snapAnimation.restart()
    }

    onValueChanged: _syncToValue()
    onRangeChanged: _syncToValue()
    onFromChanged: _syncToValue()
    onToChanged: _syncToValue()
    Component.onCompleted: _position = Math.max(from, Math.min(to, value)) - from

    NumberAnimation {
        id: snapAnimation
        target: numberPickerRoot
        property: "_position"
        to: numberPickerRoot._snapTarget
        duration: 200
        easing.type: Easing.OutCubic
    }

    Repeater {
        model: numberPickerRoot.visibleItemCount + 2
        delegate: Item {
            id: slot
            width: numberPickerRoot.width
            height: numberPickerRoot.itemHeight

            // Slot offset from the centre row, in items.
            readonly property int _slot: index - (numberPickerRoot._halfVisible + 1)
            readonly property int _itemIndex: numberPickerRoot._rounded + _slot
            readonly property real _distance: Math.abs(_slot - numberPickerRoot._fraction)
            readonly property real _normalizedDistance: Math.min(1,
                _distance / (numberPickerRoot._halfVisible + 0.5))

            visible: numberPickerRoot._inRange(_itemIndex)
            y: numberPickerRoot.height / 2 - numberPickerRoot.itemHeight / 2
                + (_slot - numberPickerRoot._fraction) * numberPickerRoot.itemHeight

            Text {
                anchors.centerIn: parent
                width: parent.width
                text: numberPickerRoot._textFor(numberPickerRoot.from
                    + numberPickerRoot._wrapIndex(slot._itemIndex))
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.family: Theme.typography.titleMedium.family
                font.pixelSize: Theme.typography.titleMedium.size
                font.weight: slot._distance < 0.5 ? Font.Bold : Font.Normal
                color: numberPickerRoot.enabled
                    ? (slot._distance < 0.5
                        ? numberPickerRoot.selectedTextColor : numberPickerRoot.unselectedTextColor)
                    : (slot._distance < 0.5
                        ? numberPickerRoot.disabledSelectedTextColor
                        : numberPickerRoot.disabledUnselectedTextColor)
                opacity: (1 - slot._normalizedDistance) * (1 - slot._normalizedDistance * 0.5)
                scale: 1 - 0.2 * slot._normalizedDistance
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: numberPickerRoot.enabled
        preventStealing: true

        onPressed: (mouse) => {
            snapAnimation.stop()
            numberPickerRoot._dragging = true
            numberPickerRoot._dragStartPosition = numberPickerRoot._position
            numberPickerRoot._pressY = mouse.y
        }
        onPositionChanged: (mouse) => {
            if (!pressed) return
            var next = numberPickerRoot._dragStartPosition
                - (mouse.y - numberPickerRoot._pressY) / numberPickerRoot.itemHeight
            if (!numberPickerRoot.wrapAround) {
                next = Math.max(0, Math.min(numberPickerRoot._itemCount - 1, next))
            }
            numberPickerRoot._position = next
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
