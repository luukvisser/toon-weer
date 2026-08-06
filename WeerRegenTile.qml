import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0
import "weer.js" as WeerJS

Tile {
    id: root
    onClicked: {
        app.radarImagesUrl = "http://toon/";  //resetimage
        if (isNxt) {
            app.radarImagesUrl = "https://api.buienradar.nl/image/1.0/RadarMapNL?width=600&height=600";
        } else {
            app.radarImagesUrl = "https://api.buienradar.nl/image/1.0/RadarMapNL?width=400&height=400";
        }
        if (app.weerActualRadarScreen) {
            app.weerActualRadarScreen.setTitle("Actuele Weer");
            app.weerActualRadarScreen.show();
        }
    }

    Text {
        id: weerRegenTileTitleText
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 38 : 30
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.tileTextColor
        text: "Regenverwachting"
    }

    Item {
        id: brgraphItem

        anchors {
            bottom: parent.bottom
            bottomMargin: isNxt ? 50 : 41
            horizontalCenter: parent.horizontalCenter
        }
        height: isNxt ? 90 : 72
        width: isNxt ? 200 : 160

        AreaGraphControl {
            id: areaGraph

            width: parent.width
            height: parent.height
            color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.graphTileRect
            yScale: app.yAxisScale ? (height / app.yAxisScale) : (height / Math.max(1, app.rainMaxMm))
            showNaN: false
            values: app.rainForecast
        }
    }

    Text {
        id: weerYaxis
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 55 : 45
            horizontalCenter: weerYaxismm.horizontalCenter
        }
        font {
            family: qfont.bold.name
            pixelSize: isNxt ? 30 : 24
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.tileTextColor
        text: app.showRain ? (app.yAxisScale ? app.yAxisScale : Math.max(1, app.rainMaxMm)) : "0"
    }

    Text {
        id: weerYaxismm
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 75 : 60
            left: parent.left
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 14 : 11
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.tileTextColor
        text: "mm/u"
    }

    Rectangle {
        id: lineYaxis
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.graphTileRect
        height: isNxt ? 90 : 72
        width: 1
        anchors {
            bottom: parent.bottom
            bottomMargin: isNxt ? 52 : 42
            left: brgraphItem.left
        }
    }

    Rectangle {
        id: lineYaxisTopMarker1
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.graphTileRect
        height: 1
        width: 6
        anchors {
            bottom: parent.bottom
            bottomMargin: isNxt ? 143 : 113
            left: lineYaxis.left
        }
    }

    Text {
        id: leftTimeText
        anchors {
            horizontalCenter: brgraphItem.left
            baseline: brgraphItem.bottom
            baselineOffset: isNxt ? 33 : 27
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 18 : 14
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.tileTextColor
        text: app.rainForecastFrom
    }

    Text {
        id: midTimeText
        anchors {
            horizontalCenter: brgraphItem.horizontalCenter
            baseline: brgraphItem.bottom
            baselineOffset: isNxt ? 33 : 27
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 18 : 14
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.tileTextColor
        text: app.rainForecastMid
    }

    Text {
        id: rightTimeText
        anchors {
            horizontalCenter: brgraphItem.right
            baseline: brgraphItem.bottom
            baselineOffset: isNxt ? 33 : 27
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 18 : 14
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.tileTextColor
        text: app.rainForecastTo
    }

    /// horizontal markers along the x-axis. In Open-Meteo combined mode the
    /// graph spans rainHours hours (rainHours * 12 5-min slots); we draw a
    /// 10-min tick over the high-resolution Buienradar window (first 2 hours)
    /// and a 1-hour tick over the Open-Meteo extension. In Buienradar-only
    /// mode the original 13-tick / 10-minute layout is used.
    Row {
        id: xLegendRow
        anchors.top: brgraphItem.bottom
        anchors.left: brgraphItem.left
        width: brgraphItem.width

        Repeater {
            id: xLegendRepeater
            // Total 5-min slots in the model: 25 for Buienradar-only, rainHours*12+1 for combined
            model: app.useOpenMeteo ? (app.rainHours * 12 + 1) : 25
            Item {
                height: isNxt ? 10 : 8
                width: app.useOpenMeteo ? (brgraphItem.width / (app.rainHours * 12)) : (brgraphItem.width / 24)

                Rectangle {
                    id: linexaxisMarker
                    color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTextColor : colors.graphTileRect
                    height: {
                        var startMin = parseInt(app.rainForecastFrom.substring(3, 5)) || 0;
                        // Wall-clock hour check is the same for both modes: each slot = 5 min
                        if ((startMin + index * 5) % 60 === 0)
                            return 9;
                        if (app.useOpenMeteo) {
                            var brSlots = Math.min(24, app.rainHours * 12);
                            // Buienradar window (first 2 hours): 10-min ticks
                            if (index < brSlots && index % 2 === 0)
                                return 3;
                            // Open-Meteo window (after 2 hours): 15-min ticks
                            if (index >= brSlots && index % 3 === 0)
                                return 3;
                            return 0;
                        }
                        // Buienradar-only: 10-min ticks
                        return (index % 2 === 0) ? 3 : 0;
                    }
                    width: 1

                    anchors {
                        baseline: parent.top
                        left: parent.left
                    }
                    visible: height > 0
                }
            }
        }
    }
}
