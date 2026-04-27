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
	property bool useKNMIData : false

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
			if (buienradarSettingsJson['useKNMIData'] !== undefined) useKNMIData = buienradarSettingsJson['useKNMIData'];
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
			"useKNMIData": useKNMIData
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

	function knmiMsToBeaufort(ms) {
		if (ms < 0.5)  return 0;
		if (ms < 1.6)  return 1;
		if (ms < 3.4)  return 2;
		if (ms < 5.5)  return 3;
		if (ms < 8.0)  return 4;
		if (ms < 10.8) return 5;
		if (ms < 13.9) return 6;
		if (ms < 17.2) return 7;
		if (ms < 20.8) return 8;
		if (ms < 24.5) return 9;
		if (ms < 28.5) return 10;
		if (ms < 32.7) return 11;
		return 12;
	}

	function knmiDegreesToCompass(deg) {
		if (deg === null || deg === undefined || deg === 0) return "VAR";
		var dirs = ['N','NNO','NO','ONO','O','OZO','ZO','ZZO','Z','ZZW','ZW','WZW','W','WNW','NW','NNW'];
		return dirs[Math.round(deg / 22.5) % 16];
	}

	function wmoToIconSuffix(code, isNight) {
		if (code === 0)                   return isNight ? "ClearNight"     : "Sunny";
		if (code <= 2)                    return isNight ? "CloudedNight"   : "SunnyIntervals";
		if (code === 3)                   return "Clouded";
		if (code <= 48)                   return isNight ? "FogNight"       : "FogDay";
		if (code <= 55)                   return isNight ? "LightRainNight" : "LightRainDay";
		if (code <= 57)                   return isNight ? "SleetNight"     : "SleetDay";
		if (code <= 67)                   return isNight ? "RainNight"      : "RainDay";
		if (code === 71 || code === 77)   return isNight ? "LightSnowNight" : "LightSnowDay";
		if (code <= 75)                   return isNight ? "SnowNight"      : "SnowDay";
		if (code === 80)                  return isNight ? "LightRainNight" : "LightRainDay";
		if (code <= 82)                   return isNight ? "RainNight"      : "RainDay";
		if (code === 85)                  return isNight ? "LightSnowNight" : "LightSnowDay";
		if (code === 86)                  return isNight ? "SnowNight"      : "SnowDay";
		if (code === 95)                  return isNight ? "ThunderNight"   : "ThunderDay";
		return                                   isNight ? "RainHailNight"  : "RainHailDay";
	}

	function wmoToDescription(code) {
		if (code === 0)  return "Helder";
		if (code === 1)  return "Overwegend helder";
		if (code === 2)  return "Gedeeltelijk bewolkt";
		if (code === 3)  return "Bewolkt";
		if (code === 45) return "Mist";
		if (code === 48) return "Aanvriezende mist";
		if (code === 51) return "Lichte motregen";
		if (code === 53) return "Motregen";
		if (code === 55) return "Dichte motregen";
		if (code === 56) return "Lichte ijzel";
		if (code === 57) return "IJzel";
		if (code === 61) return "Lichte regen";
		if (code === 63) return "Regen";
		if (code === 65) return "Zware regen";
		if (code === 66) return "Lichte bevriezenregen";
		if (code === 67) return "Zware bevriezenregen";
		if (code === 71) return "Lichte sneeuwval";
		if (code === 73) return "Sneeuwval";
		if (code === 75) return "Zware sneeuwval";
		if (code === 77) return "Sneeuwkorrels";
		if (code === 80) return "Lichte buien";
		if (code === 81) return "Buien";
		if (code === 82) return "Zware buien";
		if (code === 85) return "Lichte sneeuwbuien";
		if (code === 86) return "Zware sneeuwbuien";
		if (code === 95) return "Onweer";
		if (code === 96) return "Onweer met hagel";
		if (code === 99) return "Onweer met zware hagel";
		return "Onbekend";
	}

	function fetchKNMIData() {
		var latVal = parseFloat(lat);
		var lonVal = parseFloat(lon);
		if (isNaN(latVal) || isNaN(lonVal)) return;

		var url = "https://api.open-meteo.com/v1/knmi" +
		          "?latitude=" + latVal +
		          "&longitude=" + lonVal +
		          "&current=temperature_2m,relative_humidity_2m,apparent_temperature,pressure_msl,wind_speed_10m,wind_direction_10m,visibility,weather_code" +
		          "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,wind_direction_10m_dominant,sunrise,sunset" +
		          "&timezone=auto" +
		          "&wind_speed_unit=ms" +
		          "&forecast_days=6";

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				try {
					var data = JSON.parse(xmlhttp.responseText);
					var c = data.current;
					var dly = data.daily;

					// --- Current observations ---
					var ta  = c.temperature_2m;
					var rh  = c.relative_humidity_2m;
					var pp  = c.pressure_msl;
					var ff  = c.wind_speed_10m;
					var dir = c.wind_direction_10m;
					var zm  = c.visibility;
					var at  = c.apparent_temperature;
					var wc  = c.weather_code;

					if (ta  !== undefined && ta  !== null) temperatuurGC      = (Math.round(ta  * 10) / 10).toString();
					if (at  !== undefined && at  !== null) gevoelstemperatuur = (Math.round(at  * 10) / 10).toString();
					if (rh  !== undefined && rh  !== null) luchtvochtigheid   = Math.round(rh).toString();
					if (pp  !== undefined && pp  !== null) luchtdruk          = (Math.round(pp  * 10) / 10).toString();
					if (ff  !== undefined && ff  !== null) {
						windsnelheidMS = (Math.round(ff * 10) / 10).toString();
						windsnelheidBF = knmiMsToBeaufort(ff).toString();
					}
					if (dir !== undefined && dir !== null) windrichting = knmiDegreesToCompass(dir);
					if (zm  !== undefined && zm  !== null) zichtmeters  = Math.round(zm).toString();

					// Current weather icon from WMO code
					if (wc !== undefined && wc !== null) {
						var nowT = new Date();
						var hh = nowT.getHours();
						var mi = nowT.getMinutes();
						var nowStr = (hh < 10 ? '0' : '') + hh + ':' + (mi < 10 ? '0' : '') + mi;
						var rise = (dly && dly.sunrise && dly.sunrise[0]) ? dly.sunrise[0] : "";
						var sset = (dly && dly.sunset  && dly.sunset[0])  ? dly.sunset[0]  : "";
						var night = (rise && sset) ? BuienradarJS.determineNight(nowStr, rise, sset) : (hh < 7 || hh >= 21);
						var suf = wmoToIconSuffix(wc, night);
						icoonzin        = wmoToDescription(wc);
						icoonimageDim   = "file:///qmf/qml/apps/buienradar/drawables/Dim"  + suf + ".png";
						icoonimageNoDim = "file:///qmf/qml/apps/buienradar/drawables/Home" + suf + ".png";
						icoonlink       = icoonimageNoDim;
					}

					// Refresh or initialise actualweather
					var tmpActual;
					if (actualweather.length > 1) {
						tmpActual = actualweather;
					} else {
						tmpActual = [
							{ 'location': 'Open-Meteo/KNMI',
							  'temperature': 'Temperatuur:', 'windsnelheid': 'Windsnelheid:',
							  'windrichting': 'Windrichting:', 'luchtvochtigheid': 'Luchtvochtigheid:',
							  'luchtdruk': 'Luchtdruk:', 'zicht': 'Zicht:', 'zonoponder': 'Zon op\/onder' },
							{ 'location': c.time || '',
							  'temperature': temperatuurGC, 'windsnelheid': windsnelheidBF,
							  'windrichting': windrichting, 'luchtvochtigheid': luchtvochtigheid,
							  'luchtdruk': luchtdruk, 'zicht': zichtmeters, 'zonoponder': '' }
						];
					}
					if (ta  !== undefined && ta  !== null) tmpActual[1]['temperature']     = temperatuurGC;
					if (ff  !== undefined && ff  !== null) tmpActual[1]['windsnelheid']     = windsnelheidBF;
					if (dir !== undefined && dir !== null) tmpActual[1]['windrichting']     = windrichting;
					if (rh  !== undefined && rh  !== null) tmpActual[1]['luchtvochtigheid'] = luchtvochtigheid;
					if (pp  !== undefined && pp  !== null) tmpActual[1]['luchtdruk']        = luchtdruk;
					if (zm  !== undefined && zm  !== null) tmpActual[1]['zicht']            = zichtmeters;
					actualweather = tmpActual;

					if (ta !== undefined && ta !== null) {
						var doc = new XMLHttpRequest();
						doc.open("PUT", "file:///var/volatile/tmp/actualBuienradarTemp.txt");
						doc.send(temperatuurGC + ":" + c.time);
					}

					// --- Daily forecast ---
					if (dly && dly.time && dly.time.length > 1) {
						var dnames = ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"];

						// Sunrise/sunset for today (index 0)
						if (dly.sunrise && dly.sunrise[0]) zonopkomst = dly.sunrise[0];
						if (dly.sunset  && dly.sunset[0])  zononder   = dly.sunset[0];
						if (dly.sunrise && dly.sunrise[0] && dly.sunset && dly.sunset[0]) {
							var tmpA = actualweather;
							tmpA[1]['zonoponder'] = BuienradarJS.lineZonOpOnder(dly.sunrise[0], dly.sunset[0]);
							actualweather = tmpA;
						}

						// fivedayforecast: index 0 = headers, 1 = rolling "today" slot, 2..6 = days
						var tmpdagweek = dnames[new Date(dly.time[1] + "T12:00:00").getDay()];
						var tmpForecast = [];
						tmpForecast.push({ 'kanszon': 'zon %', 'kansregen': 'regen %',
						                   'mintemp': 'min', 'maxtemp': 'max', 'wind': 'wind' });

						if (firstdayForecast === "  ") {
							firstdayForecast = tmpdagweek;
							tmpForecast.push({});
						} else if (firstdayForecast !== tmpdagweek) {
							tmpForecast.push(fivedayforecast.length > 2 ? fivedayforecast[2] : {});
							firstdayForecast = tmpdagweek;
						} else {
							tmpForecast.push(fivedayforecast.length > 1 ? fivedayforecast[1] : {});
						}

						var maxDays = Math.min(5, dly.time.length - 1);
						for (var fi = 1; fi <= maxDays; fi++) {
							var fwc  = dly.weather_code[fi];
							var ftmn = dly.temperature_2m_min[fi];
							var ftmx = dly.temperature_2m_max[fi];
							var frn  = dly.precipitation_probability_max[fi];
							var fff  = dly.wind_speed_10m_max[fi];
							var fdir = dly.wind_direction_10m_dominant[fi];
							var fday = dnames[new Date(dly.time[fi] + "T12:00:00").getDay()];
							var fsuf = wmoToIconSuffix(fwc, false);
							tmpForecast.push({
								'dagweek':   fday,
								'kanszon':   "",
								'kansregen': (frn  !== null && frn  !== undefined) ? Math.round(frn).toString()             : "",
								'mintemp':   (ftmn !== null && ftmn !== undefined) ? (Math.round(ftmn * 10) / 10).toString() : "",
								'maxtemp':   (ftmx !== null && ftmx !== undefined) ? (Math.round(ftmx * 10) / 10).toString() : "",
								'wind':      knmiDegreesToCompass(fdir) + " " + knmiMsToBeaufort(fff).toString(),
								'icoon':     "file:///qmf/qml/apps/buienradar/drawables/Home" + fsuf + ".png"
							});
						}
						fivedayforecast = tmpForecast;
					}

				} catch(e) {}
			}
		};
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}

	function updateKNMITemperature() {
		if (!useKNMIData) return;
		fetchKNMIData();
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

					if ( indexStation > -1 && !useKNMIData ) {
 
	
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

					if (!useKNMIData) {
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
					} // end !useKNMIData forecast block

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

					if (!useKNMIData) {
					icoonimageDim = BuienradarJS.parseWeatherIdAndText(true, "file:///qmf/qml/apps/buienradar/drawables/Dim", icoonid, icoonzin, zonopkomst, zononder, timeStr);
					icoonimageNoDim = BuienradarJS.parseWeatherIdAndText(true, "file:///qmf/qml/apps/buienradar/drawables/Home", icoonid, icoonzin, zonopkomst, zononder, timeStr);
					}
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
