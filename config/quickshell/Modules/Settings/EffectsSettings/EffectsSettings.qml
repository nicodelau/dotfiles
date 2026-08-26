import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Modules.Settings.Components

SettingContainer {
    id: root

    SettingGroup {
        title: "Animations"
        icon: "sparkles"

        SettingSpinBox {
            label: "Global Animation Speed"
            description: "Control UI transition and fade speed"
            from: 0
            to: 2
            stepSize: 0.1
            value: HyprlandService.enableAnimations ? HyprlandService.animationSpeedFactor : 0
            suffix: "x"
            decimals: 1
            allowOff: true
            offText: "Off"
            onMoved: (val) => {
                if (val <= 0.001) {
                    HyprlandService.enableAnimations = false;
                } else {
                    if (!HyprlandService.enableAnimations)
                        HyprlandService.enableAnimations = true;

                    HyprlandService.animationSpeedFactor = Number(val.toFixed(1));
                }
            }
        }

    }

    SettingGroup {
        title: "Wallpaper Transitions"
        icon: "picture-spark"

        SettingSelect {
            label: "Transition Type"
            model: ["none", "grow", "fade", "wipe", "wave", "random"]
            currentIndex: {
                if (!HyprlandService.wpEnableTransitions)
                    return 0;

                let idx = model.indexOf(HyprlandService.wpTransitionType);
                return idx !== -1 ? idx : 1;
            }
            onActivated: (index) => {
                let val = model[index];
                if (val === "none") {
                    HyprlandService.wpEnableTransitions = false;
                } else {
                    HyprlandService.wpEnableTransitions = true;
                    HyprlandService.wpTransitionType = val;
                }
            }
        }

        SettingSelect {
            label: "Transition Position"
            model: ["top-left", "top", "top-right", "left", "center", "right", "bottom-left", "bottom", "bottom-right"]
            currentIndex: {
                let idx = model.indexOf(HyprlandService.wpTransitionPos);
                return idx !== -1 ? idx : 4;
            }
            onActivated: (index) => {
                HyprlandService.wpTransitionPos = model[index];
            }
            enabled: HyprlandService.wpEnableTransitions && HyprlandService.wpTransitionType !== "random"
            opacity: enabled ? 1 : 0.4

            Behavior on opacity {
                NumberAnimation {
                    duration: Constants.animFast
                }

            }

        }

        ColumnLayout {
            spacing: Constants.sizeLg
            Layout.fillWidth: true
            enabled: HyprlandService.wpEnableTransitions
            opacity: enabled ? 1 : 0.4

            SettingSegmented {
                label: "Transition Speed"
                model: [{
                    "text": "Slow",
                    "value": 60
                }, {
                    "text": "Normal",
                    "value": 120
                }, {
                    "text": "Fast",
                    "value": 180
                }, {
                    "text": "Ultra",
                    "value": 240
                }]
                currentValue: HyprlandService.wpTransitionStep
                onActivated: (val) => {
                    HyprlandService.wpTransitionStep = val;
                }
            }

            SettingSegmented {
                label: "Transition Frame Rate"
                model: [{
                    "text": "30",
                    "value": 30
                }, {
                    "text": "60",
                    "value": 60
                }, {
                    "text": "120",
                    "value": 120
                }, {
                    "text": "144",
                    "value": 144
                }]
                currentValue: HyprlandService.wpTransitionFps
                onActivated: (val) => {
                    HyprlandService.wpTransitionFps = val;
                }
            }

            ThemedSlider {
                label: "Transition Angle"
                from: 0
                to: 360
                stepSize: 10
                value: HyprlandService.wpTransitionAngle
                suffix: "°"
                decimals: 0
                visible: HyprlandService.wpTransitionType === "wipe" || HyprlandService.wpTransitionType === "wave"
                onMoved: (val) => {
                    HyprlandService.wpTransitionAngle = Math.round(val);
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Constants.animFast
                }

            }

        }

    }

    SettingGroup {
        title: "Compositor Effects"
        icon: "hyprland"

        SettingToggle {
            id: blurToggle

            label: "Enable Window & Panel Blur"
            onCheckedChanged: {
                if (checked !== HyprlandService.hyprBlur)
                    HyprlandService.hyprBlur = checked;

            }

            Binding on checked {
                value: HyprlandService.hyprBlur
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeMd
            enabled: HyprlandService.hyprBlur
            opacity: enabled ? 1 : 0.5

            SettingSpinBox {
                label: "Blur Size"
                from: 1
                to: 15
                stepSize: 1
                value: HyprlandService.hyprBlurSize
                defaultValue: 6
                onMoved: (val) => {
                    HyprlandService.hyprBlurSize = Math.round(val);
                }
            }

            SettingSpinBox {
                label: "Blur Passes"
                from: 1
                to: 10
                stepSize: 1
                value: HyprlandService.hyprBlurPasses
                defaultValue: 4
                onMoved: (val) => {
                    HyprlandService.hyprBlurPasses = Math.round(val);
                }
            }

        }

        Divider {
        }

        SettingToggle {
            id: shadowToggle

            label: "Enable Window Shadows"
            onCheckedChanged: {
                if (checked !== HyprlandService.hyprShadow)
                    HyprlandService.hyprShadow = checked;

            }

            Binding on checked {
                value: HyprlandService.hyprShadow
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeMd
            enabled: HyprlandService.hyprShadow
            opacity: enabled ? 1 : 0.5

            SettingSpinBox {
                label: "Shadow Range"
                from: 1
                to: 40
                stepSize: 1
                value: HyprlandService.hyprShadowRange
                defaultValue: 4
                suffix: "px"
                onMoved: (val) => {
                    HyprlandService.hyprShadowRange = Math.round(val);
                }
            }

            SettingSpinBox {
                label: "Shadow Render Power"
                from: 1
                to: 4
                stepSize: 1
                value: HyprlandService.hyprShadowRenderPower
                defaultValue: 3
                onMoved: (val) => {
                    HyprlandService.hyprShadowRenderPower = Math.round(val);
                }
            }

        }

    }

}
