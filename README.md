# Redmi Clock: domestic weather adaptation

This is a source adaptation of Redmi Clock 0.6.4 by zayronxio, distributed on [KDE Store](https://store.kde.org/p/2175475). This is an independent adaptation, not an upstream GitHub fork.

The clock layout is preserved. Weather uses the Central Meteorological Observatory (NMC) public HTTPS service, with a configurable city and station ID. No API key or IP geolocation service is used. This adaptation replaces the original Open-Meteo provider and is currently intended for Chinese cities supported by NMC.

## Configure

Open the widget settings. Enter the exact city name and station ID from the NMC city forecast page. The station ID is the value of the hidden `stationId` input in that page. This is the encoded identifier used by NMC, not the numeric meteorological station number.

City and station defaults are empty. User settings are stored by Plasma locally and are not part of this source package. The configured station ID is sent to NMC when retrieving weather.

The provider refreshes every 15 minutes, times out after 15 seconds, and rejects malformed values, mismatched cities/stations, future timestamps and observations older than three hours. Network failure preserves a recent observation; expired data displays an em dash. Hover over the clock to see the source, observation time or error.

The website endpoint is public but undocumented. It can change without notice. The data is fetched for the widget display and is not redistributed as a dataset.

## Install (no compilation)

```sh
kpackagetool6 -t Plasma/Applet -u package
```

Use `-i` instead of `-u` if Redmi Clock is not already installed. Reload the widget or log in again for QML changes to take effect.

## Validate

```sh
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software qml6 tests/weather.qml
```

Tests use synthetic data and a generated current timestamp, covering city/station validation, invalid temperatures, zero degrees, Celsius/Fahrenheit conversion and stale-cache behavior.

## License

The original package declares GPL-3.0+. Original author attribution remains in `package/metadata.json`. Modifications are GPL-3.0-or-later. Quicksand font assets retain their bundled license, where supplied.
