import QtQuick 2.1
import qb.components 1.0

Tile {
    id: weerSummaryTile

    onClicked: {
        if (app.weerDetailsScreen)
            app.weerDetailsScreen.show();
    }

    // Min/max temp row at the top
    Text {
        id: summaryMinTemp
        text: "min: " + (app.minTempSummary !== "" ? app.minTempSummary + "°" : "—")
        anchors {
            top: parent.top
            topMargin: isNxt ? 14 : 11
            left: parent.left
            leftMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryMaxTemp
        text: "max: " + (app.maxTempSummary !== "" ? app.maxTempSummary + "°" : "—")
        anchors {
            top: parent.top
            topMargin: isNxt ? 14 : 11
            right: parent.right
            rightMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    // Center: current weather icon + current temperature, below min/max row
    Item {
        id: summaryCenterRow
        anchors {
            top: summaryMinTemp.bottom
            topMargin: isNxt ? 6 : 5
            horizontalCenter: parent.horizontalCenter
        }
        width: summaryCurrentIcon.width + summaryCurrentTemp.width + (isNxt ? 8 : 6)
        height: Math.max(summaryCurrentIcon.height, summaryCurrentTemp.height)

        Image {
            id: summaryCurrentIcon
            source: app.iconImageDim || ""
            width: isNxt ? 56 : 44
            height: width
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            visible: source != ""
        }

        Text {
            id: summaryCurrentTemp
            text: i18n.number(Number(app.temperature), 1) + "°"
            anchors {
                verticalCenter: parent.verticalCenter
                left: summaryCurrentIcon.visible ? summaryCurrentIcon.right : parent.left
                leftMargin: summaryCurrentIcon.visible ? (isNxt ? 8 : 6) : 0
            }
            font {
                family: qfont.regular.name
                pixelSize: isNxt ? 56 : 44
            }
            color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        }
    }

    // "nu | vandaag" label below the big temperature
    Text {
        id: summaryDayLabel
        text: app.showTomorrow ? "nu | morgen" : "nu | vandaag"
        anchors {
            top: summaryCenterRow.bottom
            topMargin: isNxt ? 4 : 3
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    // Bottom row 1, left side: current wind | max wind m/s
    // Pipe is at a fixed left position so it aligns with the UV row pipe below.
    Text {
        id: summaryWindCur
        text: app.windSpeedMs !== "" ? i18n.number(Number(app.windSpeedMs), 1) : "—"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -36 : -29
            left: parent.left
            leftMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryWindPipe
        text: "| "
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -36 : -29
            left: parent.left
            leftMargin: isNxt ? 65 : 52
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryWindMax
        text: (app.maxWindMsSummary !== "" ? i18n.number(Number(app.maxWindMsSummary), 1) : "—") + " m/s"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -36 : -29
            left: summaryWindPipe.right
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    // Bottom row 1, right side: score now | score today /10
    // Pipe is at a fixed right position so it aligns with the precip row pipe below.
    Text {
        id: summaryScoreNow
        text: app.scoreNow !== "" ? i18n.number(Number(app.scoreNow), 1) : "—"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -36 : -29
            right: summaryScorePipe.left
            rightMargin: 4
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryScorePipe
        text: "| "
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -36 : -29
            right: parent.right
            rightMargin: isNxt ? 82 : 66
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryScoreSum
        text: (app.scoreSummary !== "" ? i18n.number(Number(app.scoreSummary), 1) : "—") + " /10"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -36 : -29
            left: summaryScorePipe.right
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    // Bottom row 2, left side: current UV | max UV UV
    // Pipe leftMargin matches summaryWindPipe so the | characters align vertically.
    Text {
        id: summaryUVCur
        text: app.uvNow >= 0 ? i18n.number(app.uvNow, 1) : "—"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -16 : -13
            left: parent.left
            leftMargin: isNxt ? 14 : 11
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryUVPipe
        text: "| "
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -16 : -13
            left: parent.left
            leftMargin: isNxt ? 65 : 52
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryUVMax
        text: (app.maxUVSummary > 0 ? i18n.number(app.maxUVSummary, 1) : "—") + " UV"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -16 : -13
            left: summaryUVPipe.right
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    // Bottom row 2, right side: precip now | total precip mm
    // Pipe rightMargin matches summaryScorePipe so the | characters align vertically.
    Text {
        id: summaryPrecipNow
        text: (app.rainForecast && app.rainForecast.length > 0) ? i18n.number(app.rainForecast[0], 1) : i18n.number(0, 1)
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -16 : -13
            right: summaryPrecipPipe.left
            rightMargin: 4
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryPrecipPipe
        text: "| "
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -16 : -13
            right: parent.right
            rightMargin: isNxt ? 82 : 66
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }

    Text {
        id: summaryPrecipTotal
        text: (app.totalRainSummary > 0 ? i18n.number(app.totalRainSummary, 1) : i18n.number(0, 1)) + " mm"
        anchors {
            baseline: parent.bottom
            baselineOffset: isNxt ? -16 : -13
            left: summaryPrecipPipe.right
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 19 : 15
        }
        color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    }
}
