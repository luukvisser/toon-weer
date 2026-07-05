import QtQuick 2.1
import qb.components 1.0

Tile {
    id: esphomeAirTile

    property color textColor: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor

    onClicked: {
        if (app.esphomeAirSettingsScreen)
            app.esphomeAirSettingsScreen.show();
    }

    Column {
        id: dataColumn
        spacing: isNxt ? 8 : 6
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        // Row 1: CO₂ (ppm) label | value
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 150 : 118
                height: co2Num.height

                Text {
                    text: "CO<sub>2</sub> (ppm):"
                    textFormat: Text.RichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.regular.name
                        pixelSize: isNxt ? 20 : 16
                    }
                    color: textColor
                }
            }

            Item {
                width: isNxt ? 165 : 132
                height: co2Num.height

                Text {
                    id: co2Num
                    text: app.co2Value
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.semiBold.name
                        pixelSize: isNxt ? 40 : 32
                    }
                    color: textColor
                }
            }
        }

        // Row 2: PM2.5 (µg/m³) label | value
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 150 : 118
                height: pm25Num.height

                Text {
                    text: "PM<sub>2.5</sub> (µg/m³):"
                    textFormat: Text.RichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.regular.name
                        pixelSize: isNxt ? 20 : 16
                    }
                    color: textColor
                }
            }

            Item {
                width: isNxt ? 165 : 132
                height: pm25Num.height

                Text {
                    id: pm25Num
                    text: {
                        var indoor = isNaN(Number(app.pm25Value)) ? app.pm25Value : i18n.number(Number(app.pm25Value), 1);
                        if (app.outdoorPm25Ip) {
                            var outdoor = isNaN(Number(app.outdoorPm25Value)) ? app.outdoorPm25Value : i18n.number(Number(app.outdoorPm25Value), 1);
                            return indoor + "|" + outdoor;
                        }
                        return indoor;
                    }
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.semiBold.name
                        pixelSize: isNxt ? 40 : 32
                    }
                    color: textColor
                }
            }
        }

        // Row 3: fan icon (%) label | value
        Row {
            spacing: isNxt ? 8 : 6

            Item {
                width: isNxt ? 150 : 118
                height: fanNum.height

                Row {
                    spacing: isNxt ? 6 : 4
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Canvas {
                        id: fanIconItem
                        width: isNxt ? 20 : 16
                        height: width
                        anchors.verticalCenter: parent.verticalCenter

                        property color blColor: textColor
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

                    Text {
                        text: "(%):"
                        anchors.verticalCenter: parent.verticalCenter
                        font {
                            family: qfont.regular.name
                            pixelSize: isNxt ? 20 : 16
                        }
                        color: textColor
                    }
                }
            }

            Item {
                width: isNxt ? 165 : 132
                height: fanNum.height

                Text {
                    id: fanNum
                    text: app.fanSpeed
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font {
                        family: qfont.semiBold.name
                        pixelSize: isNxt ? 40 : 32
                    }
                    color: textColor
                }
            }
        }
    }
}
