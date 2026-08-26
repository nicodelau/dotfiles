import QtQuick
import qs.Core
import qs.Core.Components

ThemedSlider {
    id: root

    property int volume: 0
    property bool muted: false

    enabled: !root.muted
    value: root.volume
    icon: (root.muted || root.volume === 0) ? "volume-off" : "volume"
}
