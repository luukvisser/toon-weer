import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

import BxtClient 1.0
import "weer.js" as WeerJS

Screen {
    id: lonlatEntryScreen

    property string qrCodeID

    function saveLon(text) {
        if (text) {
            app.lon = parseFloat(text.replace(",", ".")).toFixed(4);
            app.saveSettings();
        }
    }

    function saveLat(text) {
        if (text) {
            app.lat = parseFloat(text.replace(",", ".")).toFixed(4);
            app.saveSettings();
            if (!app.useOpenMeteo)
                findNearestWeatherStation();
        }
    }

    function validateCoordinate(text, isFinalString) {
        return null;
    }

    hasCancelButton: true
    hasSaveButton: false

    screenTitle: "Weer settings"

    onShown: {
        addCustomTopRightButton("Opslaan");
        if (app.stationIndex > -1)
            stationLabel.inputText = app.stationNames[app.stationIndex];
    }

    function toRad(x) {
        return x * Math.PI / 180;
    }

    function haversineDistance(lat1, lon1, lat2, lon2) {
        var R = 6371; // km
        var x1 = lat2 - lat1;
        var dLat = toRad(x1);
        var x2 = lon2 - lon1;
        var dLon = toRad(x2);
        var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        var d = R * c;
        return d;
    }

    function findNearestWeatherStation() {
        var nearestDistance = 1000000;	// a random very high number :-)
        var nearestStation = "";
        var distance = 0;
        for (var i = 0; i < app.stationNames.length; i++) {
            distance = haversineDistance(parseFloat(app.lat), parseFloat(app.lon), parseFloat(app.stationLats[i]), parseFloat(app.stationLons[i]));
            if (nearestDistance > distance) {
                nearestDistance = distance;
                nearestStation = app.stationIds[i];
            }
        }
        app.location = nearestStation;
        app.stationIndex = app.stationIds.indexOf(parseInt(app.location));
        app.saveSettings();
        app.updateWeather();
        stationLabel.inputText = app.stationNames[app.stationIndex];
        qdialog.showDialog(qdialog.SizeLarge, "Weer mededeling", "Op basis van de ingevoerde lat/lon coordinaten is het volgende dichtsbijzijnde weerstation geselekteerd:\n\nStation: " + app.stationNames[app.stationIndex] + "\nAfstand : " + (Math.round(nearestDistance * 100) / 100) + " km", "Sluiten");
    }

    onCustomButtonClicked: {
        app.saveSettings();
        app.updateRain();
        hide();
    }

    Text {
        id: title
        text: "Invoeren GPS coordinaten (4 decimalen) voor de exacte regenverwachting en automatische selektie van het dichtsbijzijnde weerstation."
        width: isNxt ? 500 : 400
        wrapMode: Text.WordWrap
        font.pixelSize: isNxt ? 20 : 16
        font.family: qfont.semiBold.name
        color: colors.rbTitle

        anchors {
            left: lonButton.right
            leftMargin: 20
            top: lonButton.top
        }
    }

    EditTextLabel4421 {
        id: lonLabel
        width: isNxt ? 350 : 280
        height: isNxt ? 45 : 35
        leftText: "Lengtegraad:"
        leftTextAvailableWidth: isNxt ? 175 : 140
        inputText: app.lon

        anchors {
            left: parent.left
            leftMargin: 40
            top: parent.top
            topMargin: 30
        }

        onClicked: {
            qnumKeyboard.open("Lengtegraad", lonLabel.inputText, app.lon, 1, saveLon, validateCoordinate);
        }
    }

    IconButton {
        id: lonButton
        width: isNxt ? 50 : 40

        iconSource: "qrc:/tsc/edit.png"

        anchors {
            left: lonLabel.right
            leftMargin: 6
            top: lonLabel.top
        }

        bottomClickMargin: 3
        onClicked: {
            qnumKeyboard.open("Lengtegraad", lonLabel.inputText, app.lon, 1, saveLon, validateCoordinate);
        }
    }

    EditTextLabel4421 {
        id: latLabel
        width: lonLabel.width
        height: isNxt ? 45 : 35
        leftText: "Breedtegraad:"
        leftTextAvailableWidth: isNxt ? 175 : 140
        inputText: app.lat

        anchors {
            left: lonLabel.left
            top: lonLabel.bottom
            topMargin: 6
        }

        onClicked: {
            qnumKeyboard.open("Breedtegraad", latLabel.inputText, app.lat, 1, saveLat, validateCoordinate);
        }
    }

    IconButton {
        id: latButton
        width: isNxt ? 50 : 40
        iconSource: "qrc:/tsc/edit.png"

        anchors {
            left: latLabel.right
            leftMargin: 6
            top: lonLabel.bottom
            topMargin: 6
        }

        topClickMargin: 3
        onClicked: {
            qnumKeyboard.open("Breedtegraad", latLabel.inputText, app.lat, 1, saveLat, validateCoordinate);
        }
    }

    Text {
        id: resolvedLocationText
        text: app.locationName !== "" ? app.locationName : (app.lat + ", " + app.lon)
        visible: app.useOpenMeteo
        height: isNxt ? 45 : 35
        verticalAlignment: Text.AlignVCenter
        anchors {
            left: lonLabel.left
            top: latLabel.bottom
            topMargin: 6
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    EditTextLabel4421 {
        id: stationLabel
        width: lonLabel.width
        height: isNxt ? 45 : 35
        leftText: "Weerstation:"
        leftTextAvailableWidth: isNxt ? 175 : 140
        visible: !app.useOpenMeteo

        anchors {
            left: lonLabel.left
            top: latLabel.bottom
            topMargin: 6
        }

        onClicked: {
            if (app.weerStationScreen) {
                app.weerStationScreen.show();
            }
        }
    }

    IconButton {
        id: stationButton
        width: isNxt ? 50 : 40
        iconSource: "qrc:/tsc/edit.png"
        visible: !app.useOpenMeteo

        anchors {
            left: stationLabel.right
            leftMargin: 6
            top: latLabel.bottom
            topMargin: 6
        }

        topClickMargin: 3
        onClicked: {
            if (app.weerStationScreen) {
                app.weerStationScreen.show();
            }
        }
    }

    Text {
        id: uitlegStation
        text: "Eventuele handmatige selektie weerstation."
        width: isNxt ? 500 : 400
        visible: !app.useOpenMeteo
        anchors {
            left: stationButton.right
            leftMargin: 20
            top: stationButton.top
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    // Open-Meteo GPS mode toggle
    Text {
        id: openMeteoLabel
        text: "Open-Meteo GPS modus:"
        anchors {
            left: lonLabel.left
            top: latLabel.bottom
            topMargin: isNxt ? 62 : 50
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: openMeteoToggleBg
        width: isNxt ? 72 : 56
        height: isNxt ? 36 : 28
        radius: height / 2
        color: app.useOpenMeteo ? "#4CAF50" : "#888888"
        anchors {
            left: openMeteoLabel.right
            leftMargin: 12
            verticalCenter: openMeteoLabel.verticalCenter
        }

        Rectangle {
            id: openMeteoThumb
            width: parent.height - 6
            height: width
            radius: width / 2
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            x: app.useOpenMeteo ? parent.width - width - 3 : 3
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                app.useOpenMeteo = !app.useOpenMeteo;
                app.saveSettings();
                app.updateWeather();
            }
        }
    }

    Text {
        id: openMeteoUitleg
        text: app.useOpenMeteo ? "Alle weerdata via Open-Meteo op basis van GPS coordinaten (geen weerstation nodig)." : "Gebruik Weer weerstation voor actuele meting."
        width: isNxt ? 480 : 370
        wrapMode: Text.WordWrap
        anchors {
            left: openMeteoToggleBg.right
            leftMargin: 16
            top: openMeteoToggleBg.top
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: colors.rbTitle
    }

    // Rain prediction window: number of hours shown in the rain tile (2-24), Open-Meteo mode only

    Text {
        id: rainHoursLabel
        text: "Regen tegel uren:"
        visible: app.useOpenMeteo
        anchors {
            left: lonLabel.left
            top: openMeteoLabel.bottom
            topMargin: isNxt ? 32 : 26
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: rainHoursMinus
        width: isNxt ? 36 : 28
        height: width
        radius: 4
        color: "#888888"
        visible: app.useOpenMeteo
        anchors {
            left: rainHoursLabel.right
            leftMargin: 12
            verticalCenter: rainHoursLabel.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "−"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.rainHours > 2) {
                    app.rainHours = app.rainHours - 1;
                    app.saveSettings();
                    app.updateRain();
                }
            }
        }
    }

    Text {
        id: rainHoursValue
        text: app.rainHours + " uur"
        width: isNxt ? 70 : 56
        horizontalAlignment: Text.AlignHCenter
        visible: app.useOpenMeteo
        anchors {
            left: rainHoursMinus.right
            leftMargin: 8
            verticalCenter: rainHoursMinus.verticalCenter
        }
        font {
            family: qfont.bold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: rainHoursPlus
        width: rainHoursMinus.width
        height: rainHoursMinus.height
        radius: 4
        color: "#888888"
        visible: app.useOpenMeteo
        anchors {
            left: rainHoursValue.right
            leftMargin: 8
            verticalCenter: rainHoursMinus.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "+"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.rainHours < 24) {
                    app.rainHours = app.rainHours + 1;
                    app.saveSettings();
                    app.updateRain();
                }
            }
        }
    }

    Text {
        id: rainHoursUitleg
        text: "Aantal uren vooruit in de regenverwachting tegel (Open-Meteo modus)."
        width: isNxt ? 480 : 370
        wrapMode: Text.WordWrap
        visible: app.useOpenMeteo
        anchors {
            left: rainHoursPlus.right
            leftMargin: 16
            verticalCenter: rainHoursPlus.verticalCenter
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: colors.rbTitle
    }

    // Weather refresh interval

    Text {
        id: weatherRefreshLabel
        text: "Weer verversing:"
        anchors {
            left: lonLabel.left
            top: app.useOpenMeteo ? rainHoursLabel.bottom : openMeteoLabel.bottom
            topMargin: isNxt ? 32 : 26
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: weatherRefreshMinus
        width: isNxt ? 36 : 28
        height: width
        radius: 4
        color: "#888888"
        anchors {
            left: weatherRefreshLabel.right
            leftMargin: 12
            verticalCenter: weatherRefreshLabel.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "−"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.weatherRefreshMin > 1) {
                    app.weatherRefreshMin = app.weatherRefreshMin - 1;
                    app.saveSettings();
                }
            }
        }
    }

    Text {
        id: weatherRefreshValue
        text: app.weatherRefreshMin + " min"
        width: isNxt ? 70 : 56
        horizontalAlignment: Text.AlignHCenter
        anchors {
            left: weatherRefreshMinus.right
            leftMargin: 8
            verticalCenter: weatherRefreshMinus.verticalCenter
        }
        font {
            family: qfont.bold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: weatherRefreshPlus
        width: weatherRefreshMinus.width
        height: weatherRefreshMinus.height
        radius: 4
        color: "#888888"
        anchors {
            left: weatherRefreshValue.right
            leftMargin: 8
            verticalCenter: weatherRefreshMinus.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "+"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.weatherRefreshMin < 60) {
                    app.weatherRefreshMin = app.weatherRefreshMin + 1;
                    app.saveSettings();
                }
            }
        }
    }

    Text {
        id: weatherRefreshUitleg
        text: "Interval voor het verversen van de weergegevens (1–60 min)."
        width: isNxt ? 480 : 370
        wrapMode: Text.WordWrap
        anchors {
            left: weatherRefreshPlus.right
            leftMargin: 16
            verticalCenter: weatherRefreshPlus.verticalCenter
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: colors.rbTitle
    }

    // Rain refresh interval

    Text {
        id: rainRefreshLabel
        text: "Regen verversing:"
        anchors {
            left: lonLabel.left
            top: weatherRefreshLabel.bottom
            topMargin: isNxt ? 32 : 26
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: rainRefreshMinus
        width: isNxt ? 36 : 28
        height: width
        radius: 4
        color: "#888888"
        anchors {
            left: rainRefreshLabel.right
            leftMargin: 12
            verticalCenter: rainRefreshLabel.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "−"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.rainRefreshMin > 1) {
                    app.rainRefreshMin = app.rainRefreshMin - 1;
                    app.saveSettings();
                }
            }
        }
    }

    Text {
        id: rainRefreshValue
        text: app.rainRefreshMin + " min"
        width: isNxt ? 70 : 56
        horizontalAlignment: Text.AlignHCenter
        anchors {
            left: rainRefreshMinus.right
            leftMargin: 8
            verticalCenter: rainRefreshMinus.verticalCenter
        }
        font {
            family: qfont.bold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: rainRefreshPlus
        width: rainRefreshMinus.width
        height: rainRefreshMinus.height
        radius: 4
        color: "#888888"
        anchors {
            left: rainRefreshValue.right
            leftMargin: 8
            verticalCenter: rainRefreshMinus.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "+"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.rainRefreshMin < 30) {
                    app.rainRefreshMin = app.rainRefreshMin + 1;
                    app.saveSettings();
                }
            }
        }
    }

    Text {
        id: rainRefreshUitleg
        text: "Interval voor het verversen van de regenverwachting (1–30 min)."
        width: isNxt ? 480 : 370
        wrapMode: Text.WordWrap
        anchors {
            left: rainRefreshPlus.right
            leftMargin: 16
            verticalCenter: rainRefreshPlus.verticalCenter
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: colors.rbTitle
    }

    // Day offset: hour at which the summary tile switches to tomorrow's data

    Text {
        id: dayOffsetLabel
        text: "Omschakeling morgen:"
        anchors {
            left: lonLabel.left
            top: rainRefreshLabel.bottom
            topMargin: isNxt ? 32 : 26
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: dayOffsetMinus
        width: isNxt ? 36 : 28
        height: width
        radius: 4
        color: "#888888"
        anchors {
            left: dayOffsetLabel.right
            leftMargin: 12
            verticalCenter: dayOffsetLabel.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "−"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.dayOffsetHour > -12) {
                    app.dayOffsetHour = app.dayOffsetHour - 1;
                    app.saveSettings();
                }
            }
        }
    }

    Text {
        id: dayOffsetValue
        text: {
            var h = ((24 + app.dayOffsetHour) % 24);
            return (h < 10 ? "0" : "") + h + ":00";
        }
        width: isNxt ? 70 : 56
        horizontalAlignment: Text.AlignHCenter
        anchors {
            left: dayOffsetMinus.right
            leftMargin: 8
            verticalCenter: dayOffsetMinus.verticalCenter
        }
        font {
            family: qfont.bold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: colors.rbTitle
    }

    Rectangle {
        id: dayOffsetPlus
        width: dayOffsetMinus.width
        height: dayOffsetMinus.height
        radius: 4
        color: "#888888"
        anchors {
            left: dayOffsetValue.right
            leftMargin: 8
            verticalCenter: dayOffsetMinus.verticalCenter
        }
        Text {
            anchors.centerIn: parent
            text: "+"
            color: "white"
            font {
                family: qfont.bold.name
                pixelSize: isNxt ? 24 : 20
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.dayOffsetHour < 12) {
                    app.dayOffsetHour = app.dayOffsetHour + 1;
                    app.saveSettings();
                }
            }
        }
    }

    Text {
        id: dayOffsetUitleg
        text: "Tijdstip waarop de samenvatting omschakelt naar het weer van morgen (−12 t/m +12 uur)."
        width: isNxt ? 480 : 370
        wrapMode: Text.WordWrap
        anchors {
            left: dayOffsetPlus.right
            leftMargin: 16
            verticalCenter: dayOffsetPlus.verticalCenter
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: colors.rbTitle
    }
}
