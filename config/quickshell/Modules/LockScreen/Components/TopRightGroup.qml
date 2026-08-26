import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Services

RowLayout {
    spacing: Constants.sizeMd

    Text {
        text: "CPU " + Math.round(SystemStats.cpuUsage) + "%"
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeSm
        color: Theme.muted
        font.letterSpacing: 1
    }

    Rectangle {
        width: Constants.sizeXl
        height: 2
        color: Theme.accent
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: "RAM " + SystemStats.memUsed.toFixed(1) + "G"
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeSm
        color: Theme.muted
        font.letterSpacing: 1
    }

    Rectangle {
        width: Constants.sizeXl
        height: 2
        color: Theme.accent
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: "UP " + SystemStats.uptime
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeSm
        color: Theme.muted
        font.letterSpacing: 1
    }

}
