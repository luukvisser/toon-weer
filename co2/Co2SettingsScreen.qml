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

    function saveOpenairIp(text) {
        if (text !== undefined)
            app.openairIp = text.trim();
    }

    function validateText(text, isFinal) {
        return null;
    }

    function saveRefresh(text) {
        if (text) {
            var v = parseInt(text);
            if (!isNaN(v) && v >= 10 && v <= 300)
                app.refreshSec = v;
        }
    }

    onShown: {
        addCustomTopRightButton("Opslaan");
        ipLabel.inputText = app.deviceIp;
        openairLabel.inputText = app.openairIp;
        refreshLabel.inputText = app.refreshSec.toString();
    }

    onCustomButtonClicked: {
        app.saveSettings();
        if (app.deviceIp || app.openairIp)
            app.fetchData();
        hide();
    }

    Text {
        id: explanationText
        text: "IP-adressen van de lokale ESPHome apparaten. AirGradient levert CO₂ en temperatuur; Open-AIR levert de ventilatorsnelheid van de Orcon WTW."
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
            top: ipLabel.top
        }
    }

    EditTextLabel4421 {
        id: ipLabel
        width: isNxt ? 350 : 280
        height: isNxt ? 45 : 35
        leftText: "AirGradient IP:"
        leftTextAvailableWidth: isNxt ? 175 : 140

        anchors {
            left: parent.left
            leftMargin: 40
            top: parent.top
            topMargin: 30
        }

        onClicked: {
            qkeyboard.open("AirGradient IP", ipLabel.inputText, saveIp, validateText);
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
            qkeyboard.open("AirGradient IP", ipLabel.inputText, saveIp, validateText);
        }
    }

    EditTextLabel4421 {
        id: openairLabel
        width: isNxt ? 350 : 280
        height: isNxt ? 45 : 35
        leftText: "Open-AIR IP:"
        leftTextAvailableWidth: isNxt ? 175 : 140

        anchors {
            left: ipLabel.left
            top: ipLabel.bottom
            topMargin: 6
        }

        onClicked: {
            qkeyboard.open("Open-AIR IP", openairLabel.inputText, saveOpenairIp, validateText);
        }
    }

    IconButton {
        id: openairButton
        width: isNxt ? 50 : 40
        iconSource: "qrc:/tsc/edit.png"

        anchors {
            left: openairLabel.right
            leftMargin: 6
            top: openairLabel.top
        }

        onClicked: {
            qkeyboard.open("Open-AIR IP", openairLabel.inputText, saveOpenairIp, validateText);
        }
    }

    EditTextLabel4421 {
        id: refreshLabel
        width: isNxt ? 350 : 280
        height: isNxt ? 45 : 35
        leftText: "Verversing (s):"
        leftTextAvailableWidth: isNxt ? 175 : 140

        anchors {
            left: openairLabel.left
            top: openairLabel.bottom
            topMargin: 6
        }

        onClicked: {
            qnumKeyboard.open("Verversing (10-300 s)", refreshLabel.inputText, app.refreshSec.toString(), 0, saveRefresh, validateText);
        }
    }

    IconButton {
        id: refreshButton
        width: isNxt ? 50 : 40
        iconSource: "qrc:/tsc/edit.png"

        anchors {
            left: refreshLabel.right
            leftMargin: 6
            top: refreshLabel.top
        }

        onClicked: {
            qnumKeyboard.open("Verversing (10-300 s)", refreshLabel.inputText, app.refreshSec.toString(), 0, saveRefresh, validateText);
        }
    }

    // -------------------------------------------------------------------------
    // Update section
    // -------------------------------------------------------------------------

    Rectangle {
        id: divider
        height: 1
        color: colors.addDeviceBackgroundRectangle
        anchors {
            left: refreshLabel.left
            right: refreshButton.right
            top: refreshLabel.bottom
            topMargin: 16
        }
    }

    Text {
        id: versionLabel
        text: "Versie: " + app.currentVersion
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
        anchors {
            left: refreshLabel.left
            top: divider.bottom
            topMargin: 12
        }
    }

    StandardButton {
        id: checkButton
        text: app.updateChecking ? "…" : "Controleer"
        width: isNxt ? 130 : 105
        enabled: !app.updateChecking && !app.updateInProgress
        anchors {
            left: versionLabel.right
            leftMargin: 16
            verticalCenter: versionLabel.verticalCenter
        }
        onClicked: app.checkForUpdate()
    }

    StandardButton {
        id: installButton
        text: "Installeer v" + app.latestVersion
        width: isNxt ? 200 : 160
        visible: app.updateAvailable && !app.updateInProgress
        anchors {
            left: refreshLabel.left
            top: versionLabel.bottom
            topMargin: 8
        }
        onClicked: app.installUpdate()
    }

    Text {
        id: updateStatusText
        text: app.updateStatus
        visible: app.updateStatus !== ""
        wrapMode: Text.WordWrap
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 18 : 14
        }
        color: colors.rbTitle
        anchors {
            left: app.updateAvailable && !app.updateInProgress ? installButton.right : refreshLabel.left
            leftMargin: app.updateAvailable && !app.updateInProgress ? 16 : 0
            right: refreshButton.right
            top: versionLabel.bottom
            topMargin: 8
        }
    }
}
