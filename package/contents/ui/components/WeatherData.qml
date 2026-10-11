// SPDX-License-Identifier: GPL-3.0-or-later
// Data source: the Central Meteorological Observatory's public weather service.
import QtQuick
import "WebWeather.js" as WebWeather

Item {
    id: weather
    signal dataChanged()
    property string city: ""
    property string datosweather: ""
    property string temperaturaActual: ""
    property string iconWeatherCurrent: ""
    property string description: ""
    property string publishTime: ""
    property string statusText: "正在获取天气…"
    property double observedAt: 0
    property var activeRequest: null
    property bool busy: false
    property string stationId: ""
    property string provider: "nmc"
    property string qweatherPage: ""
    property string latitude: ""
    property string longitude: ""
    readonly property string sourceName: ({nmc:"中央气象台", openmeteo:"Open-Meteo (CC BY 4.0)", qweather:"和风天气（网页）", openweather:"OpenWeather (web)"})[provider] || "Unknown"
    property bool autoRefresh: true
    property int temperatureUnit: 0
    property bool ready: false
    readonly property int maximumAge: 3 * 60 * 60 * 1000

    function iconFor(code) {
        var n = Number(code);
        var names = {0:"clear", 1:"few-clouds", 2:"clouds", 3:"showers-scattered",
                     4:"storm", 5:"storm", 6:"snow-rain", 13:"snow-scattered",
                     14:"snow", 15:"snow", 16:"snow", 17:"snow", 18:"fog",
                     19:"showers", 20:"fog", 26:"snow", 27:"snow", 28:"snow",
                     29:"fog", 30:"fog", 31:"fog", 53:"fog"};
        if ((n >= 7 && n <= 12) || (n >= 21 && n <= 25)) return "weather-showers";
        return "weather-" + (names[n] || "clouds");
    }

    function fail(reason) {
        statusText = city + " · " + sourceName + "\n" + reason;
        if (!observedAt || Date.now() - observedAt > maximumAge) {
            datosweather = "";
            temperaturaActual = "";
            iconWeatherCurrent = "";
        } else {
            statusText += "\n保留上次数据：" + publishTime;
        }
    }

    function accept(data) {
        if (!data || !data.station || data.station.city !== city || data.station.code !== stationId || !data.weather) throw new Error("城市数据不匹配");
        var raw = data.weather.temperature;
        var temp = Number(raw);
        if (raw === null || raw === "" || raw === undefined || !isFinite(temp) || temp < -60 || temp > 60)
            throw new Error("温度数据无效");
        var time = String(data.publish_time);
        if (!/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?$/.test(time)) throw new Error("天气时间格式无效");
        var stamp = Date.parse(time.replace(" ", "T") + (time.length === 16 ? ":00" : "") + "+08:00");
        if (!isFinite(stamp) || Date.now() - stamp > maximumAge || stamp > Date.now() + 15 * 60000)
            throw new Error("天气数据已过期或时间异常");
        observedAt = stamp;
        publishTime = String(data.publish_time);
        description = String(data.weather.info || "");
        var fahrenheit = temperatureUnit === 1;
        temperaturaActual = String(fahrenheit ? temp * 9 / 5 + 32 : temp);
        datosweather = String(temp);
        iconWeatherCurrent = iconFor(data.weather.img);
        statusText = city + " · " + sourceName + "\n" + description + " · " + temperaturaActual + (fahrenheit ? " °F" : " °C")
                   + "\n更新时间：" + publishTime;
        dataChanged();
    }

    function coordinatesValid() {
        if (!latitude.trim() || !longitude.trim()) return false;
        var lat = Number(latitude), lon = Number(longitude);
        return isFinite(lat) && isFinite(lon) && lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    }

    function globalWeather(code, day) {
        var names = {0:["clear","Clear"],1:["few-clouds","Mainly clear"],2:["few-clouds","Partly cloudy"],3:["clouds","Overcast"],
            45:["fog","Fog"],48:["fog","Rime fog"],51:["showers-scattered","Light drizzle"],53:["showers-scattered","Drizzle"],55:["showers","Heavy drizzle"],
            56:["snow-rain","Freezing drizzle"],57:["snow-rain","Freezing drizzle"],61:["showers-scattered","Light rain"],63:["showers","Rain"],65:["showers","Heavy rain"],
            66:["snow-rain","Freezing rain"],67:["snow-rain","Freezing rain"],71:["snow-scattered","Light snow"],73:["snow","Snow"],75:["snow","Heavy snow"],77:["snow","Snow grains"],
            80:["showers-scattered","Rain showers"],81:["showers","Rain showers"],82:["showers","Heavy rain showers"],85:["snow-scattered","Snow showers"],86:["snow","Heavy snow showers"],
            95:["storm","Thunderstorm"],96:["storm","Thunderstorm with hail"],99:["storm","Thunderstorm with hail"]};
        if (!names[code]) throw new Error("Unknown WMO weather code");
        var icon = "weather-" + names[code][0];
        if (day === 0 && code === 0) icon = "weather-clear-night";
        else if (day === 0 && (code === 1 || code === 2)) icon = "weather-few-clouds-night";
        return {icon:icon, description:names[code][1]};
    }

    function acceptOpenMeteo(data) {
        if (!data || !data.current || !data.current_units || data.current_units.temperature_2m !== "°C" || data.current_units.time !== "unixtime")
            throw new Error("Invalid Open-Meteo payload or units");
        if (!coordinatesValid() || typeof data.latitude !== "number" || typeof data.longitude !== "number"
            || Math.abs(data.latitude - Number(latitude)) > 0.2 || Math.abs(data.longitude - Number(longitude)) > 0.2)
            throw new Error("Weather location mismatch");
        var current = data.current;
        var temp = current.temperature_2m;
        var stamp = current.time * 1000;
        if (typeof temp !== "number" || !isFinite(temp) || temp < -90 || temp > 60) throw new Error("Invalid temperature");
        if (typeof current.time !== "number" || !isFinite(stamp) || Date.now() - stamp > maximumAge || stamp > Date.now() + 15 * 60000)
            throw new Error("Weather timestamp is stale or invalid");
        if (typeof current.weather_code !== "number" || (current.is_day !== 0 && current.is_day !== 1)) throw new Error("Invalid weather condition");
        var condition = globalWeather(current.weather_code, current.is_day);
        observedAt = stamp;
        publishTime = new Date(stamp).toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm");
        description = condition.description;
        datosweather = String(temp);
        temperaturaActual = String(temperatureUnit === 1 ? temp * 9 / 5 + 32 : temp);
        iconWeatherCurrent = condition.icon;
        statusText = (city || latitude + ", " + longitude) + " · " + sourceName + "\n" + description + " · " + temperaturaActual
            + (temperatureUnit === 1 ? " °F" : " °C") + "\n更新时间：" + publishTime + "\nhttps://open-meteo.com/";
        dataChanged();
    }

    function acceptWebObservation(observation, sourceUrl) {
        if (typeof observation.temperature !== "number" || !isFinite(observation.temperature) || observation.temperature < -90 || observation.temperature > 60)
            throw new Error("Invalid web weather temperature");
        if (typeof observation.stamp !== "number" || !isFinite(observation.stamp) || Date.now()-observation.stamp > maximumAge || observation.stamp > Date.now()+15*60000)
            throw new Error("Web weather is stale or has invalid time");
        observedAt = observation.stamp;
        publishTime = new Date(observedAt).toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm");
        datosweather = String(observation.temperature);
        temperaturaActual = String(temperatureUnit === 1 ? observation.temperature*9/5+32 : observation.temperature);
        description = observation.description;
        iconWeatherCurrent = observation.icon;
        statusText = (observation.location || city || latitude+", "+longitude) + " · " + sourceName + "\n" + description + " · " + temperaturaActual
            + (temperatureUnit === 1 ? " °F" : " °C") + "\n更新时间：" + publishTime + "\n" + sourceUrl;
        dataChanged();
    }
    function acceptQWeather(html) {
        acceptWebObservation(WebWeather.parseQWeather(html, qweatherPage.trim()), qweatherPage.trim());
    }
    function acceptOpenWeather(data) {
        if (!coordinatesValid()) throw new Error("Invalid weather coordinates");
        acceptWebObservation(WebWeather.parseOpenWeather(data, Number(latitude), Number(longitude)), "https://openweathermap.org/");
    }

    function refresh() {
        if (busy) return;
        if (["nmc","openmeteo","qweather","openweather"].indexOf(provider) < 0) { fail("Unknown weather provider"); return; }
        if (provider === "nmc" && (!city || !/^[a-zA-Z0-9_-]+$/.test(stationId))) { fail("请在设置中填写城市和中央气象台气象站 ID"); return; }
        if ((provider === "openmeteo" || provider === "openweather") && !coordinatesValid()) { fail("Enter latitude (-90…90) and longitude (-180…180) in settings"); return; }
        if (provider === "qweather" && !WebWeather.validQWeatherUrl(qweatherPage.trim())) { fail("请填写和风中国城市天气页完整 HTTPS 地址"); return; }
        busy = true;
        var req = new XMLHttpRequest();
        activeRequest = req;
        var url = provider === "qweather" ? qweatherPage.trim()
            : provider === "openweather" ? "https://openweathermap.org/api/widget/onecall?lat=" + encodeURIComponent(latitude.trim()) + "&lon=" + encodeURIComponent(longitude.trim()) + "&units=metric"
            : provider === "openmeteo"
            ? "https://api.open-meteo.com/v1/forecast?latitude=" + encodeURIComponent(latitude.trim()) + "&longitude=" + encodeURIComponent(longitude.trim())
              + "&current=temperature_2m,weather_code,is_day&temperature_unit=celsius&timeformat=unixtime&timezone=GMT&forecast_days=1"
            : "https://www.nmc.cn/rest/real/" + encodeURIComponent(stationId) + "?_=" + Date.now();
        req.open("GET", url);
        req.onreadystatechange = function() {
            if (req.readyState !== XMLHttpRequest.DONE || activeRequest !== req) return;
            deadline.stop();
            activeRequest = null;
            busy = false;
            if (req.status !== 200) { fail("连接失败（HTTP " + req.status + "）"); return; }
            try {
                if (provider === "qweather") acceptQWeather(req.responseText);
                else {
                    var data = JSON.parse(req.responseText);
                    if (provider === "openmeteo") acceptOpenMeteo(data);
                    else if (provider === "openweather") acceptOpenWeather(data);
                    else accept(data);
                }
            }
            catch (error) { fail(String(error.message || error)); }
        };
        req.send();
        deadline.restart();
    }

    function resetConfiguration() {
        var req = activeRequest;
        activeRequest = null;
        if (req) req.abort();
        busy = false;
        deadline.stop();
        observedAt = 0;
        fail("等待刷新");
        if (ready && autoRefresh) refresh();
    }
    onQweatherPageChanged: resetConfiguration()
    onProviderChanged: resetConfiguration()
    onLatitudeChanged: resetConfiguration()
    onLongitudeChanged: resetConfiguration()
    onStationIdChanged: resetConfiguration()
    onCityChanged: resetConfiguration()
    onTemperatureUnitChanged: resetConfiguration()
    Component.onCompleted: { ready = true; if (autoRefresh) refresh(); }
    Component.onDestruction: { if (activeRequest) activeRequest.abort(); }
    Timer {
        id: deadline
        interval: 15000
        onTriggered: {
            var req = activeRequest;
            activeRequest = null;
            busy = false;
            if (req) req.abort();
            fail("连接超时，稍后重试");
        }
    }
    Timer { interval: provider === "qweather" || provider === "openweather" ? 30 * 60000 : 15 * 60000; running: autoRefresh; repeat: true; onTriggered: refresh() }
    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: { if (observedAt && Date.now() - observedAt > maximumAge) fail("天气数据已过期"); }
    }
}
