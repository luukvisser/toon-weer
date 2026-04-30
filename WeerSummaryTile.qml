import QtQuick 2.1
import qb.components 1.0

Tile {
	id: weerSummaryTile

	property bool dimState: screenStateController.dimmedColors

	onClicked: {
		if (app.weerDetailsScreen)
			app.weerDetailsScreen.show();
	}

	// Dimmed state: show large temperature only
	Text {
		id: summaryDimTemp
		text: i18n.number(Number(app.temperatuurGC), 1) + "°"
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

	// Normal state

	Text {
		id: summaryTitle
		text: "Vandaag"
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 28 : 22
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 18 : 14
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		visible: !dimState
	}

	Text {
		id: summaryCurrentTemp
		text: i18n.number(Number(app.temperatuurGC), 1) + "°"
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 84 : 67
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 54 : 43
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		visible: !dimState
	}

	Rectangle {
		id: summarySeparator
		height: 1
		opacity: 0.35
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: parent.top
			topMargin: isNxt ? 96 : 76
			left: parent.left
			right: parent.right
			leftMargin: isNxt ? 14 : 11
			rightMargin: isNxt ? 14 : 11
		}
		visible: !dimState
	}

	// Bottom 2×2 grid: top row = min/max temp, bottom row = UV/precipitation

	Text {
		id: summaryMinTemp
		text: "min: " + (app.minTemp12h !== "" ? app.minTemp12h + "°" : "—")
		anchors {
			baseline: parent.bottom
			baselineOffset: isNxt ? -36 : -29
			left: parent.left
			leftMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		visible: !dimState
	}

	Text {
		id: summaryMaxTemp
		text: "max: " + (app.maxTemp12h !== "" ? app.maxTemp12h + "°" : "—")
		anchors {
			baseline: summaryMinTemp.baseline
			right: parent.right
			rightMargin: isNxt ? 14 : 11
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 19 : 15
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		visible: !dimState
	}

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
		visible: !dimState
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
		visible: !dimState
	}
}
