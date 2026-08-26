import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Modules.Settings.Components

SettingContainer {
    id: root

    SettingGroup {
        title: "Default Applications"
        icon: "star"

        SettingSelect {
            label: "Default Music Player"
            description: "Used by media widgets"
            model: {
                let players = [];
                if (SystemStats.hasSpotify || SettingsService.musicPlayer === "spotify")
                    players.push("spotify");

                if (SystemStats.hasYoutubeMusic || SettingsService.musicPlayer === "youtube-music")
                    players.push("youtube-music");

                if (SystemStats.hasKew || SettingsService.musicPlayer === "kew")
                    players.push("kew");

                if (players.indexOf("mpd") === -1)
                    players.push("mpd");

                if (players.indexOf("custom") === -1)
                    players.push("custom");

                return players;
            }
            currentIndex: {
                let idx = model.indexOf(SettingsService.musicPlayer);
                return idx !== -1 ? idx : 0;
            }
            onActivated: (index) => {
                let player = model[index];
                SettingsService.musicPlayer = player;
                if (player !== "custom")
                    SettingsService.musicPlayerCommand = player;

            }
            iconMap: {
                "spotify": "spotify",
                "youtube-music": "youtube",
                "mpd": "music",
                "kew": "music",
                "custom": "terminal"
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeMd
            visible: SettingsService.musicPlayer === "custom"

            ThemedTextField {
                Layout.fillWidth: true
                placeholderText: "Command to launch music player..."
                text: SettingsService.musicPlayerCommand
                onEditingFinished: {
                    SettingsService.musicPlayerCommand = text;
                }
            }

        }

    }

    SettingGroup {
        title: "Quotes"
        icon: "quote"

        SettingSelect {
            label: "Quote Category"
            description: "Used by quote widget"
            model: QuoteService.categories
            currentIndex: {
                let idx = model.indexOf(SettingsService.quoteCategory);
                return idx !== -1 ? idx : 0;
            }
            onActivated: (index) => {
                SettingsService.quoteCategory = model[index];
            }
        }

    }

    SettingGroup {
        title: "GitHub Integration"
        icon: "github"

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Constants.size2Xs

            ThemedText {
                text: "GitHub Username"
                font.pixelSize: Constants.sizeMd
            }

            ThemedTextField {
                Layout.fillWidth: true
                placeholderText: "octocat"
                text: SettingsService.githubUsername
                onEditingFinished: {
                    SettingsService.githubUsername = text;
                }
            }

        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Constants.size2Xs

            ThemedText {
                text: "GitHub Personal Access Token"
                font.pixelSize: Constants.sizeMd
            }

            ThemedTextField {
                Layout.fillWidth: true
                placeholderText: "ghp_xxxxxxxxxxxxxxxxxxxx"
                isPassword: true
                text: SettingsService.githubToken
                onEditingFinished: {
                    SettingsService.githubToken = text;
                }
            }

        }

    }

}
