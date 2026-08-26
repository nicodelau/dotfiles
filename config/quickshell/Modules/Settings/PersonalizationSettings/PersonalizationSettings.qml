import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Utils
import qs.Modules.Settings.Components

SettingContainer {
    id: appearanceRoot

    property bool showingDark: true
    property var availableFonts: []
    property string currentFontName: "Geist"
    property int currentFontSize: 11

    function applyFont() {
        SettingsService.fontFamily = appearanceRoot.currentFontName;
        setFontProc.command = ["python3", Quickshell.shellDir + "/Scripts/apply_font.py", appearanceRoot.currentFontName, appearanceRoot.currentFontSize.toString()];
        setFontProc.running = false;
        setFontProc.running = true;
    }

    onShowingDarkChanged: {
        if (!Theme.generateFromWallpaper) {
            let t = Theme.themes[0];
            let scheme = showingDark ? t.dark : t.light;
            Theme.applyScheme(scheme);
        }
    }
    Component.onCompleted: {
        showingDark = ColorUtils.isDark(Theme.bg);
    }

    Connections {
        function onBgChanged() {
            appearanceRoot.showingDark = ColorUtils.isDark(Theme.bg);
        }

        target: Theme
    }

    Process {
        id: setFontProc
    }

    Process {
        id: fetchFontsProc

        command: ["sh", "-c", "fc-list : family | cut -d, -f1 | sort -u"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (data) {
                    let lines = data.split('\n').map((x) => {
                        return x.trim();
                    }).filter((x) => {
                        return x !== "";
                    });
                    let arr = appearanceRoot.availableFonts.slice();
                    let changed = false;
                    lines.forEach((l) => {
                        if (arr.indexOf(l) === -1) {
                            arr.push(l);
                            changed = true;
                        }
                    });
                    if (changed)
                        appearanceRoot.availableFonts = arr;

                }
            }
        }

    }

    Process {
        id: getFontProc

        command: ["sh", "-c", "gsettings get org.gnome.desktop.interface font-name | tr -d \"'\""]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim() !== "") {
                    let full = data.trim();
                    let match = full.match(/(.*)\s+(\d+)$/);
                    if (match) {
                        appearanceRoot.currentFontName = match[1];
                        appearanceRoot.currentFontSize = parseInt(match[2]);
                    } else {
                        appearanceRoot.currentFontName = full;
                        appearanceRoot.currentFontSize = 11;
                    }
                    if (appearanceRoot.availableFonts.indexOf(appearanceRoot.currentFontName) === -1) {
                        let arr = appearanceRoot.availableFonts.slice();
                        arr.unshift(appearanceRoot.currentFontName);
                        appearanceRoot.availableFonts = arr;
                    }
                }
            }
        }

    }

    SettingGroup {
        title: "Color Theme"
        icon: "color-palette"

        SettingToggle {
            label: "Dynamic Colors"
            description: "Generate color scheme from current wallpaper"
            checked: Theme.generateFromWallpaper
            onCheckedChanged: {
                if (checked !== Theme.generateFromWallpaper) {
                    Theme.generateFromWallpaper = checked;
                    if (checked) {
                        if (WallpaperManager.currentWallpaperPath !== "")
                            Theme.generateTheme(WallpaperManager.currentWallpaperPath);

                    } else {
                        let t = Theme.themes[0];
                        let baseName = Theme.currentScheme.replace(" Light", "");
                        for (let i = 0; i < Theme.themes.length; i++) {
                            if (Theme.themes[i].name === baseName) {
                                t = Theme.themes[i];
                                break;
                            }
                        }
                        let scheme = appearanceRoot.showingDark ? t.dark : t.light;
                        Theme.applyScheme(scheme);
                    }
                }
            }
        }

        Divider {
        }

        SettingSelect {
            label: "Static Theme"
            description: "Color scheme when dynamic colors are off"
            enabled: !Theme.generateFromWallpaper
            opacity: enabled ? 1 : 0.5
            model: {
                let m = [];
                for (let i = 0; i < Theme.themes.length; i++) {
                    m.push(Theme.themes[i].name);
                }
                return m;
            }
            currentIndex: {
                let baseName = Theme.currentScheme.replace(" Light", "");
                let idx = -1;
                for (let i = 0; i < Theme.themes.length; i++) {
                    if (Theme.themes[i].name === baseName) {
                        idx = i;
                        break;
                    }
                }
                return idx !== -1 ? idx : 0;
            }
            onActivated: (index) => {
                let t = Theme.themes[index];
                let scheme = appearanceRoot.showingDark ? t.dark : t.light;
                Theme.applyScheme(scheme);
            }
        }

        Divider {
        }

        SettingToggle {
            label: "Dark Mode"
            description: "Use dark variant of the selected theme"
            enabled: !Theme.generateFromWallpaper
            opacity: enabled ? 1 : 0.5
            checked: appearanceRoot.showingDark
            onCheckedChanged: {
                appearanceRoot.showingDark = checked;
            }
        }

        Divider {
        }

        SettingSpinBox {
            label: "Bar Opacity"
            description: "Set the transparency level of the status bar"
            from: 0
            to: 100
            stepSize: 5
            value: Math.round(Theme.bgOpacity * 100)
            suffix: "%"
            decimals: 0
            onMoved: (val) => {
                let opacity = val / 100.0;
                if (Theme.bgOpacity !== opacity) {
                    Theme.bgOpacity = opacity;
                    Theme.saveScheme();
                }
            }
        }

    }

    SettingGroup {
        title: "System Fonts"
        icon: "font"

        SettingSelect {
            label: "System Font"
            description: "Global font for GTK, Qt and Shell"
            comboWidth: 260
            model: appearanceRoot.availableFonts
            currentIndex: {
                let idx = model.indexOf(appearanceRoot.currentFontName);
                return idx !== -1 ? idx : 0;
            }
            onActivated: (index) => {
                let newFont = model[index];
                if (appearanceRoot.currentFontName !== newFont) {
                    appearanceRoot.currentFontName = newFont;
                    appearanceRoot.applyFont();
                }
            }
        }

        SettingSpinBox {
            label: "System Font Size"
            description: "Global font size for GTK and Qt"
            from: 8
            to: 24
            stepSize: 1
            value: appearanceRoot.currentFontSize
            suffix: " pt"
            decimals: 0
            onMoved: (val) => {
                let newSize = Math.round(val);
                if (appearanceRoot.currentFontSize !== newSize) {
                    appearanceRoot.currentFontSize = newSize;
                    appearanceRoot.applyFont();
                }
            }
        }

    }

    SettingGroup {
        title: "Wallpaper Settings"
        icon: "picture"

        SettingToggle {
            id: autoShuffleToggle

            label: "Auto-shuffle Wallpapers"
            onCheckedChanged: {
                if (checked !== HyprlandService.wpAutoShuffle)
                    HyprlandService.wpAutoShuffle = checked;

            }

            Binding {
                target: autoShuffleToggle
                property: "checked"
                value: HyprlandService.wpAutoShuffle
            }

        }

        SettingSpinBox {
            enabled: HyprlandService.wpAutoShuffle
            opacity: enabled ? 1 : 0.5
            label: "Shuffle Interval"
            from: 1
            to: 60
            stepSize: 1
            value: HyprlandService.wpShuffleInterval
            suffix: " min"
            decimals: 0
            onMoved: (val) => {
                HyprlandService.wpShuffleInterval = Math.round(val);
            }
        }

    }

}
