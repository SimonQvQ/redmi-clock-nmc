import QtQuick
import "../package/contents/ui/components" as Weather
Item {
    Weather.WeatherData { id: data; autoRefresh: false; provider: "qweather"; qweatherPage: "https://www.qweather.com/weather/test-city-101010100.html"; latitude: "52.52"; longitude: "13.405" }
    function check(ok, message) { if (!ok) throw new Error(message); }
    function rejects(call) { var rejected = false; try { call(); } catch(e) { rejected = true; } check(rejected, "Malformed observation accepted"); }
    Component.onCompleted: {
        var time = new Date(Date.now()+8*3600000).toISOString().slice(0,16).replace("T"," ");
        var html = '<title>Test City天气</title><link rel="canonical" href="'+data.qweatherPage+'"><div class="current-weather__bg"><p class="current-time">'+time+'</p><img src="https://static.qweather.com/img/common/icon/202106d/150.png"><p>0°</p><p>晴</p><div class="current-basic">';
        var ow = {lat:52.52,lon:13.405,current:{dt:Math.floor(Date.now()/1000),temp:0,weather:[{icon:"01n",description:"clear sky"}]}};
        try {
            data.acceptQWeather(html);check(data.datosweather === "0", "QWeather zero rejected");check(data.iconWeatherCurrent === "weather-clear-night", "QWeather night icon mismatch");
            rejects(function(){ data.acceptQWeather(html.replace("test-city-101010100","wrong-city-101010100")); });
            rejects(function(){ data.acceptQWeather(html.replace("current-weather__bg","unknown")); });
            rejects(function(){ data.acceptQWeather(html.replace("<p>0°</p>","<p>—</p>")); });
            rejects(function(){ data.acceptQWeather(html.replace(time,"2020-01-01 00:00")); });
            data.qweatherPage = "https://example.com/weather/test-city-101010100.html";rejects(function(){data.acceptQWeather(html);});
            data.provider = "openweather";data.acceptOpenWeather(ow);check(data.datosweather === "0", "OW zero rejected");check(data.iconWeatherCurrent === "weather-clear-night", "OW night icon mismatch");
            data.temperatureUnit = 1;data.acceptOpenWeather(ow);check(data.temperaturaActual === "32", "OW Fahrenheit mismatch");
            var wrong = JSON.parse(JSON.stringify(ow));wrong.current.temp = null;rejects(function(){data.acceptOpenWeather(wrong);});
            wrong = JSON.parse(JSON.stringify(ow));wrong.current.dt -= 4*3600;rejects(function(){data.acceptOpenWeather(wrong);});
            wrong = JSON.parse(JSON.stringify(ow));wrong.lat = 0;rejects(function(){data.acceptOpenWeather(wrong);});
            wrong = JSON.parse(JSON.stringify(ow));wrong.current.weather[0].icon = "bad";rejects(function(){data.acceptOpenWeather(wrong);});
            data.acceptOpenWeather(ow);data.fail("offline");check(data.datosweather !== "", "Recent web cache lost");
            data.provider = "qweather";check(data.datosweather === "", "Cross-source cache retained");Qt.exit(0);
        } catch(e) { console.error(e);Qt.exit(1); }
    }
}
