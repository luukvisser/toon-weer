import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: wazeTravelTimeEditScreen

	screenTitle: "Waze reistijd instellingen"
	hasCancelButton: true
	hasSaveButton: false

	onShown: {
		addCustomTopRightButton("Opslaan");
		r1FromLatLabel.inputText = app.route1FromLat;
		r1FromLonLabel.inputText = app.route1FromLon;
		r1ToLatLabel.inputText   = app.route1ToLat;
		r1ToLonLabel.inputText   = app.route1ToLon;
		r1NameLabel.inputText    = app.route1Label;
		r2FromLatLabel.inputText = app.route2FromLat;
		r2FromLonLabel.inputText = app.route2FromLon;
		r2ToLatLabel.inputText   = app.route2ToLat;
		r2ToLonLabel.inputText   = app.route2ToLon;
		r2NameLabel.inputText    = app.route2Label;
	}

	onCustomButtonClicked: {
		app.saveSettings();
		app.updateRoutes();
		hide();
	}

	function validateCoord(text, isFinalString) { return null; }

	function saveCoord(prop, text) {
		if (text) {
			var val = Math.round(parseFloat(text.replace(",", ".")) * 10000) / 10000;
			app[prop] = val.toString();
		}
	}

	// ── Column widths and positions ──────────────────────────────────────────
	property int colWidth:    isNxt ? 290 : 230
	property int btnWidth:    isNxt ? 50  : 40
	property int fieldHeight: isNxt ? 45  : 35
	property int colSpacing:  isNxt ? 20  : 15
	property int col1X:       isNxt ? 20  : 15
	property int col2X:       col1X + colWidth + btnWidth + colSpacing + (isNxt ? 30 : 20)
	property int labelW:      isNxt ? 145 : 115
	property int rowGap:      6
	property int sectionTop:  isNxt ? 30  : 22

	// ── Route 1 column ───────────────────────────────────────────────────────

	Text {
		id: r1Header
		text: "Route 1 – " + app.route1Label
		font { family: qfont.semiBold.name; pixelSize: isNxt ? 22 : 17 }
		color: colors.rbTitle
		anchors { left: parent.left; leftMargin: col1X; top: parent.top; topMargin: sectionTop }
	}

	// From lat
	EditTextLabel4421 {
		id: r1FromLatLabel
		width: colWidth; height: fieldHeight
		leftText: "Van breedtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: parent.left; leftMargin: col1X; top: r1Header.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Van breedtegraad", r1FromLatLabel.inputText, app.route1FromLat, 4,
			function(t){ saveCoord('route1FromLat', t); r1FromLatLabel.inputText = app.route1FromLat; }, validateCoord)
	}
	IconButton {
		id: r1FromLatBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r1FromLatLabel.right; leftMargin: 6; top: r1FromLatLabel.top }
		onClicked: qnumKeyboard.open("Van breedtegraad", r1FromLatLabel.inputText, app.route1FromLat, 4,
			function(t){ saveCoord('route1FromLat', t); r1FromLatLabel.inputText = app.route1FromLat; }, validateCoord)
	}

	// From lon
	EditTextLabel4421 {
		id: r1FromLonLabel
		width: colWidth; height: fieldHeight
		leftText: "Van lengtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: r1FromLatLabel.left; top: r1FromLatLabel.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Van lengtegraad", r1FromLonLabel.inputText, app.route1FromLon, 4,
			function(t){ saveCoord('route1FromLon', t); r1FromLonLabel.inputText = app.route1FromLon; }, validateCoord)
	}
	IconButton {
		id: r1FromLonBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r1FromLonLabel.right; leftMargin: 6; top: r1FromLonLabel.top }
		onClicked: qnumKeyboard.open("Van lengtegraad", r1FromLonLabel.inputText, app.route1FromLon, 4,
			function(t){ saveCoord('route1FromLon', t); r1FromLonLabel.inputText = app.route1FromLon; }, validateCoord)
	}

	// To lat
	EditTextLabel4421 {
		id: r1ToLatLabel
		width: colWidth; height: fieldHeight
		leftText: "Naar breedtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: r1FromLatLabel.left; top: r1FromLonLabel.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Naar breedtegraad", r1ToLatLabel.inputText, app.route1ToLat, 4,
			function(t){ saveCoord('route1ToLat', t); r1ToLatLabel.inputText = app.route1ToLat; }, validateCoord)
	}
	IconButton {
		id: r1ToLatBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r1ToLatLabel.right; leftMargin: 6; top: r1ToLatLabel.top }
		onClicked: qnumKeyboard.open("Naar breedtegraad", r1ToLatLabel.inputText, app.route1ToLat, 4,
			function(t){ saveCoord('route1ToLat', t); r1ToLatLabel.inputText = app.route1ToLat; }, validateCoord)
	}

	// To lon
	EditTextLabel4421 {
		id: r1ToLonLabel
		width: colWidth; height: fieldHeight
		leftText: "Naar lengtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: r1FromLatLabel.left; top: r1ToLatLabel.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Naar lengtegraad", r1ToLonLabel.inputText, app.route1ToLon, 4,
			function(t){ saveCoord('route1ToLon', t); r1ToLonLabel.inputText = app.route1ToLon; }, validateCoord)
	}
	IconButton {
		id: r1ToLonBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r1ToLonLabel.right; leftMargin: 6; top: r1ToLonLabel.top }
		onClicked: qnumKeyboard.open("Naar lengtegraad", r1ToLonLabel.inputText, app.route1ToLon, 4,
			function(t){ saveCoord('route1ToLon', t); r1ToLonLabel.inputText = app.route1ToLon; }, validateCoord)
	}

	// Route 1 label / name
	EditTextLabel4421 {
		id: r1NameLabel
		width: colWidth; height: fieldHeight
		leftText: "Naam:"
		leftTextAvailableWidth: labelW
		anchors { left: r1FromLatLabel.left; top: r1ToLonLabel.bottom; topMargin: rowGap }
		onClicked: qkeyboard.open("Route 1 naam", r1NameLabel.inputText,
			function(t){ if(t){ app.route1Label = t; r1NameLabel.inputText = t; } })
	}
	IconButton {
		id: r1NameBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r1NameLabel.right; leftMargin: 6; top: r1NameLabel.top }
		onClicked: qkeyboard.open("Route 1 naam", r1NameLabel.inputText,
			function(t){ if(t){ app.route1Label = t; r1NameLabel.inputText = t; } })
	}

	// ── Route 2 column ───────────────────────────────────────────────────────

	Text {
		id: r2Header
		text: "Route 2 – " + app.route2Label
		font { family: qfont.semiBold.name; pixelSize: isNxt ? 22 : 17 }
		color: colors.rbTitle
		anchors { left: parent.left; leftMargin: col2X; top: parent.top; topMargin: sectionTop }
	}

	// From lat
	EditTextLabel4421 {
		id: r2FromLatLabel
		width: colWidth; height: fieldHeight
		leftText: "Van breedtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: parent.left; leftMargin: col2X; top: r2Header.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Van breedtegraad", r2FromLatLabel.inputText, app.route2FromLat, 4,
			function(t){ saveCoord('route2FromLat', t); r2FromLatLabel.inputText = app.route2FromLat; }, validateCoord)
	}
	IconButton {
		id: r2FromLatBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r2FromLatLabel.right; leftMargin: 6; top: r2FromLatLabel.top }
		onClicked: qnumKeyboard.open("Van breedtegraad", r2FromLatLabel.inputText, app.route2FromLat, 4,
			function(t){ saveCoord('route2FromLat', t); r2FromLatLabel.inputText = app.route2FromLat; }, validateCoord)
	}

	// From lon
	EditTextLabel4421 {
		id: r2FromLonLabel
		width: colWidth; height: fieldHeight
		leftText: "Van lengtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: r2FromLatLabel.left; top: r2FromLatLabel.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Van lengtegraad", r2FromLonLabel.inputText, app.route2FromLon, 4,
			function(t){ saveCoord('route2FromLon', t); r2FromLonLabel.inputText = app.route2FromLon; }, validateCoord)
	}
	IconButton {
		id: r2FromLonBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r2FromLonLabel.right; leftMargin: 6; top: r2FromLonLabel.top }
		onClicked: qnumKeyboard.open("Van lengtegraad", r2FromLonLabel.inputText, app.route2FromLon, 4,
			function(t){ saveCoord('route2FromLon', t); r2FromLonLabel.inputText = app.route2FromLon; }, validateCoord)
	}

	// To lat
	EditTextLabel4421 {
		id: r2ToLatLabel
		width: colWidth; height: fieldHeight
		leftText: "Naar breedtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: r2FromLatLabel.left; top: r2FromLonLabel.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Naar breedtegraad", r2ToLatLabel.inputText, app.route2ToLat, 4,
			function(t){ saveCoord('route2ToLat', t); r2ToLatLabel.inputText = app.route2ToLat; }, validateCoord)
	}
	IconButton {
		id: r2ToLatBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r2ToLatLabel.right; leftMargin: 6; top: r2ToLatLabel.top }
		onClicked: qnumKeyboard.open("Naar breedtegraad", r2ToLatLabel.inputText, app.route2ToLat, 4,
			function(t){ saveCoord('route2ToLat', t); r2ToLatLabel.inputText = app.route2ToLat; }, validateCoord)
	}

	// To lon
	EditTextLabel4421 {
		id: r2ToLonLabel
		width: colWidth; height: fieldHeight
		leftText: "Naar lengtegraad:"
		leftTextAvailableWidth: labelW
		anchors { left: r2FromLatLabel.left; top: r2ToLatLabel.bottom; topMargin: rowGap }
		onClicked: qnumKeyboard.open("Naar lengtegraad", r2ToLonLabel.inputText, app.route2ToLon, 4,
			function(t){ saveCoord('route2ToLon', t); r2ToLonLabel.inputText = app.route2ToLon; }, validateCoord)
	}
	IconButton {
		id: r2ToLonBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r2ToLonLabel.right; leftMargin: 6; top: r2ToLonLabel.top }
		onClicked: qnumKeyboard.open("Naar lengtegraad", r2ToLonLabel.inputText, app.route2ToLon, 4,
			function(t){ saveCoord('route2ToLon', t); r2ToLonLabel.inputText = app.route2ToLon; }, validateCoord)
	}

	// Route 2 label / name
	EditTextLabel4421 {
		id: r2NameLabel
		width: colWidth; height: fieldHeight
		leftText: "Naam:"
		leftTextAvailableWidth: labelW
		anchors { left: r2FromLatLabel.left; top: r2ToLonLabel.bottom; topMargin: rowGap }
		onClicked: qkeyboard.open("Route 2 naam", r2NameLabel.inputText,
			function(t){ if(t){ app.route2Label = t; r2NameLabel.inputText = t; } })
	}
	IconButton {
		id: r2NameBtn; width: btnWidth; iconSource: "qrc:/tsc/edit.png"
		anchors { left: r2NameLabel.right; leftMargin: 6; top: r2NameLabel.top }
		onClicked: qkeyboard.open("Route 2 naam", r2NameLabel.inputText,
			function(t){ if(t){ app.route2Label = t; r2NameLabel.inputText = t; } })
	}

	// ── Hint text ────────────────────────────────────────────────────────────
	Text {
		id: hintText
		text: "Voer GPS-coördinaten in met 4 decimalen (bijv. 52.3791).\nReistijden worden elke 5 minuten ververst via Waze."
		width: isNxt ? 500 : 390
		wrapMode: Text.WordWrap
		font { family: qfont.semiBold.name; pixelSize: isNxt ? 18 : 14 }
		color: colors.rbTitle
		anchors {
			left: r1NameLabel.left
			top: r1NameLabel.bottom
			topMargin: isNxt ? 18 : 14
		}
	}
}
