import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services

SvgIconButton {
    id: root

    icon: HyprlandService.nightLightActive ? "moon-filled" : "moon"
    iconColor: HyprlandService.nightLightActive ? Theme.accent : Theme.muted
    iconSize: Constants.sizeXl
    onClicked: {
        HyprlandService.nightLightActive = !HyprlandService.nightLightActive;
    }
}
