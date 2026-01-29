import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "#14141e"

    property string fontFamily: config.FontFamily || "SF Pro Display"
    property color accentColor: config.AccentColor || "#0A84FF"
    property color glassBg: Qt.rgba(20/255, 20/255, 30/255, parseFloat(config.GlassOpacity) || 0.65)
    property color glassBorder: config.GlassBorder || "#ffffff1f"
    property int roundCorners: parseInt(config.RoundCorners) || 14

    // Background image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.Background || ""
        fillMode: Image.PreserveAspectCrop
        visible: true
    }

    // Blur the background
    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: parseInt(config.BlurRadius) || 40
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
    }

    // Center container
    Item {
        anchors.centerIn: parent
        width: 380
        height: 460

        // Glass card
        Rectangle {
            id: glassCard
            anchors.fill: parent
            color: root.glassBg
            radius: root.roundCorners
            border.width: 1
            border.color: root.glassBorder

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 8
                radius: 24
                samples: 49
                color: Qt.rgba(0, 0, 0, 0.4)
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 60

            // Clock
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "HH:mm")
                font.family: root.fontFamily
                font.pixelSize: 56
                font.weight: Font.Bold
                color: "#f0f0f0"

                Timer {
                    interval: 30000
                    running: true
                    repeat: true
                    onTriggered: parent.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            // Date
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), "dddd, d MMMM")
                font.family: root.fontFamily
                font.pixelSize: 16
                color: Qt.rgba(1, 1, 1, 0.6)
                Layout.bottomMargin: 20
            }

            // User icon
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 72
                height: 72
                radius: 36
                color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: "\uf007"
                    font.family: "Font Awesome 6 Free"
                    font.pixelSize: 28
                    color: Qt.rgba(1, 1, 1, 0.7)
                }
            }

            // Username selector
            ComboBox {
                id: userSelector
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex

                background: Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.06)
                    radius: root.roundCorners
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }

                contentItem: Text {
                    text: userSelector.displayText
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    color: Qt.rgba(1, 1, 1, 0.85)
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 16
                }
            }

            // Password field
            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Contrasena"
                echoMode: TextInput.Password
                font.family: root.fontFamily
                font.pixelSize: 14
                color: "#f0f0f0"

                background: Rectangle {
                    color: Qt.rgba(1, 1, 1, 0.06)
                    radius: root.roundCorners
                    border.width: passwordField.activeFocus ? 2 : 1
                    border.color: passwordField.activeFocus ? root.accentColor : Qt.rgba(1, 1, 1, 0.12)

                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                }

                placeholderTextColor: Qt.rgba(1, 1, 1, 0.35)
                leftPadding: 16
                rightPadding: 16

                Keys.onReturnPressed: login()
                Keys.onEnterPressed: login()
            }

            // Error message
            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignHCenter
                text: ""
                font.family: root.fontFamily
                font.pixelSize: 12
                color: "#ff453a"
                visible: text !== ""
            }

            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "Iniciar sesion"

                background: Rectangle {
                    color: loginButton.pressed
                        ? Qt.darker(root.accentColor, 1.2)
                        : loginButton.hovered
                            ? Qt.lighter(root.accentColor, 1.1)
                            : root.accentColor
                    radius: root.roundCorners
                    opacity: loginButton.pressed ? 0.9 : 1.0

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                contentItem: Text {
                    text: loginButton.text
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: login()
            }

            // Session selector
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                spacing: 8

                Text {
                    text: "Sesion:"
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    color: Qt.rgba(1, 1, 1, 0.4)
                }

                ComboBox {
                    id: sessionSelector
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                    implicitWidth: 160

                    background: Rectangle {
                        color: Qt.rgba(1, 1, 1, 0.04)
                        radius: 8
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    contentItem: Text {
                        text: sessionSelector.displayText
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        color: Qt.rgba(1, 1, 1, 0.6)
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }
                }
            }
        }
    }

    // Power buttons (bottom right)
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 12

        Repeater {
            model: ListModel {
                ListElement { icon: "\uf011"; action: "poweroff" }
                ListElement { icon: "\uf01e"; action: "reboot" }
                ListElement { icon: "\uf186"; action: "suspend" }
            }

            delegate: Rectangle {
                width: 40
                height: 40
                radius: 20
                color: mouseArea.containsMouse ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.06)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: model.icon
                    font.family: "Font Awesome 6 Free"
                    font.pixelSize: 14
                    color: Qt.rgba(1, 1, 1, 0.6)
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (model.action === "poweroff") sddm.powerOff()
                        else if (model.action === "reboot") sddm.reboot()
                        else if (model.action === "suspend") sddm.suspend()
                    }
                }
            }
        }
    }

    // Login function
    function login() {
        errorMessage.text = ""
        sddm.login(
            userSelector.currentText,
            passwordField.text,
            sessionSelector.currentIndex
        )
    }

    // Handle login failure
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Credenciales incorrectas"
            passwordField.text = ""
            passwordField.focus = true
        }
    }

    // Focus password on load
    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
