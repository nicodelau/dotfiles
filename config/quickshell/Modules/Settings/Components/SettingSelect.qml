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
    property var model: []
    property int currentIndex: 0
    property int comboWidth: 160
    property string fallbackText: "Auto"
    property var iconMap: ({
    })
    property bool isSubSetting: false

    signal activated(int index)

    Layout.preferredHeight: mainLayout.implicitHeight
    Layout.fillWidth: true
    color: "transparent"

    RowLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        ColumnLayout {
            spacing: Constants.size3Xs
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

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

        ComboBox {
            id: internalCombo

            z: 10
            opacity: root.enabled ? 1 : 0.5
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            implicitWidth: root.comboWidth
            implicitHeight: 36
            model: root.model
            currentIndex: root.currentIndex
            scale: (internalCombo.down && !internalCombo.popup.visible) ? 0.95 : (internalCombo.hovered ? 1.02 : 1)
            onActivated: (index) => {
                root.activated(index);
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Constants.animFast
                    easing.type: Easing.OutBack
                }

            }

            indicator: SvgIcon {
                x: internalCombo.width - width - Constants.sizeSm
                y: (internalCombo.height - height) / 2
                flat: true
                icon: "chevron-down"
                iconSize: Constants.sizeMd
                iconColor: internalCombo.popup.visible ? Theme.accent : Theme.muted
                rotation: internalCombo.popup.visible ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: Constants.animNormal
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on iconColor {
                    ColorAnimation {
                        duration: Constants.animFast
                    }

                }

            }

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Constants.sizeSm
                anchors.rightMargin: 36
                spacing: Constants.sizeXs

                ThemedText {
                    Layout.fillWidth: true
                    text: {
                        let txt = internalCombo.displayText;
                        if (!txt)
                            return root.fallbackText;

                        return txt.split('-').map((word) => {
                            return word.charAt(0).toUpperCase() + word.slice(1);
                        }).join('-');
                    }
                    font.pixelSize: Constants.sizeSm
                    font.bold: true
                    color: internalCombo.popup.visible ? Theme.accent : Theme.fg
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter

                    Behavior on color {
                        ColorAnimation {
                            duration: Constants.animFast
                        }

                    }

                }

            }

            background: Rectangle {
                color: internalCombo.down || internalCombo.hovered || internalCombo.popup.visible ? Qt.lighter(Theme.bgTertiary, 1.2) : Theme.bgTertiary
                radius: Constants.sizeSm
                border.width: 1
                border.color: Theme.border

                Behavior on color {
                    ColorAnimation {
                        duration: Constants.animFast
                    }

                }

            }

            popup: Popup {
                y: internalCombo.height + Constants.size2Xs
                width: internalCombo.width
                implicitHeight: Math.min(contentItem.implicitHeight + Constants.sizeXs, 200)
                padding: Constants.size2Xs

                enter: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Constants.animFast
                    }

                    NumberAnimation {
                        property: "y"
                        from: internalCombo.height - Constants.sizeMd
                        to: internalCombo.height + Constants.size2Xs
                        duration: Constants.animNormal
                        easing.type: Easing.OutBack
                    }

                }

                exit: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: Constants.animFast
                    }

                    NumberAnimation {
                        property: "y"
                        from: internalCombo.height + Constants.size2Xs
                        to: internalCombo.height - Constants.sizeMd
                        duration: Constants.animFast
                        easing.type: Easing.InCubic
                    }

                }

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: internalCombo.popup.visible ? internalCombo.delegateModel : null
                    currentIndex: internalCombo.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator {
                    }

                }

                background: Rectangle {
                    color: Theme.bg
                    border.width: 1
                    border.color: Theme.border
                    radius: Constants.sizeSm
                }

            }

            delegate: ItemDelegate {
                id: delegateItem

                width: ListView.view.width
                height: 34
                scale: delegateItem.down ? 0.95 : (delegateItem.hovered ? 1.02 : 1)

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Constants.animFast
                        easing.type: Easing.OutBack
                    }

                }

                background: Rectangle {
                    anchors.fill: parent
                    anchors.margins: Constants.size3Xs
                    radius: Constants.sizeLg - Constants.size3Xs
                    color: internalCombo.currentIndex === index || internalCombo.highlightedIndex === index ? Theme.bgSecondary : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Constants.animFast
                        }

                    }

                }

                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Constants.sizeXs
                    anchors.rightMargin: Constants.sizeXs
                    spacing: Constants.sizeXs

                    ThemedText {
                        Layout.fillWidth: true
                        text: {
                            if (typeof modelData !== "string")
                                return "";

                            return modelData.split('-').map((word) => {
                                return word.charAt(0).toUpperCase() + word.slice(1);
                            }).join('-');
                        }
                        font.pixelSize: Constants.sizeSm
                        font.bold: internalCombo.currentIndex === index
                        color: internalCombo.currentIndex === index ? Theme.accent : Theme.fg
                        verticalAlignment: Text.AlignVCenter
                    }

                }

            }

        }

    }

}
