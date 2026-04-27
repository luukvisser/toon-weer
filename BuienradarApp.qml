import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import "buienradar.js" as BuienradarJS

App {
	id: buienradarApp
	objectName: "BuienradarApp"

		// default weerstation after cold boot if no saved location exists	
	property string location : "6344";
		// default coordinates voor 2-uurs regenradardata if no saved location exists
	property string lat : "52.21"
	property string lon : "4.53"

	property url tileUrl : "BuienradarTile.qml"
	property url tileUrlRegen : "BuienradarRegenTile.qml"
	property url tileSunrise : "BuienradarSunriseTile.qml"
	property url thumbnailIcon: "qrc:/tsc/buienradar.png"
	property BuienradarDetailsScreen buienradarDetailsScreen
	property BuienradarStationScreen buienradarStationScreen
	property BuienradarActualRadarScreen buienradarActualRadarScreen
	property BuienradarEditLonLatScreen buienradarEditLonLatScreen
	property BuienradarFullWeatherForecastScreen buienradarFullWeatherForecastScreen
	property url menuUrl : "BuienradarMenu.qml"
	property url trayUrl : "BuienradarTray.qml";
	property string timeStr

	property string locationName
	property variant regenVerwachting : []
	property string regenVerwachtingVanaf
	property string regenVerwachtingMidden
	property string regenVerwachtingTot
	property real regenMaxValue
	property bool showRain : false
	property variant stationArray : []
	property variant locationArray : []
	property int indexStation
	property variant latArray : []
	property variant lonArray : []
	property variant brJson : {}

	// KNMI Data Platform settings
	property string knmiApiKey : "eyJvcmciOiI1ZTU1NGUxOTI3NGE5NjAwMDEyYTNlYjEiLCJpZCI6ImVlNDFjMWI0MjlkODQ2MThiNWI4ZDViZDAyMTM2YTM3IiwiaCI6Im11cm11cjEyOCJ9"
	property string knmiNearestStationId : ""

	property string temperatuurGC
	property string gevoelstemperatuur
	property string windsnelheidBF
	property string windsnelheidMS
	property string windrichting
	property string icoonlink
	property string icoonid
	property string icoonzin
	property string icoonimageDim
	property string icoonimageNoDim
	property string luchtvochtigheid
	property string luchtdruk
	property string zichtmeters
	property string weersverwachtingTitel
	property string weersverwachtingTekst
	property string datumupdate
	property string stillimagesurl
	property string radarimagesurl
	property string radarimagesSmallurl
	property string extraScreensurl
	property string zonopkomst
	property string zononder

	property variant fivedayforecast: []
	property variant actualweather: []
	property string firstdayForecast: "  "

	// user settings from config file
	property variant buienradarSettingsJson : {}

	FileIO {
		id: buienradarSettingsFile
		source: "file:///mnt/data/tsc/buienradar.userSettings.json"
 	}

	QtObject {
		id: p

		property url buienradarDetailsScreenUrl : "BuienradarDetailsScreen.qml"
		property url buienradarStationScreenUrl : "BuienradarStationScreen.qml"
		property url buienradarActualRadarScreenUrl : "BuienradarActualRadarScreen.qml"
		property url buienradarEditLonLatScreenUrl : "BuienradarEditLonLatScreen.qml"
		property url buienradarFullWeatherForecastScreenUrl : "BuienradarFullWeatherForecastScreen.qml"
		property url buienradarMenuUrl   : "BuienradarMenu.qml"
		property url buienradarTrayUrl: "BuienradarTray.qml"
	}

	
	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Buienradar"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrlRegen, this, null, {thumbLabel: "Regenverw.", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileSunrise, this, null, {thumbLabel: "Zon op/onder", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", p.buienradarDetailsScreenUrl, this, "buienradarDetailsScreen");
		registry.registerWidget("screen", p.buienradarStationScreenUrl, this, "buienradarStationScreen");
		registry.registerWidget("screen", p.buienradarActualRadarScreenUrl, this, "buienradarActualRadarScreen");
		registry.registerWidget("screen", p.buienradarEditLonLatScreenUrl, this, "buienradarEditLonLatScreen");
		registry.registerWidget("screen", p.buienradarFullWeatherForecastScreenUrl, this, "buienradarFullWeatherForecastScreen");
		registry.registerWidget("menuItem", p.buienradarMenuUrl, this, "buienradarMenu", {weight: 110});
		registry.registerWidget("systrayIcon", p.buienradarTrayUrl, buienradarApp);
	}

	Component.onCompleted: {

		//read user settings

		try {
			buienradarSettingsJson = JSON.parse(buienradarSettingsFile.read());
			if (buienradarSettingsJson['selectedStation']) location = buienradarSettingsJson['selectedStation'];
			if (buienradarSettingsJson['selectedLongitude']) lon = buienradarSettingsJson['selectedLongitude'];
			if (buienradarSettingsJson['selectedLatitude']) lat = buienradarSettingsJson['selectedLatitude'];
			if (buienradarSettingsJson['knmiApiKey']) knmiApiKey = buienradarSettingsJson['knmiApiKey'];
			if (buienradarSettingsJson['knmiNearestStationId']) knmiNearestStationId = buienradarSettingsJson['knmiNearestStationId'];
		} catch(e) {
		}
	}

	function saveSettings() {

		// save user settings
		var tmpUserSettingsJson = {
			"selectedStation": location,
			"selectedLongitude": lon,
			"selectedLatitude": lat,
			"knmiApiKey": knmiApiKey,
			"knmiNearestStationId": knmiNearestStationId
		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///mnt/data/tsc/buienradar.userSettings.json");
   		doc3.send(JSON.stringify(tmpUserSettingsJson ));
	}

	function formatISODate(d) {
		var pad2 = function(n) { return (n < 10 ? '0' : '') + n; };
		return d.getUTCFullYear() + '-' + pad2(d.getUTCMonth() + 1) + '-' + pad2(d.getUTCDate()) +
		       'T' + pad2(d.getUTCHours()) + ':' + pad2(d.getUTCMinutes()) + ':' + pad2(d.getUTCSeconds()) + 'Z';
	}

	function knmiHaversine(lat1, lon1, lat2, lon2) {
		var R = 6371;
		var dLat = (lat2 - lat1) * Math.PI / 180;
		var dLon = (lon2 - lon1) * Math.PI / 180;
		var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
		        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
		        Math.sin(dLon / 2) * Math.sin(dLon / 2);
		return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	}

	function findKNMINearestStation(callback) {
		var latVal = parseFloat(lat);
		var lonVal = parseFloat(lon);
		if (isNaN(latVal) || isNaN(lonVal)) return;

		var now = new Date();
		var url = "https://api.dataplatform.knmi.nl/edr/v1/collections/10-minute-in-situ-meteorological-observations/locations" +
		          "?datetime=" + encodeURIComponent(formatISODate(now));

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				try {
					var response = JSON.parse(xmlhttp.responseText);
					var features = response.features;
					var nearestId = "";
					var nearestDist = 1000000;

					for (var i = 0; i < features.length; i++) {
						var coords = features[i].geometry.coordinates; // [lon, lat]
						var dist = knmiHaversine(latVal, lonVal, coords[1], coords[0]);
						if (dist < nearestDist) {
							nearestDist = dist;
							nearestId = features[i].id;
						}
					}

					if (nearestId) {
						knmiNearestStationId = nearestId;
						saveSettings();
						if (callback) callback();
					}
				} catch(e) {}
			}
		};
		xmlhttp.open("GET", url, true);
		xmlhttp.setRequestHeader("Authorization", knmiApiKey);
		xmlhttp.send();
	}

	function fetchKNMITemperature() {
		if (!knmiNearestStationId) return;

		var now = new Date();
		var thirtyMinsAgo = new Date(now.getTime() - 30 * 60 * 1000);
		var datetime = formatISODate(thirtyMinsAgo) + "/" + formatISODate(now);

		var url = "https://api.dataplatform.knmi.nl/edr/v1/collections/10-minute-in-situ-meteorological-observations/locations/" +
		          knmiNearestStationId +
		          "?datetime=" + encodeURIComponent(datetime) +
		          "&parameter-name=ta";

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				try {
					var response = JSON.parse(xmlhttp.responseText);
					var knmiTemp = null;
					var timestamp = formatISODate(now);

					// CoverageCollection: each Coverage is one time step; take the last non-null value
					if (response.coverages && response.coverages.length > 0) {
						for (var j = response.coverages.length - 1; j >= 0; j--) {
							var cov = response.coverages[j];
							if (cov.ranges && cov.ranges.ta && cov.ranges.ta.values) {
								var vals = cov.ranges.ta.values;
								for (var k = vals.length - 1; k >= 0; k--) {
									if (vals[k] !== null && vals[k] !== undefined) {
										knmiTemp = vals[k];
										if (cov.domain && cov.domain.axes && cov.domain.axes.t && cov.domain.axes.t.values.length > 0)
											timestamp = cov.domain.axes.t.values[cov.domain.axes.t.values.length - 1];
										break;
									}
								}
								if (knmiTemp !== null) break;
							}
						}
					} else if (response.ranges && response.ranges.ta && response.ranges.ta.values) {
						// Single Coverage with time-series values
						var values = response.ranges.ta.values;
						for (var i = values.length - 1; i >= 0; i--) {
							if (values[i] !== null && values[i] !== undefined) {
								knmiTemp = values[i];
								break;
							}
						}
					}

					if (knmiTemp !== null) {
						temperatuurGC = (Math.round(knmiTemp * 10) / 10).toString();

						// Also refresh the value inside the actualweather details array
						if (actualweather.length > 1) {
							var tmp = actualweather;
							tmp[1]['temperature'] = temperatuurGC;
							actualweather = tmp;
						}

						var doc = new XMLHttpRequest();
						doc.open("PUT", "file:///var/volatile/tmp/actualBuienradarTemp.txt");
						doc.send(temperatuurGC + ":" + timestamp);
					}
				} catch(e) {}
			}
		};
		xmlhttp.open("GET", url, true);
		xmlhttp.setRequestHeader("Authorization", knmiApiKey);
		xmlhttp.send();
	}

	function updateKNMITemperature() {
		if (!knmiNearestStationId) {
			findKNMINearestStation(fetchKNMITemperature);
		} else {
			fetchKNMITemperature();
		}
	}

	function updateBuienradar() {
		
  		var weekday = new Array(7);
  		weekday[0] = "Zo";
  		weekday[1] = "Ma";
 		weekday[2] = "Di";
  		weekday[3] = "Wo";
 		weekday[4] = "Do";
  		weekday[5] = "Vr";
  		weekday[6] = "Za";

		var now = new Date().getTime();
		timeStr = i18n.dateTime(now, i18n.time_yes);

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange=function() {

			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var brJson = JSON.parse(xmlhttp.responseText);
					indexStation = -1;

						// if not done already first fill array with available weatherstations

					for (var i=0; i < brJson['actual']['stationmeasurements'].length; i++) {
						stationArray = BuienradarJS.addStationName(stationArray, i, brJson['actual']['stationmeasurements'][i]['stationname'].slice (-1 * (brJson['actual']['stationmeasurements'][i]['stationname'].length - 12)));
						locationArray = BuienradarJS.addStationName(locationArray, i, brJson['actual']['stationmeasurements'][i]['stationid']);
						latArray = BuienradarJS.addStationName(latArray, i, brJson['actual']['stationmeasurements'][i]['lat']);
						lonArray = BuienradarJS.addStationName(lonArray, i, brJson['actual']['stationmeasurements'][i]['lon']);
						if (location == brJson['actual']['stationmeasurements'][i]['stationid']) indexStation = i;
					}

						// read specific selected location weather data

					if ( indexStation > -1 ) {
 
	
						// save actual temp for use in TemperatureLogger app

   						var doc2 = new XMLHttpRequest();
						doc2.open("PUT", "file:///var/volatile/tmp/actualBuienradarTemp.txt");
   						doc2.send(brJson['actual']['stationmeasurements'][indexStation]['temperature'] + ":" + brJson['actual']['stationmeasurements'][indexStation]['timestamp']);

						if (brJson['actual']['stationmeasurements'][indexStation]['windspeed']) windsnelheidMS = brJson['actual']['stationmeasurements'][indexStation]['windspeed'];
						if (brJson['actual']['stationmeasurements'][indexStation]['windspeedBft']) windsnelheidBF = brJson['actual']['stationmeasurements'][indexStation]['windspeedBft'];
						if (brJson['actual']['stationmeasurements'][indexStation]['winddirection']) windrichting = brJson['actual']['stationmeasurements'][indexStation]['winddirection'].toUpperCase();
						if (brJson['actual']['stationmeasurements'][indexStation]['airpressure']) luchtdruk = brJson['actual']['stationmeasurements'][indexStation]['airpressure'];
						if (brJson['actual']['stationmeasurements'][indexStation]['visibility']) zichtmeters = brJson['actual']['stationmeasurements'][indexStation]['visibility'];
						if (brJson['actual']['stationmeasurements'][indexStation]['temperature']) temperatuurGC = brJson['actual']['stationmeasurements'][indexStation]['temperature'];
						if (brJson['actual']['stationmeasurements'][indexStation]['feeltemperature']) gevoelstemperatuur = brJson['actual']['stationmeasurements'][indexStation]['feeltemperature'];
						if (brJson['actual']['stationmeasurements'][indexStation]['humidity']) luchtvochtigheid = brJson['actual']['stationmeasurements'][indexStation]['humidity'];

						icoonzin = brJson['actual']['stationmeasurements'][indexStation]['weatherdescription'];
						var tmpUrl = brJson['actual']['stationmeasurements'][indexStation]['iconurl'].split("/");
						icoonid = tmpUrl[tmpUrl.length - 1].substring(0, tmpUrl[tmpUrl.length - 1].length - 4);
						icoonlink = "qrc:/tsc/" + icoonid + ".png";

							// fill model for grid of weather station data on detail screen
	
						var tmpActual = [];	
						tmpActual.push({'location': stationArray[indexStation],
							  'temperature': 'Temperatuur:',
							  'windsnelheid': 'Windsnelheid:',
							  'windrichting': 'Windrichting:',
							  'luchtvochtigheid': 'Luchtvochtigheid:',
							  'luchtdruk': 'Luchtdruk:',
							  'zicht': 'Zicht:',
							  'zonoponder': 'Zon op\/onder'});
						tmpActual.push({'location': BuienradarJS.dateFormat(brJson['actual']['stationmeasurements'][indexStation]['timestamp']),
							  'temperature': temperatuurGC,
							  'windrichting': windrichting,
							  'windsnelheid': windsnelheidBF,
							  'luchtvochtigheid': luchtvochtigheid,
							  'luchtdruk': luchtdruk,
							  'zicht': zichtmeters,
							  'zonoponder': BuienradarJS.lineZonOpOnder(brJson['actual']['sunrise'], brJson['actual']['sunset'])});
						actualweather = tmpActual;

				
						zonopkomst = brJson['actual']['sunrise']
						zononder = brJson['actual']['sunset']

					}


						// read 5-days weather forecast

					var tmpNewDate = new Date(brJson['forecast']['fivedayforecast'][0]['day']);
					var tmpdagweek = weekday[tmpNewDate.getDay()];

					var tmpForecast = [];	
					tmpForecast.push({'kanszon': 'zon %',
							  'kansregen': 'regen %',
							  'mintemp': 'min',
							  'maxtemp': 'max',
							  'wind': 'wind'});

						// if the new day-plus 1 differs from the old one, we have received a new set of 5 days and can copy the old day1 to day0 (which is today actually)

					if (firstdayForecast == "  ") {
						firstdayForecast = tmpdagweek;
						tmpForecast.push({}); // at start, empty column 1
					} else {
						if (firstdayForecast !== tmpdagweek) {
							tmpForecast.push(fivedayforecast[2])  // move column 2 to column 1
							firstdayForecast = tmpdagweek;
						} else {
							tmpForecast.push(fivedayforecast[1])  // keep old column 1
						}
					}

						// load next 5 days forecast

					for (var i = 0; i < 5; i++) {
						var tmpNewDate = new Date(brJson['forecast']['fivedayforecast'][i]['day']);
						var tmpdagweek = weekday[tmpNewDate.getDay()];
						var tmpUrl = brJson['forecast']['fivedayforecast'][i]['iconurl'].split("/");
						var dpicoonid = tmpUrl[tmpUrl.length - 1].substring(0, tmpUrl[tmpUrl.length - 1].length - 4);
						var dpicoon = "qrc:/tsc/" + dpicoonid + ".png";
						tmpForecast.push({'dagweek': tmpdagweek,
							  'kanszon': brJson['forecast']['fivedayforecast'][i]['sunChance'].toString(),
							  'kansregen': brJson['forecast']['fivedayforecast'][i]['rainChance'].toString(),
							  'mintemp': brJson['forecast']['fivedayforecast'][i]['mintemperatureMin'].toString(),
							  'maxtemp': brJson['forecast']['fivedayforecast'][i]['maxtemperatureMax'].toString(),
							  'wind': brJson['forecast']['fivedayforecast'][i]['windDirection'].toUpperCase() + " " + brJson['forecast']['fivedayforecast'][i]['wind'].toString(),
							  'icoon': dpicoon});
					}
					fivedayforecast = tmpForecast;

						//forecast title and text, remove special characters

					weersverwachtingTitel = brJson['forecast']['weatherreport']['title'];
					weersverwachtingTekst = brJson['forecast']['weatherreport']['text'];
					var w = weersverwachtingTekst.indexOf("nbsp;");
					while (w > 0) { 
						var tmptx = weersverwachtingTekst.substring(0, w - 5) + " " + weersverwachtingTekst.substring(w + 5, weersverwachtingTekst.length);
						weersverwachtingTekst = tmptx;
						w = weersverwachtingTekst.indexOf("nbsp;")
					}
					w = weersverwachtingTekst.indexOf("rsquo;");
					while (w > 0) { 
						var tmptx = weersverwachtingTekst.substring(0, w - 5) + "'" + weersverwachtingTekst.substring(w + 6, weersverwachtingTekst.length);
						weersverwachtingTekst = tmptx;
						w = weersverwachtingTekst.indexOf("rsquo;")
					}

						// link to icon images

					icoonimageDim = BuienradarJS.parseWeatherIdAndText(true, "file:///qmf/qml/apps/buienradar/drawables/Dim", icoonid, icoonzin, zonopkomst, zononder, timeStr);
					icoonimageNoDim = BuienradarJS.parseWeatherIdAndText(true, "file:///qmf/qml/apps/buienradar/drawables/Home", icoonid, icoonzin, zonopkomst, zononder, timeStr);
				}
			}
		}
		xmlhttp.open("GET", "https://data.buienradar.nl/2.0/feed/json", true);
		xmlhttp.send();
	}

	function updateRegenkans() {
		var xmlhttp = new XMLHttpRequest();
		var newArray = [];
		var mmRegen = 0;
		var maxValue = 0;
		regenMaxValue = 0;
		var tmpNewDate = new Date();
		var now = new Date();
		var startForecasts = 0;
		var forecastCounter = 0;
		showRain = false;

		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {

					var response = xmlhttp.responseText;
			                if (response.length > 0) {

						var brJson = JSON.parse(xmlhttp.responseText);
							// find start of actual forecast

						for (var i = 0; i < brJson['forecasts'].length ; i++) {
							tmpNewDate = new Date(brJson['forecasts'][i]['datetime']);
							if (now < tmpNewDate) {
								startForecasts = i;
								break;
							}
						}

      			       			regenVerwachtingVanaf = brJson['forecasts'][startForecasts]['datetime'].substring(11,16);
 
							// fill array with the next 24 values

						for (var i = startForecasts; i < brJson['forecasts'].length ; i++) {
							mmRegen =  brJson['forecasts'][i]['precipation'];
							newArray.push(mmRegen);
							if (mmRegen > 0) showRain = true;
							if (mmRegen > maxValue) maxValue = mmRegen;
							forecastCounter = forecastCounter + 1;
							if (forecastCounter == 24) break;
						}

							// fill remaining slots , just in case we didn't had 24 datapoints

						if (forecastCounter < 24) {

							for (var i = forecastCounter; i < 24 ; i++) {  // add empty columns
								mmRegen = 0;
								newArray.push(mmRegen);
							}
						}

       			       			regenVerwachtingMidden = BuienradarJS.addMinutes(regenVerwachtingVanaf, 60);
       		          			regenVerwachtingTot = BuienradarJS.addMinutes(regenVerwachtingVanaf, 120);
						regenVerwachting = newArray;
							
						regenMaxValue = Math.round(maxValue + 0.5); 
					}
				}
			}
		}

		xmlhttp.open("GET", "https://graphdata.buienradar.nl/2.0/forecast/geo/RainHistoryForecast?lat="+lat+"&lon="+lon, true);
		xmlhttp.send();
	}

	
	Timer {
		id: datetimeTimer
		interval: 600000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateBuienradar()
	}


	Timer {
		id: datetimeTimer2
		interval: 300000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateRegenkans()
	}

	Timer {
		id: knmiTempTimer
		interval: 600000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateKNMITemperature()
	}
}
