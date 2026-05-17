import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
    id: co2App
    objectName: "Co2App"

    property string deviceIp: "192.168.68.111"
    property string openairIp: "192.168.68.113"
    property int refreshSec: 60

    property string co2Value: "—"
    property string temperature: "—"
    property string fanSpeed: "—"
    property string lastUpdated: ""

    // Update state
    property string currentVersion: "—"
    property string latestVersion: ""
    property bool updateAvailable: false
    property bool updateChecking: false
    property bool updateInProgress: false
    property string updateStatus: ""

    property url tileUrl: "Co2TempTile.qml"
    property url thumbnailIcon: "qrc:/tsc/weer.png"
    property Co2SettingsScreen co2SettingsScreen

    FileIO {
        id: co2SettingsFile
        source: "file:///mnt/data/tsc/co2.userSettings.json"
    }

    FileIO {
        id: co2VersionFile
        source: "file:///qmf/qml/apps/co2/version.txt"
    }

    QtObject {
        id: p
        property var fetchXhr: null

        // files downloaded sequentially during an update
        property var updateFileList: [
            "qmldir",
            "Co2App.qml",
            "Co2TempTile.qml",
            "Co2SettingsScreen.qml",
            "EditTextLabel4421.qml",
            "update.sh",
            "version.txt"
        ]
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
            currentVersion = co2VersionFile.read().trim();
        } catch (e) {
            currentVersion = "onbekend";
        }

        try {
            var settings = JSON.parse(co2SettingsFile.read());
            if (settings['deviceIp'])
                deviceIp = settings['deviceIp'];
            if (settings['openairIp'])
                openairIp = settings['openairIp'];
            if (settings['refreshSec'] !== undefined) {
                var r = parseInt(settings['refreshSec']);
                if (!isNaN(r) && r >= 10 && r <= 300)
                    refreshSec = r;
            }
        } catch (e) {
        }
        if (deviceIp || openairIp)
            fetchData();
    }

    function saveSettings() {
        var settings = {
            "deviceIp": deviceIp,
            "openairIp": openairIp,
            "refreshSec": refreshSec
        };
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file:///mnt/data/tsc/co2.userSettings.json");
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
                            if (tag.indexOf("co2-v") === 0) {
                                found = tag.substring(5);
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
        var rawUrl = "https://raw.githubusercontent.com/luukvisser/toon-weer/co2-v" + latestVersion + "/co2/" + filename;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4) {
                xhr.onreadystatechange = null;
                if (xhr.status == 200) {
                    var putXhr = new XMLHttpRequest();
                    putXhr.open("PUT", "file:///qmf/qml/apps/co2/" + filename);
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
                            temperature = (Math.round(data.value * 10) / 10).toString();
                    } catch (e) {
                    }
                }
                fetchFanSpeed();
            }
        };
        xhr.open("GET", "http://" + deviceIp + "/sensor/temperature", true);
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
                        var speed = -1;
                        if (data.speed_level !== undefined)
                            speed = data.speed_level;
                        else if (data.value !== undefined && typeof data.value === "number")
                            speed = data.value;
                        if (speed >= 0)
                            fanSpeed = Math.round(speed).toString();
                        else if (data.value === false)
                            fanSpeed = "0";
                    } catch (e) {
                    }
                }
                updateTimestamp();
            }
        };
        xhr.open("GET", "http://" + openairIp + "/fan/fan_motor", true);
        xhr.send();
    }

    function updateTimestamp() {
        var now = new Date();
        lastUpdated = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2);
    }

    Timer {
        interval: refreshSec * 1000
        running: deviceIp.length > 0 || openairIp.length > 0
        repeat: true
        onTriggered: fetchData()
    }
}
