import QtQuick 2.1
import qb.components 1.0
import "weer.js" as WeerJS

Screen {
	id: weerDetailsScreen

	screenTitle: "Actueel weer plus weersverwachting";

	property bool dimState: screenStateController.dimmedColors;

	onCustomButtonClicked: {
		if (app.weerEditLonLatScreen) {
			 app.weerEditLonLatScreen.show();
		}
	}

	onShown: {
		addCustomTopRightButton("Locatie");
		app.radarImagesSmallUrl = "http://toon/";
		app.radarImagesSmallUrl = "https://api.buienradar.nl/image/1.0/RadarMapNL?width=180&height=180";
		fivedayforecastModel.clear();
		for (var i = 0; i < app.fiveDayForecast.length; i++) {
			fivedayforecastModel.append(app.fiveDayForecast[i]);
		}
		actualWeatherModel.clear();
		for (var i = 0; i < app.actualWeather.length; i++) {
			actualWeatherModel.append(app.actualWeather[i]);
		}
		hourlyForecastModel.clear();
		for (var i = 0; i < app.hourlyForecast.length; i++) {
			hourlyForecastModel.append(app.hourlyForecast[i]);
		}
	}

//selected weatherstation data

	Rectangle {
		id: backgroundRect
		height: isNxt ? 265 : 210
		width: isNxt ? 345 : 275
		anchors {
			baseline: parent.top
			baselineOffset: 5
			left: parent.left
			leftMargin: 5
		}
		color: colors.addDeviceBackgroundRectangle
	}

	Rectangle {
		id: backgroundRect2
		height: isNxt ? 265 : 210
		width:  isNxt ? 655 : 500
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 5 : 5
			right: parent.right
			rightMargin: 5
		}
		color: colors.addDeviceBackgroundRectangle
	}

	Rectangle {
		color: "#FFFF00"
		width: backgroundRect.width
		height: isNxt ? 35 : 28
		anchors {
			top: backgroundRect.top
			left: backgroundRect.left
		}
	}


