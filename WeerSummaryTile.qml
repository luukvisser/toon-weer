import QtQuick 2.1
import qb.components 1.0

Tile {
	id: weerSummaryTile

	onClicked: {
		if (app.weerDetailsScreen)
			app.weerDetailsScreen.show();
	}

	// Top corners: min/max temp over the configured summary window

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
			family: qfont.bold.name
			pixelSize: isNxt ? 23 : 18
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
			family: qfont.bold.name
			pixelSize: isNxt ? 23 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	// Center row: current weather icon + current temperature (nudged up to leave room below)

	Item {
		id: summaryCenterRow
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: isNxt ? -10 : -8
		}
		width: summaryCurrentIcon.width + summaryCurrentTemp.width + (isNxt ? 8 : 6)
		height: Math.max(summaryCurrentIcon.height, summaryCurrentTemp.height)

		Image {
			id: summaryCurrentIcon
			source: app.icoonlink || ""
			width: isNxt ? 56 : 44
			height: width
			fillMode: Image.PreserveAspectFit
			anchors.verticalCenter: parent.verticalCenter
			anchors.left: parent.left
			visible: source != ""
		}

		Text {
			id: summaryCurrentTemp
			text: i18n.number(Number(app.temperatuurGC), 1) + "°"
			anchors {
				verticalCenter: parent.verticalCenter
				left: summaryCurrentIcon.visible ? summaryCurrentIcon.right : parent.left
				leftMargin: summaryCurrentIcon.visible ? (isNxt ? 8 : 6) : 0
			}
			font {
				family: qfont.bold.name
				pixelSize: isNxt ? 50 : 40
			}
			color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		}
	}

	// Mid-low row: max wind (left) and weather score (right)

	Text {
		id: summaryWind
		text: {
			var cur = app.windsnelheidBF !== "" ? app.windsnelheidBF : "—"
			var max = app.maxWindBftSummary !== "" ? app.maxWindBftSummary : "—"
			return cur + " → " + max + " Bft"
		}
		anchors {
			baseline: parent.bottom
			baselineOffset: isNxt ? -36 : -29
			left: parent.left
			leftMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 23 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	Text {
		id: summaryScore
		text: {
			var nowStr = app.scoreNow !== "" ? app.scoreNow : "—"
			var sumStr = app.scoreSummary !== "" ? app.scoreSummary : "—"
			return nowStr + " → " + sumStr + " /10"
		}
		anchors {
			baseline: summaryWind.baseline
			right: parent.right
			rightMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	// Bottom row: max UV and total precipitation over the configured summary window

	Text {
		id: summaryUV
		text: {
			var cur = app.uvNow >= 0 ? app.uvNow.toString() : "—"
			var max = app.maxUVSummary > 0 ? app.maxUVSummary.toString() : "—"
			return cur + " → " + max + " UV"
		}
		anchors {
			baseline: parent.bottom
			baselineOffset: isNxt ? -16 : -13
			left: parent.left
			leftMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 23 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	Text {
		id: summaryPrecip
		text: (app.totalRegenSummary > 0 ? i18n.number(app.totalRegenSummary, 1) : "0") + " mm"
		anchors {
			baseline: summaryUV.baseline
			right: parent.right
			rightMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 23 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}
}
