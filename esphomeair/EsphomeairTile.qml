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
                        pixelSize: isNxt ? 20 : 16
                    }
                    color: defaultTextColor
                }
            }

            Item {
                id: co2ValueItem
                width: co2Num.width + (isNxt ? 5 : 4) + co2Unit.width
                height: co2Num.height

                Text {
                    id: co2Num
                    text: app.co2Value
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: co2Color(app.co2Value)
                }

                Text {
                    id: co2Unit
                    text: "ppm"
                    anchors.left: co2Num.right
                    anchors.leftMargin: isNxt ? 5 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
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
                        pixelSize: isNxt ? 20 : 16
                    }
                    color: defaultTextColor
                }
            }

            Item {
                id: pm25ValueItem
                width: pm25Num.width + (isNxt ? 5 : 4) + pm25Unit.width
                height: pm25Num.height

                Text {
                    id: pm25Num
                    text: app.pm25Value
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: pm25Color(app.pm25Value)
                }

                Text {
                    id: pm25Unit
                    text: "µg/m³"
                    anchors.left: pm25Num.right
                    anchors.leftMargin: isNxt ? 5 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
                }
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

            Item {
                id: fanSpeedItem
                width: fanNum.width + (isNxt ? 5 : 4) + fanUnit.width
                height: fanNum.height

                Text {
                    id: fanNum
                    text: app.fanSpeed
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: defaultTextColor
                }

                Text {
                    id: fanUnit
                    text: "%"
                    anchors.left: fanNum.right
                    anchors.leftMargin: isNxt ? 5 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: defaultTextColor
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
                        pixelSize: isNxt ? 20 : 16
                    }
                    color: dimTextColor
                }
            }

            Item {
                id: dimCo2Value
                width: dimCo2Num.width + (isNxt ? 5 : 4) + dimCo2Unit.width
                height: dimCo2Num.height

                Text {
                    id: dimCo2Num
                    text: app.co2Value
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: dimTextColor
                }

                Text {
                    id: dimCo2Unit
                    text: "ppm"
                    anchors.left: dimCo2Num.right
                    anchors.leftMargin: isNxt ? 5 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
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
                        pixelSize: isNxt ? 20 : 16
                    }
                    color: dimTextColor
                }
            }

            Item {
                id: dimPm25Value
                width: dimPm25Num.width + (isNxt ? 5 : 4) + dimPm25Unit.width
                height: dimPm25Num.height

                Text {
                    id: dimPm25Num
                    text: app.pm25Value
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: dimTextColor
                }

                Text {
                    id: dimPm25Unit
                    text: "µg/m³"
                    anchors.left: dimPm25Num.right
                    anchors.leftMargin: isNxt ? 5 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
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
                    anchors.right: parent.right
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

            Item {
                id: dimFanSpeed
                width: dimFanNum.width + (isNxt ? 5 : 4) + dimFanUnit.width
                height: dimFanNum.height

                Text {
                    id: dimFanNum
                    text: app.fanSpeed
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 40 : 32 }
                    color: dimTextColor
                }

                Text {
                    id: dimFanUnit
                    text: "%"
                    anchors.left: dimFanNum.right
                    anchors.leftMargin: isNxt ? 5 : 4
                    anchors.verticalCenter: parent.verticalCenter
                    font { family: qfont.regular.name; pixelSize: isNxt ? 20 : 16 }
                    color: dimTextColor
                }
            }
        }
    }
}
