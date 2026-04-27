import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

MenuItem {
	property WazeTravelTimeApp app;
	label: "Reistijd"
	image: "qrc:/tsc/buienradar.png"
	weight: 220

	onClicked: {
		if (app && app.wazeTravelTimeEditScreen)
			app.wazeTravelTimeEditScreen.show();
	}
}
