import QtQuick 2.1
import qb.components 1.0

Tile {
	id: wazeTravelTimeTile

	property bool dimState: screenStateController.dimmedColors

	function formatMinutes(minutes) {
		if (minutes < 0) return "- m";
		return minutes + " m";
	}

	onClicked: {
		if (app.wazeTravelTimeEditScreen)
			app.wazeTravelTimeEditScreen.show();
	}

	// Route 1 travel time
	Text {
		id: time1Text
		text: formatMinutes(app.route1Minutes)
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 72 : 57
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 58 : 45
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
	}

	// Combined route label (sits between the two times, as decoration)
	Text {
		id: routeLabelsText
		text: app.route1Label + "  /  " + app.route2Label
		anchors {
			left: time1Text.left
			leftMargin: isNxt ? 14 : 10
			top: time1Text.bottom
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 17 : 13
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
	}

	// Route 2 travel time
	Text {
		id: time2Text
		text: formatMinutes(app.route2Minutes)
		anchors {
			left: time1Text.left
			top: time1Text.bottom
			topMargin: isNxt ? 22 : 17
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 58 : 45
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
	}
}
