import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.Core
import qs.Core.Components

PanelWindow {
    id: root

    required property var notificationService

    screen: Quickshell.screens[0]
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    implicitWidth: 400
    implicitHeight: 1000
    visible: true
    color: "transparent"

    anchors {
        top: true
        right: true
    }

    margins {
        top: 64
        right: 8
    }

    Column {
        id: notificationContainer

        anchors.top: parent.top
        anchors.right: parent.right
        width: 380
        spacing: Constants.sizeLg

        Repeater {
            id: notificationList

            model: notificationService ? notificationService.activeList : null

            delegate: Rectangle {
                id: toastRect

                property bool isRemoving: false
                property bool expanded: false
                property real slideOffset: (model.notifData.summary === "Volume" || model.notifData.summary === "Brightness" || model.notifData.summary === "Microphone") ? 0 : 400
                property real dragOffset: 0
                property string bodyVal: model.notifData.body

                function closeNotification() {
                    if (isRemoving)
                        return ;

                    isRemoving = true;
                    animInDelayTimer.stop();
                    dragOffset = 0;
                    slideOffset = 400;
                    removalTimer.start();
                }

                onExpandedChanged: {
                    if (expanded)
                        model.notifData.lock("expanded");
                    else
                        model.notifData.unlock("expanded");
                }
                onBodyValChanged: {
                }
                width: notificationContainer.width
                height: layout.implicitHeight + Constants.sizeSm * 2 + 4
                color: Theme.bg
                radius: Constants.sizeLg
                border.color: mainMouseArea.containsMouse ? Theme.accent : Theme.border
                border.width: 1
                layer.enabled: true
                Component.onCompleted: {
                    if (model.notifData.summary !== "Volume" && model.notifData.summary !== "Brightness" && model.notifData.summary !== "Microphone") {
                        animInDelayTimer.interval = index * Constants.animNormal;
                        animInDelayTimer.start();
                    }
                }

                Connections {
                    function onPopupChanged() {
                        if (!model.notifData.popup && !toastRect.isRemoving)
                            toastRect.closeNotification();

                    }

                    target: model.notifData
                }

                Process {
                    id: actionCommand
                }

                Timer {
                    id: animInDelayTimer

                    repeat: false
                    onTriggered: {
                        if (toastRect.isRemoving)
                            return ;

                        toastRect.slideOffset = 0;
                    }
                }

                Timer {
                    id: removalTimer

                    interval: Constants.animSlow
                    repeat: false
                    onTriggered: {
                        if (model.notifData.closed || model.notifData.isTransient) {
                            if (notificationService)
                                notificationService.dismissNotification(model.notifData.notificationId);

                        } else {
                            if (notificationService) {
                                for (var i = 0; i < notificationService.activeList.count; i++) {
                                    if (notificationService.activeList.get(i).id == model.notifData.notificationId) {
                                        notificationService.activeList.remove(i);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: mainMouseArea

                    onEntered: model.notifData.lock(toastRect)
                    onExited: model.notifData.unlock(toastRect)
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (model.notifData.summary !== "Power Menu")
                            toastRect.closeNotification();

                    }
                }

                DragHandler {
                    id: dragHandler

                    target: null
                    yAxis.enabled: false
                    onTranslationChanged: {
                        if (translation.x > 0)
                            toastRect.dragOffset = translation.x;
                        else
                            toastRect.dragOffset = 0;
                    }
                    onActiveChanged: {
                        if (!active) {
                            if (toastRect.dragOffset > toastRect.width / 4)
                                toastRect.closeNotification();
                            else
                                snapBackAnim.restart();
                        }
                    }
                }

                NumberAnimation {
                    id: snapBackAnim

                    target: toastRect
                    property: "dragOffset"
                    to: 0
                    duration: Constants.animFast
                    easing.type: Easing.OutBack
                }

                RowLayout {
                    id: layout

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: Constants.sizeSm
                    anchors.leftMargin: Constants.sizeSm
                    anchors.rightMargin: Constants.sizeSm
                    spacing: Constants.sizeSm

                    NotificationIcon {
                        id: iconContainer

                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: 2
                        Layout.preferredWidth: iconContainer.isUrgencyIcon ? Constants.sizeLg : Constants.size4Xl
                        Layout.preferredHeight: iconContainer.isUrgencyIcon ? Constants.sizeLg : Constants.size4Xl
                        notifData: model.notifData
                        bgColor: Theme.bgSecondary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: Constants.sizeMd

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Constants.sizeXs

                                ThemedText {
                                    id: summaryText

                                    Layout.fillWidth: true
                                    text: model.notifData.summary
                                    color: Theme.accent
                                    font.pixelSize: Constants.sizeMd
                                    font.weight: Font.Medium
                                    maximumLineCount: toastRect.expanded ? 100 : 1
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                }

                                SvgIconButton {
                                    id: expandButton

                                    Layout.alignment: Qt.AlignTop
                                    iconSize: Constants.sizeSm
                                    iconColor: Theme.fg
                                    icon: toastRect.expanded ? "chevron-up" : "chevron-down"
                                    visible: bodyText.truncated || summaryText.truncated || toastRect.expanded
                                    onClicked: {
                                        toastRect.expanded = !toastRect.expanded;
                                    }
                                }

                            }

                            ThemedText {
                                id: bodyText

                                Layout.fillWidth: true
                                text: model.notifData.body
                                wrapMode: Text.Wrap
                                color: Theme.muted
                                font.pixelSize: Constants.sizeSm
                                maximumLineCount: toastRect.expanded ? 100 : 2
                                elide: Text.ElideRight
                            }

                        }

                        Rectangle {
                            id: levelBarTrack

                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: Theme.bgSecondary
                            visible: model.notifData.summary === "Volume" || model.notifData.summary === "Brightness"

                            Rectangle {
                                id: levelBar

                                height: parent.height
                                radius: parent.radius
                                color: Theme.accent
                                width: {
                                    let val = parseInt(model.notifData.body);
                                    if (isNaN(val))
                                        val = 0;

                                    return parent.width * (Math.min(100, Math.max(0, val)) / 100);
                                }

                                Behavior on width {
                                    NumberAnimation {
                                        duration: Constants.animFast
                                        easing.type: Easing.OutQuad
                                    }

                                }

                            }

                        }

                        RowLayout {
                            id: actionButtons

                            visible: model && model.notifData && model.notifData.summary === "Power Menu"
                            spacing: Constants.sizeMd

                            Rectangle {
                                id: acceptButton

                                visible: model.notifData.summary === "Power Menu"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                color: Theme.bgSecondary
                                radius: height / 2
                                scale: acceptMouse.containsPress ? 0.95 : 1

                                ThemedText {
                                    anchors.centerIn: parent
                                    text: "Accept"
                                    color: Theme.accent
                                    font.bold: true
                                    font.pixelSize: Constants.sizeSm
                                }

                                MouseArea {
                                    id: acceptMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    preventStealing: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        actionCommand.command = ["bash", "-c", "kill -USR1 $(cat /tmp/quickshell_power_action.pid 2>/dev/null)"];
                                        actionCommand.startDetached();
                                        toastRect.closeNotification();
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Constants.animNormal
                                    }

                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Constants.animFast
                                        easing.type: Easing.OutBack
                                    }

                                }

                            }

                            Rectangle {
                                id: cancelButton

                                visible: model.notifData.summary === "Power Menu"
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 28
                                color: Theme.bgSecondary
                                radius: height / 2
                                scale: cancelMouse.containsPress ? 0.95 : 1

                                ThemedText {
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    color: Theme.accent
                                    font.bold: true
                                    font.pixelSize: Constants.sizeSm
                                }

                                MouseArea {
                                    id: cancelMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    preventStealing: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        actionCommand.command = ["bash", "-c", "kill -TERM $(cat /tmp/quickshell_power_action.pid 2>/dev/null)"];
                                        actionCommand.startDetached();
                                        toastRect.closeNotification();
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Constants.animNormal
                                    }

                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Constants.animFast
                                        easing.type: Easing.OutBack
                                    }

                                }

                            }

                        }

                    }

                }

                Rectangle {
                    id: progressTrack

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottomMargin: 0
                    anchors.leftMargin: Constants.sizeSm
                    anchors.rightMargin: Constants.sizeSm
                    height: 2
                    radius: height / 2
                    color: Theme.bgSecondary
                    visible: model.notifData.summary !== "Volume" && model.notifData.summary !== "Brightness" && model.notifData.summary !== "Microphone"

                    Rectangle {
                        id: progressBar

                        height: parent.height
                        radius: height / 2
                        color: Theme.accent
                        width: parent.width * model.notifData.progress
                        onWidthChanged: {
                            if (width === 0 && !toastRect.isRemoving && model.notifData.summary === "Power Menu") {
                                actionCommand.command = ["bash", "-c", "kill -USR1 $(cat /tmp/quickshell_power_action.pid 2>/dev/null)"];
                                actionCommand.startDetached();
                            }
                        }
                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: Constants.animNormal
                    }

                }

                transform: Translate {
                    x: toastRect.slideOffset + toastRect.dragOffset
                }

                Behavior on height {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutQuint
                    }

                }

                Behavior on slideOffset {
                    NumberAnimation {
                        duration: Constants.animSlow
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }

                }

            }

        }

        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Constants.animSlow
                easing.type: Easing.OutQuint
            }

        }

        add: Transition {
            NumberAnimation {
                properties: "opacity"
                from: 0
                to: 1
                duration: Constants.animFast
            }

        }

    }

    mask: Region {
        x: 0
        y: 0
        width: root.width
        height: root.height
        intersection: Intersection.Xor

        Region {
            x: 0
            y: 0
            width: root.width
            height: notificationContainer.height
            intersection: Intersection.Subtract
        }

    }

}
