import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

SvgIconButton {
    id: root

    icon: "record-icon"
    iconColor: Recorder.running ? Theme.accent : Theme.muted
    iconSize: Constants.sizeXl
    onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton)
            Recorder.toggle(["-s", "-r"]);
        else
            Recorder.toggle(["-s"]);
    }
}
