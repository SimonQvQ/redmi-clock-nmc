# Redmi Clock Weather 0.1

A Redmi-style desktop clock for KDE Plasma 6, maintained by [SimonQvQ](https://github.com/SimonQvQ). Choose **NMC**, **Open-Meteo**, **QWeather webpage**, or **OpenWeather webpage**. No compilation or API key required. The widget's settings include bilingual usage instructions.

## 安装 / Install

Download `redmi-clock-weather-0.1.plasmoid`. Right-click the desktop → Add Widgets → Get New Widgets → Install Widget From Local File. Choose the file and add **Redmi Clock Weather** to the desktop.

下载 `.plasmoid` 后，右键桌面 → 添加小部件 → 获取新小部件 → 从本地文件安装，选择安装包，再添加 Redmi Clock Weather。

Alternatively:

```sh
kpackagetool6 -t Plasma/Applet -i redmi-clock-weather-0.1.plasmoid
# To update an existing installation of this adaptation:
kpackagetool6 -t Plasma/Applet -u redmi-clock-weather-0.1.plasmoid
# Or install directly from this repository:
kpackagetool6 -t Plasma/Applet -i package
```

Requires KDE Plasma 6, Qt Quick Controls, Kirigami and Qt Labs Platform, normally included with Plasma. Plugin ID: `org.simonqvq.redmiclock`. This is separate from upstream `Redmi.Clock`; to migrate, add the new widget, copy your weather/color settings, then remove the old widget. No compiler is needed.

## 使用 / Configure

Right-click the widget → Configure → General. Select the provider and Apply. Hover over the weather for source, timestamp and errors. Weather location defaults are empty. Weather is not available until configured.

右键时钟 → 配置 → 常规，选择天气源、填写位置并应用。悬停可查看来源、时间和错误。安装包不包含个人城市或位置，首次安装需要配置天气。

### 中央气象台 / NMC

1. Open the desired city's forecast page on [nmc.cn](https://www.nmc.cn/).
2. Enter the city's exact name from that page.
3. View the page source, search `stationId`, and copy the `value` of the hidden input. This encoded ID is different from a numeric meteorological station number.
4. Enter the ID and Apply. City and station must match.

打开中央气象台城市预报页，填写准确城市名；查看网页源代码，搜索 `stationId`，复制隐藏输入框的 `value`。这里使用编码 ID，不是数字气象站号。

### Open-Meteo / 全球天气

Choose Open-Meteo and enter decimal latitude and longitude. North/east are positive; south/west are negative. Example: **Berlin: latitude 52.52, longitude 13.405**. The city field is an optional display label. Use a decimal point, not a decimal comma. No key or IP geolocation is required.

选择 Open-Meteo，输入十进制经纬度（北纬、东经为正；南纬、西经为负）。例如柏林：纬度 `52.52`，经度 `13.405`。城市字段只作显示，可以留空。无需密钥，不按 IP 自动定位。

Weather data by [Open-Meteo](https://open-meteo.com/), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Its current conditions are weather-model estimates, not necessarily local station observations. [API documentation](https://open-meteo.com/en/docs) and [API terms](https://open-meteo.com/en/terms) apply; the public free endpoint is for non-commercial use. The selected provider's attribution is shown in the tooltip and Usage instructions.

### 和风网页 / QWeather webpage

Open the desired **Chinese city** page on [qweather.com](https://www.qweather.com/), copy its complete HTTPS URL and paste it into the QWeather city page field. Example: `https://www.qweather.com/weather/beijing-101010100.html`. No API key. Reads the current temperature, condition icon and observation time from the public HTML. Chinese page times are interpreted as UTC+8. Only Chinese `101…` city pages are supported by this parser.

打开和风的中国城市天气页，把完整 HTTPS 地址粘贴到设置。无需密钥；从公开网页读取当前温度、天气图标和更新时间。此解析器只支持中国城市页，网页时间按北京时间解析。

### OW 网页 / OpenWeather webpage

Select OpenWeather webpage and enter decimal coordinates, using the same location fields as Open-Meteo. No API key. Uses the public `/api/widget/onecall` request made by OpenWeather's own website, and displays its current observation. No website API keys are extracted or distributed.

选择 OW 网页源，填写十进制经纬度（和 Open-Meteo 共用位置字段），无需密钥。使用 OW 官网的公开预报请求读取当前天气。

Both webpage integrations are **unofficial** and refresh every **30 minutes**. Website endpoints/HTML may change or stop working; errors are shown in the tooltip, expired data is not displayed as current weather. Source links are provided in the tooltip and instructions. Availability and use are subject to the respective websites' terms.

两个网页源均为非官方集成，每 30 分钟刷新。网站接口或 HTML 改版可能导致失效；错误显示在提示中，不会把过期数据当作当前天气。

### Troubleshooting / 故障排查

API sources refresh every 15 minutes; webpage sources every 30 minutes. Requests have a 15-second timeout. Failure retains data up to three hours old; expired data displays `—`. Changing provider, location or units clears old data and requests fresh weather. No automatic provider switching. If weather is missing, check the tooltip, location/station ID, internet access and selected API availability. NMC's public website endpoint is undocumented and may change. Mainland connectivity to Open-Meteo can vary.

每 15 分钟刷新，15 秒连接超时；断网保留三小时以内的数据，过期显示 `—`。修改天气源、位置或单位后清空旧数据并刷新。不会自动切源。显示 `—` 时请查看提示，检查位置配置及网络。

## Privacy / 隐私

No IP location lookup, telemetry or bundled personal configuration. NMC receives the configured station ID; Open-Meteo and OpenWeather receive configured coordinates; QWeather receives the configured city-page request. Requests go directly to the selected provider over HTTPS. Configuration is stored locally by Plasma. No weather data is bundled or redistributed as a dataset.

不按 IP 定位，不收集遥测，不捆绑个人配置。选 NMC 时发送气象站 ID，选 Open-Meteo 时发送经纬度，均通过 HTTPS 直接请求。设置只保存在本机。

## Validate

```sh
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software qml6 tests/weather.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software qml6 tests/global-weather.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software qml6 tests/web-weather.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software qml6 tests/settings.qml
```

Synthetic tests cover city/station and coordinate validation, invalid/zero temperatures, Celsius/Fahrenheit conversion, WMO/night icons, timestamps, provider switching and cache expiry. No private coordinates or live network access are required for these tests.

## Credits and license

Based on Redmi Clock 0.6.4 by **zayronxio**, distributed on [KDE Store](https://store.kde.org/p/2175475). This is an independent adaptation, not an upstream GitHub fork. The original package declares GPL-3.0+; modifications are GPL-3.0-or-later. Quicksand font assets retain the bundled OFL license. Original source attribution is retained here. Author displayed in this adaptation: **SimonQvQ**.
