import QtQuick 2.1
import qb.components 1.0
import "weer.js" as WeerJS

Tile {
	id: weerTile

	property bool dimState: screenStateController.dimmedColors

	onClicked: {
		app.radarImagesSmallUrl ="http://toon/";  //resetimage
		app.radarImagesSmallUrl ="https://api.buienradar.nl/image/1.0/RadarMapNL?w=180&h=180";
		if (app.weerDetailsScreen)
			app.weerDetailsScreen.show();
	}


	Text {
		id: weatherSunrise
		text: app.sunrise ? app.sunrise.substr(11, 5) : ""
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
 	}

	Text {
		id: weatherSunsetText
		text: "Zon op / onder"
		anchors {
			left: weatherSunrise.left
			leftMargin: isNxt ? 16 : 12
			top: weatherSunrise.bottom
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 16
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
 	}

	Text {
		id: weatherSunset
		text: app.sunset ? app.sunset.substr(11, 5) : ""
		anchors {
			left: weatherSunrise.left
			top: weatherSunsetText.bottom
			topMargin: isNxt ? 4 : 3
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 65 : 50
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
 	}
}
