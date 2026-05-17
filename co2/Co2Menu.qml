import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

MenuItem {
    property Co2App app
    label: "Luchtkwaliteit"
    image: "qrc:/tsc/weer.png"
    weight: 210

    onClicked: {
        if (app && app.co2SettingsScreen)
            app.co2SettingsScreen.show();
    }
}
