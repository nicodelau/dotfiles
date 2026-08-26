import qs.Core.Components
import qs.Core.Services
import qs.Modules.Settings.Components

SettingContainer {
    SettingGroup {
        title: "Update Preferences"
        icon: "update"

        SettingToggle {
            label: "Auto-check System Updates"
            checked: UpdateService.packageManagerChecksEnabled
            onCheckedChanged: UpdateService.packageManagerChecksEnabled = checked
        }

        SettingSelect {
            enabled: UpdateService.packageManagerChecksEnabled
            opacity: enabled ? 1 : 0.5
            label: "Check Interval"
            description: "Frequency of update checks"
            model: ["1 hour", "6 hours", "12 hours", "24 hours"]
            currentIndex: {
                let val = UpdateService.packageManagerCheckInterval;
                if (val === 3.6e+06)
                    return 0;

                if (val === 2.16e+07)
                    return 1;

                if (val === 4.32e+07)
                    return 2;

                if (val === 8.64e+07)
                    return 3;

                return 3;
            }
            onActivated: (index) => {
                let intervals = [3.6e+06, 2.16e+07, 4.32e+07, 8.64e+07];
                UpdateService.packageManagerCheckInterval = intervals[index];
            }
        }

    }

}
