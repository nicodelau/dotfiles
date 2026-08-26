import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

Card {
    id: root

    property string title: ""
    property string icon: "ghost"
    default property alias groupContent: contentLayout.data

    Layout.fillWidth: true
    contentPadding: Constants.sizeLg

    ColumnLayout {
        id: mainLayout

        width: parent.width
        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeMd
            visible: root.title !== ""

            SvgIcon {
                icon: root.icon
                iconSize: Constants.sizeLg
                iconColor: Theme.muted
                flat: true
            }

            ThemedText {
                text: root.title
                font.pixelSize: Constants.sizeSm
                color: Theme.muted
            }

        }

        ColumnLayout {
            id: contentLayout

            Layout.fillWidth: true
            spacing: Constants.sizeLg
        }

    }

}
