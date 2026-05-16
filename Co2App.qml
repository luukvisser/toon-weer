import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
    id: co2App
    objectName: "Co2App"

    property string deviceIp: ""
    property int refreshSec: 60

    property string co2Value: "—"
    property string temperature: "—"
    property string lastUpdated: ""

    property url tileUrl: "Co2TempTile.qml"
    property url thumbnailIcon: "qrc:/tsc/weer.png"
    property Co2SettingsScreen co2SettingsScreen

    FileIO {
        id: co2SettingsFile
        source: "file:///mnt/data/tsc/co2.userSettings.json"
    }

    QtObject {
        id: p
        property var fetchXhr: null
    }

    function cancelXhr(xhr) {
        if (!xhr)
            return;
        xhr.onreadystatechange = null;
        try {
            xhr.abort();
        } catch (e) {
        }
    }

    function init() {
        registry.registerWidget("tile", tileUrl, this, null, {
                "thumbLabel": "Luchtkwaliteit",
                "thumbIcon": thumbnailIcon,
                "thumbCategory": "general",
                "thumbWeight": 30,
                "baseTileWeight": 10,
                "thumbIconVAlignment": "center"
            });
        registry.registerWidget("screen", "Co2SettingsScreen.qml", this, "co2SettingsScreen");
    }

    Component.onDestruction: {
        cancelXhr(p.fetchXhr);
        p.fetchXhr = null;
    }

    Component.onCompleted: {
        try {
            var settings = JSON.parse(co2SettingsFile.read());
            if (settings['deviceIp'])
                deviceIp = settings['deviceIp'];
            if (settings['refreshSec'] !== undefined) {
                var r = parseInt(settings['refreshSec']);
                if (!isNaN(r) && r >= 10 && r <= 300)
                    refreshSec = r;
            }
        } catch (e) {
        }
        if (deviceIp)
            fetchData();
    }

    function saveSettings() {
        var settings = {
            "deviceIp": deviceIp,
            "refreshSec": refreshSec
        };
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///mnt/data/tsc/co2.userSettings.json");
        xhr.send(JSON.stringify(settings));
    }

    function fetchData() {
        if (!deviceIp)
            return;
        cancelXhr(p.fetchXhr);
        var xhr = new XMLHttpRequest();
        p.fetchXhr = xhr;
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                p.fetchXhr = null;
                if (xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.value !== undefined)
                            co2Value = Math.round(data.value).toString();
                    } catch (e) {
                    }
                }
                fetchTemperature();
            }
        };
        xhr.open("GET", "http://" + deviceIp + "/sensor/co2", true);
        xhr.send();
    }

    function fetchTemperature() {
        if (!deviceIp)
            return;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.value !== undefined)
                            temperature = (Math.round(data.value * 10) / 10).toString();
                    } catch (e) {
                    }
                }
                var now = new Date();
                lastUpdated = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2);
            }
        };
        xhr.open("GET", "http://" + deviceIp + "/sensor/temperature", true);
        xhr.send();
    }

    Timer {
        interval: refreshSec * 1000
        running: deviceIp.length > 0
        repeat: true
        onTriggered: fetchData()
    }
}
