import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Core.Components
import qs.Core.Services

Rectangle {
    id: sidebarRoot

    property int activeTab: 0
    property var fullModel: [{
        "index": 0,
        "label": "Personalization",
        "icon": "color-palette"
    }, {
        "index": 1,
        "label": "Desktop Effects",
        "icon": "sparkles"
    }, {
        "index": 2,
        "label": "Window Management",
        "icon": "window"
    }, {
        "index": 3,
        "label": "Integrations & Apps",
        "icon": "apps"
    }, {
        "index": 4,
        "label": "Input & Clipboard",
        "icon": "edit"
    }, {
        "index": 5,
        "label": "Update Preferences",
        "icon": "update"
    }, {
        "index": 6,
        "label": "System Info",
        "icon": "info"
    }]

    signal tabClicked(int index)

    Layout.preferredWidth: 64
    Layout.maximumWidth: 64
    Layout.minimumWidth: 64
    Layout.fillHeight: true
    color: Theme.bgSecondary

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Constants.sizeLg
        anchors.bottomMargin: Constants.sizeLg
        anchors.leftMargin: Constants.sizeMd
        anchors.rightMargin: Constants.sizeMd
        spacing: Constants.sizeMd

        Item {
            Layout.fillHeight: true
        }

        Repeater {
            id: tabRepeater

            model: fullModel

            delegate: Item {
                id: delegateRoot

                property bool isActive: sidebarRoot.activeTab === modelData.index
                property bool isHovered: hoverHandler.hovered
                property bool isPressed: tapHandler.pressed

                Layout.fillWidth: true
                Layout.preferredHeight: width

                ToolTip {
                    text: modelData.label
                    visible: delegateRoot.isHovered
                    delay: 300

                    contentItem: ThemedText {
                        text: modelData.label
                        font.pixelSize: Constants.sizeSm
                        font.bold: true
                        color: Theme.fg
                    }

                    background: Rectangle {
                        color: Theme.bg
                        border.color: Theme.border
                        border.width: 1
                        radius: Constants.sizeSm
                    }

                }

                Rectangle {
                    anchors.fill: parent
                    radius: Constants.sizeSm
                    color: delegateRoot.isActive ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : (delegateRoot.isHovered ? Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.05) : "transparent")
                    scale: delegateRoot.isPressed ? 0.95 : 1

                    Rectangle {
                        width: 4
                        height: delegateRoot.isActive ? parent.height * 0.5 : 8
                        radius: 2
                        color: Theme.accent
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: -Constants.sizeSm
                        opacity: delegateRoot.isActive ? 1 : 0
                        scale: delegateRoot.isActive ? 1 : 0.5

                        Behavior on height {
                            NumberAnimation {
                                duration: Constants.animNormal
                                easing.type: Easing.OutBack
                                easing.overshoot: 1.5
                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Constants.animNormal
                                easing.type: Easing.OutBack
                            }

                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Constants.animFast
                            }

                        }

                    }

                    SvgIcon {
                        anchors.centerIn: parent
                        icon: delegateRoot.isActive ? (modelData.icon + "-filled") : modelData.icon
                        iconSize: Constants.sizeXl
                        flat: true
                        iconColor: delegateRoot.isActive ? Theme.accent : (delegateRoot.isHovered ? Theme.fg : Theme.muted)

                        Behavior on iconColor {
                            ColorAnimation {
                                duration: Constants.animFast
                            }

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
                            easing.type: Easing.OutBack
                        }

                    }

                }

                TapHandler {
                    id: tapHandler

                    onTapped: sidebarRoot.tabClicked(modelData.index)
                }

                HoverHandler {
                    id: hoverHandler

                    cursorShape: Qt.PointingHandCursor
                }

            }

        }

        Item {
            Layout.fillHeight: true
        }

    }

}
