import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

App {
	id: root
	// These are the URL's for the QML resources from which our widgets will be instantiated.
	// By making them a URL type property they will automatically be converted to full paths,
	// preventing problems when passing them around to code that comes from a different path.
	//property url trayUrl : "SpotenergyTray.qml";
	property url tileUrl : "ZappiTile.qml";
	property url thumbnailIcon: "qrc:/tsc/zappiicon.png"
	property url zappiScreenUrl : "ZappiScreen.qml"
	property url zappiSettingsUrl : "ZappiSettings.qml"
        property ZappiSettings zappiSettings


	property variant settings: { 
		"hubSerial" : "", 
		"hubPassword" : "", 
	}
	property int zappiIndex
	property int zappiDevices
	property int zappiDeviceFases
	property int zappiSerial
	property int zappiGridImport
	property int zappiCharging
	property int zappiMode
	property variant zappiModeText: ["Unknown", "Fast","Eco","Eco+"]
	property int zappiStatus
	property variant zappiStatusText: ["Unknown(0)", "Paused","Unknown(2)","Charging","Unknown(3)","Completed"]
	property string zappiState
	property variant zappiStateText: { 
		"A" : "Disconnected", 
		"B1" : "Waiting for surplus", 
		"B2" : "Ready to charge",
		"C1" : "Stopping charge", 
		"C2" : "Charging active", 
		"D" : "Request ventilation", 
		"D1" : "Stopping charge - ventilation", 
		"D2" : "Charging active - ventilation", 
	}
	property int zappiChargedkWh
	property int zappiMinGreenLevel
	property bool zappiValidLogin: false

	function init() {
		registry.registerWidget("screen", zappiScreenUrl, this);
		registry.registerWidget("screen", zappiSettingsUrl, this, "zappiSettings");
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: "Zappi", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
	}

	Component.onCompleted: {
		// load the settings on completed is recommended instead of during init
		loadSettings() 
		collectData.start()
	}

	function loadSettings()  {
		var settingsFile = new XMLHttpRequest();
		settingsFile.onreadystatechange = function() {
			if (settingsFile.readyState == XMLHttpRequest.DONE) {
				if (settingsFile.responseText.length > 0)  {
					var temp = JSON.parse(settingsFile.responseText);
					for (var setting in settings) {
						if (temp[setting] === undefined )  { temp[setting] = settings[setting]; } // use default if no saved setting exists
					}
					settings = temp;
				}
			}
		}
		settingsFile.open("GET", "file:///mnt/data/tsc/zappi.userSettings.json", true);
		settingsFile.send();
	}

	function saveSettings() {
                // save the new app settings into the json file
                var saveFile = new XMLHttpRequest();
                saveFile.open("PUT", "file:///mnt/data/tsc/zappi.userSettings.json");
                saveFile.send(JSON.stringify(settings));
		// restart the timer to try to login with new settings
		collectData.restart()
	}

	function changeZappiMode(newZappiMode) {
		// here a call to url to change zappi mode
		zappiMode = newZappiMode
		if (settings["hubSerial"].length > 0) {
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
			var url =  "https://s" + serialLastDigit + ".myenergi.net/cgi-zappi-mode-Z" + zappiSerial + "-" + zappiMode + "-0-0-0000"
			//console.log("Zappi set mode url: " + url)
	        	var xmlhttp = new XMLHttpRequest()
	        	xmlhttp.open("GET", url, true, settings["hubSerial"],settings["hubPassword"])
			xmlhttp.setRequestHeader("Authorization","Digest realm=\"MyEnergi Telemetry\"");
	        	xmlhttp.onreadystatechange = function() {
	        		if (xmlhttp.readyState == XMLHttpRequest.DONE) {
	        	        	//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
				}
			}
	        	xmlhttp.send()
		}
	}

	function changeZappiMinGreenLevelDelayed(newZappiMinGreenLevel) {
		// delay command to zappi api because slider will call this routine while changing very often 
		zappiMinGreenLevel = newZappiMinGreenLevel 
		delayTimer.restart();
	}

	function changeZappiMinGreenLevel(newZappiMinGreenLevel) {
		// here a call to url to change zappi mgl
		zappiMinGreenLevel = newZappiMinGreenLevel 
		if (settings["hubSerial"].length > 0) {
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
			var url =  "https://s" + serialLastDigit + ".myenergi.net/cgi-set-min-green-Z" + zappiSerial + "-" + zappiMinGreenLevel
			//console.log("Zappi set mode url: " + url)
	        	var xmlhttp = new XMLHttpRequest()
	        	xmlhttp.open("GET", url, true, settings["hubSerial"],settings["hubPassword"])
			xmlhttp.setRequestHeader("Authorization","Digest realm=\"MyEnergi Telemetry\"");
	        	xmlhttp.onreadystatechange = function() {
	        		if (xmlhttp.readyState == XMLHttpRequest.DONE) {
	        	        	//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
				}
			}
	        	xmlhttp.send()
		}
	}

	function collectZappiData() {
		//console.log("Zappi collecting data");
		if (settings["hubSerial"].length > 0) {
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
	        	var xmlhttp = new XMLHttpRequest();
	        	xmlhttp.open("GET", "https://s" + serialLastDigit + ".myenergi.net/cgi-jstatus-*", true, settings["hubSerial"],settings["hubPassword"]);
			xmlhttp.setRequestHeader("Authorization","Digest realm=\"MyEnergi Telemetry\"");
	        	xmlhttp.onreadystatechange = function() {
	        		if (xmlhttp.readyState == XMLHttpRequest.DONE) {
	        	        	//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
					if (xmlhttp.status !== 200) {
						collectData.interval = collectData.interval * 2  //this will slowly increase to make sure we don't flood the server with bad logins
						if (collectData.interval > 3600000) { collectData.interval = 3600000 } //max at 1 hour interval
						zappiValidLogin = false
						return
					}
					// we have a valid login, set a faster timer if not already set 
					zappiValidLogin = true
					collectData.interval = 60000 //collect once a minute
					writeZappiDataToFile(xmlhttp.responseText)
					var jsonResult = JSON.parse(xmlhttp.responseText)
					for (var i = 0;i < jsonResult.length; i++) {
						//look for the zappi devices first
						if ( jsonResult[i].zappi !== undefined) {
							zappiIndex = i
							zappiDevices = jsonResult[zappiIndex].zappi.length //currently only one zappi is supported
							zappiDeviceFases = 1
							if ( jsonResult[zappiIndex].zappi[zappiDevices-1].ectt3 !== undefined) {
								zappiDeviceFases = 3
								//console.log("This Zappi has 3 fases!")
							}
							zappiCharging = 0
							if ( jsonResult[zappiIndex].zappi[zappiDevices-1].div !== undefined) {
								zappiCharging = jsonResult[zappiIndex].zappi[zappiDevices-1].div
							}
							//console.log("Zappi charging: " + zappiCharging)
							zappiSerial = jsonResult[zappiIndex].zappi[zappiDevices-1].sno
							//console.log("Zappi serial: " + zappiSerial)
							zappiGridImport = jsonResult[zappiIndex].zappi[zappiDevices-1].grd
							//console.log("Zappi grid import: " + zappiGridImport)
 							zappiMode = jsonResult[zappiIndex].zappi[zappiDevices-1].zmo
							//console.log("Zappi mode: " + zappiMode)
							zappiStatus = jsonResult[zappiIndex].zappi[zappiDevices-1].sta 
							//console.log("Zappi status: " + zappiStatus)
							zappiState = jsonResult[zappiIndex].zappi[zappiDevices-1].pst
							//console.log("Zappi state: " + zappiState)
							zappiChargedkWh = jsonResult[zappiIndex].zappi[zappiDevices-1].che
							//console.log("Zappi charged kwh: " + zappiChargedkWh)
							zappiMinGreenLevel = jsonResult[zappiIndex].zappi[zappiDevices-1].mgl
  							//console.log("Zappi min green level: " + zappiMinGreenLevel)
							//test zappiCharging = Math.round((Math.random() * 8000)) //test
							//test zappiChargedkWh = 15 //test
						}
					}
				}
			}
	        	xmlhttp.send();
		}
	}

	function writeZappiDataToFile(data) {
		var saveFile = new XMLHttpRequest();
                saveFile.open("PUT", "file:///qmf/www/tsc/zappi.json");
                saveFile.send(data);
	}


	Timer {
		id: collectData
		interval: 300000 //this is the start interval. interval is changes with valid login or increases when bad logins are detected
		triggeredOnStart: true
	 	running: false
		repeat: true
		onTriggered: {
			// update interval to only update at the start of the next hour
			collectZappiData();
		}
	}
	Timer {
		id: delayTimer
		interval: 2000
		triggeredOnStart: false
		running: false
		repeat: false
		onTriggered: {
			changeZappiMinGreenLevel(zappiMinGreenLevel);
		}
	}

}
