import QtQuick
import "../package/contents/ui/components" as Weather
Item {
    Weather.WeatherData { id: data; autoRefresh: false; provider: "openmeteo"; latitude: "52.52"; longitude: "13.405" }
    function check(ok, message) { if (!ok) throw new Error(message); }
    function rejects(value) { var rejected = false; try { data.acceptOpenMeteo(value); } catch(e) { rejected = true; } check(rejected, "Invalid payload accepted"); }
    Component.onCompleted: {
        var sample = {latitude:52.52, longitude:13.405, current_units:{time:"unixtime",temperature_2m:"°C"},current:{time:Math.floor(Date.now()/1000),temperature_2m:0,weather_code:0,is_day:0}};
        function clone() { return JSON.parse(JSON.stringify(sample)); }
        try {
            check(data.coordinatesValid(), "Valid coordinates rejected");
            data.acceptOpenMeteo(sample);check(data.datosweather === "0", "Zero temperature rejected");check(data.iconWeatherCurrent === "weather-clear-night", "Night icon mismatch");
            data.temperatureUnit = 1;data.acceptOpenMeteo(sample);check(data.temperaturaActual === "32", "Fahrenheit mismatch");
            var wrong = clone();wrong.current.temperature_2m = null;rejects(wrong);
            wrong = clone();wrong.current.temperature_2m = true;rejects(wrong);
            wrong = clone();wrong.current.temperature_2m = 99;rejects(wrong);
            wrong = clone();wrong.current.time -= 4*3600;rejects(wrong);
            wrong = clone();wrong.current.time += 3600;rejects(wrong);
            wrong = clone();wrong.current.time = null;rejects(wrong);
            wrong = clone();wrong.current_units.temperature_2m = "°F";rejects(wrong);
            wrong = clone();wrong.latitude = 0;rejects(wrong);
            wrong = clone();wrong.current.weather_code = 999;rejects(wrong);
            wrong = clone();wrong.current.is_day = null;rejects(wrong);
            data.latitude = "";check(!data.coordinatesValid(), "Empty coordinates accepted");rejects(sample);
            data.latitude = "91";check(!data.coordinatesValid(), "Latitude bounds ignored");
            data.latitude = "0";data.longitude = "0";check(data.coordinatesValid(), "Zero coordinates rejected");
            data.latitude = "52.52";data.longitude = "13.405";data.acceptOpenMeteo(sample);data.fail("offline");check(data.datosweather !== "", "Recent cache lost");
            data.provider = "nmc";check(data.datosweather === "", "Cross-provider cache retained");
            console.warn("PASS: Open-Meteo validation, coordinates, units, night icons, provider switching and cache");Qt.exit(0);
        } catch(e) { console.error(e);Qt.exit(1); }
    }
    Timer { interval: 10000; running: true; onTriggered: Qt.exit(2) }
}
