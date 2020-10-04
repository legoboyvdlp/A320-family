# A3XX ECAM
# Joshua Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var ap_active = 0;
var athr_active = 0;
var phase = 0;
var aileron = 0;
var elevator = 0;
var stateL = 0;
var stateR = 0;
var engModeSel = 0;
var APUMaster = 0;
var APURPM = 0;
var elapsedSec = 0;
var gearDown = 0;
var agl = 0;
var apOffTime = 0;
var athrOffTime = 0;
var apWarnNode = 0;
var athrWarnNode = 0;
var engStrtTimeSw = 0;
var engStrtTime = 0;
var page = 0;
var apuLight = 0;
var bleedLight = 0;
var condLight = 0;
var doorLight = 0;
var elecLight = 0;
var engLight = 0;
var fctlLight = 0;
var fuelLight = 0;
var hydLight = 0;
var pressLight = 0;
var stsLight = 0;
var wheelLight = 0;
var clrLight = 0;

var ECAM = {
	_cachePage: "",
	init: func() {
		setprop("/systems/gear/landing-gear-warning-light", 0);
		page = props.globals.initNode("/ECAM/Lower/page", "door", "STRING");
		apuLight = props.globals.initNode("/ECAM/Lower/light/apu", 0, "BOOL");
		bleedLight = props.globals.initNode("/ECAM/Lower/light/bleed", 0, "BOOL");
		condLight = props.globals.initNode("/ECAM/Lower/light/cond", 0, "BOOL");
		doorLight = props.globals.initNode("/ECAM/Lower/light/door", 0, "BOOL");
		elecLight = props.globals.initNode("/ECAM/Lower/light/elec", 0, "BOOL");
		engLight = props.globals.initNode("/ECAM/Lower/light/eng", 0, "BOOL");
		fctlLight = props.globals.initNode("/ECAM/Lower/light/fctl", 0, "BOOL");
		fuelLight = props.globals.initNode("/ECAM/Lower/light/fuel", 0, "BOOL");
		hydLight = props.globals.initNode("/ECAM/Lower/light/hyd", 0, "BOOL");
		pressLight = props.globals.initNode("/ECAM/Lower/light/press", 0, "BOOL");
		stsLight = props.globals.initNode("/ECAM/Lower/light/sts", 0, "BOOL");
		wheelLight = props.globals.initNode("/ECAM/Lower/light/wheel", 0, "BOOL");
		clrLight = props.globals.initNode("/ECAM/Lower/light/clr", 0, "BOOL");
		
		phase = props.globals.initNode("/ECAM/warning-phase", 0, "INT");
		apOffTime = props.globals.initNode("/ECAM/ap-off-time", 0, "INT");
		athrOffTime = props.globals.initNode("/ECAM/athr-off-time", 0, "INT");
		engStrtTimeSw = props.globals.initNode("/ECAM/engine-start-time-switch", 0, "BOOL");
		engStrtTime = props.globals.initNode("/ECAM/engine-start-time", 0.0, "DOUBLE");
		apWarnNode = props.globals.initNode("/it-autoflight/output/ap-warning", 0, "INT");
		athrWarnNode = props.globals.initNode("/it-autoflight/output/athr-warning", 0, "INT");
		me.reset();
	},
	reset: func() {
		setprop("ECAM/msg/line1", "");
		setprop("ECAM/msg/line2", "");
		setprop("ECAM/msg/line3", "");
		setprop("ECAM/msg/line4", "");
		setprop("ECAM/msg/line5", "");
		setprop("ECAM/msg/line6", "");
		setprop("ECAM/msg/line7", "");
		setprop("ECAM/msg/line8", "");
		setprop("ECAM/msg/linec1", "w");
		setprop("ECAM/msg/linec2", "w");
		setprop("ECAM/msg/linec3", "w");
		setprop("ECAM/msg/linec4", "w");
		setprop("ECAM/msg/linec5", "w");
		setprop("ECAM/msg/linec6", "w");
		setprop("ECAM/msg/linec7", "w");
		setprop("ECAM/msg/linec8", "w");
		setprop("ECAM/rightmsg/line1", "");
		setprop("ECAM/rightmsg/line2", "");
		setprop("ECAM/rightmsg/line3", "");
		setprop("ECAM/rightmsg/line4", "");
		setprop("ECAM/rightmsg/line5", "");
		setprop("ECAM/rightmsg/line6", "");
		setprop("ECAM/rightmsg/line7", "");
		setprop("ECAM/rightmsg/line8", "");
		setprop("ECAM/rightmsg/linec1", "w");
		setprop("ECAM/rightmsg/linec2", "w");
		setprop("ECAM/rightmsg/linec3", "w");
		setprop("ECAM/rightmsg/linec4", "w");
		setprop("ECAM/rightmsg/linec5", "w");
		setprop("ECAM/rightmsg/linec6", "w");
		setprop("ECAM/rightmsg/linec7", "w");
		setprop("ECAM/rightmsg/linec8", "w");
		
		page.setValue("door");
		apuLight.setValue(0);
		bleedLight.setValue(0);
		condLight.setValue(0);
		doorLight.setValue(0);
		elecLight.setValue(0);
		engLight.setValue(0);
		fctlLight.setValue(0);
		fuelLight.setValue(0);
		hydLight.setValue(0);
		pressLight.setValue(0);
		stsLight.setValue(0);
		wheelLight.setValue(0);
		clrLight.setValue(0);
	},
	loop: func() {
		stateL = pts.Engines.Engine.state[0].getValue();
		stateR = pts.Engines.Engine.state[1].getValue();
		wow = pts.Gear.wow[0].getValue();
		elapsedTime = pts.Sim.Time.elapsedSec.getValue();
		
		if (stateL != 3 or stateR != 3) {
			if (engStrtTimeSw.getBoolValue()) {
				engStrtTimeSw.setBoolValue(0);
				engStrtTime.setValue(0);
			}
		} else if (stateL == 3 and stateR == 3 and wow == 1) {
			if (!engStrtTimeSw.getBoolValue()) {
				engStrtTime.setValue(elapsedTime);
				engStrtTimeSw.setBoolValue(1);
			}
		} else if (wow == 1) {
			if (engStrtTimeSw.getBoolValue()) {
				engStrtTimeSw.setBoolValue(0);
			}
		}
		
		# AP / ATHR warnings
		if (ap_active == 1 and apWarnNode.getValue() == 0) {
			ap_active = 0;
		} elsif (ap_active == 1 and apWarnNode.getValue() == 1 and elapsedTime > (apOffTime.getValue() + 9)) {
			ap_active = 0;
			apWarnNode.setValue(0);
		} elsif (ap_active == 0 and apWarnNode.getValue() != 0) {
			ap_active = 1;
		}
		
		if (ap_active == 1 and apWarnNode.getValue() == 1 and elapsedTime > (apOffTime.getValue() + 3) and ecam.lights[0].getBoolValue()) {
			ecam.lights[0].setBoolValue(0);
		}
		
		if (apWarnNode.getValue() == 2 and (fmgc.Output.ap1.getValue() == 1 or fmgc.Output.ap2.getValue() == 1)) {
			apWarnNode.setValue(0);
		}
		
		if (athr_active == 1 and athrWarnNode.getValue() == 0) {
			athr_active = 0;
		} elsif (athr_active == 1 and athrWarnNode.getValue() == 1 and elapsedTime > (athrOffTime.getValue() + 9)) {
			athr_active = 0;
			athrWarnNode.setValue(0);
		} elsif (athr_active == 0 and athrWarnNode.getValue() != 0) {
			athr_active = 1;
		}
		
		
		if (athr_active == 1 and athrWarnNode.getValue() == 1 and elapsedTime > (athrOffTime.getValue() + 3) and ecam.lights[1].getBoolValue()) {
			ecam.lights[1].setValue(0);
		}
		
		if (athrWarnNode.getValue() == 2 and fmgc.Output.athr.getValue() == 1) {
			athrWarnNode.setValue(0);
		}
		
		SystemDisplay.update();
		
		if (me._cachePage != SystemDisplay.page) {
			me._cachePage = SystemDisplay.page;
			page.setValue(SystemDisplay.page);
		}
	},
	clrLight: func() {
		clrLight.setValue(1);
	}
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
	update: func() {
		phase = pts.ECAM.fwcWarningPhase.getValue();
		APUMaster = systems.APUNodes.Controls.master.getValue();
		APURPM = pts.APU.rpm.getValue();
		engModeSel = pts.Controls.Engines.startSw.getValue();
		elapsedSec = pts.Sim.Time.elapsedSec.getValue();
		
		if (APUMaster == 1 and me.APU10sec != 1) {
			me.autoCall("apu");
			me.fctl20sec = 0;
			
			if (me.APU10sec == 9 and APURPM >= 95.0) {
				me.APU10sec = 0;
				me._apuTime = elapsedSec;
			}
			
			if (me.APU10sec != 9 and elapsedSec > me._apuTime + 10) {
				me.APU10sec = 1;
			}
		} elsif (engModeSel == 0 or engModeSel == 2 or (engModeSel == 1 and me.eng10sec == 0)) {
			me.autoCall("eng");
			me.fctl20sec = 0;
			
			if (me.eng10sec == 9 and engModeSel == 1) {
				me.eng10sec = 0;
				me._engTime = elapsedSec;
			}
			
			if (me.eng10sec != 9 and elapsedSec > me._engTime + 10) {
				me.eng10sec = 1;
			}
		} else {
			# Reset variables
			if (APUMaster == 0) {
				me.APU10sec = 9;
			}
			me.eng10sec = 9;
			
			# Phase logic
			if (phase == 1) {
				me.autoCall("door");
				me.fctl20sec = 9;
			} elsif (phase == 2) {
				aileron = pts.Fdm.JSBsim.Fbw.aileron.getValue();
				elevator = pts.Fdm.JSBsim.Fbw.elevator.getValue();
				
				if (abs(aileron) >= 0.15 or abs(elevator) >= 0.15 and me.fctl20sec == 9) {
					me.autoCall("fctl");
					
					if (me.fctl20sec == 9) {
						me.fctl20sec = 0;
						me._fctlTime = elapsedSec;
					}
					
					if (me.fctl20sec != 9 and elapsedSec > me._fctlTime + 20) {
						me.fctl20sec = 1;
					}
				} elsif (me.fctl20sec == 0) {
					if (me.fctl20sec != 9 and elapsedSec > me._fctlTime + 20) {
						me.fctl20sec = 1;
					}
				} else {
					me.autoCall("wheel");
					me.fctl20sec = 9;
				}
			} elsif (phase >= 3 and phase <= 5) {
				me.autoCall("eng");
				me.fctl20sec = 9;
			} elsif (phase == 6) {
				gearLever = pts.Controls.Gear.gearDown.getValue();
				agl = pts.Position.gearAglFt.getValue();
				
				if (gearLever and agl <= 16000) {
					me.autoCall("wheel");
				} else {
					me.autoCall("crz");
				}
				me.fctl20sec = 9;
			} elsif (phase >= 7 and phase <= 9) {
				me.autoCall("wheel");
				me.fctl20sec = 9;
			} elsif (phase == 10) {
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
	lightOff: func(page) {
		if (page == "clr") { clrLight.setBoolValue(0); }
		elsif (page == "apu") { apuLight.setBoolValue(0); }
		elsif (page == "bleed") { bleedLight.setBoolValue(0); }
		elsif (page == "cond") { condLight.setBoolValue(0); }
		elsif (page == "door") { doorLight.setBoolValue(0); }
		elsif (page == "elec") { elecLight.setBoolValue(0); }
		elsif (page == "eng") { engLight.setBoolValue(0); }
		elsif (page == "fctl") { fctlLight.setBoolValue(0); }
		elsif (page == "fuel") { fuelLight.setBoolValue(0); }
		elsif (page == "hyd") { hydLight.setBoolValue(0); }
		elsif (page == "press") { pressLight.setBoolValue(0); }
		elsif (page == "sts") { stsLight.setBoolValue(0); }
		elsif (page == "wheel") { wheelLight.setBoolValue(0); }
	},
	lightOn: func(page) {
		if (page == "clr") { clrLight.setBoolValue(1); }
		elsif (page == "apu") { apuLight.setBoolValue(1); }
		elsif (page == "bleed") { bleedLight.setBoolValue(1); }
		elsif (page == "cond") { condLight.setBoolValue(1); }
		elsif (page == "door") { doorLight.setBoolValue(1); }
		elsif (page == "elec") { elecLight.setBoolValue(1); }
		elsif (page == "eng") { engLight.setBoolValue(1); }
		elsif (page == "fctl") { fctlLight.setBoolValue(1); }
		elsif (page == "fuel") { fuelLight.setBoolValue(1); }
		elsif (page == "hyd") { hydLight.setBoolValue(1); }
		elsif (page == "press") { pressLight.setBoolValue(1); }
		elsif (page == "sts") { stsLight.setBoolValue(1); }
		elsif (page == "wheel") { wheelLight.setBoolValue(1); }
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