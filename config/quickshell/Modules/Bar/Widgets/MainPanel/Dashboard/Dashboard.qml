import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components

RowLayout {
    id: root

    property var widget

    spacing: Constants.sizeLg

    ColumnLayout {
        spacing: Constants.sizeLg
        Layout.fillWidth: false
        Layout.preferredWidth: 280
        Layout.fillHeight: true

        GithubWidget {
            id: githubWidget

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        spacing: Constants.sizeLg
        Layout.fillWidth: true
        Layout.preferredWidth: 420
        Layout.fillHeight: true

        MiniMusicWidget {
            id: miniMusicWidget

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        UpdatesCard {
            id: updatesCard

            Layout.fillWidth: true
            Layout.fillHeight: false
        }

        QuoteWidget {
            id: quoteWidget

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }

}
