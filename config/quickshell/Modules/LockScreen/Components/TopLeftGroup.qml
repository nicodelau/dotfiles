import QtQuick
import QtQuick.Layouts
import qs.Core

RowLayout {
    spacing: Constants.sizeLg

    Rectangle {
        width: Constants.sizeXs
        height: Constants.sizeXs
        color: Theme.accent
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: "LOCKED"
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeSm
        font.letterSpacing: 2
        color: Theme.muted
    }

}
