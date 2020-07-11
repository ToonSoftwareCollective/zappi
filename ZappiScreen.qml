import QtQuick 2.1

import qb.components 1.0

Screen {
	id: zappiScreen
	screenTitleIconUrl: "qrc:/tsc/zappiIcon.png"

	screenTitle: "MyEnergy Zappi EV charger"

	Rectangle {
		id: mainRectangle
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			leftMargin: 20               
			rightMargin: 20               
		}
		color: colors.addDeviceBackgroundRectangle
	}


        StandardButton {
                id: btnConfigScreen
                width: 150
                text: "Instellingen"
                anchors.top : mainRectangle.top
                anchors.right : mainRectangle.right
                anchors.rightMargin : 10
                anchors.topMargin : 10
                onClicked: {
                        if (app.zappiSettings) {
                                app.zappiSettings.show();
                        }
                }
        }

	Text {
		id: zappiModeTitle
		anchors {
			baseline: mainRectangle.top
			baselineOffset: 100
			horizontalCenter: mainRectangle.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: colors.tileTitleColor
		text: "Charging mode"
	}

	StandardButton {
		id: zappiModeEco 
		width: 150
		text: "Eco"
		primary: app.zappiMode === 2 ? true : false
		anchors.top : zappiModeTitle.bottom
		anchors.topMargin : 10 
		anchors.horizontalCenter: mainRectangle.horizontalCenter
		onClicked: {
			app.changeZappiMode(2)
		}
	}
	StandardButton {
		id: zappiModeFase
		width: 150
		text: "Fast"
		primary: app.zappiMode === 1 ? true : false
		anchors.top : zappiModeTitle.bottom
		anchors.topMargin : 10 
		anchors.right : zappiModeEco.left
		anchors.rightMargin : 10 
		onClicked: {
			app.changeZappiMode(1)
		}
	}
	StandardButton {
		id: zappiModeEcoPlus
		width: 150
		text: "Eco+"
		primary: app.zappiMode === 3 ? true : false
		anchors.top : zappiModeTitle.bottom
		anchors.topMargin : 10 
		anchors.left : zappiModeEco.right
		anchors.leftMargin : 10 
		onClicked: {
			app.changeZappiMode(3)
		}
	}

        Text {
                id: txtZappiGridImport
                text: "Grid: " + app.zappiGridImport + " Watt"
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
                anchors {
                        top: zappiModeEco.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 40
                font.family: qfont.regular.name
        }

        Text {
                id: txtZappiCharging
                text: "Charging: " + app.zappiCharging + " Watt"
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
                anchors {
                        top: txtZappiGridImport.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 40
                font.family: qfont.regular.name
        }


        Text {
                id: txtZappiMode
                text: "Mode: " + app.zappiModeText[app.zappiMode]
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
                anchors {
                        top: txtZappiCharging.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 40
                font.family: qfont.regular.name
        }


        Text {
                id: txtZappiStatus
                text: "Status: " + app.zappiStatusText[app.zappiStatus]
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
                anchors {
                        top: txtZappiMode.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 40
                font.family: qfont.regular.name
        }

        Text {
                id: txtZappiChargekWh
                text: "Charged: " + app.zappiChargedkWh + " kWh"
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
                anchors {
                        top: txtZappiStatus.bottom
                        topMargin: 0
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 40
                font.family: qfont.regular.name
        }


}
