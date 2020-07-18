import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;


Tile {
	id: zappiTile

        QtObject {
                id: p
		property int numFrames: 10 
		property int currentFrame: -1 

		function update() {
			if ( (isNaN(app.zappiCharging)) || (app.zappiCharging === 0) ) {
				animationTimer.stop()
				p.currentFrame = -1
			} else {
				animationTimer.interval = 100 
				if (app.zappiCharging < 6000) {
					animationTimer.interval = 200 
				}
				if (app.zappiCharging < 4000) {
					animationTimer.interval = 400 
				}
				if (app.zappiCharging < 2000) {
					animationTimer.interval = 800 
				}
				animationTimer.restart();
			}
		}
	}


	// Will be called when widget instantiated
	function init() {
                app.zappiChargingChanged.connect(p.update);
        }

        Component.onDestruction: app.zappiChargingChanged.disconnect(p.update);


        onClicked: {
                stage.openFullscreen(app.zappiScreenUrl)
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

        Image {
                id: zappiIcon
		scale: isNxt ? 0.3 : 0.2
                anchors.centerIn: parent
                source: "qrc:/tsc/car-charge-"+(p.currentFrame+1) + (dimState ? "-dim" : "" ) + ".svg"
        }

        Text {
                id: txtZappiMode
                text: app.zappiModeText[app.zappiMode]
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        bottom: parent.bottom 
                        bottomMargin: 10
                        horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.family: qfont.regular.name
        }

        Text {
                id: txtCharging
                text: Math.round(app.zappiCharging / 100) / 10 + "kW"
		visible: animationTimer.running 
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        bottom: parent.bottom 
                        bottomMargin: 40
                        left: parent.left
			leftMargin: 10
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 25 
                font.family: qfont.regular.name
        }

        Text {
                id: txtChargedkWh
                text: app.zappiChargedkWh + "kWh"
		visible: animationTimer.running 
               	color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor 
                anchors {
                        bottom: parent.bottom 
                        bottomMargin: 40
                        right: parent.right
  			rightMargin: 10
                }
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 25 
                font.family: qfont.regular.name
        }

        Timer {
                id: animationTimer
                interval: 1000
                repeat: true
                onTriggered: (p.currentFrame = ((p.currentFrame + 1) % p.numFrames))
        }
}
