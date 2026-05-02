import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import "weer.js" as WeerJS

App {
	id: weerApp
	objectName: "WeerApp"

		// default weerstation after cold boot if no saved location exists	
	property string location : "6344";
		// default coordinates voor 2-uurs regenradardata if no saved location exists
	property string lat : "52.21"
	property string lon : "4.53"

	property url tileUrl : "WeerTile.qml"
	property url tileUrlRegen : "WeerRegenTile.qml"
	property url tileSunrise : "WeerSunriseTile.qml"
	property url tileSummary : "WeerSummaryTile.qml"
	property url thumbnailIcon: "qrc:/tsc/weer.png"
	property WeerDetailsScreen weerDetailsScreen
	property WeerStationScreen weerStationScreen
	property WeerActualRadarScreen weerActualRadarScreen
	property WeerEditLonLatScreen weerEditLonLatScreen
	property WeerFullWeatherForecastScreen weerFullWeatherForecastScreen
	property url menuUrl : "WeerMenu.qml"
	property url trayUrl : "WeerTray.qml";
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
	property string zonopkomst
	property string zononder

	property string minTempSummary: ""
	property string maxTempSummary: ""
	property int    maxUVSummary: 0
	property real   totalRegenSummary: 0
	property string maxWindBftSummary: ""
	property string maxWindDirSummary: ""
	property string scoreToday: ""
	property int    summaryHours: 18
	property int    rainHours: 6
	property real   yaxisScale: 0

	property variant fivedayforecast: []
	property variant actualweather: []
	property string firstdayForecast: "  "

	property bool useOpenMeteo: false

	FileIO {
		id: weerSettingsFile
		source: "file:///mnt/data/tsc/weer.userSettings.json"
 	}

	QtObject {
		id: p

		property url weerDetailsScreenUrl : "WeerDetailsScreen.qml"
		property url weerStationScreenUrl : "WeerStationScreen.qml"
		property url weerActualRadarScreenUrl : "WeerActualRadarScreen.qml"
		property url weerEditLonLatScreenUrl : "WeerEditLonLatScreen.qml"
		property url weerFullWeatherForecastScreenUrl : "WeerFullWeatherForecastScreen.qml"
		property url weerMenuUrl   : "WeerMenu.qml"
		property url weerTrayUrl: "WeerTray.qml"
	}

	
	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("OM Weer"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrlRegen, this, null, {thumbLabel: "OM Regenverw.", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileSunrise, this, null, {thumbLabel: "OM Zon op/onder", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileSummary, this, null, {thumbLabel: "OM Vandaag", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", p.weerDetailsScreenUrl, this, "weerDetailsScreen");
		registry.registerWidget("screen", p.weerStationScreenUrl, this, "weerStationScreen");
		registry.registerWidget("screen", p.weerActualRadarScreenUrl, this, "weerActualRadarScreen");
		registry.registerWidget("screen", p.weerEditLonLatScreenUrl, this, "weerEditLonLatScreen");
		registry.registerWidget("screen", p.weerFullWeatherForecastScreenUrl, this, "weerFullWeatherForecastScreen");
		registry.registerWidget("menuItem", p.weerMenuUrl, this, "weerMenu", {weight: 110});
		registry.registerWidget("systrayIcon", p.weerTrayUrl, weerApp);
	}

	Component.onCompleted: {

		//read user settings

		try {
			var s = JSON.parse(weerSettingsFile.read());
			if (s['selectedStation']) location = s['selectedStation'];
			if (s['selectedLongitude']) lon = s['selectedLongitude'];
			if (s['selectedLatitude']) lat = s['selectedLatitude'];
			if (s['useOpenMeteo'] !== undefined) useOpenMeteo = s['useOpenMeteo'];
			if (s['summaryHours'] !== undefined) {
				var sh = parseInt(s['summaryHours']);
				if (!isNaN(sh) && sh >= 1 && sh <= 24) summaryHours = sh;
			}
			if (s['rainHours'] !== undefined) {
				var rh = parseInt(s['rainHours']);
				if (!isNaN(rh) && rh >= 2 && rh <= 24) rainHours = rh;
			}
		} catch(e) {
		}
	}

	function saveSettings() {

		// save user settings
		var tmpUserSettingsJson = {
			"selectedStation": location,
			"selectedLongitude": lon,
			"selectedLatitude": lat,
			"useOpenMeteo": useOpenMeteo,
			"summaryHours": summaryHours,
			"rainHours": rainHours
		}

  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///mnt/data/tsc/weer.userSettings.json");
   		doc3.send(JSON.stringify(tmpUserSettingsJson ));
	}

	function updateWeer() {
		
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
						stationArray = WeerJS.addStationName(stationArray, i, brJson['actual']['stationmeasurements'][i]['stationname'].slice (-1 * (brJson['actual']['stationmeasurements'][i]['stationname'].length - 12)));
						locationArray = WeerJS.addStationName(locationArray, i, brJson['actual']['stationmeasurements'][i]['stationid']);
						latArray = WeerJS.addStationName(latArray, i, brJson['actual']['stationmeasurements'][i]['lat']);
						lonArray = WeerJS.addStationName(lonArray, i, brJson['actual']['stationmeasurements'][i]['lon']);
						if (location == brJson['actual']['stationmeasurements'][i]['stationid']) indexStation = i;
					}

						// read specific selected location weather data

					if ( indexStation > -1 ) {
 
	
						// save actual temp for use in TemperatureLogger app

   						var doc2 = new XMLHttpRequest();
						doc2.open("PUT", "file:///var/volatile/tmp/actualWeerTemp.txt");
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
						var rawIconUrl = brJson['actual']['stationmeasurements'][indexStation]['iconurl'];
						if (rawIconUrl) {
							var tmpUrl = rawIconUrl.split("/");
							icoonid = tmpUrl[tmpUrl.length - 1].substring(0, tmpUrl[tmpUrl.length - 1].length - 4);
							icoonlink = "file:///qmf/qml/apps/weer/drawables/" + icoonid + ".png";
						}

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
						tmpActual.push({'location': WeerJS.dateFormat(brJson['actual']['stationmeasurements'][indexStation]['timestamp']),
							  'temperature': WeerJS.lineTemp(temperatuurGC),
							  'windrichting': windrichting,
							  'windsnelheid': WeerJS.lineWindsnelheid(windsnelheidBF),
							  'luchtvochtigheid': WeerJS.lineLuchtvochtigheid(luchtvochtigheid),
							  'luchtdruk': WeerJS.lineLuchtdruk(luchtdruk),
							  'zicht': WeerJS.lineZichtmeters(zichtmeters),
							  'zonoponder': WeerJS.lineZonOpOnder(brJson['actual']['sunrise'], brJson['actual']['sunset'])});
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
							  'wind': 'wind',
							  'score': 'score'});

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
						var fcRawUrl = brJson['forecast']['fivedayforecast'][i]['iconurl'];
						var dpicoonid = fcRawUrl ? fcRawUrl.split("/").pop().replace(".png", "") : "a";
						var dpicoon = "file:///qmf/qml/apps/weer/drawables/" + dpicoonid + ".png";
						var fcKanszon  = brJson['forecast']['fivedayforecast'][i]['sunChance'].toString();
						var fcKansregen = brJson['forecast']['fivedayforecast'][i]['rainChance'].toString();
						var fcMaxtemp  = brJson['forecast']['fivedayforecast'][i]['maxtemperatureMax'].toString();
						var fcWindDir  = brJson['forecast']['fivedayforecast'][i]['windDirection'];
						var fcWind     = (fcWindDir ? fcWindDir.toUpperCase() : "") + " " + brJson['forecast']['fivedayforecast'][i]['wind'].toString();
						var fcScore    = WeerJS.calcWeatherScore(fcKanszon, fcKansregen, fcMaxtemp, fcWind).toString();
						if (i === 0) scoreToday = fcScore;
						tmpForecast.push({'dagweek': tmpdagweek,
							  'kanszon': fcKanszon,
							  'kansregen': fcKansregen,
							  'mintemp': brJson['forecast']['fivedayforecast'][i]['mintemperatureMin'].toString(),
							  'maxtemp': fcMaxtemp,
							  'wind': fcWind,
							  'score': fcScore,
							  'icoon': dpicoon});
					}
					fivedayforecast = tmpForecast;

						// summary tile data from today's forecast (Buienradar feed has no hourly weather data)
					var todayFc = brJson['forecast']['fivedayforecast'][0];
					if (todayFc) {
						if (todayFc['mintemperatureMin'] !== undefined) minTempSummary = todayFc['mintemperatureMin'].toString();
						if (todayFc['maxtemperatureMax'] !== undefined) maxTempSummary = todayFc['maxtemperatureMax'].toString();
						if (todayFc['uvindex'] !== undefined) maxUVSummary = todayFc['uvindex'];
						if (todayFc['mmRainMax'] !== undefined) totalRegenSummary = todayFc['mmRainMax'];
					}
					maxWindBftSummary = windsnelheidBF;
					maxWindDirSummary = windrichting;

						//forecast title and text, remove special characters

					weersverwachtingTitel = brJson['forecast']['weatherreport']['title'];
					weersverwachtingTekst = brJson['forecast']['weatherreport']['text'];
					var w = weersverwachtingTekst.indexOf("nbsp;");
					while (w !== -1) {
						weersverwachtingTekst = weersverwachtingTekst.substring(0, w - 1) + " " + weersverwachtingTekst.substring(w + 5);
						w = weersverwachtingTekst.indexOf("nbsp;");
					}
					w = weersverwachtingTekst.indexOf("rsquo;");
					while (w !== -1) {
						weersverwachtingTekst = weersverwachtingTekst.substring(0, w - 1) + "'" + weersverwachtingTekst.substring(w + 6);
						w = weersverwachtingTekst.indexOf("rsquo;");
					}

						// link to icon images

					icoonimageDim = WeerJS.parseWeatherIdAndText(false, "file:///qmf/qml/apps/weer/drawables/Dim", icoonid, icoonzin, zonopkomst, zononder, timeStr);
					icoonimageNoDim = WeerJS.parseWeatherIdAndText(false, "file:///qmf/qml/apps/weer/drawables/Home", icoonid, icoonzin, zonopkomst, zononder, timeStr);
				}
			}
		}
		xmlhttp.open("GET", "https://data.buienradar.nl/2.0/feed/json", true);
		xmlhttp.send();
	}

	function updateOpenMeteo() {

		var weekday = ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"];
		var now = new Date().getTime();
		timeStr = i18n.dateTime(now, i18n.time_yes);

		var lat4 = parseFloat(lat).toFixed(4);
		var lon4 = parseFloat(lon).toFixed(4);
		var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat4
			+ "&longitude=" + lon4
			+ "&current=temperature_2m,apparent_temperature,relative_humidity_2m"
			+ ",wind_speed_10m,wind_direction_10m,surface_pressure,weather_code,uv_index"
			+ "&hourly=visibility,temperature_2m,uv_index,precipitation,wind_speed_10m,wind_direction_10m"
			+ "&daily=weather_code,temperature_2m_max,temperature_2m_min"
			+ ",precipitation_sum,precipitation_probability_max,wind_speed_10m_max"
			+ ",wind_direction_10m_dominant,sunshine_duration,sunrise,sunset,uv_index_max"
			+ "&timezone=auto&forecast_days=5";

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4) {
				if (xmlhttp.status == 200) {
					var data = JSON.parse(xmlhttp.responseText);
					var current = data['current'];
					var daily = data['daily'];
					var hourly = data['hourly'];

					// current conditions
					temperatuurGC = current['temperature_2m'];
					gevoelstemperatuur = current['apparent_temperature'];
					luchtvochtigheid = current['relative_humidity_2m'];
					luchtdruk = current['surface_pressure'];

					var windKmh = current['wind_speed_10m'];
					windsnelheidMS = (windKmh / 3.6).toFixed(1);
					windsnelheidBF = WeerJS.kmhToBft(windKmh);
					windrichting = WeerJS.degreesToWindDir(current['wind_direction_10m']);

					// visibility from hourly slot matching current time; remember index for summary aggregates
					var currentHourStr = current['time'].substring(0, 13) + ":00";
					zichtmeters = "";
					var startHourIdx = -1;
					for (var j = 0; j < hourly['time'].length; j++) {
						if (hourly['time'][j] === currentHourStr) {
							zichtmeters = hourly['visibility'][j];
							startHourIdx = j;
							break;
						}
					}

					// sunrise / sunset from first daily entry
					zonopkomst = daily['sunrise'][0];
					zononder  = daily['sunset'][0];

					// weather icon mapped from WMO code
					icoonid = WeerJS.wmoCodeToIconId(current['weather_code']);
					icoonzin = WeerJS.wmoCodeToDescription(current['weather_code']);
					icoonimageDim   = WeerJS.parseWeatherIdAndText(
						false, "file:///qmf/qml/apps/weer/drawables/Dim",
						icoonid, icoonzin, zonopkomst, zononder, timeStr);
					icoonimageNoDim = WeerJS.parseWeatherIdAndText(
						false, "file:///qmf/qml/apps/weer/drawables/Home",
						icoonid, icoonzin, zonopkomst, zononder, timeStr);
					var isNight = WeerJS.determineNight(timeStr, zonopkomst, zononder);
					icoonlink = "file:///qmf/qml/apps/weer/drawables/" + (isNight ? icoonid + icoonid : icoonid) + ".png";

					// save actual temp for TemperatureLogger
					var doc2 = new XMLHttpRequest();
					doc2.open("PUT", "file:///var/volatile/tmp/actualWeerTemp.txt");
					doc2.send(temperatuurGC + ":" + current['time']);

					// build actualweather immediately with coordinates, update when geocode resolves
					var omUvIndex = current['uv_index'] != null ? current['uv_index'].toString() : "-";
					function buildActualWeatherOM(locStr) {
						var rows = [];
						rows.push({'location': 'GPS locatie',
							'temperature': 'Temperatuur:',
							'windsnelheid': 'Windsnelheid:',
							'windrichting': 'Windrichting:',
							'luchtvochtigheid': 'Luchtvochtigheid:',
							'luchtdruk': 'Luchtdruk:',
							'zicht': 'UV index:',
							'zonoponder': 'Zon op\/onder'});
						rows.push({'location': locStr,
							'temperature': WeerJS.lineTemp(temperatuurGC),
							'windsnelheid': WeerJS.lineWindsnelheid(windsnelheidBF),
							'windrichting': windrichting,
							'luchtvochtigheid': WeerJS.lineLuchtvochtigheid(luchtvochtigheid),
							'luchtdruk': WeerJS.lineLuchtdruk(luchtdruk),
							'zicht': omUvIndex,
							'zonoponder': WeerJS.lineZonOpOnder(zonopkomst, zononder)});
						actualweather = rows;
					}
					// fall back to coordinates immediately so the tile resolves even if the geocode fails
					locationName = lat4 + ", " + lon4;
					buildActualWeatherOM(locationName);

					// reverse-geocode GPS coordinates to city name via BigDataCloud
					// (free, no API key, no User-Agent requirement — Nominatim rejects header-less QML XHRs)
					var geoHttp = new XMLHttpRequest();
					geoHttp.onreadystatechange = function() {
						if (geoHttp.readyState == 4 && geoHttp.status == 200) {
							try {
								var geo = JSON.parse(geoHttp.responseText);
								var city = geo['city'] || geo['locality'] || geo['principalSubdivision'];
								if (city) {
									locationName = city;
									buildActualWeatherOM(locationName);
								}
							} catch (e) {
							}
						}
					}
					geoHttp.open("GET", "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=" + lat4 + "&longitude=" + lon4 + "&localityLanguage=nl", true);
					geoHttp.send();

					// 5-day forecast
					var tmpForecast = [];
					tmpForecast.push({'kanszon': 'zon %',
						'kansregen': 'regen %',
						'mintemp': 'min °C',
						'maxtemp': 'max °C',
						'wind': 'wind',
						'score': 'score'});

					for (var i = 0; i < 5; i++) {
						var dayDate = new Date(daily['time'][i]);
						var dayName = weekday[dayDate.getDay()];
						var daylightSec = (new Date(daily['sunset'][i]).getTime() - new Date(daily['sunrise'][i]).getTime()) / 1000;
						var sunPct = daylightSec > 0 ? Math.round(daily['sunshine_duration'][i] / daylightSec * 100) : 0;
						var rainPct = daily['precipitation_probability_max'][i] || 0;
						var wDir = WeerJS.degreesToWindDir(daily['wind_direction_10m_dominant'][i]);
						var wBft = WeerJS.kmhToBft(daily['wind_speed_10m_max'][i]);
						var fcIconId = WeerJS.wmoCodeToIconId(daily['weather_code'][i]);
						var fcIconPath = "file:///qmf/qml/apps/weer/drawables/" + fcIconId + ".png";
						var omKanszon  = sunPct.toString();
						var omKansregen = rainPct.toString();
						var omMaxtemp  = daily['temperature_2m_max'][i].toString();
						var omWind     = wDir + " " + wBft;
						var omScore    = WeerJS.calcWeatherScore(omKanszon, omKansregen, omMaxtemp, omWind).toString();
						if (i === 0) scoreToday = omScore;
						tmpForecast.push({
							'dagweek': dayName,
							'kanszon': omKanszon,
							'kansregen': omKansregen,
							'mintemp': daily['temperature_2m_min'][i].toString(),
							'maxtemp': omMaxtemp,
							'wind': omWind,
							'score': omScore,
							'icoon': fcIconPath});
					}
					fivedayforecast = tmpForecast;

					// summary tile data: aggregate the next summaryHours hourly slots starting at the current hour
					minTempSummary = "";
					maxTempSummary = "";
					maxUVSummary = 0;
					totalRegenSummary = 0;
					maxWindBftSummary = "";
					maxWindDirSummary = "";
					if (startHourIdx >= 0) {
						var endIdx = Math.min(startHourIdx + summaryHours, hourly['time'].length);
						var minT = null, maxT = null, maxUV = 0, totalRain = 0;
						var maxWindKmh = -1, maxWindDirDeg = 0;
						for (var k = startHourIdx; k < endIdx; k++) {
							var t = hourly['temperature_2m'][k];
							if (t !== null && t !== undefined) {
								if (minT === null || t < minT) minT = t;
								if (maxT === null || t > maxT) maxT = t;
							}
							var uv = hourly['uv_index'] ? hourly['uv_index'][k] : null;
							if (uv !== null && uv !== undefined && uv > maxUV) maxUV = uv;
							var pr = hourly['precipitation'] ? hourly['precipitation'][k] : null;
							if (pr !== null && pr !== undefined) totalRain += pr;
							var ws = hourly['wind_speed_10m'] ? hourly['wind_speed_10m'][k] : null;
							if (ws !== null && ws !== undefined && ws > maxWindKmh) {
								maxWindKmh = ws;
								var wd = hourly['wind_direction_10m'] ? hourly['wind_direction_10m'][k] : null;
								if (wd !== null && wd !== undefined) maxWindDirDeg = wd;
							}
						}
						minTempSummary = minT !== null ? Math.round(minT).toString() : "";
						maxTempSummary = maxT !== null ? Math.round(maxT).toString() : "";
						maxUVSummary = Math.round(maxUV);
						totalRegenSummary = Math.round(totalRain * 10) / 10;
						if (maxWindKmh >= 0) {
							maxWindBftSummary = WeerJS.kmhToBft(maxWindKmh);
							maxWindDirSummary = WeerJS.degreesToWindDir(maxWindDirDeg);
						}
					}

					// no narrative forecast text from Open-Meteo
					weersverwachtingTitel = "Open-Meteo GPS";
					weersverwachtingTekst = "";
				}
			}
		}
		xmlhttp.open("GET", url, true);
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

       			       			regenVerwachtingMidden = WeerJS.addMinutes(regenVerwachtingVanaf, 60);
       		          			regenVerwachtingTot = WeerJS.addMinutes(regenVerwachtingVanaf, 120);
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
		onTriggered: useOpenMeteo ? updateOpenMeteo() : updateWeer()
	}


	function updateOpenMeteoRain() {
		var lat4 = parseFloat(lat).toFixed(4);
		var lon4 = parseFloat(lon).toFixed(4);
		var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat4
			+ "&longitude=" + lon4
			+ "&hourly=precipitation"
			+ "&timezone=auto&forecast_days=2";

		var xmlhttp = new XMLHttpRequest();
		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var data = JSON.parse(xmlhttp.responseText);
				var hourly = data['hourly'];

				var now = new Date();
				var currentHourStr = now.getFullYear() + "-"
					+ ("0" + (now.getMonth() + 1)).slice(-2) + "-"
					+ ("0" + now.getDate()).slice(-2) + "T"
					+ ("0" + now.getHours()).slice(-2) + ":00";

				var startIdx = -1;
				for (var i = 0; i < hourly['time'].length; i++) {
					if (hourly['time'][i] === currentHourStr) {
						startIdx = i;
						break;
					}
				}

				if (startIdx < 0) return;

				var newArray = [];
				var maxValue = 0;
				var hasRain = false;
				var endIdx = Math.min(startIdx + rainHours, hourly['time'].length);

				for (var j = startIdx; j < endIdx; j++) {
					var pr = hourly['precipitation'][j] || 0;
					newArray.push(pr);
					if (pr > 0) hasRain = true;
					if (pr > maxValue) maxValue = pr;
				}
				while (newArray.length < rainHours) newArray.push(0);

				regenVerwachting = newArray;
				regenMaxValue = Math.round(maxValue + 0.5) || 1;
				showRain = hasRain;

				var startHour = now.getHours();
				regenVerwachtingVanaf = ("0" + startHour).slice(-2) + ":00";
				regenVerwachtingMidden = WeerJS.addMinutes(regenVerwachtingVanaf, Math.floor(rainHours / 2) * 60);
				regenVerwachtingTot = WeerJS.addMinutes(regenVerwachtingVanaf, rainHours * 60);
			}
		}
		xmlhttp.open("GET", url, true);
		xmlhttp.send();
	}

	Timer {
		id: datetimeTimer2
		interval: 300000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: useOpenMeteo ? updateOpenMeteoRain() : updateRegenkans()
	}
}
