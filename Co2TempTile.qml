import QtQuick 2.1
import qb.components 1.0

Tile {
    id: co2TempTile

    property bool dimState: screenStateController.dimmedColors

    function co2Color(val) {
        var v = parseInt(val);
        if (isNaN(v))
            return (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor;
        if (v < 800)
            return "#2ecc71";
        if (v < 1200)
            return "#f39c12";
        return "#e74c3c";
    }

    onClicked: {
        if (app.co2SettingsScreen)
            app.co2SettingsScreen.show();
    }

    // Dimmed state: large CO2 reading centered
    Text {
        id: dimCo2Text
        text: app.co2Value
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 70 : 55
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 65 : 50
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
        visible: dimState
    }

    Text {
        id: dimCo2Unit
        text: "ppm"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 100 : 80
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 22 : 18
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
        visible: dimState
    }

    // Normal state: CO2 left, temperature right
    Text {
        id: co2Label
        text: "CO₂"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 32 : 25
            left: parent.left
            leftMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: tempLabel
        text: "Temp"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 32 : 25
            right: parent.right
            rightMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: co2ValueText
        text: app.co2Value + " ppm"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 75 : 60
            left: parent.left
            leftMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 22 : 18
        }
        color: co2Color(app.co2Value)
        visible: !dimState
    }

    Text {
        id: tempValueText
        text: app.temperature + "°"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 75 : 60
            right: parent.right
            rightMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 22 : 18
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: lastUpdatedText
        text: app.lastUpdated
        anchors {
            baseline: parent.bottom
            baselineOffset: -8
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 16 : 13
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }
}
