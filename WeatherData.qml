// SPDX-License-Identifier: GPL-3.0-or-later
// Data source: the Central Meteorological Observatory's public weather service.
import QtQuick

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
        statusText = city + " · 中央气象台\n" + reason;
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
        statusText = city + " · 中央气象台\n" + description + " · " + temperaturaActual + (fahrenheit ? " °F" : " °C")
                   + "\n更新时间：" + publishTime;
        dataChanged();
    }

    function refresh() {
        if (busy) return;
        if (!city || !/^[a-zA-Z0-9_-]+$/.test(stationId)) { fail("请在设置中填写城市和中央气象台气象站 ID"); return; }
        busy = true;
        var req = new XMLHttpRequest();
        activeRequest = req;
        req.open("GET", "https://www.nmc.cn/rest/real/" + encodeURIComponent(stationId) + "?_=" + Date.now());
        req.onreadystatechange = function() {
            if (req.readyState !== XMLHttpRequest.DONE || activeRequest !== req) return;
            deadline.stop();
            activeRequest = null;
            busy = false;
            if (req.status !== 200) { fail("连接失败（HTTP " + req.status + "）"); return; }
            try { accept(JSON.parse(req.responseText)); }
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
    Timer { interval: 15 * 60000; running: autoRefresh; repeat: true; onTriggered: refresh() }
    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: { if (observedAt && Date.now() - observedAt > maximumAge) fail("天气数据已过期"); }
    }
}
