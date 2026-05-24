import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
    id: esphomeAirApp
    objectName: "EsphomeairApp"

    property string deviceIp: "192.168.68.111"
    property string openairIp: "192.168.68.113"
    property string outdoorPm25Ip: ""
    property string outdoorPm25Path: "sensor/pm2_5"
    property int refreshSec: 60
    property string co2SensorPath: "sensor/carbon_dioxide"
    property string pm25SensorPath: "sensor/pm2_5"
    property string fanSpeedPath: "sensor/Fan Speed"

    property string co2Value: "—"
    property string temperature: "—"
    property string pm25Value: "—"
    property string outdoorPm25Value: "—"
    property string fanSpeed: "—"
    property string lastUpdated: ""

    // Update state
    property string currentVersion: "—"
    property string latestVersion: ""
    property bool updateAvailable: false
    property bool updateChecking: false
    property bool updateInProgress: false
    property string updateStatus: ""

    property url tileUrl: "EsphomeairTile.qml"
    property url menuUrl: "EsphomeairMenu.qml"
    property url settingsScreenUrl: "EsphomeairSettingsScreen.qml"
    property url thumbnailIcon: "qrc:/tsc/weer.png"
    property EsphomeairSettingsScreen esphomeAirSettingsScreen

    FileIO {
        id: settingsFile
        source: "file:///mnt/data/tsc/esphomeair.userSettings.json"
    }

    FileIO {
        id: versionFile
        source: "file:///qmf/qml/apps/esphomeair/version.txt"
    }

    QtObject {
        id: p
        property var fetchXhr: null

        property var updateFileList: ["qmldir", "EsphomeairApp.qml", "EsphomeairTile.qml", "EsphomeairSettingsScreen.qml", "EsphomeairMenu.qml", "EditTextLabel4421.qml", "update.sh", "version.txt"]
    }

    function cancelXhr(xhr) {
        if (!xhr)
            return;
        xhr.onreadystatechange = null;
        try {
            xhr.abort();
        } catch (e) {}
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
        registry.registerWidget("screen", settingsScreenUrl, this, "esphomeAirSettingsScreen");
        registry.registerWidget("menuItem", menuUrl, this, "esphomeAirMenu", {
            "weight": 210
        });
    }

    Component.onDestruction: {
        cancelXhr(p.fetchXhr);
        p.fetchXhr = null;
    }

    Component.onCompleted: {
        try {
            currentVersion = versionFile.read().trim();
        } catch (e) {
            currentVersion = "onbekend";
        }

        try {
            var settings = JSON.parse(settingsFile.read());
            if (settings['deviceIp'])
                deviceIp = settings['deviceIp'];
            if (settings['openairIp'])
                openairIp = settings['openairIp'];
            if (settings['refreshSec'] !== undefined) {
                var r = parseInt(settings['refreshSec']);
                if (!isNaN(r) && r >= 10 && r <= 300)
                    refreshSec = r;
            }
            if (settings['co2SensorPath'])
                co2SensorPath = settings['co2SensorPath'];
            if (settings['pm25SensorPath'])
                pm25SensorPath = settings['pm25SensorPath'];
            if (settings['fanSpeedPath'])
                fanSpeedPath = settings['fanSpeedPath'];
            if (settings['outdoorPm25Ip'] !== undefined)
                outdoorPm25Ip = settings['outdoorPm25Ip'];
            if (settings['outdoorPm25Path'])
                outdoorPm25Path = settings['outdoorPm25Path'];
        } catch (e) {}
        if (deviceIp || openairIp)
            fetchData();
    }

    function saveSettings() {
        var settings = {
            "deviceIp": deviceIp,
            "openairIp": openairIp,
            "outdoorPm25Ip": outdoorPm25Ip,
            "outdoorPm25Path": outdoorPm25Path,
            "refreshSec": refreshSec,
            "co2SensorPath": co2SensorPath,
            "pm25SensorPath": pm25SensorPath,
            "fanSpeedPath": fanSpeedPath
        };
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///mnt/data/tsc/esphomeair.userSettings.json");
        xhr.send(JSON.stringify(settings));
    }

    // -------------------------------------------------------------------------
    // Update functions
    // -------------------------------------------------------------------------

    function checkForUpdate() {
        if (updateChecking || updateInProgress)
            return;
        updateChecking = true;
        updateStatus = "Controleren…";
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                updateChecking = false;
                if (xhr.status == 200) {
                    try {
                        var releases = JSON.parse(xhr.responseText);
                        var found = "";
                        for (var i = 0; i < releases.length; i++) {
                            var tag = releases[i].tag_name;
                            if (tag.indexOf("esphomeair-v") === 0) {
                                found = tag.substring(13);
                                break;
                            }
                        }
                        if (found) {
                            latestVersion = found;
                            if (found === currentVersion) {
                                updateAvailable = false;
                                updateStatus = "Versie " + currentVersion + " is de laatste versie.";
                            } else {
                                updateAvailable = true;
                                updateStatus = "Versie " + found + " beschikbaar!";
                            }
                        } else {
                            updateStatus = "Geen release gevonden.";
                        }
                    } catch (e) {
                        updateStatus = "Fout bij verwerken van releaseinfo.";
                    }
                } else {
                    updateStatus = "Kan GitHub niet bereiken.";
                }
            }
        };
        xhr.open("GET", "https://api.github.com/repos/luukvisser/toon-weer/releases", true);
        xhr.send();
    }

    function installUpdate() {
        if (!updateAvailable || updateInProgress)
            return;
        updateInProgress = true;
        downloadFile(0);
    }

    function downloadFile(index) {
        if (index >= p.updateFileList.length) {
            currentVersion = latestVersion;
            updateAvailable = false;
            updateInProgress = false;
            updateStatus = "Klaar! Herstart de Toon om de update toe te passen.";
            return;
        }
        var filename = p.updateFileList[index];
        var total = p.updateFileList.length;
        updateStatus = "Downloaden " + filename + " (" + (index + 1) + "/" + total + ")…";
        var rawUrl = "https://raw.githubusercontent.com/luukvisser/toon-weer/esphomeair-v" + latestVersion + "/esphomeair/" + filename;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    var putXhr = new XMLHttpRequest();
                    putXhr.open("PUT", "file:///qmf/qml/apps/esphomeair/" + filename);
                    putXhr.send(xhr.responseText);
                } else {
                    updateStatus = "Fout bij downloaden van " + filename + ".";
                    updateInProgress = false;
                    return;
                }
                downloadFile(index + 1);
            }
        };
        xhr.open("GET", rawUrl, true);
        xhr.send();
    }

    // -------------------------------------------------------------------------
    // Sensor fetch chain
    // -------------------------------------------------------------------------

    function fetchData() {
        if (deviceIp)
            fetchCo2();
        else
            fetchFanSpeed();
    }

    function fetchCo2() {
        if (!deviceIp) {
            fetchFanSpeed();
            return;
        }
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
                    } catch (e) {}
                }
                fetchTemperature();
            }
        };
        xhr.open("GET", "http://" + deviceIp + "/" + co2SensorPath, true);
        xhr.send();
    }

    function fetchTemperature() {
        if (!deviceIp) {
            fetchPm25();
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.value !== undefined)
                            temperature = (Math.round(data.value * 10) / 10).toString();
                    } catch (e) {}
                }
                fetchPm25();
            }
        };
        xhr.open("GET", "http://" + deviceIp + "/sensor/temperature", true);
        xhr.send();
    }

    function fetchPm25() {
        if (!deviceIp) {
            fetchFanSpeed();
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.value !== undefined)
                            pm25Value = (Math.round(data.value * 10) / 10).toString();
                    } catch (e) {}
                }
                fetchOutdoorPm25();
            }
        };
        xhr.open("GET", "http://" + deviceIp + "/" + pm25SensorPath, true);
        xhr.send();
    }

    function fetchOutdoorPm25() {
        if (!outdoorPm25Ip) {
            fetchFanSpeed();
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.value !== undefined)
                            outdoorPm25Value = (Math.round(data.value * 10) / 10).toString();
                    } catch (e) {}
                }
                fetchFanSpeed();
            }
        };
        xhr.open("GET", "http://" + outdoorPm25Ip + "/" + outdoorPm25Path, true);
        xhr.send();
    }

    function fetchFanSpeed() {
        if (!openairIp) {
            updateTimestamp();
            return;
        }
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        if (data.value !== undefined && typeof data.value === "number")
                            fanSpeed = Math.round(data.value).toString();
                    } catch (e) {}
                }
                updateTimestamp();
            }
        };
        xhr.open("GET", "http://" + openairIp + "/" + fanSpeedPath, true);
        xhr.send();
    }

    function updateTimestamp() {
        var now = new Date();
        lastUpdated = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2);
    }

    Timer {
        interval: refreshSec * 1000
        running: deviceIp.length > 0 || openairIp.length > 0 || outdoorPm25Ip.length > 0
        repeat: true
        onTriggered: fetchData()
    }
}
