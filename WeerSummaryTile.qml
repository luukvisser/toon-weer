import QtQuick 2.1
import qb.components 1.0

Tile {
	id: weerSummaryTile

	onClicked: {
		if (app.weerDetailsScreen)
			app.weerDetailsScreen.show();
	}

	// Top corners: min/max temp for the next 12 hours

	Text {
		id: summaryMinTemp
		text: "min: " + (app.minTemp12h !== "" ? app.minTemp12h + "°" : "—")
		anchors {
			top: parent.top
			topMargin: isNxt ? 14 : 11
			left: parent.left
			leftMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	Text {
		id: summaryMaxTemp
		text: "max: " + (app.maxTemp12h !== "" ? app.maxTemp12h + "°" : "—")
		anchors {
			top: parent.top
			topMargin: isNxt ? 14 : 11
			right: parent.right
			rightMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	// Center: current temperature
	Text {
		id: summaryCurrentTemp
		text: i18n.number(Number(app.temperatuurGC), 1) + "°"
		anchors.centerIn: parent
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 54 : 43
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	// Bottom corners: max UV and total precipitation for the next 12 hours

	Text {
		id: summaryUV
		text: "UV: " + (app.maxUV12h > 0 ? app.maxUV12h.toString() : "—")
		anchors {
			baseline: parent.bottom
			baselineOffset: isNxt ? -16 : -13
			left: parent.left
			leftMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

	Text {
		id: summaryPrecip
		text: (app.totalRegen12h > 0 ? i18n.number(app.totalRegen12h, 1) : "0") + " mm"
		anchors {
			baseline: summaryUV.baseline
			right: parent.right
			rightMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}
}
