import QtQuick 2.1

import qb.components 1.0

Screen {
	id: zappiScreen
	screenTitleIconUrl: "qrc:/tsc/zappiicon.png"

	screenTitle: "myenergi Zappi EV charger"

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
                text: "Settings"
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
		id: zappiBadLogin
		visible: ! app.zappiValidLogin
  		anchors {
			baseline: mainRectangle.top
			baselineOffset: 40
			horizontalCenter: mainRectangle.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: 35 
		}
		color: "red" 
		text: "Not a valid login provided!"
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
		id: sliderTitle
		anchors {
                        top: zappiModeEco.bottom
                        topMargin: 10
			horizontalCenter: mainRectangle.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: colors.tileTitleColor
		text: "Minimal green level"
	}

Item {
    id: slider; width: 400; height: 30
                anchors {
                        top: sliderTitle.bottom
                        topMargin: 10 
                        horizontalCenter: parent.horizontalCenter
                }
    // value is read/write.
    property real value: app.zappiMinGreenLevel
    onValueChanged: { handle.x = 2 + (value - minimum) * slider.xMax / (maximum - minimum); }
    property real maximum: 100
    property real minimum: 1
    property int xMax: slider.width - handle.width - 4

    Rectangle {
        anchors.fill: parent
        border.color: "white"; border.width: 0; radius: 8
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#66343434" }
            GradientStop { position: 1.0; color: "#66000000" }
        }
    }
    
    MouseArea {
	anchors.fill: parent
	onClicked: {
            var pos = Math.round(mouse.x / slider.width * (slider.maximum - slider.minimum) + slider.minimum)
            slider.value = pos
	    app.changeZappiMinGreenLevelDelayed(slider.value)
        }

    }

    Rectangle {
        id: handle; smooth: true
        x: slider.width / 2 - handle.width / 2; y: 2; width: 50; height: slider.height-4; radius: 6
        gradient: Gradient {
            GradientStop { position: 0.0; color: "lightgreen" }
            GradientStop { position: 1.0; color: "green" }
        }

	Text {
		id: sliderText
		text: slider.value
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter 
                font.family: qfont.regular.name
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
	}

        MouseArea {
            anchors.fill: parent; drag.target: parent
            drag.axis: Drag.XAxis; drag.minimumX: 2; drag.maximumX: slider.xMax+2
            onPositionChanged: { slider.value = Math.round((slider.maximum - slider.minimum) * (handle.x-2) / slider.xMax + slider.minimum ); app.changeZappiMinGreenLevelDelayed(slider.value) }
        }
    }
}

        Text {
                id: txtZappiGridImport
                text: "Grid: " + app.zappiGridImport + " Watt"
                color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
                anchors {
                        top: slider.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: isNxt ? 30 : 20 
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
                font.pixelSize: isNxt ? 30 : 20 
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
                font.pixelSize: isNxt ? 30 : 20 
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
                font.pixelSize: isNxt ? 30 : 20 
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
                font.pixelSize: isNxt ? 30 : 20 
                font.family: qfont.regular.name
        }


}
