import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Core
import qs.Core.Components

SvgIconButton {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property int volume: (sink && sink.audio) ? Math.round(sink.audio.volume * 100) : 0
    property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    function setVolume(val) {
        if (sink && sink.audio)
            sink.audio.volume = val / 100;

    }

    function toggleMute() {
        if (sink && sink.audio)
            sink.audio.muted = !sink.audio.muted;

    }

    icon: muted ? "volume-off" : "volume"
    iconColor: muted ? Theme.muted : Theme.accent
    iconSize: Constants.sizeXl
    onClicked: root.toggleMute()

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

}
