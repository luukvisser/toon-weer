import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {
    id: co2SettingsScreen

    screenTitle: "Luchtkwaliteit instellingen"
    hasCancelButton: true

    function saveIp(text) {
        if (text !== undefined)
            app.deviceIp = text.trim();
    }

    function validateIp(text, isFinal) {
        return null;
    }

    function saveRefresh(text) {
        if (text) {
            var v = parseInt(text);
            if (!isNaN(v) && v >= 10 && v <= 300)
                app.refreshSec = v;
        }
    }

    function validateRefresh(text, isFinal) {
        return null;
    }

    onShown: {
        addCustomTopRightButton("Opslaan");
        ipLabel.inputText = app.deviceIp;
        refreshLabel.inputText = app.refreshSec.toString();
    }

    onCustomButtonClicked: {
        app.saveSettings();
        if (app.deviceIp)
            app.fetchData();
        hide();
    }

    Text {
        id: explanationText
        text: "IP-adres van de AirGradient luchtkwaliteitsmeter op het lokale netwerk."
        width: isNxt ? 500 : 400
        wrapMode: Text.WordWrap
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
        anchors {
            left: ipButton.right
            leftMargin: 20
            top: ipButton.top
        }
    }

    EditTextLabel4421 {
        id: ipLabel
        width: isNxt ? 350 : 280
        height: isNxt ? 45 : 35
        leftText: "IP-adres:"
        leftTextAvailableWidth: isNxt ? 175 : 140

        anchors {
            left: parent.left
            leftMargin: 40
            top: parent.top
            topMargin: 30
        }

        onClicked: {
            qkeyboard.open("IP-adres", ipLabel.inputText, saveIp, validateIp);
        }
    }

    IconButton {
        id: ipButton
        width: isNxt ? 50 : 40
        iconSource: "qrc:/tsc/edit.png"

        anchors {
            left: ipLabel.right
            leftMargin: 6
            top: ipLabel.top
        }

        onClicked: {
            qkeyboard.open("IP-adres", ipLabel.inputText, saveIp, validateIp);
        }
    }

    EditTextLabel4421 {
        id: refreshLabel
        width: isNxt ? 350 : 280
        height: isNxt ? 45 : 35
        leftText: "Verversing (s):"
        leftTextAvailableWidth: isNxt ? 175 : 140

        anchors {
            left: ipLabel.left
            top: ipLabel.bottom
            topMargin: 6
        }

        onClicked: {
            qnumKeyboard.open("Verversing (10-300 s)", refreshLabel.inputText, app.refreshSec.toString(), 0, saveRefresh, validateRefresh);
        }
    }

    IconButton {
        id: refreshButton
        width: isNxt ? 50 : 40
        iconSource: "qrc:/tsc/edit.png"

        anchors {
            left: refreshLabel.right
            leftMargin: 6
            top: ipLabel.bottom
            topMargin: 6
        }

        onClicked: {
            qnumKeyboard.open("Verversing (10-300 s)", refreshLabel.inputText, app.refreshSec.toString(), 0, saveRefresh, validateRefresh);
        }
    }
}
