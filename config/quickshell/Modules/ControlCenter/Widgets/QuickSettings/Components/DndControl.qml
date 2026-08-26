import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services

SvgIconButton {
    id: root

    property var notificationService

    icon: (notificationService && notificationService.dndEnabled) ? "bell-off" : "bell"
    iconColor: (notificationService && notificationService.dndEnabled) ? Theme.muted : Theme.accent
    iconSize: Constants.sizeXl
    onClicked: {
        if (notificationService)
            notificationService.dndEnabled = !notificationService.dndEnabled;

    }
}
