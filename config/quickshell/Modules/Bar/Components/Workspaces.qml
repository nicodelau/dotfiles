import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Core
import qs.Core.Services

BarButton {
    id: root

    implicitWidth: hLayout.implicitWidth + 24
    implicitHeight: 32
    color: Theme.bgSecondary

    RowLayout {
        id: hLayout

        anchors.centerIn: parent
        spacing: Constants.sizeSm

        Repeater {
            model: 10

            Rectangle {
                id: wsItemH

                readonly property int wsId: index + 1
                readonly property var workspace: Hyprland.workspaces.values.find((ws) => {
                    return ws.id === wsId;
                })
                readonly property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
                readonly property bool hasWindows: workspace !== undefined && (workspace.windows > 0 || workspace.id === wsId)

                Layout.preferredWidth: isActive ? 28 : (hasWindows ? 10 : 8)
                Layout.preferredHeight: isActive ? 10 : (hasWindows ? 10 : 8)
                radius: isActive ? 5 : (hasWindows ? 5 : 4)
                color: mouseAreaH.containsMouse ? Theme.accent : (isActive ? Theme.fg : (hasWindows ? Theme.fg : Theme.muted))
                scale: mouseAreaH.pressed ? 0.9 : (mouseAreaH.containsMouse ? 1.1 : 1)

                MouseArea {
                    id: mouseAreaH

                    anchors.fill: parent
                    anchors.margins: -12
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch('hl.dsp.focus({workspace=' + wsId + '})')
                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animFast
                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Constants.animFast
                        easing.type: Easing.OutQuad
                    }

                }

            }

        }

    }

}
