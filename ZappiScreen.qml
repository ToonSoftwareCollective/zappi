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
		anchors.top: mainRectangle.top
		anchors.right: mainRectangle.right
		anchors.rightMargin: 10
		anchors.topMargin: 10
		onClicked: {
			if (app.zappiSettings) {
				app.zappiSettings.show();
			}
		}
	}
	StandardButton {
		id: btnInfoScreen
		width: 150
		text: "Info"
		anchors.top: mainRectangle.top
		anchors.left: mainRectangle.left
		anchors.leftMargin: 10
		anchors.topMargin: 10
		onClicked: {
			if (app.zappiInfo) {
				app.zappiInfo.show();
			}
		}
	}
	Text {
		id: zappiBadLogin
		visible: !app.zappiValidLogin
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
		anchors.top: zappiModeTitle.bottom
		anchors.topMargin: 10
		anchors.right: mainRectangle.horizontalCenter
		onClicked: {
			app.changeZappiMode(2)
		}
	}
	StandardButton {
		id: zappiModeFast
		width: 150
		text: "Fast"
		primary: app.zappiMode === 1 ? true : false
		anchors.top: zappiModeTitle.bottom
		anchors.topMargin: 10
		anchors.right: zappiModeEco.left
		anchors.rightMargin: 10
		onClicked: {
			app.changeZappiMode(1)
		}
	}
	StandardButton {
		id: zappiModeEcoPlus
		width: 150
		text: "Eco+"
		primary: app.zappiMode === 3 ? true : false
		anchors.top: zappiModeTitle.bottom
		anchors.topMargin: 10
		anchors.left: zappiModeEco.right
		anchors.leftMargin: 10
		onClicked: {
			app.changeZappiMode(3)
		}
	}
	StandardButton {
		id: zappiModeStop
		width: 150
		text: "Stop"
		primary: app.zappiMode === 4 ? true : false
		anchors.top: zappiModeTitle.bottom
		anchors.topMargin: 10
		anchors.left: zappiModeEcoPlus.right
		anchors.leftMargin: 10
		onClicked: {
			app.changeZappiMode(4)
		}
	}
	Text {
		id: sliderMglTitle
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
		id: sliderMgl;width: 400;height: 30
		anchors {
			top: sliderMglTitle.bottom
			topMargin: 10
			horizontalCenter: parent.horizontalCenter
		}
		// value is read/write.
		property real value: app.zappiMinGreenLevel
		onValueChanged: {
			handleMgl.x = 2 + (value - minimum) * sliderMgl.xMax / (maximum - minimum);
		}
		property real maximum: 100
		property real minimum: 1
		property int xMax: sliderMgl.width - handleMgl.width - 4
		Rectangle {
			anchors.fill: parent
			border.color: "white";
			border.width: 0;
			radius: 8
			gradient: Gradient {
				GradientStop {
					position: 0.0;color: "#66343434"
				}
				GradientStop {
					position: 1.0;color: "#66000000"
				}
			}
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				var pos = Math.round(mouse.x / sliderMgl.width * (sliderMgl.maximum - sliderMgl.minimum) + sliderMgl.minimum)
				sliderMgl.value = pos
				app.changeZappiMinGreenLevelDelayed(sliderMgl.value)
			}
		}
		Rectangle {
			id: handleMgl;smooth: true
			x: sliderMgl.width / 2 - handleMgl.width / 2;y: 2;width: 50;height: sliderMgl.height - 4;radius: 6
			gradient: Gradient {
				GradientStop {
					position: 0.0;color: "lightgreen"
				}
				GradientStop {
					position: 1.0;color: "green"
				}
			}
			Text {
				id: sliderMglText
				text: sliderMgl.value
				font.pixelSize: 20
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				font.family: qfont.regular.name
				color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
			}
			MouseArea {
				anchors.fill: parent;
				drag.target: parent
				drag.axis: Drag.XAxis;
				drag.minimumX: 2;
				drag.maximumX: sliderMgl.xMax + 2
				onPositionChanged: {
					sliderMgl.value = Math.round((sliderMgl.maximum - sliderMgl.minimum) * (handleMgl.x - 2) / sliderMgl.xMax + sliderMgl.minimum)
					app.changeZappiMinGreenLevelDelayed(sliderMgl.value)
				}
			}
		}
	}
	Text {
		id: sliderBoostTitle
		anchors {
			top: sliderMgl.bottom
			topMargin: 10
			horizontalCenter: mainRectangle.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: colors.tileTitleColor
		text: "Boost kWh"
	}
	Item {
		id: sliderBoost;width: 400;height: 30
		visible: (app.zappiState !== 1 && (app.zappiMode === 2 || app.zappiMode === 3)) //only allow boost when connected and in eco or eco+ mode
		anchors {
			top: sliderBoostTitle.bottom
			topMargin: 10
			horizontalCenter: parent.horizontalCenter
		}
		// value is read/write.
		property real value: app.zappiBoostkWh
		onValueChanged: {
			handleBoost.x = 2 + (value - minimum) * sliderBoost.xMax / (maximum - minimum);
		}
		property real maximum: 100
		property real minimum: 1
		property int xMax: sliderBoost.width - handleBoost.width - 4
		Rectangle {
			anchors.fill: parent
			border.color: "white";
			border.width: 0;
			radius: 8
			gradient: Gradient {
				GradientStop {
					position: 0.0;color: "#66343434"
				}
				GradientStop {
					position: 1.0;color: "#66000000"
				}
			}
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				var pos = Math.round(mouse.x / sliderBoost.width * (sliderBoost.maximum - sliderBoost.minimum) + sliderBoost.minimum)
				sliderBoost.value = pos
				//app.changeZappiMinGreenLevelDelayed(sliderBoost.value)
			}
		}
		Rectangle {
			id: handleBoost;smooth: true
			x: sliderBoost.width / 2 - handleBoost.width / 2;y: 2;width: 50;height: sliderBoost.height - 4;radius: 6
			gradient: Gradient {
				GradientStop {
					position: 0.0;color: "lightgreen"
				}
				GradientStop {
					position: 1.0;color: "green"
				}
			}
			Text {
				id: sliderBoostText
				text: sliderBoost.value
				font.pixelSize: 20
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				font.family: qfont.regular.name
				color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
			}
			MouseArea {
				anchors.fill: parent;
				drag.target: parent
				drag.axis: Drag.XAxis;
				drag.minimumX: 2;
				drag.maximumX: sliderBoost.xMax + 2
				onPositionChanged: {
					sliderBoost.value = Math.round((sliderBoost.maximum - sliderBoost.minimum) * (handleBoost.x - 2) / sliderBoost.xMax + sliderBoost.minimum)
					//app.changeZappiMinGreenLevelDelayed(slider.value)
				}
			}
		}
	}
        StandardButton {
                id: zappiBoostNow
                width: 250
		visible: (app.zappiState !== 1 && (app.zappiMode === 2 || app.zappiMode === 3)) //only allow boost when connected and in eco or eco+ mode
                text: app.zappiBoostMode ? "Boosting" : "Boost now"
                primary: app.zappiBoostMode
                anchors.verticalCenter: sliderBoost.verticalCenter
                anchors.right: sliderBoost.left 
                anchors.rightMargin: 10 
                onClicked: {
                        //app.changeZappiMode(2)
                }
        }
	Text {
		id: sliderSmartBoostTitle
		anchors {
			top: sliderBoost.bottom
			topMargin: 10
			horizontalCenter: mainRectangle.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: colors.tileTitleColor
		text: "Smart Boost kWh"
	}
	Item {
		id: sliderSmartBoost;width: 400;height: 30
		visible: (app.zappiState !== 1 && (app.zappiMode === 2 || app.zappiMode === 3)) //only allow boost when connected and in eco or eco+ mode
		anchors {
			top: sliderSmartBoostTitle.bottom
			topMargin: 10
			horizontalCenter: parent.horizontalCenter
		}
		// value is read/write.
		property real value: app.zappiSmartBoostkWh
		onValueChanged: {
			handleSmartBoost.x = 2 + (value - minimum) * sliderSmartBoost.xMax / (maximum - minimum);
		}
		property real maximum: 100
		property real minimum: 1
		property int xMax: sliderSmartBoost.width - handleSmartBoost.width - 4
		Rectangle {
			anchors.fill: parent
			border.color: "white";
			border.width: 0;
			radius: 8
			gradient: Gradient {
				GradientStop {
					position: 0.0;color: "#66343434"
				}
				GradientStop {
					position: 1.0;color: "#66000000"
				}
			}
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
				var pos = Math.round(mouse.x / sliderSmartBoost.width * (sliderSmartBoost.maximum - sliderSmartBoost.minimum) + sliderSmartBoost.minimum)
				sliderSmartBoost.value = pos
				//app.changeZappiMinGreenLevelDelayed(sliderSmartBoost.value)
			}
		}
		Rectangle {
			id: handleSmartBoost;smooth: true
			x: sliderSmartBoost.width / 2 - handleSmartBoost.width / 2;y: 2;width: 50;height: sliderSmartBoost.height - 4;radius: 6
			gradient: Gradient {
				GradientStop {
					position: 0.0;color: "lightgreen"
				}
				GradientStop {
					position: 1.0;color: "green"
				}
			}
			Text {
				id: sliderSmartBoostText
				text: sliderSmartBoost.value
				font.pixelSize: 20
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				font.family: qfont.regular.name
				color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
			}
			MouseArea {
				anchors.fill: parent;
				drag.target: parent
				drag.axis: Drag.XAxis;
				drag.minimumX: 2;
				drag.maximumX: sliderSmartBoost.xMax + 2
				onPositionChanged: {
					sliderSmartBoost.value = Math.round((sliderSmartBoost.maximum - sliderSmartBoost.minimum) * (handleSmartBoost.x - 2) / sliderSmartBoost.xMax + sliderSmartBoost.minimum)
					//app.changeZappiMinGreenLevelDelayed(slider.value)
				}
			}
		}
	}
        StandardButton {
                id: zappiSmartBoostNow
                width: 250
		visible: (app.zappiState !== 1 && (app.zappiMode === 2 || app.zappiMode === 3)) //only allow boost when connected and in eco or eco+ mode
                text: app.zappiSmartBoostMode ? "Smart boosting" : "Smart boost now"
                primary: app.zappiSmartBoostMode
                anchors.verticalCenter: sliderSmartBoost.verticalCenter
                anchors.right: sliderSmartBoost.left 
                anchors.rightMargin: 10 
                onClicked: {
                        //app.changeZappiMode(2)
                }
        }
        NumberSpinner {
                id: nsHour
                anchors {
			verticalCenter : sliderSmartBoost.verticalCenter
                        left: sliderSmartBoost.right
                        leftMargin: 10 
                }
                rangeMin: 0
                rangeMax: 23
                increment: 1
                value: 0
                wrapAtMaximum: true
                wrapAtMinimum: true
		implicitWidth: Math.round(90 * horizontalScaling)
		implicitHeight: Math.round(40 * verticalScaling)
		buttonWidth: Math.round(25 * horizontalScaling)
                function valueToText(value) { return value < 10 ? "0" + value : value; }

                //onValueChanged: p.timeChanged();
        }
        NumberSpinner {
                id: nsMinute
		anchors {
			verticalCenter : sliderSmartBoost.verticalCenter
                        left: nsHour.right
                        leftMargin: 10 
                }
                rangeMin: 0
                rangeMax: 45
                increment: 15
                value: 0
                wrapAtMaximum: true
                wrapAtMinimum: true
		implicitWidth: Math.round(90 * horizontalScaling)
		implicitHeight: Math.round(40 * verticalScaling)
		buttonWidth: Math.round(25 * horizontalScaling)
                function valueToText(value) { return value < 10 ? "0" + value : value; }

                //onValueChanged: p.timeChanged();
        }
        Text {
                id: colon
                anchors {
                        left: nsHour.right
                        right: nsMinute.left
                        verticalCenter: nsHour.verticalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                text: ":"

                font.family: qfont.regular.name
                font.pixelSize: qfont.spinnerText
                color: colors.numberSpinnerNumber
        }
        Text {
                id: smartBoostTimeText 
                anchors {
                        verticalCenter: sliderSmartBoostTitle.verticalCenter 
                        horizontalCenter: colon.horizontalCenter
                }
                font {
                        family: qfont.regular.name
                        pixelSize: qfont.tileTitle
                }
                color: colors.tileTitleColor
                text: "Smart boost ready before"
        }
}
