import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Core.Components
import qs.Core.Services

SvgIconButton {
    id: root

    icon: AudioService.micMuted ? "microphone-off" : "microphone"
    iconColor: AudioService.micMuted ? Theme.muted : Theme.accent
    iconSize: Constants.sizeXl
    onClicked: AudioService.setMicMuted(!AudioService.micMuted)
}
