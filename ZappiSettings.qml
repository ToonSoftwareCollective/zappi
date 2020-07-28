import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0
Screen {
	id: zappiSettingsScreen
	hasBackButton: false
	hasHomeButton: false
	hasCancelButton: true
	property bool firstShown: true; // we need this because exiting a keyboard will load onShown again. Without this the input will be overwritten with the app settings again
	screenTitle: "Zappi configuration"
	onShown: {
		addCustomTopRightButton("Save");
		if (firstShown) { // only update the input boxes if this is the first time shown, not while coming back from a keyboard input
			firstShown = false;
		}
	}
	onCanceled: {
		firstShown = true; // if canceled we can overwrite the input boxes again with the app settings 
	}
	onCustomButtonClicked: {
		hide();
		var temp = app.settings; // updating app property variant is only possible in its whole, not by elements only, so we need this
		temp.hubSerial = serialNumberInput.inputText
		temp.hubPassword = passwordInput.inputText
		app.settings = temp;
		firstShown = true; // we have saved the settings so on a fresh settings screen we can load the input boxes with the new app settings
		// save the new app settings into the json file
		app.saveSettings()
	}
	EditTextLabel {
		id: serialNumberInput
		anchors {
			top: parent.top
			topMargin: 80
			left: parent.left
			leftMargin: isNxt ? 100 : 80
			right: parent.right
			rightMargin: isNxt ? 100 : 80
		}
		labelText: qsTr("MyEnergi hub serial")
		prefilledText: app.settings.hubSerial
		leftTextAvailableWidth: Math.max(serialNumberInput.leftTextImplicitWidth, passwordInput.leftTextImplicitWidth) + Math.round(30 * horizontalScaling)
		inputHints: Qt.ImhDigitsOnly
		validator: RegExpValidator {
				regExp: /.+/
			} // not empty
		maxLength: 32
	}
	EditTextLabel {
		id: passwordInput
		anchors {
			top: serialNumberInput.bottom
			topMargin: 10
			left: parent.left
			leftMargin: isNxt ? 100 : 80
			right: parent.right
			rightMargin: isNxt ? 100 : 80
		}
		labelText: qsTr("MyEnergi hub password")
		prefilledText: app.settings.hubPassword
		leftTextAvailableWidth: Math.max(serialNumberInput.leftTextImplicitWidth, passwordInput.leftTextImplicitWidth) + Math.round(30 * horizontalScaling)
		isPassword: true
		inputHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
		maxLength: 64
	}
}