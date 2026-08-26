import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Services

ColumnLayout {
    spacing: Constants.sizeMd

    Text {
        text: "“" + QuoteService.currentQuote.text + "”"
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeMd
        font.italic: true
        color: Theme.muted
        horizontalAlignment: Text.AlignRight
        Layout.alignment: Qt.AlignRight
        wrapMode: Text.WordWrap
        Layout.maximumWidth: 400
    }

    Text {
        text: "— " + QuoteService.currentQuote.author.toUpperCase()
        font.family: Constants.fontFamily
        font.pixelSize: Constants.sizeXs + 2
        color: Theme.muted
        font.letterSpacing: 2
        Layout.alignment: Qt.AlignRight
    }

}
