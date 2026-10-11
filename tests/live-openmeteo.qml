import QtQuick
import "../package/contents/ui/components" as Weather
Item {
    Weather.WeatherData {
        id: data
        provider: "openmeteo"
        latitude: "52.52"
        longitude: "13.405"
        city: "Berlin"
        onDataChanged: { if(datosweather !== "" && observedAt > 0 && statusText.indexOf("Open-Meteo") >= 0) Qt.exit(0);else Qt.exit(1); }
    }
    Timer { interval: 20000; running: true; onTriggered: { console.error(data.statusText);Qt.exit(2); } }
}
