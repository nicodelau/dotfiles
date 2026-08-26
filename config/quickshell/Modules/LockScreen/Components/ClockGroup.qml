import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Services

ColumnLayout {
    spacing: Constants.sizeLg

    RowLayout {
        spacing: Constants.sizeSm

        Text {
            text: Qt.formatTime(SystemInfoService.currentTime, "hh")
            font.family: Constants.fontFamily
            font.pixelSize: Constants.size5Xl * 4
            font.weight: Font.Light
            color: Theme.fg
        }

        Column {
            Layout.alignment: Qt.AlignVCenter
            spacing: Constants.size5Xl * 0.7

            Rectangle {
                width: Constants.sizeMd
                height: Constants.sizeMd
                radius: Constants.sizeMd / 2
                color: Theme.accent
            }

            Rectangle {
                width: Constants.sizeMd
                height: Constants.sizeMd
                radius: Constants.sizeMd / 2
                color: Theme.accent
            }

        }

        Text {
            text: Qt.formatTime(SystemInfoService.currentTime, "mm")
            font.family: Constants.fontFamily
            font.pixelSize: Constants.size5Xl * 4
            font.weight: Font.Light
            color: Theme.fg
        }

    }

    Text {
        text: Qt.formatDate(SystemInfoService.currentTime, "ddd . dd MMM / yyyy").toUpperCase()
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeMd
        font.letterSpacing: 4
        color: Theme.muted
        font.bold: true
    }

}
