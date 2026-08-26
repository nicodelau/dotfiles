import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Core.Components
import qs.Core.Services

Rectangle {
    id: root

    property string label: ""
    property string description: ""
    property bool checked: false
    property bool isSubSetting: false

    signal toggled(bool checked)

    Layout.fillWidth: true
    color: "transparent"
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Constants.sizeLg

        Item {
            id: headerWrapper

            Layout.fillWidth: true
            implicitHeight: headerRow.implicitHeight

            RowLayout {
                id: headerRow

                anchors.fill: parent

                ColumnLayout {
                    spacing: Constants.size3Xs
                    Layout.fillWidth: true

                    ThemedText {
                        text: root.label
                        font.pixelSize: Constants.sizeMd
                        color: root.enabled ? Theme.fg : Theme.muted
                    }

                    ThemedText {
                        text: root.description
                        font.pixelSize: Constants.sizeSm
                        color: Theme.muted
                        visible: root.description !== ""
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Switch {
                    id: settingSwitch

                    z: 10
                    Layout.alignment: Qt.AlignVCenter
                    opacity: root.enabled ? 1 : 0.5
                    checked: root.checked
                    onToggled: root.checked = checked
                    implicitWidth: 44
                    implicitHeight: 24

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    indicator: Rectangle {
                        implicitWidth: 44
                        implicitHeight: 24
                        radius: height / 2
                        color: settingSwitch.checked ? Theme.accent : Theme.muted

                        Rectangle {
                            id: knob

                            x: settingSwitch.checked ? parent.width - width - 3 : 3
                            y: (parent.height - height) / 2
                            width: 18
                            height: 18
                            radius: width / 2
                            color: Theme.bg
                            scale: settingSwitch.pressed ? 0.85 : (settingSwitch.hovered ? 1.08 : 1)
                            layer.enabled: true

                            layer.effect: DropShadow {
                                transparentBorder: true
                                color: Qt.rgba(0, 0, 0, 0.4)
                                radius: 4
                                samples: 9
                                verticalOffset: 1
                            }

                            Behavior on x {
                                NumberAnimation {
                                    duration: Constants.animFast
                                    easing.type: Easing.OutBack
                                }

                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Constants.animFast
                                    easing.type: Easing.OutBack
                                }

                            }

                            Behavior on color {
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

                    }

                }

            }

        }

    }

}
