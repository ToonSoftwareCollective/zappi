import QtQuick 2.1
import qb.components 1.0
Screen {
	id: zappiInfo
	screenTitleIconUrl: "qrc:/tsc/zappiicon.png"
	screenTitle: "myenergi Zappi EV charger - info"
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
	Text {
		id: txtZappiGridImport
		text: "Grid: " + app.zappiGridImport + " Watt"
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
                        baseline: mainRectangle.top
                        baselineOffset: 40
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
		id: txtZappiChargeFases
		text: "Charging on fases: " + app.zappiChargeFases
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
		id: txtZappiMode
		text: "Mode: " + app.zappiModeText[app.zappiMode]
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: txtZappiChargeFases.bottom
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
		id: txtZappiState
		text: "State: " + app.zappiStateText[app.zappiState]
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
	Text {
		id: txtZappiChargekWh
		text: "Charged: " + app.zappiChargedkWh + " kWh"
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: txtZappiState.bottom
			topMargin: 0
			horizontalCenter: parent.horizontalCenter
		}
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: isNxt ? 30 : 20
		font.family: qfont.regular.name
	}
	Text {
		id: txtZappiScreenLock
		text: "Screen locked: " + app.zappiScreenLocked
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: txtZappiChargekWh.bottom
			topMargin: 0
			horizontalCenter: parent.horizontalCenter
		}
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: isNxt ? 30 : 20
		font.family: qfont.regular.name
	}
	Text {
		id: txtZappiChargingAllowed
		text: "Charging allowed: " + app.zappiChargingAllowed
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: txtZappiScreenLock.bottom
			topMargin: 0
			horizontalCenter: parent.horizontalCenter
		}
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: isNxt ? 30 : 20
		font.family: qfont.regular.name
	}
}
