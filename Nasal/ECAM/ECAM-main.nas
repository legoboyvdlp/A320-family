# A3XX ECAM
# Joshua Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var ap_active = 0;
var athr_active = 0;
var aileron = 0;
var elevator = 0;
var engModeSel = 0;
var APUMaster = 0;
var APURPM = 0;
var gearDown = 0;
var apOffTime = 0;
var athrOffTime = 0;
var apWarnNode = 0;
var athrWarnNode = 0;
var engStrtTimeSw = 0;
var engStrtTime = 0;
var page = 0;

var gearWarnLight = props.globals.initNode("/ECAM/warnings/landing-gear-warning-light", 0, "BOOL");

var ECAM = {
	_cachePage: "",
	init: func() {
		page = props.globals.initNode("/ECAM/Lower/page", "door", "STRING");
		
		apOffTime = props.globals.initNode("/ECAM/warnings/ap-off-time", 0, "INT");
		athrOffTime = props.globals.initNode("/ECAM/warnings/athr-off-time", 0, "INT");
		engStrtTimeSw = props.globals.initNode("/ECAM/engine-start-time-switch", 0, "BOOL");
		engStrtTime = props.globals.initNode("/ECAM/engine-start-time", 0.0, "DOUBLE");
		apWarnNode = props.globals.initNode("/it-autoflight/output/ap-warning", 0, "INT");
		athrWarnNode = props.globals.initNode("/it-autoflight/output/athr-warning", 0, "INT");
		me.reset();
	},
	update_items: [
		props.UpdateManager.FromHashList(["ap1","ap2","apWarn"], nil, func(val) {
			if (val.apWarn == 2 and (val.ap1 or val.ap2)) {
				apWarnNode.setValue(0);
				ecam.lights[0].setBoolValue(0);
			}
		}),
		props.UpdateManager.FromHashList(["athr","athrWarn"], nil, func(val) {
			if (val.athrWarn == 2 and val.athr) {
				athrWarnNode.setValue(0);
			}
		}),
		props.UpdateManager.FromHashList(["engine1State","engine2State","gear0Wow"], nil, func(val) {
			if (val.engine1State != 3 or val.engine2State != 3) {
				engStrtTimeSw.setBoolValue(0);
				engStrtTime.setValue(0);
			} else if (val.engine1State == 3 and val.engine2State == 3 and val.gear0Wow) {
				engStrtTime.setValue(val.elapsedTime);
				engStrtTimeSw.setBoolValue(1);
			} else if (val.gear0Wow) {
				engStrtTimeSw.setBoolValue(0);
			}
		}),
	],
	lights: {
		"apu": props.globals.initNode("/ECAM/Lower/light/apu", 0, "BOOL"),
		"bleed": props.globals.initNode("/ECAM/Lower/light/bleed", 0, "BOOL"),
		"cond": props.globals.initNode("/ECAM/Lower/light/cond", 0, "BOOL"),
		"door": props.globals.initNode("/ECAM/Lower/light/door", 0, "BOOL"),
		"elec": props.globals.initNode("/ECAM/Lower/light/elec", 0, "BOOL"),
		"eng": props.globals.initNode("/ECAM/Lower/light/eng", 0, "BOOL"),
		"fctl": props.globals.initNode("/ECAM/Lower/light/fctl", 0, "BOOL"),
		"fuel": props.globals.initNode("/ECAM/Lower/light/fuel", 0, "BOOL"),
		"hyd": props.globals.initNode("/ECAM/Lower/light/hyd", 0, "BOOL"),
		"press": props.globals.initNode("/ECAM/Lower/light/press", 0, "BOOL"),
		"sts": props.globals.initNode("/ECAM/Lower/light/sts", 0, "BOOL"),
		"wheel": props.globals.initNode("/ECAM/Lower/light/wheel", 0, "BOOL"),
		"clr": props.globals.initNode("/ECAM/Lower/light/clr", 0, "BOOL"),
	},
	reset: func() {
		for (var i = 0; i <= 8; i = i + 1) {
			setprop("ECAM/msg/line" ~ i, "");
			setprop("ECAM/rightmsg/line" ~ i, "");
			setprop("ECAM/msg/linec" ~ i, "w");
			setprop("ECAM/rightmsg/linec" ~ i, "w");
		}
		
		page.setValue("door");
		me.lights.apu.setValue(0);
		me.lights.bleed.setValue(0);
		me.lights.cond.setValue(0);
		me.lights.door.setValue(0);
		me.lights.elec.setValue(0);
		me.lights.eng.setValue(0);
		me.lights.fctl.setValue(0);
		me.lights.fuel.setValue(0);
		me.lights.hyd.setValue(0);
		me.lights.press.setValue(0);
		me.lights.sts.setValue(0);
		me.lights.wheel.setValue(0);
		me.lights.clr.setValue(0);
	},
	loop: func(notification) {
		# AP / ATHR warnings
		if (ap_active == 1 and !notification.apWarn) {
			ap_active = 0;
		} elsif (ap_active == 1 and notification.apWarn == 1 and notification.elapsedTime > (notification.apOffTime + 9)) {
			ap_active = 0;
			apWarnNode.setValue(0);
		} elsif (ap_active == 0 and notification.apWarn != 0) {
			ap_active = 1;
		}
		
		if (ap_active == 1 and notification.apWarn == 1 and notification.elapsedTime > (notification.apOffTime + 3) and notification.masterWarn) {
			ecam.lights[0].setBoolValue(0);
		}
		
		if (athr_active == 1 and !notification.athrWarn) {
			athr_active = 0;
		} elsif (athr_active == 1 and notification.athrWarn == 1 and notification.elapsedTime > (notification.athrOffTime + 9)) {
			athr_active = 0;
			athrWarnNode.setValue(0);
		} elsif (athr_active == 0 and notification.athrWarn != 0) {
			athr_active = 1;
		}
		
		if (athr_active == 1 and notification.athrWarn == 1 and notification.elapsedTime > (notification.athrOffTime + 3) and notification.masterCaution) {
			ecam.lights[1].setValue(0);
		}
		
		foreach (var update_item; me.update_items) {
			update_item.update(notification);
		}
		
		SystemDisplay.update(notification);
		
		if (me._cachePage != SystemDisplay.page) {
			me.updateSDPage(SystemDisplay.page);
		}
	},
	updateSDPage: func(newPage) {
		me._cachePage = newPage;
		page.setValue(newPage);
	},
	clrLight: func() {
		me.lights.clr.setValue(1);
	},
};

