import QtQuick
import "../package/contents/ui/components" as Weather
Item {
 Weather.WeatherData { id: data; autoRefresh: false; city: "Test City"; stationId: "test_station" }
 Component.onCompleted: {
  var now = new Date(Date.now() + 8*3600000).toISOString().slice(0,19).replace("T", " ");
  var sample = {station:{city:"Test City",code:"test_station"}, publish_time:now,
                weather:{temperature:12.5,info:"Clear",img:"0"}};
  function check(ok,message) { if(!ok)throw new Error(message); }
  function rejects(value) { var rejected=false; try{data.accept(value)}catch(e){rejected=true}check(rejected,"Invalid payload accepted"); }
  function clone() { return JSON.parse(JSON.stringify(sample)); }
  try {
   data.accept(sample);check(data.temperaturaActual==="12.5","Celsius mismatch");
   var wrong=clone();wrong.station.city="Other City";rejects(wrong);
   wrong=clone();wrong.station.code="other_station";rejects(wrong);
   wrong=clone();wrong.publish_time="2020-01-01 00:00";rejects(wrong);
   wrong=clone();wrong.publish_time="broken";rejects(wrong);
   wrong=clone();wrong.weather.temperature=null;rejects(wrong);
   wrong=clone();wrong.weather.temperature=9999;rejects(wrong);
   wrong=clone();wrong.weather.temperature=0;data.accept(wrong);check(data.datosweather==="0","Valid zero rejected");
   data.temperatureUnit=1;data.accept(wrong);check(data.temperaturaActual==="32","Fahrenheit mismatch");
   data.fail("offline");check(data.datosweather!=="","Fresh cached data lost");
   data.observedAt=Date.now()-data.maximumAge-1000;data.fail("stale");check(data.datosweather==="","Stale cache retained");
   console.log("PASS: provider validation, units, zero, timestamp, cache expiry");Qt.exit(0);
  } catch(e) { console.error(e);Qt.exit(1); }
 }
}
