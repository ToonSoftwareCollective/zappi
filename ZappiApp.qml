import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
App {
	id: root
		// These are the URL's for the QML resources from which our widgets will be instantiated.
		// By making them a URL type property they will automatically be converted to full paths,
		// preventing problems when passing them around to code that comes from a different path.
		//property url trayUrl : "SpotenergyTray.qml";
	property url tileUrl: "ZappiTile.qml";
	property url thumbnailIcon: "qrc:/tsc/zappiicon.png"
	property url zappiScreenUrl: "ZappiScreen.qml"
	property url zappiInfoUrl: "ZappiInfo.qml"
	property url zappiSettingsUrl: "ZappiSettings.qml"
	property ZappiSettings zappiSettings
	property ZappiInfo zappiInfo
	property variant settings: {
		"hubSerial": "",
		"hubPassword": "",
	}
	property variant zappiASN: ""
	property int zappiASNRedirects: 0
	property int zappiIndex
	property int zappiDevices
	property int zappiDeviceFases: 1
	property int zappiChargeFases: 1
	property int zappiSerial
	property int zappiGridImport
	property int zappiCharging
	property int zappiMode
	property variant zappiModeText: ["Unknown", "Fast", "Eco", "Eco+", "Stop"]
	property int zappiStatus
	property variant zappiStatusText: ["Starting", "Paused", "DSR", "Charging", "Boosting", "Completed"]
	property string zappiState
	property variant zappiStateText: {
		"A": "Disconnected",
		"B1": "Not charging",
		"B2": "Ready to charge",
		"C1": "Stopping charge",
		"C2": "Charging active",
		"D": "Request ventilation",
		"D1": "Stopping charge - ventilation",
		"D2": "Charging active - ventilation",
		"F": "Fault/Restart",
	}
	property int zappiChargedkWh
	property int zappiMinGreenLevel
	property int zappiBoostkWh: 5
	property bool zappiBoostMode: false
	property int zappiSmartBoostkWh: 5
	property bool zappiSmartBoostMode: false
	property int zappiSmartBoostHour
	property int zappiSmartBoostMinute
	property bool zappiValidLogin: false
	property int  zappiLck: 0
	property bool zappiScreenLocked: false
	property bool zappiScreenLockConnected: false
	property bool zappiScreenLockDisconnected: false
	property bool zappiAllowChargeWhileScreenLock: false
	property bool zappiChargingAllowed: false
	function init() {
		registry.registerWidget("screen", zappiScreenUrl, this);
		registry.registerWidget("screen", zappiInfoUrl, this, "zappiInfo");
		registry.registerWidget("screen", zappiSettingsUrl, this, "zappiSettings");
		registry.registerWidget("tile", tileUrl, this, null, {
			thumbLabel: "Zappi",
			thumbIcon: thumbnailIcon,
			thumbCategory: "general",
			thumbWeight: 30,
			baseTileWeight: 10,
			baseTileSolarWeight: 10,
			thumbIconVAlignment: "center"
		});
	}
	Component.onCompleted: {
		// load the settings on completed is recommended instead of during init
		loadSettings()
		collectData.start()
	}

	function loadSettings() {
		var settingsFile = new XMLHttpRequest();
		settingsFile.onreadystatechange = function() {
			if (settingsFile.readyState == XMLHttpRequest.DONE) {
				if (settingsFile.responseText.length > 0) {
					var temp = JSON.parse(settingsFile.responseText);
					for (var setting in settings) {
						if (temp[setting] === undefined) {
							temp[setting] = settings[setting];
						} // use default if no saved setting exists
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

	function setZappiBoostMode(newBoostkWh) {
		// here a call to url to change zappi mode
		zappiBoostMode = !zappiBoostMode
		zappiBoostkWh = newBoostkWh 
		if (zappiASN !== "") {
			var url = "https://" + zappiASN + "/cgi-zappi-mode-Z" + zappiSerial + "-0-10-" + zappiBoostkWh + "-0000"	
			if (!zappiBoostMode) {
				zappiBoostkWh = 0
				url = "https://" + zappiASN + "/cgi-zappi-mode-Z" + zappiSerial + "-0-2-0-0000"	
			}
			//console.log("Zappi set mode url: " + url)
			var xmlhttp = new XMLHttpRequest()
			xmlhttp.open("GET", url, true, settings["hubSerial"], settings["hubPassword"])
			xmlhttp.onreadystatechange = function() {
				if (xmlhttp.readyState == XMLHttpRequest.DONE) {
					//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
					collectData.interval = 30000 //set next interval to 30 secs for the set request to fullfill
				}
			}
			xmlhttp.send()
		}
	}

	function padNumber(num, len) {
        	var result = String(num)
         	len = len - result.length
		for (var i = 0; i < len; i++) {
                	result = "0" + result
            	}
            	return result 
        }

	function setZappiSmartBoostMode(newSmartBoostkWh, setHour, setMinute) {
		// here a call to url to change zappi mode
		zappiSmartBoostMode = !zappiSmartBoostMode
		zappiSmartBoostkWh = newSmartBoostkWh 
		if (zappiASN !== "") {
			var url = "https://" + zappiASN + "/cgi-zappi-mode-Z" + zappiSerial + "-0-11-" + zappiSmartBoostkWh + "-" + padNumber(setHour,2) + padNumber(setMinute,2) 
			if (!zappiSmartBoostMode) {
				zappiSmartBoostkWh = 0
				url = "https://" + zappiASN + "/cgi-zappi-mode-Z" + zappiSerial + "-0-2-0-0000"	
			}
			//console.log("Zappi set mode url: " + url)
			var xmlhttp = new XMLHttpRequest()
			xmlhttp.open("GET", url, true, settings["hubSerial"], settings["hubPassword"])
			xmlhttp.onreadystatechange = function() {
				if (xmlhttp.readyState == XMLHttpRequest.DONE) {
					//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
					collectData.interval = 30000 //set next interval to 30 secs for the set request to fullfill
				}
			}
			xmlhttp.send()
		}
	}

	function changeZappiMode(newZappiMode) {
		// here a call to url to change zappi mode
		zappiMode = newZappiMode
		if (zappiASN !== "") {
			var url = "https://" + zappiASN + "/cgi-zappi-mode-Z" + zappiSerial + "-" + zappiMode + "-0-0-0000"	
			//console.log("Zappi set mode url: " + url)
			var xmlhttp = new XMLHttpRequest()
			xmlhttp.open("GET", url, true, settings["hubSerial"], settings["hubPassword"])
			xmlhttp.onreadystatechange = function() {
				if (xmlhttp.readyState == XMLHttpRequest.DONE) {
					//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
					collectData.interval = 30000 //set next interval to 30 secs for the set request to fullfill
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
		if (zappiASN !== "") {
			var url = "https://" + zappiASN + "/cgi-set-min-green-Z" + zappiSerial + "-" + zappiMinGreenLevel
			//console.log("Zappi set mode url: " + url)
			var xmlhttp = new XMLHttpRequest()
			xmlhttp.open("GET", url, true, settings["hubSerial"], settings["hubPassword"])
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
		if (zappiASN !== "") {
			var xmlhttp = new XMLHttpRequest();
			//console.log("Zappi ASN url: https://" + zappiASN + "/cgi-jstatus-*");
			xmlhttp.open("GET", "https://" + zappiASN + "/cgi-jstatus-*", true, settings["hubSerial"], settings["hubPassword"])
			xmlhttp.onreadystatechange = function() {
				if (xmlhttp.readyState == XMLHttpRequest.DONE) {
					//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi ASN header received: " + xmlhttp.getResponseHeader("x_myenergi-asn"))
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
					if ((xmlhttp.getResponseHeader("x_myenergi-asn") !== undefined) && (xmlhttp.getResponseHeader("x_myenergi-asn") !== "") ) {
						var nowASN =  xmlhttp.getResponseHeader("x_myenergi-asn") 
						if (zappiASN !== nowASN) {
							console.log("Zappi ASN info from header got changed to: " + nowASN);
							zappiASNRedirects++
							zappiASN = nowASN
						} else {
							zappiASNRedirects = 0;
						}
					}
					if (zappiASNRedirects > 3) {
						// the server is redirecting us 3 times in a row to another server. act like login is failing and try again 1 hour later
						//console.log("********* Zappi too many ASN redirects: " + zappiASNRedirects)
						zappiValidLogin = false
						collectData.interval = 3600000
						return
					}
					if (xmlhttp.status !== 200) {
						collectData.interval = collectData.interval * 2 //this will slowly increase to make sure we don't flood the server with bad logins
						if (collectData.interval > 3600000) {
							collectData.interval = 3600000
							zappiASN = ""; // reset ASN so we check old method again on next attempt
						} //max at 1 hour interval
						zappiValidLogin = false
						//console.log("********* Zappi http status: " + xmlhttp.status)
						//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
						//console.log("********* Zappi data received: " + xmlhttp.responseText)
						return
					}
					// we have a valid login, set a faster timer if not already set 
					zappiValidLogin = true
					collectData.interval = 30000 //collect every 30 sec normally
					writeZappiDataToFile(xmlhttp.responseText)
					var jsonResult = JSON.parse(xmlhttp.responseText)
					for (var i = 0; i < jsonResult.length; i++) {
						//look for the zappi devices first
						if (jsonResult[i].zappi !== undefined) {
							zappiIndex = i
							zappiDevices = jsonResult[zappiIndex].zappi.length //currently only one zappi is supported
							if ((jsonResult[zappiIndex].zappi[zappiDevices - 1].pha !== undefined) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].pha === 3)) {
								//console.log("This Zappi has 3 fases!")
								zappiDeviceFases = 3
								if ((jsonResult[zappiIndex].zappi[zappiDevices - 1].ectp1 !== undefined) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].ectp2 !== undefined) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].ectp3 !== undefined)) {
									if ((jsonResult[zappiIndex].zappi[zappiDevices - 1].ectp1 > 1000) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].ectp2 > 1000) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].ectp3 > 1000) ) {
										//console.log("This Zappi has 3 fases, and charging on 3 fases!")
										zappiChargeFases = 3
									} else {
										//console.log("This Zappi has 3 fases, but charging on 1 fase!")
										zappiChargeFases = 1
									}
								
								}
							}
							if (jsonResult[zappiIndex].zappi[zappiDevices - 1].div !== undefined) {
								zappiCharging = jsonResult[zappiIndex].zappi[zappiDevices - 1].div
								collectData.interval = 10000 //collect every 10 sec during charging
							} else {
								zappiCharging = 0
							}
							//console.log("Zappi charging: " + zappiCharging)
							zappiSerial = jsonResult[zappiIndex].zappi[zappiDevices - 1].sno
							//console.log("Zappi serial: " + zappiSerial)
							zappiGridImport = jsonResult[zappiIndex].zappi[zappiDevices - 1].grd
							//console.log("Zappi grid import: " + zappiGridImport)
							zappiMode = jsonResult[zappiIndex].zappi[zappiDevices - 1].zmo
							//console.log("Zappi mode: " + zappiMode)
							//stupid hack for now
							var tmpZappiStateText = zappiStateText
							tmpZappiStateText["B1"] = "Not charging"
							if (zappiMode === 3) {
								//if zappi is in charging mode change the B1 text from 'not charging' to 'waiting for surplus'
								tmpZappiStateText["B1"] = "Waiting for surplus"
							}
							zappiStateText = tmpZappiStateText
							zappiStatus = jsonResult[zappiIndex].zappi[zappiDevices - 1].sta
							//console.log("Zappi status: " + zappiStatus)
							zappiState = jsonResult[zappiIndex].zappi[zappiDevices - 1].pst
							//console.log("Zappi state: " + zappiState)
							zappiChargedkWh = jsonResult[zappiIndex].zappi[zappiDevices - 1].che
							//console.log("Zappi charged kwh: " + zappiChargedkWh)
							zappiMinGreenLevel = jsonResult[zappiIndex].zappi[zappiDevices - 1].mgl
							//console.log("Zappi min green level: " + zappiMinGreenLevel)
							zappiBoostMode = ( (jsonResult[zappiIndex].zappi[zappiDevices - 1].bsm !== undefined) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].bsm === 1) ) ? true : false 
							zappiBoostkWh = (jsonResult[zappiIndex].zappi[zappiDevices - 1].tbk !== undefined ) ? jsonResult[zappiIndex].zappi[zappiDevices - 1].tbk : 0
							zappiSmartBoostMode = ( (jsonResult[zappiIndex].zappi[zappiDevices - 1].bss !== undefined) && (jsonResult[zappiIndex].zappi[zappiDevices - 1].bss === 1) ) ? true : false 
							zappiSmartBoostkWh = (jsonResult[zappiIndex].zappi[zappiDevices - 1].sbk !== undefined ) ? jsonResult[zappiIndex].zappi[zappiDevices - 1].sbk : 0
							zappiSmartBoostHour = (jsonResult[zappiIndex].zappi[zappiDevices - 1].sbh !== undefined ) ? jsonResult[zappiIndex].zappi[zappiDevices - 1].sbh : 0
							zappiSmartBoostMinute = (jsonResult[zappiIndex].zappi[zappiDevices - 1].sbm !== undefined ) ? jsonResult[zappiIndex].zappi[zappiDevices - 1].sbm : 0
							zappiLck = (jsonResult[zappiIndex].zappi[zappiDevices - 1].lck !== undefined ) ? jsonResult[zappiIndex].zappi[zappiDevices - 1].lck : 0
							zappiScreenLocked = (zappiLck & 1)
							zappiScreenLockConnected = (zappiLck & 2)
							zappiScreenLockDisconnected = (zappiLck & 4)
							zappiAllowChargeWhileScreenLock = (zappiLck & 8)
							zappiChargingAllowed = (zappiLck & 16)
						}
						else if (jsonResult[i].asn !== undefined) {
							//check if ASN is still same
							var nowASN = jsonResult[i].asn
							if (zappiASN !== nowASN) {
								console.log("Zappi ASN info from json data got changed to: " + nowASN);
								zappiASNRedirects++
								zappiASN = nowASN
							} else {
								zappiASNRedirects = 0;
							}
						}
					}
				}
			}
			xmlhttp.send();
		} else if (settings["hubSerial"].length > 0) {
			console.log("Zappi collecting ASN first");
			//director returns 401 and this thing isn't receiving headers then... so do check on old server for ASN
			//var url = "https://director.myenergi.net/"
			var serialLastDigit = settings["hubSerial"].substr(settings["hubSerial"].length - 1)
			var url = "https://s" + serialLastDigit + ".myenergi.net/cgi-set-min-green-Z" + zappiSerial + "-" + zappiMinGreenLevel
			var xmlhttp = new XMLHttpRequest()
			xmlhttp.open("GET", url, true, settings["hubSerial"], settings["hubPassword"])
			xmlhttp.onreadystatechange = function() {
				if (xmlhttp.readyState == XMLHttpRequest.DONE) {
					//console.log("********* Zappi http status: " + xmlhttp.status)
					//console.log("********* Zappi headers received: " + xmlhttp.getAllResponseHeaders())
					//console.log("********* Zappi data received: " + xmlhttp.responseText)
					if ((xmlhttp.getResponseHeader("x_myenergi-asn") !== undefined) && (xmlhttp.getResponseHeader("x_myenergi-asn") !== "") ) {
						var nowASN =  xmlhttp.getResponseHeader("x_myenergi-asn") 
						if (zappiASN !== nowASN) {
							console.log("Zappi ASN info from header got changed to: " + nowASN);
							zappiASN = nowASN
							zappiASNRedirects++;
							collectData.restart()
						}
					}
				}
			}
			xmlhttp.send()
		}
	}

	function writeZappiDataToFile(data) {
		var saveFile = new XMLHttpRequest()
		saveFile.open("PUT", "file:///qmf/www/tsc/zappi.json")
		saveFile.send(data)
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