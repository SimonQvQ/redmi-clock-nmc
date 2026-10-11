import QtQuick
import "../package/contents/ui/components" as Weather
Item {
    property bool qweatherPassed: false
    property bool openweatherPassed: false
    function done() { if (qweatherPassed && openweatherPassed) Qt.exit(0); }
    Weather.WeatherData {
        id: qw
        provider: "qweather"
        qweatherPage: "https://www.qweather.com/weather/beijing-101010100.html"
        onDataChanged: { qweatherPassed = observedAt > 0 && datosweather !== ""; done(); }
    }
    Weather.WeatherData {
        id: ow
        provider: "openweather"
        latitude: "52.52"
        longitude: "13.405"
        onDataChanged: { openweatherPassed = observedAt > 0 && datosweather !== ""; done(); }
    }
    Timer { interval: 22000; running: true; onTriggered: { console.error("QWeather:",qw.statusText,"OpenWeather:",ow.statusText);Qt.exit(2); } }
}