var SystemDisplay = {
	page: "",
	
	manShownPage: 0,
	failShownPage: 0,
	APU10sec: 9,
	eng10sec: 9,
	fctl20sc: 9,
	_apuTime: 0,
	_engTime: 0,
	_fctlTime: 0,
	
	failCall: func(page) {
		if (me.manShownPage) {
			me.manShownPage = 0;
			ECAMControlPanel.lightOff(me.page);
		}
		ECAMControlPanel.lightOn(page);
		me.page = page;
		me.failShownPage = 1;
	},
	manCall: func(page) {
		ECAMControlPanel.lightOff(me.page);
		ECAMControlPanel.lightOn(page);
		me.page = page;
		me.manShownPage = 1;
	},
	autoCall: func(page) {
		if (me.manShownPage or me.failShownPage) { return; }
		if (me.page != page) {
			me.page = page;
		}
	},
	update: func(notification) {
		APUMaster = systems.APUNodes.Controls.master.getValue();
		APURPM = pts.APU.rpm.getValue();
		engModeSel = pts.Controls.Engines.startSw.getValue();
		
		if (APUMaster == 1 and me.APU10sec != 1) {
			me.autoCall("apu");
			me.fctl20sec = 0;
			
			if (me.APU10sec == 9 and APURPM >= 95.0) {
				me.APU10sec = 0;
				me._apuTime = notification.elapsedTime;
			}
			
			if (me.APU10sec != 9 and notification.elapsedTime > me._apuTime + 10) {
				me.APU10sec = 1;
			}
		} elsif (engModeSel == 0 or engModeSel == 2 or (engModeSel == 1 and me.eng10sec == 0)) {
			me.autoCall("eng");
			me.fctl20sec = 0;
			
			if (me.eng10sec == 9 and engModeSel == 1) {
				me.eng10sec = 0;
				me._engTime = notification.elapsedTime;
			}
			
			if (me.eng10sec != 9 and notification.elapsedTime > me._engTime + 10) {
				me.eng10sec = 1;
			}
		} else {
			# Reset variables
			if (APUMaster == 0) {
				me.APU10sec = 9;
			}
			me.eng10sec = 9;
			
			# Phase logic
			if (notification.FWCPhase == 1) {
				me.autoCall("door");
				me.fctl20sec = 9;
			} elsif (notification.FWCPhase == 2) {
				if (notification.aileronFBW >= 0.15 or notification.elevatorFBW >= 0.15 and me.fctl20sec == 9) {
					me.autoCall("fctl");
					
					if (me.fctl20sec == 9) {
						me.fctl20sec = 0;
						me._fctlTime = notification.elapsedTime;
					}
					
					if (me.fctl20sec != 9 and notification.elapsedTime > me._fctlTime + 20) {
						me.fctl20sec = 1;
					}
				} elsif (me.fctl20sec == 0) {
					if (me.fctl20sec != 9 and notification.elapsedTime > me._fctlTime + 20) {
						me.fctl20sec = 1;
					}
				} else {
					me.autoCall("wheel");
					me.fctl20sec = 9;
				}
			} elsif (notification.FWCPhase >= 3 and notification.FWCPhase <= 5) {
				me.autoCall("eng");
				me.fctl20sec = 9;
			} elsif (notification.FWCPhase == 6) {
				if (notification.gearLever and notification.agl <= 16000) {
					me.autoCall("wheel");
				} else {
					me.autoCall("crz");
				}
				me.fctl20sec = 9;
			} elsif (notification.FWCPhase >= 7 and notification.FWCPhase <= 9) {
				me.autoCall("wheel");
				me.fctl20sec = 9;
			} elsif (notification.FWCPhase == 10) {
				me.autoCall("door");
				me.fctl20sec = 9;
			}
		}
	},
};

