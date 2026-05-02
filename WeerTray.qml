import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: weerSystrayIcon
	visible: true
	posIndex: 9000
        property string objectName: "weerSystrayIcon"

	onClicked: {
		app.radarimagesurl ="http://toon/";  //resetimage
		if (isNxt) {
			app.radarimagesurl = "https://api.buienradar.nl/image/1.0/RadarMapNL?w=600&h=600";
		} else {
			app.radarimagesurl = "https://api.buienradar.nl/image/1.0/RadarMapNL?w=400&h=400";
		}
		if (app.weerActualRadarScreen) {
			app.weerActualRadarScreen.setTitle("Actuele Weer");
			app.weerActualRadarScreen.show();
		}
	}

	Image {
		id: imgNewMessage
		anchors.centerIn: parent
		source: "qrc:/tsc/buienradarTray.png"
	}
}
