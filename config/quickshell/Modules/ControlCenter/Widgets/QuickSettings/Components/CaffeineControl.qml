import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services

SvgIconButton {
    id: root

    icon: !HyprlandService.caffeineActive ? "coffee" : "coffee-filled"
    iconColor: !HyprlandService.caffeineActive ? Theme.muted : Theme.accent
    iconSize: Constants.sizeXl
    onClicked: {
        HyprlandService.caffeineActive = !HyprlandService.caffeineActive;
    }
}