//weatherforecast data for selected weather station

	GridView {
		id: grid

		model: actualWeatherModel
		delegate: actualDelegateGrid

		interactive: false
		flow: GridView.TopToBottom
		cellWidth: isNxt ? 175 : 140
		cellHeight: backgroundRect.height
		height: backgroundRect.height
		width: parent.width
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 32 : 24
			left: parent.left
			leftMargin: 10
		}
	}


	ListModel {
		id: actualWeatherModel
	}

	Component {
		id: actualDelegateGrid

		Item {
			width: grid.width / grid.columns
		        height: grid.height
			Rectangle {
				anchors.fill: parent

			 	Text {
					id: txtstation
					text: location
					anchors {
						baseline: parent.top
					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}


				Text {
					id: txttemperature
					text: temperature
					anchors {
						top: txtstation.bottom
						topMargin: isNxt ? 5 : 4
					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: txtwindsnelheid
					text: windsnelheid
					anchors {
						top: txttemperature.bottom
						topMargin: isNxt ? 5 : 4

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: txtwindrichting
					text: windDirection
					anchors {
						top: txtwindsnelheid.bottom
						topMargin: isNxt ? 5 : 4

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: txthumidity
					text: humidity
					anchors {
						top: txtwindrichting.bottom
						topMargin: isNxt ? 5 : 4

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: txtluchtdruk
					text: pressure
					anchors {
						top: txthumidity.bottom
						topMargin: isNxt ? 5 : 4

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: txtzicht
					text: zicht
					anchors {
						top: txtluchtdruk.bottom
						topMargin: isNxt ? 5 : 4
					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: txtzonop
					text: zonoponder
					anchors {
						top: txtzicht.bottom
						topMargin: isNxt ? 5 : 4

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}
			}
		}
        }

//weatherforecast data per day of week

	GridView {
		id: grid2

		model: fivedayforecastModel
		delegate: delegateGrid

		interactive: false
		flow: GridView.TopToBottom
		cellWidth: isNxt ? 100 : 75
		cellHeight: backgroundRect2.height
		height: backgroundRect2.height
		width: parent.width
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 32 : 24
			left: parent.left
			leftMargin: isNxt ? 375 : 300		}
	}

	ListModel {
		id: fivedayforecastModel
	}

	Component {
		id: delegateGrid

		Item {
			width: grid2.cellWidth
		        height: grid2.cellHeight
			Rectangle {
				anchors.fill: parent

			 	Text {
					id: forecastdagweek
					text: dagweek
					anchors {
						baseline: parent.top
					}
					font {
						family: qfont.bold.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: forecastkanszon
					text: kanszon
					anchors {
						top: forecastdagweek.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: forecastkansregen
					text: kansregen
					anchors {
						top: forecastkanszon.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: forecasttemprange
					text: tempRange
					anchors {
						top: forecastkansregen.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left
					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: forecastprecip
					text: precip
					anchors {
						top: forecasttemprange.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left
					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: forecastwind
					text: wind
					anchors {
						top: forecastprecip.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left

					}
					font {
						family: (index == 0) ? qfont.bold.name : qfont.regular.name
						pixelSize: isNxt ? 18 : 15
					}
					color: colors.clockTileColor
				}

				Text {
					id: forecastscore
					text: score
					anchors {
						top: forecastwind.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left
					}
					font {
						family: qfont.bold.name
						pixelSize: isNxt ? 18 : 15
					}
					color: {
						var s = parseInt(score);
						if (isNaN(s)) return colors.clockTileColor;
						if (s >= 8) return "#4CAF50";
						if (s >= 6) return "#FFC107";
						if (s >= 4) return "#FF9800";
						return "#F44336";
					}
				}

				Image {
					id: forecasticoon
					source: icoon
					width: isNxt ? 32 : 24
					height: isNxt ? 32 : 24
					fillMode: Image.PreserveAspectFit
					anchors {
						top: forecastscore.bottom
						topMargin: isNxt ? 5 : 4
						left: forecastdagweek.left
					}
					cache: false
				}
			}
		}
        }

	Text {
		id: weerDS2wvtitel
		text: app.forecastTitle
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 290 : 235
			left: parent.left
			leftMargin: 10
		}
		font {
			family: qfont.bold.name
			pixelSize: 20
		}
		color: colors.clockTileColor
	}

	Rectangle {
		id: backgroundRect3
		height: isNxt ? 280 : 180
		width: isNxt ? 800 : 580
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 290 : 235
			left: parent.left
			leftMargin: 10
		}
		color: colors.addDeviceBackgroundRectangle

	       Flickable {
	            id: flickArea
	            visible: !app.useOpenMeteo
	             anchors.fill: parent
	             contentWidth: backgroundRect3.width; contentHeight: backgroundRect3.height
	             flickableDirection: Flickable.VerticalFlick
	             clip: true

	             TextEdit{
	                  id: helpText
	                   wrapMode: TextEdit.Wrap
	                   width:backgroundRect3.width;
			   textFormat: TextEdit.RichText
	                   readOnly:true
				font {
					family: qfont.regular.name
					pixelSize: isNxt ? 18 : 15
				}

	                   text:  app.forecastText
	            }
	      }

		ListView {
			id: hourlyStrip
			visible: app.useOpenMeteo
			anchors.fill: parent
			anchors.margins: isNxt ? 8 : 6
			model: hourlyForecastModel
			orientation: ListView.Horizontal
			interactive: false
			clip: true
			spacing: 0

			delegate: Item {
				width: hourlyStrip.width / Math.max(hourlyForecastModel.count, 1)
				height: hourlyStrip.height

				Text {
					id: hourLbl
					text: hour
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: parent.top
					font {
						family: qfont.bold.name
						pixelSize: isNxt ? 18 : 14
					}
					color: colors.clockTileColor
				}

				Image {
					id: hourIcon
					source: icoon
					width: isNxt ? 48 : 32
					height: isNxt ? 48 : 32
					fillMode: Image.PreserveAspectFit
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: hourLbl.bottom
					anchors.topMargin: isNxt ? 8 : 4
					cache: false
				}

				Text {
					id: hourTemp
					text: temp
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: hourIcon.bottom
					anchors.topMargin: isNxt ? 8 : 4
					font {
						family: qfont.bold.name
						pixelSize: isNxt ? 20 : 16
					}
					color: colors.clockTileColor
				}

				Text {
					id: hourRainPct
					text: rainPct
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: hourTemp.bottom
					anchors.topMargin: isNxt ? 4 : 2
					font {
						family: qfont.regular.name
						pixelSize: isNxt ? 16 : 13
					}
					color: {
						var p = parseInt(rainPct);
						if (isNaN(p)) return colors.clockTileColor;
						if (p >= 60) return "#1976D2";
						if (p >= 30) return "#64B5F6";
						return colors.clockTileColor;
					}
				}

				Text {
					text: score
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: hourRainPct.bottom
					anchors.topMargin: isNxt ? 4 : 2
					font {
						family: qfont.bold.name
						pixelSize: isNxt ? 16 : 13
					}
					color: {
						var s = parseInt(score);
						if (isNaN(s)) return colors.clockTileColor;
						if (s >= 8) return "#4CAF50";
						if (s >= 6) return "#FFC107";
						if (s >= 4) return "#FF9800";
						return "#F44336";
					}
				}
			}
		}

		ListModel {
			id: hourlyForecastModel
		}

		MouseArea {
			anchors.fill: parent
			onClicked: {
				if (app.weerFullWeatherForecastScreen)
					app.weerFullWeatherForecastScreen.show();
			}
		}

	}

	Rectangle {
 		id: backgroundRectradar
		height: 180
		width: 180
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 290 : 235
			right: parent.right
			rightMargin: 10
		}
    		AnimatedImage { id: animation; source: app.radarImagesSmallUrl }

		MouseArea {
			anchors.fill: parent
			onClicked: {
				app.radarImagesUrl = "http://toon/";  //resetimage
				if (isNxt) {
					app.radarImagesUrl = "https://api.buienradar.nl/image/1.0/RadarMapNL?width=600&height=600";
				} else {
					app.radarImagesUrl = "https://api.buienradar.nl/image/1.0/RadarMapNL?width=400&height=400";
				}
				if (app.weerActualRadarScreen) {
					app.weerActualRadarScreen.setTitle("Actuele Weer");
					app.weerActualRadarScreen.show();
				}
			}
		}
	}
}
