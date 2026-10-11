// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform as Platform
import org.kde.kirigami as Kirigami

Item {
    id: configRoot
    implicitWidth: 560
    implicitHeight: form.implicitHeight
    property string cfg_weatherProvider: "nmc"
    property alias cfg_qweatherPage: qweatherPage.text
    property alias cfg_nmcCity: city.text
    property alias cfg_nmcStationId: station.text
    property alias cfg_weatherLatitude: latitude.text
    property alias cfg_weatherLongitude: longitude.text
    property int cfg_temperatureUnit: 0
    property alias cfg_colorHex: colorDialog.color
    Platform.ColorDialog { id: colorDialog }
    Kirigami.FormLayout {
        id: form
        anchors.left: parent.left
        anchors.right: parent.right
        ComboBox {
            Kirigami.FormData.label: i18n("Weather provider:")
            model: [i18n("Central Meteorological Observatory (China)"), i18n("Open-Meteo (Worldwide)"), i18n("QWeather webpage (China)"), i18n("OpenWeather webpage (Worldwide)")]
            currentIndex: Math.max(0, ["nmc","openmeteo","qweather","openweather"].indexOf(configRoot.cfg_weatherProvider))
            onActivated: configRoot.cfg_weatherProvider = ["nmc","openmeteo","qweather","openweather"][currentIndex]
        }
        TextField {
            id: city
            Kirigami.FormData.label: i18n("City / display name:")
            placeholderText: configRoot.cfg_weatherProvider === "nmc" ? i18n("Exact city name from NMC") : i18n("Optional location label")
            Layout.fillWidth: true
        }
        TextField {
            id: station
            Kirigami.FormData.label: i18n("NMC station ID:")
            visible: configRoot.cfg_weatherProvider === "nmc"
            placeholderText: i18n("Encoded stationId from the NMC forecast page")
            Layout.fillWidth: true
        }
        TextField {
            id: qweatherPage
            Kirigami.FormData.label: i18n("QWeather city page:")
            visible: configRoot.cfg_weatherProvider === "qweather"
            placeholderText: "https://www.qweather.com/weather/beijing-101010100.html"
            Layout.fillWidth: true
        }
        TextField {
            id: latitude
            Kirigami.FormData.label: i18n("Latitude:")
            visible: configRoot.cfg_weatherProvider === "openmeteo" || configRoot.cfg_weatherProvider === "openweather"
            placeholderText: i18n("-90 to 90; north is positive")
            validator: DoubleValidator { bottom: -90; top: 90; decimals: 6; locale: "C"; notation: DoubleValidator.StandardNotation }
        }
        TextField {
            id: longitude
            Kirigami.FormData.label: i18n("Longitude:")
            visible: configRoot.cfg_weatherProvider === "openmeteo" || configRoot.cfg_weatherProvider === "openweather"
            placeholderText: i18n("-180 to 180; east is positive")
            validator: DoubleValidator { bottom: -180; top: 180; decimals: 6; locale: "C"; notation: DoubleValidator.StandardNotation }
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: configRoot.cfg_weatherProvider === "qweather" || configRoot.cfg_weatherProvider === "openweather"
                ? i18n("Public webpage source, no API key. Refreshes every 30 minutes. Website changes can break parsing. Your configured city URL or coordinates are sent to the selected website.")
                : configRoot.cfg_weatherProvider === "openmeteo"
                ? i18n("No API key required. Coordinates are sent to Open-Meteo. No IP location lookup. Weather data: Open-Meteo, CC BY 4.0.")
                : i18n("City and station ID are entered manually. Weather source: NMC. See Usage instructions for finding the station ID.")
        }
        ComboBox {
            Kirigami.FormData.label: i18n("Temperature unit:")
            model: [i18n("Celsius (°C)"), i18n("Fahrenheit (°F)")]
            currentIndex: configRoot.cfg_temperatureUnit
            onActivated: configRoot.cfg_temperatureUnit = currentIndex
        }
        Button {
            Kirigami.FormData.label: i18n("Text color:")
            text: i18n("Choose color…")
            onClicked: colorDialog.open()
        }
    }
}
