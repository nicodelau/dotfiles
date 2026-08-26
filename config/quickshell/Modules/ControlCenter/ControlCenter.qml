import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Windows
import qs.Modules.ControlCenter.Widgets.NotificationCenter
import qs.Modules.ControlCenter.Widgets.PerformanceWidget
import qs.Modules.ControlCenter.Widgets.QuickSettings

SidebarWindow {
    id: root

    property var notificationService

    popupId: "controlCenter"
    preferredHeight: root._screenHeight > 0 ? root._screenHeight - 64 - 8 : 1000
    backgroundColor: Theme.bg
    preferredWidth: contentCol.implicitWidth + (Constants.sizeLg * 2)

    ColumnLayout {
        id: contentCol

        spacing: Constants.sizeLg

        QuickSettings {
            id: quickSettings

            Layout.fillWidth: true
            quickSettingsOpen: root.isOpen
            notificationService: root.notificationService
        }

        PerformanceWidget {
            id: performanceWidget

            Layout.fillWidth: true
        }

        NotificationCenter {
            id: notificationCenter

            Layout.fillWidth: true
            Layout.fillHeight: true
            notificationService: root.notificationService
        }

    }

}
