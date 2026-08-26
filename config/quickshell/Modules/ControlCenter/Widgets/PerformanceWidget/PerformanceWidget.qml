import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Windows

Item {
    id: root

    property string powerProfile: SystemInfoService.powerProfile

    implicitWidth: cardContainer.implicitWidth
    implicitHeight: cardContainer.implicitHeight

    Card {
        id: cardContainer

        width: parent.width

        ColumnLayout {
            id: mainCol

            anchors.fill: parent
            spacing: Constants.sizeLg

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                ThemedText {
                    text: "Performance Mode"
                    font.pixelSize: Constants.sizeLg
                    font.bold: true
                    color: Theme.fg
                }

                ThemedText {
                    text: "Select a power profile"
                    font.pixelSize: Constants.sizeXs + 2
                    color: Theme.muted
                }

            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Constants.sizeLg

                Repeater {
                    model: {
                        let profiles = [{
                            "id": "power-saver",
                            "name": "Saver",
                            "desc": "CPU power-saver profile. Brightness set to 15%. Disables animations, blur, shadows, and Caffeine. Widget updates every 5s.",
                            "icon": "energy-saver"
                        }, {
                            "id": "balanced",
                            "name": "Balanced",
                            "desc": "CPU balanced profile. Brightness set to 75%. Restores Hyprland configuration. Widget updates every 2s.",
                            "icon": "balance"
                        }];
                        if (SystemInfoService.hasPerformanceProfile)
                            profiles.push({
                            "id": "performance",
                            "name": "Performance",
                            "desc": "CPU performance profile. Brightness set to 100%. Restores Hyprland configuration. Widget updates every 1s.",
                            "icon": "rocket"
                        });

                        return profiles;
                    }

                    delegate: Rectangle {
                        id: profileCard

                        required property var modelData
                        property bool isActive: root.powerProfile === modelData.id
                        property bool isHovered: hoverHandler.hovered
                        property bool isPressed: tapHandler.pressed

                        Layout.fillWidth: true
                        Layout.preferredHeight: delegateLayout.implicitHeight + Constants.sizeLg * 2
                        radius: Constants.sizeLg
                        color: profileCard.isHovered ? Theme.bgTertiary : Theme.bgSecondary
                        border.width: profileCard.isActive ? 1 : 0
                        border.color: profileCard.isActive ? Theme.accent : Theme.border
                        scale: isPressed ? 0.95 : (isHovered ? 1.02 : 1)

                        RowLayout {
                            id: delegateLayout

                            anchors.fill: parent
                            anchors.margins: Constants.sizeLg
                            spacing: Constants.sizeLg

                            SvgIcon {
                                icon: profileCard.modelData.icon
                                iconSize: Constants.size2Xl
                                iconColor: profileCard.isActive ? Theme.accent : (profileCard.isHovered ? Theme.accent : Theme.fg)
                                Layout.alignment: Qt.AlignVCenter
                                isCircle: true

                                Behavior on iconColor {
                                    ColorAnimation {
                                        duration: Constants.animFast
                                    }

                                }

                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                ThemedText {
                                    text: profileCard.modelData.name
                                    font.pixelSize: Constants.sizeSm
                                    font.bold: true
                                    color: profileCard.isActive ? Theme.accent : Theme.fg
                                    Layout.fillWidth: true
                                }

                                ThemedText {
                                    text: profileCard.modelData.desc
                                    font.pixelSize: Constants.sizeXs + 2
                                    color: profileCard.isActive ? Theme.fg : Theme.muted
                                    wrapMode: Text.Wrap
                                    lineHeight: 1.2
                                    Layout.fillWidth: true
                                }

                            }

                        }

                        TapHandler {
                            id: tapHandler

                            onTapped: SystemInfoService.applyProfile(profileCard.modelData.id)
                        }

                        HoverHandler {
                            id: hoverHandler

                            cursorShape: Qt.PointingHandCursor
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Constants.animFast
                            }

                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Constants.animFast
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

    }

}
