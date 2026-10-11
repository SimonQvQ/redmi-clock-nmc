// SPDX-License-Identifier: GPL-3.0-or-later
.pragma library

function validQWeatherUrl(url) {
    // Chinese city pages display their observation times in UTC+8.
    return /^https:\/\/www\.qweather\.com\/weather\/[a-z0-9-]+-101\d{6}\.html$/.test(url);
}
function text(value) {
    return value.replace(/<[^>]*>/g, "").replace(/&nbsp;/g, " ").replace(/&amp;/g, "&").replace(/&#176;|&deg;/g, "°").trim();
}
function qweatherIcon(code) {
    if (code === 100) return "weather-clear";
    if (code === 150) return "weather-clear-night";
    if ([151,152,153].indexOf(code) >= 0) return "weather-few-clouds-night";
    if ([101,102,103].indexOf(code) >= 0) return "weather-few-clouds";
    if (code === 104) return "weather-clouds";
    if (code >= 300 && code < 400) {
        if ([302,303,304].indexOf(code) >= 0) return "weather-storm";
        if (code === 313) return "weather-snow-rain";
        return "weather-showers";
    }
    if (code >= 400 && code < 500) return [404,405,406].indexOf(code) >= 0 ? "weather-snow-rain" : "weather-snow";
    if (code >= 500 && code < 600) return "weather-fog";
    return "weather-clouds";
}
function parseQWeather(html, url) {
    if (!validQWeatherUrl(url) || typeof html !== "string" || html.length > 1000000) throw new Error("Invalid QWeather page");
    var canonical = html.match(/<link\b[^>]*rel=["']canonical["'][^>]*href=["']([^"']+)["']/i);
    if (!canonical || canonical[1] !== url) throw new Error("QWeather page location mismatch");
    var block = html.match(/class=["']current-weather__bg["'][^>]*>([\s\S]*?)<div\b[^>]*class=["']current-basic\b/i);
    if (!block) throw new Error("QWeather page structure changed");
    var time = block[1].match(/class=["']current-time["'][^>]*>\s*(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\s*</i);
    var icon = block[1].match(/static\.qweather\.com\/img\/common\/icon\/[a-zA-Z0-9]+\/(\d{3})\.png/);
    var live = block[1].match(/<p\b[^>]*>\s*(-?\d+(?:\.\d+)?)\s*(?:°|&#176;|&deg;)\s*<\/p>\s*<p\b[^>]*>([^<]+)<\/p>/i);
    if (!time || !icon || !live) throw new Error("QWeather observation fields missing");
    var title = html.match(/<title>([^<]+?)天气/);
    return {temperature:Number(live[1]), stamp:Date.parse(time[1].replace(" ","T")+":00+08:00"),
        icon:qweatherIcon(Number(icon[1])), description:text(live[2]), location:title ? text(title[1]) : "QWeather"};
}
function openweatherIcon(code) {
    var icons = {"01d":"clear","01n":"clear-night","02d":"few-clouds","02n":"few-clouds-night","03d":"clouds","03n":"clouds",
        "04d":"clouds","04n":"clouds","09d":"showers","09n":"showers","10d":"showers-scattered","10n":"showers-scattered",
        "11d":"storm","11n":"storm","13d":"snow","13n":"snow","50d":"fog","50n":"fog"};
    if (!icons[code]) throw new Error("Invalid OpenWeather condition icon");
    return "weather-" + icons[code];
}
function parseOpenWeather(data, latitude, longitude) {
    if (!data || !data.current || typeof data.lat !== "number" || typeof data.lon !== "number" || !isFinite(data.lat) || !isFinite(data.lon)
        || Math.abs(data.lat-latitude) > 0.2 || Math.abs(data.lon-longitude) > 0.2) throw new Error("OpenWeather location mismatch");
    var c = data.current;
    if (typeof c.temp !== "number" || typeof c.dt !== "number" || !Array.isArray(c.weather) || !c.weather[0]) throw new Error("Invalid OpenWeather observation");
    return {temperature:c.temp, stamp:c.dt*1000, icon:openweatherIcon(c.weather[0].icon), description:String(c.weather[0].description || c.weather[0].main || "")};
}
