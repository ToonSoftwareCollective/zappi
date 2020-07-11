import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;


Tile {
	id: zappiTile

	// Will be called when widget instantiated
	function init() {}

        onClicked: {
                stage.openFullscreen(app.zappiScreenUrl);
        }


	Text {
		id: tileTitle
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.tileTitleColor : colors.tileTitleColor
		text: "Zappi" 
	}

        Text {
                id: txtZappiGridImport
                text: "Grid: " + app.jsonZappiGridImport + " Watt"
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        top: tileTitle.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.family: qfont.regular.name
        }

        Text {
                id: txtZappiCharging
                text: "Charging: " + app.jsonZappiCharging + " Watt"
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        top: txtZappiGridImport.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.family: qfont.regular.name
        }

        Text {
                id: txtZappiMode
                text: "Mode: " + app.jsonZappiModeText[app.jsonZappiMode]
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        top: txtZappiCharging.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.family: qfont.regular.name
        }


        Text {
                id: txtZappiStatus
                text: "Status: " + app.jsonZappiStatusText[app.jsonZappiStatus]
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        top: txtZappiMode.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.family: qfont.regular.name
        }

        Text {
                id: txtZappiChargekWh
                text: "Charged: " + app.jsonZappiChargedkWh + " kWh"
              	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        top: txtZappiStatus.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.family: qfont.regular.name
        }

        Image {
                id: zappiIcon
                anchors.centerIn: parent
                source: "qrc://scaled/tsc/car-charge-0.svg"
        }

}
