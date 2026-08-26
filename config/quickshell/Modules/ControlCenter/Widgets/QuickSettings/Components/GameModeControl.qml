import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

SvgIconButton {
    id: root

    icon: HyprlandService.gameModeActive ? "gamepad-filled" : "gamepad"
    iconColor: HyprlandService.gameModeActive ? Theme.accent : Theme.muted
    iconSize: Constants.sizeXl
    onClicked: {
        HyprlandService.gameModeActive = !HyprlandService.gameModeActive;
    }
}
