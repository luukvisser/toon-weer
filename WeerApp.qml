import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import "weer.js" as WeerJS

App {
	id: weerApp
	objectName: "WeerApp"

	// --- Data source config ---
	property bool   useOpenMeteo: false
	property int    summaryHours: 18
	property int    rainHours: 6
	property int    weatherRefreshMin: 10
	property int    rainRefreshMin: 5
	property string location: "6344"
	property string lat: "52.21"
	property string lon: "4.53"

	// --- App assets ---
	property url tileUrl: "WeerTile.qml"
	property url tileUrlRegen: "WeerRegenTile.qml"
	property url tileSunrise: "WeerSunriseTile.qml"
	property url tileSummary: "WeerSummaryTile.qml"
	property url thumbnailIcon: "qrc:/tsc/weer.png"
	property WeerDetailsScreen weerDetailsScreen
	property WeerStationScreen weerStationScreen
	property WeerActualRadarScreen weerActualRadarScreen
	property WeerEditLonLatScreen weerEditLonLatScreen
	property WeerFullWeatherForecastScreen weerFullWeatherForecastScreen
	property url menuUrl: "WeerMenu.qml"
	property url trayUrl: "WeerTray.qml"
	property string timeStr

	// --- Current conditions ---
	property string locationName
	property string temperature
	property string feelsLikeTemp
	property string windSpeedBft
	property string windSpeedMs
	property string windDirection
	property string iconUrl
	property string iconId
	property string weatherDescription
	property string iconImageDim
	property string iconImageNoDim
	property string humidity
	property string pressure
	property string visibilityMeters
	property string sunrise
	property string sunset
	property real   uvNow: -1

	// --- Forecast & station data ---
	property variant stationNames: []
	property variant stationIds: []
	property int     stationIndex
	property variant stationLats: []
	property variant stationLons: []
	property variant fiveDayForecast: []
	property variant hourlyForecast: []
	property variant actualWeather: []
	property string  firstDayForecast: "  "
	property string  forecastTitle
	property string  forecastText
	property string  lastUpdated
	property string  stillImagesUrl
	property string  radarImagesUrl
	property string  radarImagesSmallUrl
	property string  scoreToday: ""

	// --- Summary tile ---
	property string minTempSummary: ""
	property string maxTempSummary: ""
	property real   maxUVSummary: 0
	property real   totalRainSummary: 0
	property string maxWindBftSummary: ""
	property string maxWindDirSummary: ""
	property string scoreNow: ""
	property string scoreSummary: ""

	// --- Rain tile ---
	property variant rainForecast: []
	property string  rainForecastFrom
	property string  rainForecastMid
	property string  rainForecastTo
	property real    rainMaxMm
	property bool    showRain: false
	property real    yAxisScale: 0

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
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Weer v2"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileUrlRegen, this, null, {thumbLabel: "Regenverw. v2", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileSunrise, this, null, {thumbLabel: "Zon op/onder v2", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", tileSummary, this, null, {thumbLabel: "Vandaag v2", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
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
			var settings = JSON.parse(weerSettingsFile.read());
			if (settings['selectedStation']) location = settings['selectedStation'];
			if (settings['selectedLongitude']) lon = settings['selectedLongitude'];
			if (settings['selectedLatitude']) lat = settings['selectedLatitude'];
			if (settings['useOpenMeteo'] !== undefined) useOpenMeteo = settings['useOpenMeteo'];
			if (settings['summaryHours'] !== undefined) {
				var parsedHours = parseInt(settings['summaryHours']);
				if (!isNaN(parsedHours) && parsedHours >= 1 && parsedHours <= 24) summaryHours = parsedHours;
			}
			if (settings['rainHours'] !== undefined) {
				var parsedHours = parseInt(settings['rainHours']);
				if (!isNaN(parsedHours) && parsedHours >= 2 && parsedHours <= 24) rainHours = parsedHours;
			}
			if (settings['weatherRefreshMin'] !== undefined) {
				var parsedHours = parseInt(settings['weatherRefreshMin']);
				if (!isNaN(parsedHours) && parsedHours >= 1 && parsedHours <= 60) weatherRefreshMin = parsedHours;
			}
			if (settings['rainRefreshMin'] !== undefined) {
				var parsedHours = parseInt(settings['rainRefreshMin']);
				if (!isNaN(parsedHours) && parsedHours >= 1 && parsedHours <= 30) rainRefreshMin = parsedHours;
			}
		} catch(e) {
		}
	}

	function saveSettings() {

		// save user settings
		var settings = {
			"selectedStation": location,
			"selectedLongitude": lon,
			"selectedLatitude": lat,
			"useOpenMeteo": useOpenMeteo,
			"summaryHours": summaryHours,
			"rainHours": rainHours,
			"weatherRefreshMin": weatherRefreshMin,
			"rainRefreshMin": rainRefreshMin
		}

  		var xhr = new XMLHttpRequest();
   		xhr.open("PUT", "file:///mnt/data/tsc/weer.userSettings.json");
   		xhr.send(JSON.stringify(settings ));
	}

	// --- Public API ---

	function updateWeather() {
		if (useOpenMeteo) fetchOpenMeteoWeather();
		else              fetchBuienradarWeather();
	}

	function updateRain() {
		if (useOpenMeteo) fetchOpenMeteoRain();
		else              fetchBuienradarRain();
	}

	// --- Buienradar data fetchers ---

	function fetchBuienradarWeather() {

  		var dayNames = new Array(7);
  		dayNames[0] = "Zo";
  		dayNames[1] = "Ma";
 		dayNames[2] = "Di";
  		dayNames[3] = "Wo";
 		dayNames[4] = "Do";
  		dayNames[5] = "Vr";
  		dayNames[6] = "Za";

		var now = new Date().getTime();
		timeStr = i18n.dateTime(now, i18n.time_yes);

		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange=function() {

			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					var data = JSON.parse(xhr.responseText);
					stationIndex = -1;

						// if not done already first fill array with available weatherstations

					for (var i=0; i < data['actual']['stationmeasurements'].length; i++) {
						stationNames = WeerJS.addStationName(stationNames, i, data['actual']['stationmeasurements'][i]['stationname'].slice (-1 * (data['actual']['stationmeasurements'][i]['stationname'].length - 12)));
						stationIds = WeerJS.addStationName(stationIds, i, data['actual']['stationmeasurements'][i]['stationid']);
						stationLats = WeerJS.addStationName(stationLats, i, data['actual']['stationmeasurements'][i]['lat']);
						stationLons = WeerJS.addStationName(stationLons, i, data['actual']['stationmeasurements'][i]['lon']);
						if (location == data['actual']['stationmeasurements'][i]['stationid']) stationIndex = i;
					}

						// read specific selected location weather data

					if ( stationIndex > -1 ) {


						// save actual temp for use in TemperatureLogger app

   						var tempLogXhr = new XMLHttpRequest();
						tempLogXhr.open("PUT", "file:///var/volatile/tmp/actualWeerTemp.txt");
   						tempLogXhr.send(data['actual']['stationmeasurements'][stationIndex]['temperature'] + ":" + data['actual']['stationmeasurements'][stationIndex]['timestamp']);

						if (data['actual']['stationmeasurements'][stationIndex]['windspeed']) windSpeedMs = data['actual']['stationmeasurements'][stationIndex]['windspeed'];
						if (data['actual']['stationmeasurements'][stationIndex]['windspeedBft']) windSpeedBft = data['actual']['stationmeasurements'][stationIndex]['windspeedBft'];
						if (data['actual']['stationmeasurements'][stationIndex]['winddirection']) windDirection = data['actual']['stationmeasurements'][stationIndex]['winddirection'].toUpperCase();
						if (data['actual']['stationmeasurements'][stationIndex]['airpressure']) pressure = data['actual']['stationmeasurements'][stationIndex]['airpressure'];
						if (data['actual']['stationmeasurements'][stationIndex]['visibility']) visibilityMeters = data['actual']['stationmeasurements'][stationIndex]['visibility'];
						if (data['actual']['stationmeasurements'][stationIndex]['temperature']) temperature = data['actual']['stationmeasurements'][stationIndex]['temperature'];
						if (data['actual']['stationmeasurements'][stationIndex]['feeltemperature']) feelsLikeTemp = data['actual']['stationmeasurements'][stationIndex]['feeltemperature'];
						if (data['actual']['stationmeasurements'][stationIndex]['humidity']) humidity = data['actual']['stationmeasurements'][stationIndex]['humidity'];

						weatherDescription = data['actual']['stationmeasurements'][stationIndex]['weatherdescription'];
						var rawIconUrl = data['actual']['stationmeasurements'][stationIndex]['iconurl'];
						if (rawIconUrl) {
							var urlParts = rawIconUrl.split("/");
							iconId = urlParts[urlParts.length - 1].substring(0, urlParts[urlParts.length - 1].length - 4);
							iconUrl = "file:///qmf/qml/apps/weer/drawables/" + iconId + ".png";
						}
						if (iconId) {
							var srPct = WeerJS.iconIdToSunRainPct(iconId);
							scoreNow = WeerJS.calcWeatherScore(
								srPct.sun.toString(), srPct.rain.toString(),
								temperature, windDirection + " " + windSpeedBft
							).toString();
						}

							// fill model for grid of weather station data on detail screen

						var rows = [];
						rows.push({'location': stationNames[stationIndex],
							  'temperature': 'Temperatuur:',
							  'windsnelheid': 'Windsnelheid:',
							  'windDirection': 'Windrichting:',
							  'humidity': 'Luchtvochtigheid:',
							  'pressure': 'Luchtdruk:',
							  'zicht': 'Zicht:',
							  'zonoponder': 'Zon op\/onder'});
						rows.push({'location': WeerJS.dateFormat(data['actual']['stationmeasurements'][stationIndex]['timestamp']),
							  'temperature': WeerJS.lineTemp(temperature),
							  'windDirection': windDirection,
							  'windsnelheid': WeerJS.lineWindsnelheid(windSpeedBft),
							  'humidity': WeerJS.lineLuchtvochtigheid(humidity),
							  'pressure': WeerJS.lineLuchtdruk(pressure),
							  'zicht': WeerJS.lineZichtmeters(visibilityMeters),
							  'zonoponder': WeerJS.lineZonOpOnder(data['actual']['sunrise'], data['actual']['sunset'])});
						actualWeather = rows;


						sunrise = data['actual']['sunrise']
						sunset = data['actual']['sunset']

					}


						// read 5-days weather forecast

					var date = new Date(data['forecast']['fivedayforecast'][0]['day']);
					var dayName = dayNames[date.getDay()];

					var forecast = [];
					forecast.push({'kanszon': 'zon %',
							  'kansregen': 'regen %',
							  'mintemp': 'min',
							  'maxtemp': 'max',
							  'wind': 'wind',
							  'score': 'score'});

						// if the new day-plus 1 differs from the old one, we have received a new set of 5 days and can copy the old day1 to day0 (which is today actually)

					if (firstDayForecast == "  ") {
						firstDayForecast = dayName;
						forecast.push({}); // at start, empty column 1
					} else {
						if (firstDayForecast !== dayName) {
							forecast.push(fiveDayForecast[2])  // move column 2 to column 1
							firstDayForecast = dayName;
						} else {
							forecast.push(fiveDayForecast[1])  // keep old column 1
						}
					}

						// load next 5 days forecast

					for (var i = 0; i < 5; i++) {
						var date = new Date(data['forecast']['fivedayforecast'][i]['day']);
						var dayName = dayNames[date.getDay()];
						var dayIconUrl = data['forecast']['fivedayforecast'][i]['iconurl'];
						var dayIconId = dayIconUrl ? dayIconUrl.split("/").pop().replace(".png", "") : "a";
						var dayIconPath = "file:///qmf/qml/apps/weer/drawables/" + dayIconId + ".png";
						var sunChance  = data['forecast']['fivedayforecast'][i]['sunChance'].toString();
						var rainChance = data['forecast']['fivedayforecast'][i]['rainChance'].toString();
						var maxTemp  = data['forecast']['fivedayforecast'][i]['maxtemperatureMax'].toString();
						var windDir  = data['forecast']['fivedayforecast'][i]['windDirection'];
						var wind     = (windDir ? windDir.toUpperCase() : "") + " " + data['forecast']['fivedayforecast'][i]['wind'].toString();
						var score    = WeerJS.calcWeatherScore(sunChance, rainChance, maxTemp, wind).toString();
						if (i === 0) {
							scoreToday = score;
							scoreSummary = score;
						}
						forecast.push({'dagweek': dayName,
							  'kanszon': sunChance,
							  'kansregen': rainChance,
							  'mintemp': data['forecast']['fivedayforecast'][i]['mintemperatureMin'].toString(),
							  'maxtemp': maxTemp,
							  'wind': wind,
							  'score': score,
							  'icoon': dayIconPath});
					}
					fiveDayForecast = forecast;

						// summary tile data from today's forecast (Buienradar feed has no hourly weather data)
					uvNow = -1;
					var todayForecast = data['forecast']['fivedayforecast'][0];
					if (todayForecast) {
						if (todayForecast['mintemperatureMin'] !== undefined) minTempSummary = i18n.number(Number(todayForecast['mintemperatureMin']), 1);
						if (todayForecast['maxtemperatureMax'] !== undefined) maxTempSummary = i18n.number(Number(todayForecast['maxtemperatureMax']), 1);
						if (todayForecast['uvindex'] !== undefined) maxUVSummary = todayForecast['uvindex'];
						if (todayForecast['mmRainMax'] !== undefined) totalRainSummary = todayForecast['mmRainMax'];
					}
					maxWindBftSummary = windSpeedBft;
					maxWindDirSummary = windDirection;

						//forecast title and text, remove special characters

					forecastTitle = data['forecast']['weatherreport']['title'];
					forecastText = data['forecast']['weatherreport']['text'];
					var w = forecastText.indexOf("nbsp;");
					while (w !== -1) {
						forecastText = forecastText.substring(0, w - 1) + " " + forecastText.substring(w + 5);
						w = forecastText.indexOf("nbsp;");
					}
					w = forecastText.indexOf("rsquo;");
					while (w !== -1) {
						forecastText = forecastText.substring(0, w - 1) + "'" + forecastText.substring(w + 6);
						w = forecastText.indexOf("rsquo;");
					}

						// link to icon images

					iconImageDim = WeerJS.parseWeatherIdAndText(false, "file:///qmf/qml/apps/weer/drawables/Dim", iconId, weatherDescription, sunrise, sunset, timeStr);
					iconImageNoDim = WeerJS.parseWeatherIdAndText(false, "file:///qmf/qml/apps/weer/drawables/Home", iconId, weatherDescription, sunrise, sunset, timeStr);
				}
			}
		}
		xhr.open("GET", "https://data.buienradar.nl/2.0/feed/json", true);
		xhr.send();
	}

	// --- Open-Meteo data fetchers ---

	function fetchOpenMeteoWeather() {

		var dayNames = ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"];
		var now = new Date().getTime();
		timeStr = i18n.dateTime(now, i18n.time_yes);

		var lat4 = parseFloat(lat).toFixed(4);
		var lon4 = parseFloat(lon).toFixed(4);
		var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat4
			+ "&longitude=" + lon4
			+ "&current=temperature_2m,apparent_temperature,relative_humidity_2m"
			+ ",wind_speed_10m,wind_direction_10m,surface_pressure,weather_code,uv_index"
			+ "&hourly=visibility,temperature_2m,uv_index,precipitation,wind_speed_10m,wind_direction_10m,weather_code,precipitation_probability"
			+ "&daily=weather_code,temperature_2m_max,temperature_2m_min"
			+ ",precipitation_sum,precipitation_probability_max,wind_speed_10m_max"
			+ ",wind_direction_10m_dominant,sunshine_duration,sunrise,sunset,uv_index_max"
			+ "&timezone=auto&forecast_days=5";

		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					var data = JSON.parse(xhr.responseText);
					var current = data['current'];
					var daily = data['daily'];
					var hourly = data['hourly'];

					// current conditions
					temperature = current['temperature_2m'];
					feelsLikeTemp = current['apparent_temperature'];
					humidity = current['relative_humidity_2m'];
					pressure = current['surface_pressure'];

					var windKmh = current['wind_speed_10m'];
					windSpeedMs = (windKmh / 3.6).toFixed(1);
					windSpeedBft = WeerJS.kmhToBft(windKmh);
					windDirection = WeerJS.degreesToWindDir(current['wind_direction_10m']);

					// visibility from hourly slot matching current time; remember index for summary aggregates
					var currentHourStr = current['time'].substring(0, 13) + ":00";
					visibilityMeters = "";
					var startHourIdx = -1;
					for (var j = 0; j < hourly['time'].length; j++) {
						if (hourly['time'][j] === currentHourStr) {
							visibilityMeters = hourly['visibility'][j];
							startHourIdx = j;
							break;
						}
					}

					// sunrise / sunset from first daily entry
					sunrise = daily['sunrise'][0];
					sunset  = daily['sunset'][0];

					// weather icon mapped from WMO code
					iconId = WeerJS.wmoCodeToIconId(current['weather_code']);
					weatherDescription = WeerJS.wmoCodeToDescription(current['weather_code']);
					var srPct = WeerJS.wmoCodeToSunRainPct(current['weather_code']);
					scoreNow = WeerJS.calcWeatherScore(
						srPct.sun.toString(), srPct.rain.toString(),
						temperature, windDirection + " " + windSpeedBft
					).toString();
					iconImageDim   = WeerJS.parseWeatherIdAndText(
						false, "file:///qmf/qml/apps/weer/drawables/Dim",
						iconId, weatherDescription, sunrise, sunset, timeStr);
					iconImageNoDim = WeerJS.parseWeatherIdAndText(
						false, "file:///qmf/qml/apps/weer/drawables/Home",
						iconId, weatherDescription, sunrise, sunset, timeStr);
					var isNight = WeerJS.determineNight(timeStr, sunrise, sunset);
					iconUrl = "file:///qmf/qml/apps/weer/drawables/" + (isNight ? iconId + iconId : iconId) + ".png";

					// save actual temp for TemperatureLogger
					var tempLogXhr = new XMLHttpRequest();
					tempLogXhr.open("PUT", "file:///var/volatile/tmp/actualWeerTemp.txt");
					tempLogXhr.send(temperature + ":" + current['time']);

					// current UV index
					uvNow = current['uv_index'] != null ? Math.round(current['uv_index'] * 10) / 10 : -1;

					// build actualWeather immediately with coordinates, update when geocode resolves
					var uvIndexStr = current['uv_index'] != null ? current['uv_index'].toString() : "-";
					function buildActualWeatherOM(locStr) {
						var rows = [];
						rows.push({'location': 'GPS locatie',
							'temperature': 'Temperatuur:',
							'windsnelheid': 'Windsnelheid:',
							'windDirection': 'Windrichting:',
							'humidity': 'Luchtvochtigheid:',
							'pressure': 'Luchtdruk:',
							'zicht': 'UV index:',
							'zonoponder': 'Zon op\/onder'});
						rows.push({'location': locStr,
							'temperature': WeerJS.lineTemp(temperature),
							'windsnelheid': WeerJS.lineWindsnelheid(windSpeedBft),
							'windDirection': windDirection,
							'humidity': WeerJS.lineLuchtvochtigheid(humidity),
							'pressure': WeerJS.lineLuchtdruk(pressure),
							'zicht': uvIndexStr,
							'zonoponder': WeerJS.lineZonOpOnder(sunrise, sunset)});
						actualWeather = rows;
					}
					// fall back to coordinates immediately so the tile resolves even if the geocode fails
					locationName = lat4 + ", " + lon4;
					buildActualWeatherOM(locationName);

					// reverse-geocode GPS coordinates to city name via BigDataCloud
					// (free, no API key, no User-Agent requirement — Nominatim rejects header-less QML XHRs)
					var geocodeXhr = new XMLHttpRequest();
					geocodeXhr.onreadystatechange = function() {
						if (geocodeXhr.readyState == 4 && geocodeXhr.status == 200) {
							try {
								var geocodeData = JSON.parse(geocodeXhr.responseText);
								var city = geocodeData['city'] || geocodeData['locality'] || geocodeData['principalSubdivision'];
								if (city) {
									locationName = city;
									buildActualWeatherOM(locationName);
								}
							} catch (e) {
							}
						}
					}
					geocodeXhr.open("GET", "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=" + lat4 + "&longitude=" + lon4 + "&localityLanguage=nl", true);
					geocodeXhr.send();

					// 5-day forecast
					var forecast = [];
					forecast.push({'kanszon': 'zon %',
						'kansregen': 'regen %',
						'mintemp': 'min °C',
						'maxtemp': 'max °C',
						'wind': 'wind',
						'score': 'score'});

					for (var i = 0; i < 5; i++) {
						var date = new Date(daily['time'][i]);
						var dayName = dayNames[date.getDay()];
						var daylightSeconds = (new Date(daily['sunset'][i]).getTime() - new Date(daily['sunrise'][i]).getTime()) / 1000;
						var daySunPct = daylightSeconds > 0 ? Math.round(daily['sunshine_duration'][i] / daylightSeconds * 100) : 0;
						var dayRainPct = daily['precipitation_probability_max'][i] || 0;
						var windDir = WeerJS.degreesToWindDir(daily['wind_direction_10m_dominant'][i]);
						var windBft = WeerJS.kmhToBft(daily['wind_speed_10m_max'][i]);
						var dayIconId = WeerJS.wmoCodeToIconId(daily['weather_code'][i]);
						var dayIconPath = "file:///qmf/qml/apps/weer/drawables/" + dayIconId + ".png";
						var sunChance  = daySunPct.toString();
						var rainChance = dayRainPct.toString();
						var maxTemp  = daily['temperature_2m_max'][i].toString();
						var wind     = windDir + " " + windBft;
						var score    = WeerJS.calcWeatherScore(sunChance, rainChance, maxTemp, wind).toString();
						if (i === 0) scoreToday = score;
						forecast.push({
							'dagweek': dayName,
							'kanszon': sunChance,
							'kansregen': rainChance,
							'mintemp': daily['temperature_2m_min'][i].toString(),
							'maxtemp': maxTemp,
							'wind': wind,
							'score': score,
							'icoon': dayIconPath});
					}
					fiveDayForecast = forecast;

					// summary tile data: aggregate the next summaryHours hourly slots starting at the current hour
					minTempSummary = "";
					maxTempSummary = "";
					maxUVSummary = 0;
					totalRainSummary = 0;
					maxWindBftSummary = "";
					maxWindDirSummary = "";
					scoreSummary = "";
					if (startHourIdx >= 0) {
						var endHourIdx = Math.min(startHourIdx + summaryHours, hourly['time'].length);
						var minTemp = null, maxTemp = null, maxUV = 0, totalRain = 0;
						var maxWindKmh = -1, maxWindDirDeg = 0;
						var maxRainProb = 0, clearHourCount = 0;
						for (var k = startHourIdx; k < endHourIdx; k++) {
							var temp = hourly['temperature_2m'][k];
							if (temp !== null && temp !== undefined) {
								if (minTemp === null || temp < minTemp) minTemp = temp;
								if (maxTemp === null || temp > maxTemp) maxTemp = temp;
							}
							var uvVal = hourly['uv_index'] ? hourly['uv_index'][k] : null;
							if (uvVal !== null && uvVal !== undefined && uvVal > maxUV) maxUV = uvVal;
							var precip = hourly['precipitation'] ? hourly['precipitation'][k] : null;
							if (precip !== null && precip !== undefined) totalRain += precip;
							var windSpeedKmh = hourly['wind_speed_10m'] ? hourly['wind_speed_10m'][k] : null;
							if (windSpeedKmh !== null && windSpeedKmh !== undefined && windSpeedKmh > maxWindKmh) {
								maxWindKmh = windSpeedKmh;
								var windDirDeg = hourly['wind_direction_10m'] ? hourly['wind_direction_10m'][k] : null;
								if (windDirDeg !== null && windDirDeg !== undefined) maxWindDirDeg = windDirDeg;
							}
							var rainProb = hourly['precipitation_probability'] ? hourly['precipitation_probability'][k] : null;
							if (rainProb !== null && rainProb !== undefined && rainProb > maxRainProb) maxRainProb = rainProb;
							var weatherCode = hourly['weather_code'] ? hourly['weather_code'][k] : null;
							if (weatherCode !== null && weatherCode !== undefined && weatherCode <= 2) clearHourCount++;
						}
						minTempSummary = minTemp !== null ? i18n.number(minTemp, 1) : "";
						maxTempSummary = maxTemp !== null ? i18n.number(maxTemp, 1) : "";
						maxUVSummary = Math.round(maxUV * 10) / 10;
						totalRainSummary = Math.round(totalRain * 10) / 10;
						if (maxWindKmh >= 0) {
							maxWindBftSummary = WeerJS.kmhToBft(maxWindKmh);
							maxWindDirSummary = WeerJS.degreesToWindDir(maxWindDirDeg);
						}
						var summarySunPct = Math.round(clearHourCount / (endHourIdx - startHourIdx) * 100);
						scoreSummary = WeerJS.calcWeatherScore(
							summarySunPct.toString(), maxRainProb.toString(),
							maxTempSummary, maxWindDirSummary + " " + maxWindBftSummary
						).toString();
					}

					// hourly strip: next 12 hours starting at the current hour
					var hourlyRows = [];
					if (startHourIdx >= 0) {
						var hourlyEnd = Math.min(startHourIdx + 12, hourly['time'].length);
						for (var h = startHourIdx; h < hourlyEnd; h++) {
							var ht = hourly['time'][h];
							var hourLabel = ht.substring(11, 13) + ":00";
							var hourDate = ht.substring(0, 10);
							var dayIdx = daily['time'].indexOf(hourDate);
							if (dayIdx < 0) dayIdx = 0;
							var hSunrise = daily['sunrise'][dayIdx];
							var hSunset  = daily['sunset'][dayIdx];
							var hTimeStr = ht.substring(11, 16);
							var hIsNight = WeerJS.determineNight(hTimeStr, hSunrise, hSunset);
							var hIconId = WeerJS.wmoCodeToIconId(hourly['weather_code'][h]);
							var hIconPath = "file:///qmf/qml/apps/weer/drawables/"
								+ (hIsNight ? hIconId + hIconId : hIconId) + ".png";
							var hTemp = hourly['temperature_2m'][h];
							var hRainProb = hourly['precipitation_probability']
								? (hourly['precipitation_probability'][h] || 0) : 0;
							hourlyRows.push({
								'hour': hourLabel,
								'icoon': hIconPath,
								'temp': (hTemp !== null && hTemp !== undefined) ? Math.round(hTemp) + "°" : "",
								'rainPct': hRainProb + "%"
							});
						}
					}
					hourlyForecast = hourlyRows;

					// no narrative forecast text from Open-Meteo
					forecastTitle = "Komende 12 uur";
					forecastText = "";
				}
			}
		}
		xhr.open("GET", url, true);
		xhr.send();
	}


	// --- Buienradar rain fetcher ---

	function fetchBuienradarRain() {
		var xhr = new XMLHttpRequest();
		var forecast = [];
		var precip = 0;
		var maxPrecip = 0;
		rainMaxMm = 0;
		var now = new Date();
		var brStartIdx = 0;
		var count = 0;
		showRain = false;

		xhr.onreadystatechange=function() {
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {

					var body = xhr.responseText;
			                if (body.length > 0) {

						var data = JSON.parse(xhr.responseText);
							// find start of actual forecast

						for (var i = 0; i < data['forecasts'].length ; i++) {
							var date = new Date(data['forecasts'][i]['datetime']);
							if (now < date) {
								brStartIdx = i;
								break;
							}
						}

      			       			rainForecastFrom = data['forecasts'][brStartIdx]['datetime'].substring(11,16);

							// fill array with the next 24 values

						for (var i = brStartIdx; i < data['forecasts'].length ; i++) {
							precip =  data['forecasts'][i]['precipation'];
							forecast.push(precip);
							if (precip > 0) showRain = true;
							if (precip > maxPrecip) maxPrecip = precip;
							count = count + 1;
							if (count == 24) break;
						}

							// fill remaining slots , just in case we didn't had 24 datapoints

						if (count < 24) {

							for (var i = count; i < 24 ; i++) {  // add empty columns
								precip = 0;
								forecast.push(precip);
							}
						}

       			       			rainForecastMid = WeerJS.addMinutes(rainForecastFrom, 60);
       		          			rainForecastTo = WeerJS.addMinutes(rainForecastFrom, 120);
						rainForecast = forecast;

						rainMaxMm = Math.round(maxPrecip + 0.5);
					}
				}
			}
		}

		xhr.open("GET", "https://graphdata.buienradar.nl/2.0/forecast/geo/RainHistoryForecast?lat="+lat+"&lon="+lon, true);
		xhr.send();
	}


	// --- Open-Meteo rain fetcher ---

	// Combined rain forecast: Buienradar 5-min data for the first 2 hours +
	// Open-Meteo hourly data for the remaining hours up to rainHours. The
	// resulting array uses 5-min resolution throughout (rainHours * 12 slots);
	// each Open-Meteo hourly value is repeated across its 12 5-min slots.
	function fetchOpenMeteoRain() {
		var totalSlots = rainHours * 12;
		var precipSlots = new Array(totalSlots);
		for (var k = 0; k < totalSlots; k++) precipSlots[k] = 0;

		var state = {
			hasRain: false,
			maxPrecip: 0,
			startTime: null,    // "HH:MM"
			startDate: null,    // Date of first slot
			gotBR: false
		};

		var brXhr = new XMLHttpRequest();
		brXhr.onreadystatechange = function() {
			if (brXhr.readyState != 4) return;

			if (brXhr.status == 200 && brXhr.responseText.length > 0) {
				try {
					var data = JSON.parse(brXhr.responseText);
					var now = new Date();
					var brStartIdx = 0;
					for (var i = 0; i < data['forecasts'].length; i++) {
						var date = new Date(data['forecasts'][i]['datetime']);
						if (now < date) {
							brStartIdx = i;
							state.startDate = date;
							break;
						}
					}
					state.startTime = data['forecasts'][brStartIdx]['datetime'].substring(11, 16);

					var brSlotCount = Math.min(24, totalSlots);
					for (var j = 0; j < brSlotCount && (brStartIdx + j) < data['forecasts'].length; j++) {
						var precip = data['forecasts'][brStartIdx + j]['precipation'] || 0;
						precipSlots[j] = precip;
						if (precip > 0) state.hasRain = true;
						if (precip > state.maxPrecip) state.maxPrecip = precip;
					}
					state.gotBR = true;
				} catch (e) {
				}
			}

			// Need Open-Meteo if rainHours > 2 (extra hours) or Buienradar failed
			if (rainHours > 2 || !state.gotBR) {
				fetchHourly();
			} else {
				finalize();
			}
		}

		function fetchHourly() {
			var lat4 = parseFloat(lat).toFixed(4);
			var lon4 = parseFloat(lon).toFixed(4);
			var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat4
				+ "&longitude=" + lon4
				+ "&hourly=precipitation"
				+ "&timezone=auto&forecast_days=2";

			var omXhr = new XMLHttpRequest();
			omXhr.onreadystatechange = function() {
				if (omXhr.readyState != 4) return;
				if (omXhr.status == 200) {
					try {
						var data = JSON.parse(omXhr.responseText);
						var hourly = data['hourly'];

						var refDate, fillStartSlot, hoursToFill;
						if (state.gotBR) {
							refDate = new Date(state.startDate.getTime());
							refDate.setHours(refDate.getHours() + 2);
							refDate.setMinutes(0, 0, 0);
							fillStartSlot = 24;
							hoursToFill = rainHours - 2;
						} else {
							var now = new Date();
							refDate = new Date(now);
							refDate.setMinutes(0, 0, 0);
							fillStartSlot = 0;
							hoursToFill = rainHours;
							state.startDate = refDate;
							state.startTime = ("0" + refDate.getHours()).slice(-2) + ":00";
						}

						var targetTimeStr = refDate.getFullYear() + "-"
							+ ("0" + (refDate.getMonth() + 1)).slice(-2) + "-"
							+ ("0" + refDate.getDate()).slice(-2) + "T"
							+ ("0" + refDate.getHours()).slice(-2) + ":00";

						var startHourIdx = -1;
						for (var i = 0; i < hourly['time'].length; i++) {
							if (hourly['time'][i] === targetTimeStr) {
								startHourIdx = i;
								break;
							}
						}

						if (startHourIdx >= 0) {
							for (var h = 0; h < hoursToFill; h++) {
								var precip = hourly['precipitation'][startHourIdx + h] || 0;
								for (var slot = 0; slot < 12; slot++) {
									var slotIdx = fillStartSlot + h * 12 + slot;
									if (slotIdx < totalSlots) {
										precipSlots[slotIdx] = precip;
										if (precip > 0) state.hasRain = true;
										if (precip > state.maxPrecip) state.maxPrecip = precip;
									}
								}
							}
						}
					} catch (e) {
					}
				}
				finalize();
			}
			omXhr.open("GET", url, true);
			omXhr.send();
		}

		function finalize() {
			rainForecast = precipSlots;
			rainMaxMm = Math.round(state.maxPrecip + 0.5);
			showRain = state.hasRain;
			if (state.startTime) {
				rainForecastFrom = state.startTime;
				rainForecastMid = WeerJS.addMinutes(state.startTime, Math.floor(rainHours / 2) * 60);
				rainForecastTo = WeerJS.addMinutes(state.startTime, rainHours * 60);
			}
		}

		brXhr.open("GET", "https://graphdata.buienradar.nl/2.0/forecast/geo/RainHistoryForecast?lat=" + lat + "&lon=" + lon, true);
		brXhr.send();
	}

	// --- Timers ---

	Timer {
		id: weatherTimer
		interval: weatherRefreshMin * 60000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateWeather()
	}

	Timer {
		id: rainTimer
		interval: rainRefreshMin * 60000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateRain()
	}
}
