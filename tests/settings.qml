import QtQuick
Item {
    function i18n(text) { return text; }
    Loader { id: general; source: "../package/contents/ui/GeneralConfig.qml" }
    Loader { id: usage; source: "../package/contents/ui/Usage.qml" }
    Timer {
        interval: 500; running: true
        onTriggered: {
            if(general.status !== Loader.Ready || usage.status !== Loader.Ready) { Qt.exit(1);return; }
            general.item.cfg_weatherProvider = "openmeteo";
            general.item.cfg_weatherLatitude = "52.52";
            general.item.cfg_weatherLongitude = "13.405";
            if(general.item.cfg_weatherProvider !== "openmeteo" || general.item.cfg_weatherLatitude !== "52.52") { Qt.exit(2);return; }
            Qt.exit(0);
        }
    }
}