var ECAMControlPanel = {
	sysPageBtn: func(page) {
		if (SystemDisplay.page != page) {
			SystemDisplay.manCall(page);
		} else {
			me.lightOff(SystemDisplay.page);
			SystemDisplay.manShownPage = 0;
		}
	},
	rclBtn: func() {
		ecam.ECAM_controller.recall();
	},
	clrBtn: func() {
		me.lightOff("clr");
		
		if (apWarnNode.getValue() == 2) {
			apWarnNode.setValue(0);
			return;
		}
		
		if (athrWarnNode.getValue() == 2) {
			athrWarnNode.setValue(0);
			return;
		}
		
		if (SystemDisplay.manShownPage) {
			me.lightOff(SystemDisplay.page);
			SystemDisplay.manShownPage = 0;
			return;
		}
		
		if (SystemDisplay.failShownPage) {
			me.lightOff(SystemDisplay.page);
			SystemDisplay.failShownPage = 0;
			return;
		}
		
		ecam.ECAM_controller.clear();
	},
	stsBtn: func() {
		SystemDisplay.manCall("sts");
	},
	allBtn: func() {
		# todo
	},
	toConfigBtn: func() {
		# todo
	},
	emerCancBtn: func() {
		# todo
	},
	lightOff: func(pageLightOff) {
		if (pageLightOff == "crz") { return; }
		ECAM.lights[pageLightOff].setBoolValue(0);
	},
	lightOn: func(pageLightOn) {
		if (pageLightOn == "crz") { return; }
		ECAM.lights[pageLightOn].setBoolValue(1);
	},
};

# Autoflight Warnings
var doAthrWarn = func(type) {
	if (type == "none") { 
		return; 
	} elsif (type == "soft") {
		athrOffTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		athrWarnNode.setValue(1);
	} else {
		ECAMControlPanel.lightOn("clr");
		athrWarnNode.setValue(2);
	}
	ecam.lights[1].setBoolValue(1);
}

var doApWarn = func(type) {
	if (type == "none") {
		return;
	} elsif (type == "soft") {
		apOffTime.setValue(pts.Sim.Time.elapsedSec.getValue());
		apWarnNode.setValue(1);
		ecam.lights[0].setBoolValue(1);
	} else {
		apWarnNode.setValue(2);
		# master warning handled by warning system in this case
	}
}

# Emesary
var ECAMRecipient =
{
	new: func(_ident)
	{
		var NewECAMRecipient = emesary.Recipient.new(_ident);
		NewECAMRecipient.Receive = func(notification)
		{
			if (notification.NotificationType == "FrameNotification")
			{
				if (math.mod(notifications.frameNotification.FrameCount,5) == 0) {
					ECAM.loop(notification);
				}
				if (math.mod(notifications.frameNotification.FrameCount,10) == 0) {
					phaseLoop();
				}
				if (math.mod(notifications.frameNotification.FrameCount,10) == 5) {
					ECAM_controller.loop(notification);
				}
				return emesary.Transmitter.ReceiptStatus_OK;
			}
			return emesary.Transmitter.ReceiptStatus_NotProcessed;
		};
		return NewECAMRecipient;
	},
};

var A320ECAM = ECAMRecipient.new("A320 ECAM");
emesary.GlobalTransmitter.Register(A320ECAM);

var input = {
	"aileronFBW": "/fdm/jsbsim/fbw/aileron-sidestick",
	"agl": "/position/gear-agl-ft",
	"athr": "/it-autoflight/output/athr",
	"athrWarn": "/it-autoflight/output/athr-warning",
	"athrOffTime": "/ECAM/warnings/athr-off-time",
	"ap1": "/it-autoflight/output/ap1",
	"ap2": "/it-autoflight/output/ap2",
	"apWarn": "/it-autoflight/output/ap-warning",
	"apOffTime": "/ECAM/warnings/ap-off-time",
	"elevatorFBW": "/fdm/jsbsim/fbw/elevator-sidestick",
	"gearLever": "/controls/gear/gear-down",
	"masterCaution": "/ECAM/warnings/master-caution-light",
	"masterWarn": "/ECAM/warnings/master-warning-light",
};

foreach (var name; keys(input)) {
	emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("A320 ECAM", name, input[name]));
}