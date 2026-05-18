import QtQuick 2.1
import qb.components 1.0

Tile {
    id: esphomeAirTile

    property bool dimState: screenStateController.dimmedColors
    property color defaultTextColor: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    property color dimTextColor: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor

    function co2Color(val) {
        var v = parseInt(val);
        if (isNaN(v))
            return defaultTextColor;
        if (v < 600)
            return "#00e400";
        if (v < 900)
            return "#ffff00";
        if (v < 1000)
            return "#ff8c00";
        if (v < 1200)
            return "#ff0000";
        return "#8f3f97";
    }

    function pm25Color(val) {
        var v = parseFloat(val);
        if (isNaN(v))
            return defaultTextColor;
        if (v < 5)
            return "#00e400";
        if (v < 15)
            return "#ffff00";
        if (v < 25)
            return "#ff8c00";
        if (v < 35)
            return "#ff0000";
        return "#8f3f97";
    }

    onClicked: {
        if (app.esphomeAirSettingsScreen)
            app.esphomeAirSettingsScreen.show();
    }

    // ----- Normal state -----

    Text {
        id: tileTitle
        text: "Luchtkwaliteit"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 28 : 22
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: defaultTextColor
        visible: !dimState
    }

    // Three-row data block: CO₂, PM2.5, fan
    Column {
        id: dataColumn
        spacing: isNxt ? 8 : 6
        anchors {
            top: tileTitle.bottom
            topMargin: isNxt ? 8 : 6
            horizontalCenter: parent.horizontalCenter
        }
        visible: !dimState

        // Row 1: CO₂ label | value
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 44 : 35
                height: co2ValueItem.height

                Text {
                    text: "CO<sub>2</sub>"
                    textFormat: Text.RichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.regular.name
                        pixelSize: isNxt ? 16 : 13
                    }
                    color: defaultTextColor
                }
            }

            Text {
                id: co2ValueItem
                text: app.co2Value + " ppm"
                font {
                    family: qfont.regular.name
                    pixelSize: isNxt ? 38 : 30
                }
                color: co2Color(app.co2Value)
            }
        }

        // Row 2: PM2.5 label | value
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 44 : 35
                height: pm25ValueItem.height

                Text {
                    text: "PM<sub>2.5</sub>"
                    textFormat: Text.RichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.regular.name
                        pixelSize: isNxt ? 16 : 13
                    }
                    color: defaultTextColor
                }
            }

            Text {
                id: pm25ValueItem
                text: app.pm25Value + " µg/m³"
                font {
                    family: qfont.regular.name
                    pixelSize: isNxt ? 38 : 30
                }
                color: pm25Color(app.pm25Value)
            }
        }

        // Row 3: fan icon | speed
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 44 : 35
                height: fanSpeedItem.height

                Canvas {
                    id: fanIconItem
                    width: isNxt ? 28 : 22
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    property color blColor: defaultTextColor
                    onBlColorChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = blColor;
                        var cx = width / 2;
                        var cy = height / 2;
                        var bladeR = width / 2 - 1;
                        var hubR = width * 0.13;
                        for (var i = 0; i < 3; i++) {
                            ctx.save();
                            ctx.translate(cx, cy);
                            ctx.rotate(i * 2 * Math.PI / 3);
                            ctx.beginPath();
                            ctx.moveTo(0, 0);
                            ctx.quadraticCurveTo(bladeR * 0.35, -bladeR * 0.55, bladeR, 0);
                            ctx.quadraticCurveTo(bladeR * 0.35, bladeR * 0.55, 0, 0);
                            ctx.fill();
                            ctx.restore();
                        }
                        ctx.beginPath();
                        ctx.arc(cx, cy, hubR, 0, 2 * Math.PI);
                        ctx.fill();
                    }
                }
            }

            Text {
                id: fanSpeedItem
                text: app.fanSpeed + " %"
                font {
                    family: qfont.regular.name
                    pixelSize: isNxt ? 38 : 30
                }
                color: defaultTextColor
            }
        }
    }

    // ----- Dimmed state -----

    Column {
        id: dimColumn
        spacing: isNxt ? 8 : 6
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        visible: dimState

        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 44 : 35
                height: dimCo2Value.height

                Text {
                    text: "CO<sub>2</sub>"
                    textFormat: Text.RichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.semiBold.name
                        pixelSize: isNxt ? 18 : 14
                    }
                    color: dimTextColor
                }
            }

            Text {
                id: dimCo2Value
                text: app.co2Value + " ppm"
                font {
                    family: qfont.regular.name
                    pixelSize: isNxt ? 38 : 30
                }
                color: dimTextColor
            }
        }

        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 44 : 35
                height: dimPm25Value.height

                Text {
                    text: "PM<sub>2.5</sub>"
                    textFormat: Text.RichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.regular.name
                        pixelSize: isNxt ? 16 : 13
                    }
                    color: dimTextColor
                }
            }

            Text {
                id: dimPm25Value
                text: app.pm25Value + " µg/m³"
                font {
                    family: qfont.regular.name
                    pixelSize: isNxt ? 38 : 30
                }
                color: dimTextColor
            }
        }

        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 44 : 35
                height: dimFanSpeed.height

                Canvas {
                    id: dimFanIcon
                    width: isNxt ? 26 : 20
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    property color blColor: dimTextColor
                    onBlColorChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.fillStyle = blColor;
                        var cx = width / 2;
                        var cy = height / 2;
                        var bladeR = width / 2 - 1;
                        var hubR = width * 0.13;
                        for (var i = 0; i < 3; i++) {
                            ctx.save();
                            ctx.translate(cx, cy);
                            ctx.rotate(i * 2 * Math.PI / 3);
                            ctx.beginPath();
                            ctx.moveTo(0, 0);
                            ctx.quadraticCurveTo(bladeR * 0.35, -bladeR * 0.55, bladeR, 0);
                            ctx.quadraticCurveTo(bladeR * 0.35, bladeR * 0.55, 0, 0);
                            ctx.fill();
                            ctx.restore();
                        }
                        ctx.beginPath();
                        ctx.arc(cx, cy, hubR, 0, 2 * Math.PI);
                        ctx.fill();
                    }
                }
            }

            Text {
                id: dimFanSpeed
                text: app.fanSpeed + " %"
                font {
                    family: qfont.regular.name
                    pixelSize: isNxt ? 38 : 30
                }
                color: dimTextColor
            }
        }
    }
}
