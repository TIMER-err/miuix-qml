# miuix-qml

HyperOS / MIUIX QML components for [qml4j](https://github.com/TIMER-err/qml4j).

Visual tokens and behavior follow [compose-miuix-ui/miuix](https://github.com/compose-miuix-ui/miuix). Public QML names match `md3.Core` where they overlap (`Button`, `Switch`, `Theme.color.primary`, …), so an app can swap:

```qml
import md3.Core
```

for:

```qml
import miuix.Core
```

KernelSU-style preference rows are extra: `SuperSwitch`, `SuperArrow`, `SuperCheckbox`, `SuperDropdown`, plus `SmallTitle`, `SearchBar`, `Divider`.

## Layout

```
miuix/Core/     qmldir module `miuix.Core`
showcases/      gallery for the qml4j android-shell / desktop host
```

Point qml4j at this tree as a resource root (same way `shared-qml/` is loaded).

```qml
import QtQuick
import miuix.Core

Rectangle {
    color: Theme.color.surface
    Column {
        width: parent.width
        SmallTitle { text: "Network"; width: parent.width }
        Card {
            width: parent.width - 24
            height: 112
            SuperSwitch { title: "Wi-Fi"; summary: "Home"; checked: true }
            SuperSwitch { y: 56; title: "Bluetooth" }
        }
    }
}
```

## License

Apache-2.0. Design/tokens ported from compose-miuix-ui/miuix (Apache-2.0); see `NOTICE.md`.
