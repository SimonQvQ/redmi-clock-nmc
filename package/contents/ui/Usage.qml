// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
Item {
    implicitWidth: 600
    implicitHeight: 480
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        TextArea {
            readOnly: true
            wrapMode: TextEdit.WordWrap
            textFormat: TextEdit.RichText
            selectByMouse: true
            onLinkActivated: link => Qt.openUrlExternally(link)
            text: "<h2>Redmi Clock Weather 0.1</h2><p>Maintained by SimonQvQ / 作者：SimonQvQ</p>"
                + "<h3>使用方法 / Usage</h3><p>右键时钟 → 配置 → 常规，选择天气源并填写位置，然后点击应用。悬停时钟查看来源、天气时间或错误。<br>Right-click the clock → Configure → General. Select a provider, enter the location and apply. Hover over the clock for status and attribution.</p>"
                + "<h3>中央气象台 / NMC</h3><p>适用于国内城市。打开 <a href='https://www.nmc.cn/'>nmc.cn</a> 的城市预报页面，填写该页面的准确城市名。查看网页源代码，搜索 stationId，复制隐藏输入框的 value。此字段是页面使用的编码 ID，不是数字气象站号。<br>For Chinese cities, use the exact city name and the encoded value of the hidden stationId input from the city forecast page source, not a numeric station number.</p>"
                + "<h3>Open-Meteo</h3><p>支持全球位置，无需密钥。输入十进制经纬度：北纬和东经为正，南纬和西经为负。例如 Berlin：52.52, 13.405。城市名只作显示，可留空。<br>Worldwide, no API key. Enter decimal latitude and longitude; north/east are positive. Example: Berlin 52.52, 13.405. City label is optional.</p>"
                + "<h3>和风网页 / QWeather webpage</h3><p>打开和风中国城市天气页，把完整 HTTPS 地址填入设置。例：https://www.qweather.com/weather/beijing-101010100.html 。无需密钥，页面时间按北京时间解析。<br>Paste a Chinese city weather page URL from qweather.com. No API key. Chinese observation times use UTC+8.</p>"
                + "<h3>OW 网页 / OpenWeather webpage</h3><p>填写十进制经纬度，和 Open-Meteo 共用位置字段。通过 OW 官网公开预报请求获取实时天气，无需密钥。<br>Enter decimal latitude/longitude. Uses OpenWeather's public website forecast request, without an API key.</p>"
                + "<h3>刷新与故障 / Refresh &amp; troubleshooting</h3><p>API 源每 15 分钟、网页源每 30 分钟刷新，连接 15 秒超时。网页源可能因网站改版失效。断网保留三小时以内的数据，超时数据显示 —。切换源或位置会清空旧数据。若显示 —，检查提示、位置配置与网络。不会自动切换天气源。<br>API sources refresh every 15 minutes; webpage sources every 30 minutes. 15-second timeout. Website changes may break webpage sources. Recent data is retained on failure for up to three hours, then shown as —. Changing provider/location clears old data. Check the tooltip, location and network if weather is missing. No automatic provider switching.</p>"
                + "<h3>来源与隐私 / Sources &amp; privacy</h3><p>不会按 IP 自动定位。选择 NMC 时发送气象站 ID；选择 Open-Meteo 或 OW 时发送输入的经纬度，选择和风时请求配置的城市页面。配置只保存本机。<br>No IP geolocation. NMC receives your station ID; Open-Meteo / OpenWeather receive your coordinates; QWeather receives the configured city page request. Configuration is stored locally.</p>"
                + "<p>Weather data by <a href='https://open-meteo.com/'>Open-Meteo</a>, licensed under <a href='https://creativecommons.org/licenses/by/4.0/'>CC BY 4.0</a>. Current conditions are weather model estimates. Web sources: <a href='https://www.qweather.com/'>QWeather</a> and <a href='https://openweathermap.org/'>OpenWeather</a> (unofficial integrations). NMC: <a href='https://www.nmc.cn/'>Central Meteorological Observatory</a>.</p>"
                + "<p>Based on Redmi Clock by zayronxio, <a href='https://store.kde.org/p/2175475'>original package</a>. GPL-3.0-or-later. <a href='https://github.com/SimonQvQ/redmi-clock-nmc'>Source / 源码</a></p>"
        }
    }
}
