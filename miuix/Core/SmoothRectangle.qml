// Geometry ported from miuix-squircle/SquirclePath.kt (Apache-2.0).
import QtQuick
import QtQuick.Shapes
import miuix.Core

Shape {
    id: smoothRect
    property color color: Theme.color.surfaceContainer
    property real radius: 16
    property real extension: 1.1
    property real borderWidth: 0
    property color borderColor: Theme.color.outline
    property bool _ready: false

    onRadiusChanged: updatePath()
    onExtensionChanged: updatePath()
    onBorderWidthChanged: updatePath()
    onWidthChanged: updatePath()
    onHeightChanged: updatePath()
    Component.onCompleted: { _ready = true; updatePath() }

    // Updating the path on geometry changes also works in engines where nested
    // PathElement bindings cannot resolve the enclosing component's scope.
    function updatePath() {
        if (!_ready) return
        var inset = Math.min(Math.max(0, borderWidth), Math.min(width, height)) / 2
        var w = Math.max(0, width - 2 * inset)
        var h = Math.max(0, height - 2 * inset)
        var tile = Math.min(Math.max(0, radius - inset) * Math.max(1, Math.min(2, extension)), Math.min(w, h) / 2)
        var handle = tile * 0.357
        var right = width - inset
        var bottom = height - inset
        outline.startX = inset + tile
        outline.startY = inset
        edgeTop.x = right - tile; edgeTop.y = inset
        cornerTR.control1X = right - handle; cornerTR.control1Y = inset
        cornerTR.control2X = right; cornerTR.control2Y = inset + handle
        cornerTR.x = right; cornerTR.y = inset + tile
        edgeRight.x = right; edgeRight.y = bottom - tile
        cornerBR.control1X = right; cornerBR.control1Y = bottom - handle
        cornerBR.control2X = right - handle; cornerBR.control2Y = bottom
        cornerBR.x = right - tile; cornerBR.y = bottom
        edgeBottom.x = inset + tile; edgeBottom.y = bottom
        cornerBL.control1X = inset + handle; cornerBL.control1Y = bottom
        cornerBL.control2X = inset; cornerBL.control2Y = bottom - handle
        cornerBL.x = inset; cornerBL.y = bottom - tile
        edgeLeft.x = inset; edgeLeft.y = inset + tile
        cornerTL.control1X = inset; cornerTL.control1Y = inset + handle
        cornerTL.control2X = inset + handle; cornerTL.control2Y = inset
        cornerTL.x = inset + tile; cornerTL.y = inset
    }

    ShapePath {
        id: outline
        fillColor: smoothRect.color
        strokeColor: smoothRect.borderWidth > 0 ? smoothRect.borderColor : "transparent"
        strokeWidth: Math.min(Math.max(0, smoothRect.borderWidth), Math.min(smoothRect.width, smoothRect.height))
        PathLine { id: edgeTop }
        PathCubic { id: cornerTR }
        PathLine { id: edgeRight }
        PathCubic { id: cornerBR }
        PathLine { id: edgeBottom }
        PathCubic { id: cornerBL }
        PathLine { id: edgeLeft }
        PathCubic { id: cornerTL }
    }
}
