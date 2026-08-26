import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components

RowLayout {
    id: root

    property string title: ""
    property string description: ""

    spacing: Constants.sizeXs

    ColumnLayout {
        spacing: Constants.size3Xs

        ThemedText {
            text: root.title.toUpperCase()
            font.pixelSize: Constants.sizeMd
            color: Theme.fg
        }

        ThemedText {
            text: root.description
            font.pixelSize: Constants.sizeSm
            color: Theme.muted
            visible: root.description !== ""
        }

    }

}
