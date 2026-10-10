import QtQuick 2.12
import QtQuick.Controls 2.12
import Qt.labs.platform
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    QtObject {
        id: unidWeatherValue
        property var value
    }



    signal configurationChanged

    property alias cfg_nmcCity: nmcCity.text
    property alias cfg_nmcStationId: nmcStationId.text
    property alias cfg_temperatureUnit: unidWeatherValue.value
    property alias cfg_colorHex: colorDialog.color

    ColorDialog {
        id: colorDialog
    }

    GridLayout {
        columns: 2
        //spacing: units.smallSpacing * 2

        Label {
            text: i18n("Color:")
            Layout.minimumWidth: configRoot.width/2
            horizontalAlignment: Text.AlignRight
        }
        Item {
            width: 64
            height: 24
            Rectangle {
                width: 64
                radius: 4
                height: 24
                border.color: "black"
                opacity: 0.5
                color: "transparent"
                border.width: 2
            }
            Rectangle {
                id: colorhex
                color: colorDialog.color
                border.color: "#B3FFFFFF"
                border.width: 1
                width: 64
                radius: 4
                height: 24
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.open()
                    }
                }
            }
        }
        Label { text: i18n("City:"); horizontalAlignment: Text.AlignRight }
        TextField { id: nmcCity; placeholderText: i18n("City name from the NMC forecast page") }
        Label { text: i18n("NMC station ID:"); horizontalAlignment: Text.AlignRight }
        TextField { id: nmcStationId; placeholderText: i18n("Station ID from the NMC forecast page") }
        Label {
            text: i18n("temperature unit:")
            Layout.minimumWidth: configRoot.width/2
            horizontalAlignment: Text.AlignRight
        }
        ComboBox {
            textRole: "text"
            valueRole: "value"
            id: positionComboBox
            model: [
                {text: i18n("Celsius (°C)"), value: 0},
                {text: i18n("Fahrenheit (°F)"), value: 1},
            ]
            onActivated: unidWeatherValue.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(unidWeatherValue.value)
        }

    }
}
