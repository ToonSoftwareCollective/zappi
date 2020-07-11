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
	property url thumbnailIcon: "http:////localhost/rsc/ZappiIcon.png"
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
	property variant zappiStatusText: ["Unknown", "Paused","Charging","Completed"]
	property int zappiChargedkWh
	property int zappiMinGreenLevel

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
		collectData.restart()
	}

	function changeZappiMode(newZappiMode) {
		// here a call to url to change zappi mode
		zappiMode = newZappiMode
		if (settings["hubSerial"].length > 0) {
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
			var url =  "https://s" + serialLastDigit + ".myenergi.net/cgi-zappi-mode-Z" + zappiSerial + "-" + zappiMode + "-0-0-0000"
			console.log("Zappi set mode url: " + url)
	        	var xmlhttp = new XMLHttpRequest()
	        	xmlhttp.open("GET", url, true, settings["hubSerial"],settings["hubPassword"])
			xmlhttp.setRequestHeader("Authorization","Digest realm=\"MyEnergi Telemetry\"");
	        	xmlhttp.onreadystatechange = function() {
	        		if (xmlhttp.readyState == XMLHttpRequest.DONE) {
	        	        	console.log("********* Zappi http status: " + xmlhttp.status)
					console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					console.log("********* Zappi data received: " + xmlhttp.responseText)
				}
			}
	        	xmlhttp.send()
		}
	}

	function changeZappiMinGreenLevel(newZappiMinGreenLevel) {
		// here a call to url to change zappi mode
		zappiMinGreenLevel = newZappiMinGreenLevel 
		// need some delay in here
		if (settings["hubSerial"].length > 0) {
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
			var url =  "https://s" + serialLastDigit + ".myenergi.net/cgi-set-min-green-Z" + zappiSerial + "-" + zappiMinGreenLevel
			console.log("Zappi set mode url: " + url)
	        	var xmlhttp = new XMLHttpRequest()
	        	xmlhttp.open("GET", url, true, settings["hubSerial"],settings["hubPassword"])
			xmlhttp.setRequestHeader("Authorization","Digest realm=\"MyEnergi Telemetry\"");
	        	xmlhttp.onreadystatechange = function() {
	        		if (xmlhttp.readyState == XMLHttpRequest.DONE) {
	        	        	console.log("********* Zappi http status: " + xmlhttp.status)
					console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					console.log("********* Zappi data received: " + xmlhttp.responseText)
				}
			}
	        	xmlhttp.send()
		}
	}

	function collectZappiData() {
		if (settings["hubSerial"].length > 0) {
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
	        	var xmlhttp = new XMLHttpRequest();
	        	xmlhttp.open("GET", "https://s" + serialLastDigit + ".myenergi.net/cgi-jstatus-*", true, settings["hubSerial"],settings["hubPassword"]);
			xmlhttp.setRequestHeader("Authorization","Digest realm=\"MyEnergi Telemetry\"");
	        	xmlhttp.onreadystatechange = function() {
	        		if (xmlhttp.readyState == XMLHttpRequest.DONE) {
	        	        	console.log("********* Zappi http status: " + xmlhttp.status)
					console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					console.log("********* Zappi data received: " + xmlhttp.responseText)
					var jsonResult = JSON.parse(xmlhttp.responseText)
					for (var i = 0;i < jsonResult.length; i++) {
						//look for the zappi devices first
						if ( jsonResult[i].zappi !== undefined) {
							zappiIndex = i
							zappiDevices = jsonResult[zappiIndex].zappi.length //currently only one zappi is supported
							zappiDeviceFases = 1
							if ( jsonResult[zappiIndex].zappi[zappiDevices-1].ectt3 !== undefined) {
								zappiDeviceFases = 3
								console.log("This Zappi has 3 fases!")
							}
							if ( jsonResult[zappiIndex].zappi[zappiDevices-1].div !== undefined) {
								zappiCharging = jsonResult[zappiIndex].zappi[zappiDevices-1].div
							}
							console.log("Zappi charging: " + zappiCharging)
							zappiSerial = jsonResult[zappiIndex].zappi[zappiDevices-1].sno
							console.log("Zappi serial: " + zappiSerial)
							zappiGridImport = jsonResult[zappiIndex].zappi[zappiDevices-1].grd
							//test zappiCharging = Math.abs(zappiGridImport) //test
							console.log("Zappi grid import: " + zappiGridImport)
 							zappiMode = jsonResult[zappiIndex].zappi[zappiDevices-1].zmo
							console.log("Zappi mode: " + zappiMode)
							zappiStatus = jsonResult[zappiIndex].zappi[zappiDevices-1].sta 
							console.log("Zappi status: " + zappiStatus)
							zappiChargedkWh = jsonResult[zappiIndex].zappi[zappiDevices-1].che
							console.log("Zappi charged kwh: " + zappiChargedkWh)
							zappiMinGreenLevel = jsonResult[zappiIndex].zappi[zappiDevices-1].mgl
  							console.log("Zappi min green level: " + zappiMinGreenLevel)
						}
					}
				}
			}
	        	xmlhttp.send();
		}
	}


	Timer {
		id: collectData
		interval: 300000
		triggeredOnStart: true
		running: false
		repeat: true
		onTriggered: {
			// update interval to only update at the start of the next hour
			collectZappiData();
		}
	}

}
