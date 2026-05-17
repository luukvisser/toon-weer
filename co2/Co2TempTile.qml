import QtQuick 2.1
import qb.components 1.0

Tile {
    id: co2TempTile

    property bool dimState: screenStateController.dimmedColors
    property color defaultTextColor: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
    property color dimTextColor: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor

    function co2Color(val) {
        var v = parseInt(val);
        if (isNaN(v))
            return defaultTextColor;
        if (v < 800)
            return "#2ecc71";
        if (v < 1200)
            return "#f39c12";
        return "#e74c3c";
    }

    onClicked: {
        if (app.co2SettingsScreen)
            app.co2SettingsScreen.show();
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

    Text {
        id: co2ValueText
        text: app.co2Value + " ppm"
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 72 : 56
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 32 : 26
        }
        color: co2Color(app.co2Value)
        visible: !dimState
    }

    Text {
        id: co2Label
        text: "CO<sub>2</sub>"
        textFormat: Text.RichText
        anchors {
            baseline: co2ValueText.baseline
            right: co2ValueText.left
            rightMargin: 8
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 18 : 14
        }
        color: defaultTextColor
        visible: !dimState
    }

    Item {
        id: fanRow
        width: fanIcon.width + fanSpeedText.width + 8
        height: fanIcon.height
        anchors {
            top: co2ValueText.baseline
            topMargin: isNxt ? 14 : 10
            horizontalCenter: parent.horizontalCenter
        }
        visible: !dimState

        Canvas {
            id: fanIcon
            width: isNxt ? 28 : 22
            height: width
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
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

        Text {
            id: fanSpeedText
            text: app.fanSpeed + " %"
            anchors {
                left: fanIcon.right
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }
            font {
                family: qfont.regular.name
                pixelSize: isNxt ? 28 : 22
            }
            color: defaultTextColor
        }
    }

    Text {
        id: tempValueText
        text: "Temp " + app.temperature + "°"
        anchors {
            bottom: lastUpdatedText.top
            bottomMargin: 2
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 18 : 14
        }
        color: defaultTextColor
        visible: !dimState
    }

    Text {
        id: lastUpdatedText
        text: app.lastUpdated
        anchors {
            baseline: parent.bottom
            baselineOffset: -8
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 14 : 12
        }
        color: defaultTextColor
        visible: !dimState
    }

    // ----- Dimmed state: CO2 above fan speed -----

    Text {
        id: dimCo2Label
        text: "CO<sub>2</sub>"
        textFormat: Text.RichText
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 28 : 22
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.semiBold.name
            pixelSize: isNxt ? 20 : 16
        }
        color: dimTextColor
        visible: dimState
    }

    Text {
        id: dimCo2Text
        text: app.co2Value
        anchors {
            baseline: parent.top
            baselineOffset: isNxt ? 75 : 60
            horizontalCenter: parent.horizontalCenter
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 50 : 40
        }
        color: dimTextColor
        visible: dimState
    }

    Text {
        id: dimCo2Unit
        text: "ppm"
        anchors {
            baseline: dimCo2Text.baseline
            left: dimCo2Text.right
            leftMargin: 6
        }
        font {
            family: qfont.regular.name
            pixelSize: isNxt ? 20 : 16
        }
        color: dimTextColor
        visible: dimState
    }

    Item {
        id: dimFanRow
        width: dimFanIcon.width + dimFanSpeedText.width + 8
        height: dimFanIcon.height
        anchors {
            top: dimCo2Text.baseline
            topMargin: isNxt ? 18 : 14
            horizontalCenter: parent.horizontalCenter
        }
        visible: dimState

        Canvas {
            id: dimFanIcon
            width: isNxt ? 36 : 28
            height: width
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
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

        Text {
            id: dimFanSpeedText
            text: app.fanSpeed + " %"
            anchors {
                left: dimFanIcon.right
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }
            font {
                family: qfont.regular.name
                pixelSize: isNxt ? 36 : 28
            }
            color: dimTextColor
        }
    }
}
