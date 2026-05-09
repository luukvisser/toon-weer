import QtQuick 2.1
import qb.components 1.0
import "weer.js" as WeerJS

Tile {
    id: weerTile
    property string tempVal: app.useOpenMeteo ? (app.locationName ? WeerJS.formatTemp(app.temperature, app.locationName) : "Even geduld") : (app.stationIndex < 0 ? "Even geduld" : WeerJS.formatTemp(app.temperature, app.stationNames[app.stationIndex]))
    property string tempWind: WeerJS.formatWind(app.windDirection, app.windSpeedBft)
    property string tempZin: WeerJS.formatZin(app.weatherDescription)
    property string tempLuchtdruk: WeerJS.formatLuchtdruk(app.pressure, app.humidity)
    property string dimTempVal: WeerJS.formatDimTemp(app.temperature)

    property bool dimState: screenStateController.dimmedColors

    onClicked: {
        app.radarImagesSmallUrl = "http://toon/";  //resetimage
        app.radarImagesSmallUrl = "https://api.buienradar.nl/image/1.0/RadarMapNL?width=180&height=180";
        if (app.weerDetailsScreen)
            app.weerDetailsScreen.show();
    }

    Image {
        id: weatherTileIconzz
        source: app.iconImageDim
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 100 : 65
            horizontalCenter: parent.horizontalCenter
        }
        cache: false
        visible: dimState
    }

    Text {
        id: weatherTileTemperatureTextzz
        text: i18n.number(Number(app.temperature), 1) + "°"
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
        id: weerTileTitleText2
        text: tempVal
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 32 : 25
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.bold.name
            pixelSize: isNxt ? 22 : 18
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: weerTileTitleText3
        text: tempZin
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 85 : 70
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: weerTileGevoelstempText4
        text: "feelsLikeTemp: " + i18n.number(Number(app.feelsLikeTemp), 1) + "°"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 60 : 50
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: weerTileWindsnelheidText
        text: tempWind
        anchors {
            bottom: weerTileLuchtdrukText4.top
            bottomMargin: isNxt ? 5 : 4
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Text {
        id: weerTileLuchtdrukText4
        text: tempLuchtdruk
        anchors {
            baseline: parent.bottom
            baselineOffset: -19
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        visible: !dimState
    }

    Image {
        id: weatherTileIcon
        source: app.iconUrl
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 96 : 75
            horizontalCenter: parent.horizontalCenter
        }
        cache: false
        visible: !dimState
    }
}
