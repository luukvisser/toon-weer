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

    Column {
        id: dataColumn
        spacing: isNxt ? 8 : 6
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        visible: !dimState

        // Row 1: value | unit | CO₂ label
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 100 : 80
                height: co2Num.height

                Text {
                    id: co2Num
                    text: app.co2Value
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: co2Color(app.co2Value)
                }
            }

            Item {
                width: co2Unit.width
                height: co2Num.height

                Text {
                    id: co2Unit
                    text: "ppm"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
            }

            Item {
                width: isNxt ? 44 : 35
                height: co2Num.height

                Text {
                    text: "CO<sub>2</sub>"
                    textFormat: Text.RichText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
            }
        }

        // Row 2: value | unit | PM2.5 label
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: app.outdoorPm25Ip ? (isNxt ? 150 : 120) : (isNxt ? 100 : 80)
                height: pm25Num.height

                Text {
                    id: pm25Num
                    text: {
                        var indoor = isNaN(Number(app.pm25Value)) ? app.pm25Value : i18n.number(Number(app.pm25Value), 1);
                        if (app.outdoorPm25Ip) {
                            var outdoor = isNaN(Number(app.outdoorPm25Value)) ? app.outdoorPm25Value : i18n.number(Number(app.outdoorPm25Value), 1);
                            return indoor + "/" + outdoor;
                        }
                        return indoor;
                    }
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: pm25Color(app.pm25Value)
                }
            }

            Item {
                width: pm25Unit.width
                height: pm25Num.height

                Text {
                    id: pm25Unit
                    text: "µg/m³"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
            }

            Item {
                width: isNxt ? 44 : 35
                height: pm25Num.height

                Text {
                    text: "PM<sub>2.5</sub>"
                    textFormat: Text.RichText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
            }
        }

        // Row 3: value | unit | fan icon
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 100 : 80
                height: fanNum.height

                Text {
                    id: fanNum
                    text: app.fanSpeed
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: defaultTextColor
                }
            }

            Item {
                width: fanUnit.width
                height: fanNum.height

                Text {
                    id: fanUnit
                    text: "%"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
            }

            Item {
                width: isNxt ? 20 : 16
                height: fanNum.height

                Canvas {
                    id: fanIconItem
                    width: isNxt ? 20 : 16
                    height: width
                    anchors.left: parent.left
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

        // Row 1: value | unit | CO₂ label
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 100 : 80
                height: dimCo2Num.height

                Text {
                    id: dimCo2Num
                    text: app.co2Value
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: dimTextColor
                }
            }

            Item {
                width: dimCo2Unit.width
                height: dimCo2Num.height

                Text {
                    id: dimCo2Unit
                    text: "ppm"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
            }

            Item {
                width: isNxt ? 44 : 35
                height: dimCo2Num.height

                Text {
                    text: "CO<sub>2</sub>"
                    textFormat: Text.RichText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.semiBold.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
            }
        }

        // Row 2: value | unit | PM2.5 label
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: app.outdoorPm25Ip ? (isNxt ? 150 : 120) : (isNxt ? 100 : 80)
                height: dimPm25Num.height

                Text {
                    id: dimPm25Num
                    text: {
                        var indoor = isNaN(Number(app.pm25Value)) ? app.pm25Value : i18n.number(Number(app.pm25Value), 1);
                        if (app.outdoorPm25Ip) {
                            var outdoor = isNaN(Number(app.outdoorPm25Value)) ? app.outdoorPm25Value : i18n.number(Number(app.outdoorPm25Value), 1);
                            return indoor + "/" + outdoor;
                        }
                        return indoor;
                    }
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: dimTextColor
                }
            }

            Item {
                width: dimPm25Unit.width
                height: dimPm25Num.height

                Text {
                    id: dimPm25Unit
                    text: "µg/m³"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
            }

            Item {
                width: isNxt ? 44 : 35
                height: dimPm25Num.height

                Text {
                    text: "PM<sub>2.5</sub>"
                    textFormat: Text.RichText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
            }
        }

        // Row 3: value | unit | fan icon
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 100 : 80
                height: dimFanNum.height

                Text {
                    id: dimFanNum
                    text: app.fanSpeed
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: dimTextColor
                }
            }

            Item {
                width: dimFanUnit.width
                height: dimFanNum.height

                Text {
                    id: dimFanUnit
                    text: "%"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
            }

            Item {
                width: isNxt ? 20 : 16
                height: dimFanNum.height

                Canvas {
                    id: dimFanIcon
                    width: isNxt ? 20 : 16
                    height: width
                    anchors.left: parent.left
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
        }
    }
}
