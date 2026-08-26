import QtQuick
import qs.Core
import qs.Core.Components
import qs.Core.Services

BarButton {
    id: root

    property string currentIcon: Theme.barIcon

    scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.05 : 1)
    Behavior on scale {
        NumberAnimation {
            duration: Constants.animFast
            easing.type: Easing.OutQuads
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.widget)
                root.widget.isOpen = !root.widget.isOpen;
        }
    }

    AnimatedMinflair {
        id: minflair
        anchors.centerIn: parent
        iconSize: Constants.size3Xl
        visible: root.currentIcon === ""
    }

    SvgIcon {
        id: customIcon
        anchors.centerIn: parent
        icon: root.currentIcon
        iconSize: Constants.sizeXl
        iconColor: Theme.accent
        bgColor: "transparent"
        flat: true
        visible: root.currentIcon !== ""
    }
}
