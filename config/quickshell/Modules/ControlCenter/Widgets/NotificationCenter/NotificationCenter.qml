import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Windows

Card {
    id: root

    property var notificationService
    property var currentTime: SystemInfoService.currentTime
    property bool controlCenterOpen: false

    function timeAgo(date, now) {
        if (!date || isNaN(date.getTime()) || !now || isNaN(now.getTime()))
            return "...";

        let diff = Math.floor((now.getTime() - date.getTime()) / 1000);
        if (diff < 60)
            return "Just now";

        if (diff < 3600)
            return Math.floor(diff / 60) + "m ago";

        if (diff < 86400)
            return Math.floor(diff / 3600) + "h ago";

        return Math.floor(diff / 86400) + "d ago";
    }

    implicitWidth: 400

    ColumnLayout {
        id: mainCol

        anchors.fill: parent
        spacing: Constants.sizeLg

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeXs

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                ThemedText {
                    text: "Notifications"
                    font.pixelSize: Constants.sizeLg
                    font.bold: true
                    color: Theme.fg
                }

                ThemedText {
                    text: historyView.count > 0 ? (historyView.count + (historyView.count === 1 ? " active notification" : " active notifications")) : "All caught up"
                    font.pixelSize: Constants.sizeXs + 2
                    color: Theme.muted
                }

            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Constants.sizeXs
                Layout.alignment: Qt.AlignVCenter

                SvgIconButton {
                    icon: "trash"
                    iconSize: Constants.sizeSm
                    iconColor: Theme.accent
                    textIcon: "Clear All"
                    textIconSize: Constants.sizeSm
                    onClicked: {
                        if (notificationService && historyView.count > 0)
                            notificationService.clearHistory();

                    }
                    useCustomWidth: true
                    disabled: historyView.count === 0
                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Constants.sizeXs

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    id: emptyState

                    anchors.centerIn: parent
                    spacing: Constants.sizeSm
                    visible: historyView.count === 0

                    SvgIcon {
                        icon: "bell"
                        iconSize: Constants.size5Xl
                        iconColor: Theme.muted
                        Layout.alignment: Qt.AlignHCenter
                        flat: true
                    }

                    ThemedText {
                        text: "All caught up!"
                        font.pixelSize: Constants.sizeSm
                        font.bold: true
                        color: Theme.fg
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ThemedText {
                        text: "No new notifications at the moment."
                        font.pixelSize: Constants.sizeXs + 2
                        color: Theme.muted
                        Layout.alignment: Qt.AlignHCenter
                    }

                }

                ListView {
                    id: historyView

                    anchors.fill: parent
                    interactive: true
                    model: notificationService ? notificationService.historyList : null
                    spacing: Constants.sizeXs

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: root.visible ? Constants.animSlow : 0
                        }

                    }

                    remove: Transition {
                        NumberAnimation {
                            property: "x"
                            to: historyView.width
                            duration: Constants.animSlow
                            easing.type: Easing.InExpo
                        }

                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: Constants.animSlow
                        }

                    }

                    removeDisplaced: Transition {
                        SequentialAnimation {
                            PauseAnimation {
                                duration: Constants.animSlow
                            }

                            NumberAnimation {
                                properties: "y"
                                duration: Constants.animSlow
                                easing.type: Easing.OutExpo
                            }

                        }

                    }

                    addDisplaced: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: root.visible ? Constants.animSlow : 0
                            easing.type: Easing.OutExpo
                        }

                    }

                    delegate: Rectangle {
                        id: delegateRoot

                        property bool expanded: false

                        width: ListView.view.width
                        height: delegateLayout.implicitHeight + Constants.sizeLg * 2
                        color: delegateMouseArea.containsMouse ? Theme.bgTertiary : Theme.bgSecondary
                        radius: Constants.sizeXl
                        border.width: 1
                        border.color: delegateMouseArea.containsMouse ? Theme.accent : Theme.border

                        MouseArea {
                            id: delegateMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (notificationService)
                                    notificationService.removeHistoryItem(index);

                            }
                        }

                        RowLayout {
                            id: delegateLayout

                            anchors.fill: parent
                            anchors.margins: Constants.sizeLg
                            spacing: Constants.sizeLg

                            NotificationIcon {
                                id: iconContainer

                                Layout.alignment: Qt.AlignTop
                                Layout.preferredWidth: iconContainer.isUrgencyIcon ? Constants.sizeLg : Constants.size4Xl
                                Layout.preferredHeight: iconContainer.isUrgencyIcon ? Constants.sizeLg : Constants.size4Xl
                                notifData: model.notifData
                                bgColor: "transparent"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Constants.sizeXs

                                    ThemedText {
                                        id: summaryText

                                        text: model.notifData.summary
                                        color: Theme.fg
                                        font.pixelSize: Constants.sizeSm
                                        font.weight: Font.Medium
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        maximumLineCount: delegateRoot.expanded ? 100 : 1
                                        wrapMode: Text.Wrap
                                    }

                                    ThemedText {
                                        Layout.alignment: Qt.AlignTop
                                        Layout.topMargin: 4
                                        text: {
                                            let ts = model.notifData.timestamp;
                                            if (!ts)
                                                return "Just now";

                                            let n = Number(ts);
                                            let d = new Date(n < 1e+10 ? n * 1000 : n);
                                            return root.timeAgo(d, root.currentTime);
                                        }
                                        color: Theme.muted
                                        font.pixelSize: Constants.sizeXs + 2
                                    }

                                    SvgIconButton {
                                        id: expandButton

                                        Layout.alignment: Qt.AlignTop
                                        iconSize: Constants.sizeSm
                                        icon: delegateRoot.expanded ? "chevron-up" : "chevron-down"
                                        visible: bodyText.truncated || summaryText.truncated || delegateRoot.expanded
                                        onClicked: {
                                            delegateRoot.expanded = !delegateRoot.expanded;
                                        }
                                    }

                                }

                                ThemedText {
                                    id: bodyText

                                    text: model.notifData.body
                                    color: Theme.muted
                                    font.pixelSize: Constants.sizeXs + 2
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    maximumLineCount: delegateRoot.expanded ? 100 : 2
                                    elide: Text.ElideRight
                                }

                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Constants.animFast
                                easing.type: Easing.OutQuint
                            }

                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: Constants.animSlow
                                easing.type: Easing.OutExpo
                            }

                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Constants.animNormal
                            }

                        }

                    }

                }

            }

        }

    }

}
