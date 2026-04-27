import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
	id: wazeTravelTimeApp
	objectName: "WazeTravelTimeApp"

	// Route 1
	property string route1FromLat: "52.3791"
	property string route1FromLon: "4.8980"
	property string route1ToLat: "52.3105"
	property string route1ToLon: "4.7683"
	property string route1Label: "Route 1"
	property int route1Minutes: -1

	// Route 2
	property string route2FromLat: "52.3105"
	property string route2FromLon: "4.7683"
	property string route2ToLat: "52.3791"
	property string route2ToLon: "4.8980"
	property string route2Label: "Route 2"
	property int route2Minutes: -1

	property url tileUrl: "WazeTravelTimeTile.qml"
	property url thumbnailIcon: "qrc:/tsc/buienradar.png"
	property WazeTravelTimeEditScreen wazeTravelTimeEditScreen
	property variant settingsJson: {}

	FileIO {
		id: settingsFile
		source: "file:///mnt/data/tsc/wazeRoutes.userSettings.json"
	}

	QtObject {
		id: p
		property url editScreenUrl: "WazeTravelTimeEditScreen.qml"
		property url menuUrl: "WazeTravelTimeMenu.qml"
	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {
			thumbLabel: "Reistijd",
			thumbIcon: thumbnailIcon,
			thumbCategory: "general",
			thumbWeight: 30,
			baseTileWeight: 10,
			thumbIconVAlignment: "center"
		});
		registry.registerWidget("screen", p.editScreenUrl, this, "wazeTravelTimeEditScreen");
		registry.registerWidget("menuItem", p.menuUrl, this, "wazeTravelTimeMenu", {weight: 120});
	}

	Component.onCompleted: {
		try {
			settingsJson = JSON.parse(settingsFile.read());
			if (settingsJson['route1FromLat']) route1FromLat = settingsJson['route1FromLat'];
			if (settingsJson['route1FromLon']) route1FromLon = settingsJson['route1FromLon'];
			if (settingsJson['route1ToLat'])   route1ToLat   = settingsJson['route1ToLat'];
			if (settingsJson['route1ToLon'])   route1ToLon   = settingsJson['route1ToLon'];
			if (settingsJson['route1Label'])   route1Label   = settingsJson['route1Label'];
			if (settingsJson['route2FromLat']) route2FromLat = settingsJson['route2FromLat'];
			if (settingsJson['route2FromLon']) route2FromLon = settingsJson['route2FromLon'];
			if (settingsJson['route2ToLat'])   route2ToLat   = settingsJson['route2ToLat'];
			if (settingsJson['route2ToLon'])   route2ToLon   = settingsJson['route2ToLon'];
			if (settingsJson['route2Label'])   route2Label   = settingsJson['route2Label'];
		} catch(e) {}
	}

	function saveSettings() {
		var s = {
			"route1FromLat": route1FromLat,
			"route1FromLon": route1FromLon,
			"route1ToLat":   route1ToLat,
			"route1ToLon":   route1ToLon,
			"route1Label":   route1Label,
			"route2FromLat": route2FromLat,
			"route2FromLon": route2FromLon,
			"route2ToLat":   route2ToLat,
			"route2ToLon":   route2ToLon,
			"route2Label":   route2Label
		};
		var doc = new XMLHttpRequest();
		doc.open("PUT", "file:///mnt/data/tsc/wazeRoutes.userSettings.json");
		doc.send(JSON.stringify(s));
	}

	// Waze unofficial routing API (same as used by Home Assistant Waze integration)
	// Note: x = longitude, y = latitude in Waze coordinate format
	function buildWazeUrl(fromLat, fromLon, toLat, toLon) {
		return "https://www.waze.com/row-RoutingManager/routingRequest"
			+ "?from=x%3D" + fromLon + "%20y%3D" + fromLat
			+ "&to=x%3D"   + toLon   + "%20y%3D" + toLat
			+ "&at=0&returnJSON=true&returnGeometries=false&returnInstructions=false"
			+ "&timeout=60000&nPaths=1"
			+ "&options=AVOID_TRAILS%3At%2CAVOID_MOTORWAYS%3Af%2CAVOID_FERRIES%3At";
	}

	function fetchRoute(fromLat, fromLon, toLat, toLon, callback) {
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					try {
						var json = JSON.parse(xmlhttp.responseText);
						// Response may have 'alternatives' array or a single 'response' object
						var routes = json.alternatives || [json];
						var seconds = routes[0].response.totalRouteTime;
						callback(Math.round(seconds / 60));
					} catch(e) {
						callback(-1);
					}
				} else {
					callback(-1);
				}
			}
		};
		xmlhttp.open("GET", buildWazeUrl(fromLat, fromLon, toLat, toLon), true);
		xmlhttp.send();
	}

	function updateRoutes() {
		fetchRoute(route1FromLat, route1FromLon, route1ToLat, route1ToLon, function(minutes) {
			route1Minutes = minutes;
		});
		fetchRoute(route2FromLat, route2FromLon, route2ToLat, route2ToLon, function(minutes) {
			route2Minutes = minutes;
		});
	}

	Timer {
		id: updateTimer
		interval: 300000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateRoutes()
	}
}
