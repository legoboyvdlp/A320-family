# A3XX System Display Controller
# Copyright (c) 2021 Jonathan Redpath (legoboyvdlp)

var Page = {
	new: func(name) {
		var page = {parents:[Page]};
		page.name = name;
		return page;
	},
};

var SystemDisplayController = {
	PageList: {
		apuPage: Page.new("apu"),
		bleedPage: Page.new("bleed"),
		cabPressPage: Page.new("press"),
		condPage: Page.new("cond"),
		cruisePage: Page.new("cruise"),
		doorPage: Page.new("door"),
		enginePage: Page.new("eng"),
		elecPage: Page.new("elec"),
		fctlPage: Page.new("fctl"),
		fuelPage: Page.new("fuel"),
		hydraulicPage: Page.new("hyd"),
		statusPage: Page.new("sts"),
		wheelPage: Page.new("wheel"),
	},
	displayedPage: nil,
	lastDisplayedPage: nil,
	lastMode: nil,
	mode: 3, # 0 = man, 1 = warning, 2 = advisory (not used yet), 3 = auto
	tempFWCPhase: nil,
	tempElapsedTime: nil,
	tempEngineModeSel: nil,
	init: func() {
		me.displayedPage = me.PageList.doorPage;
		ECAMTimer.start();
	},
	autoCallLoop: func() {
		if (me.mode != 3) { return; }
		me.tempFWCPhase = pts.ECAM.fwcWarningPhase.getValue();
		
		if (me.Display.APU) {
			me.displayedPage = me.PageList.apuPage;
		} else if (me.Display.Engine) {
			me.displayedPage = me.PageList.enginePage;
		} else if (me.tempFWCPhase == 1) {
			if (me.Display.Elec) {
				me.displayedPage = me.PageList.elecPage;
			} else {
				me.displayedPage = me.PageList.doorPage;
			}
		} else if (me.tempFWCPhase == 2) {
			if (me.Display.Elec) {
				me.displayedPage = me.PageList.elecPage;
			} else if (me.Display.FCTL) {
				me.displayedPage = me.PageList.fctlPage;
			} else {
				me.displayedPage = me.PageList.wheelPage;
			}
		} else if (me.tempFWCPhase == 3 or me.tempFWCPhase == 4 or me.tempFWCPhase == 5) {
			me.displayedPage = me.PageList.enginePage;
		} else if (me.tempFWCPhase == 6) {
			if (pts.Controls.Gear.gearDown.getValue() and me.altitudeBelow16000) {
				me.displayedPage = me.PageList.wheelPage;
			} else if (me.Display.Cruise) {
				me.displayedPage = me.PageList.cruisePage;
			} else {
				me.displayedPage = me.PageList.enginePage;
			}
		} else if (me.tempFWCPhase == 7) {
			me.displayedPage = me.PageList.wheelPage;
		} else if (me.tempFWCPhase == 8 or me.tempFWCPhase == 9) {
			if (me.Display.Elec) {
				me.displayedPage = me.PageList.elecPage;
			} else {
				me.displayedPage = me.PageList.wheelPage;
			}
		} else if (me.tempFWCPhase == 10) {
			if (me.Display.Elec) {
				me.displayedPage = me.PageList.elecPage;
			} else {
				me.displayedPage = me.PageList.doorPage;
			}
		}
	},
	Timers: {
		APUTimeOn: 0,
		APUTime: 0,
		CruiseTime: 0,
		CruiseTimeOn: 0,
		EngineTime: 0,
		EngineTimeStart: 0,
		EngineTimeOn: 0,
		FCTLTimeStart: 0,
		FCTLTimeOn: 0,
		FCTLTime: 0,
	},
	Display: {
		APU: 0,
		Cruise: 0,
		Elec: 0,
		Engine: 0,
		FCTL: 0,
	},
	altitudeBelow16000: 0,
	update: func() {
		me.tempElapsedTime = pts.Sim.Time.elapsedSec.getValue();
		
		me.altitude = pts.Position.altitudeFt.getValue();
		if (me.altitude < 16000) {
			if (!me.altitudeBelow16000) {
				me.altitudeBelow16000 = 1;
				me.autoCallLoop();
			}
		} else { 
			if (me.altitudeBelow16000) {
				me.altitudeBelow16000 = 0;
				me.autoCallLoop();
			}
		}
		
		if (systems.ELEC.Switch.emerGenTest.getValue()) {
			if (!me.Display.Elec) {
				me.Display.Elec = 1;
				me.autoCallLoop();
			}
		} else {
			if (me.Display.Elec) {
				me.Display.Elec = 0;
				me.autoCallLoop();
			}
		}
		
		if (systems.APUNodes.Controls.master.getValue()) {
			if (pts.APU.rpm.getValue() > 95 and !me.Timers.APUTimeOn) {
				me.Timers.APUTimeOn = 1;
				me.Timers.APUTime = me.tempElapsedTime;
			}
			
			if ((me.Timers.APUTimeOn and (me.tempElapsedTime - me.Timers.APUTime) < 10) or !me.Timers.APUTimeOn) {
				if (!me.Display.APU) {
					me.Display.APU = 1;
					me.autoCallLoop();
				}
			} else {
				if (me.Display.APU) {
					me.Display.APU = 0;
					me.autoCallLoop();
				}
			}
		} else {
			me.Timers.APUTimeOn = 0;
			me.Timers.APUTime = 0;
			if (me.Display.APU) {
				me.Display.APU = 0;
				me.autoCallLoop();
			}
		}
		
		if (abs(pts.Controls.Flight.aileron.getValue()) > 0.05 or abs(pts.Controls.Flight.elevator.getValue()) > 0.05 or abs(pts.Controls.Flight.rudder.getValue()) > 0.50) {
			me.Timers.FCTLTimeStart = 1;
			if (!me.Display.FCTL) {
				me.Display.FCTL = 1;
				me.autoCallLoop();
			}
			me.autoCallLoop();
		} else {
			if (!me.Timers.FCTLTimeOn and me.Timers.FCTLTimeStart) {
				me.Timers.FCTLTimeOn = 1;
				me.Timers.FCTLTimeStart = 0;
				me.Timers.FCTLTime = me.tempElapsedTime;
			} else if (me.Timers.FCTLTimeOn) {
				if ((me.tempElapsedTime - me.Timers.FCTLTime) < 20) {
					if (!me.Display.FCTL) {
						me.Display.FCTL = 1;
						me.autoCallLoop();
					}
				} else {
					me.Timers.FCTLTimeOn = 0;
					me.Timers.FCTLTime = 0;
				}
			} else {
				if (me.Display.FCTL) {
					me.Display.FCTL = 0;
					me.autoCallLoop();
				}
				me.Timers.FCTLTime = 0;
			}
		}
		
		me.tempFWCPhase = pts.ECAM.fwcWarningPhase.getValue();
		if (me.tempFWCPhase == 6) {
			if (!ecam.FWC.toPower.getValue() and pts.Controls.Flight.flapsPos.getValue() == 0) {
				if (!me.Display.Cruise) {
					me.Display.Cruise = 1;
					me.autoCallLoop();
				}
			} else if (!me.Display.Cruise) {
				if (!me.Timers.CruiseTimeOn) {
					me.Timers.CruiseTimeOn = 1;
					me.Timers.CruiseTime = me.tempElapsedTime;
				} else {
					if ((me.tempElapsedTime - me.Timers.CruiseTime) > 60) {
						if (!me.Display.Cruise) {
							me.Display.Cruise = 1;
							me.autoCallLoop();
						}
					}
				}
			}
		} else {
			me.Timers.CruiseTime = 0;
			me.Timers.CruiseTimeOn = 0;
			if (me.Display.Cruise) {
				me.Display.Cruise = 0;
				me.autoCallLoop();
			}
		}
		
		me.tempEngineModeSel = pts.Controls.Engines.startSw.getValue();
		if (me.tempEngineModeSel == 0 or me.tempEngineModeSel == 2) {
			if (!me.Display.Engine) {
				me.Display.Engine = 1;
				me.autoCallLoop();
			}
			
			if (me.tempEngineModeSel == 2) {
				me.Timers.EngineTimeStart = 1;
			}
		} else {
			if (me.Timers.EngineTimeStart and !me.Timers.EngineTimeOn) {
				me.Timers.EngineTimeOn = 1;
				me.Timers.EngineTime = me.tempElapsedTime;
			}
			
			if (me.Timers.EngineTimeOn) {
				if ((me.tempElapsedTime - me.Timers.EngineTime) < 10) {
					if (!me.Display.Engine) {
						me.Display.Engine = 1;
						me.autoCallLoop();
					}
				} else {
					me.Timers.EngineTimeStart = 0;
					me.Timers.EngineTimeOn = 0;
					me.Timers.EngineTime = 0;
					if (me.Display.Engine) {
						me.Display.Engine = 0;
						me.autoCallLoop();
					}
				}
			} else {
				if (me.Display.Engine) {
					me.Display.Engine = 0;
					me.autoCallLoop();
				}
			}
		}
	},
	autoCall: func() {
		me.mode = 3;
		me.autoCallLoop();
	},
	failureCall: func(newPage) {
		if (contains(me.PageList, newPage)) {
			ECAMControlPanel.lightOff(me.displayedPage.name);
			me.lastDisplayedPage = me.displayedPage;
			me.displayedPage = me.PageList[newPage];
			me.lastMode = me.mode;
			me.mode = 1;
			ECAMControlPanel.lightOn(me.displayedPage.name);
		} else {
			debug.dump("Attempted to set page to unknown page", newPage);
		}
	},
	manCall: func(newPage) {
		if (contains(me.PageList, newPage)) {
			if (me.displayedPage == me.PageList[newPage] and me.mode != 3) {
				ECAMControlPanel.lightOff(me.displayedPage.name);
				me.displayedPage = me.autoCall();
			} else {
				ECAMControlPanel.lightOff(me.displayedPage.name);
				if (me.mode == 1) {
					me.lastDisplayedPage = me.displayedPage;
					me.lastMode = me.mode;
				}
				me.displayedPage = me.PageList[newPage];
				me.mode = 0;
				ECAMControlPanel.lightOn(me.displayedPage.name);
			}
		} elsif (newPage == "CLR") {
			if (me.mode == 1) {
				if (me.lastMode == 0) {
					ECAMControlPanel.lightOff(me.displayedPage.name);
					me.displayedPage = me.lastDisplayedPage;
					ECAMControlPanel.lightOn(me.displayedPage.name);
					me.lastDisplayedPage = nil;
					me.mode = 0;
				} else {
					ECAMControlPanel.lightOff(me.displayedPage.name);
					me.displayedPage = me.autoCall();
				}
			} elsif (me.mode == 0) {
				if (me.lastMode == 1) {
					ECAMControlPanel.lightOff(me.displayedPage.name);
					me.displayedPage = me.lastDisplayedPage;
					ECAMControlPanel.lightOn(me.displayedPage.name);
					me.lastDisplayedPage = nil;
					me.mode = 1;
				} else {
					ECAMControlPanel.lightOff(me.displayedPage.name);
					me.displayedPage = me.autoCall();
				}
			}
		} else {
			debug.dump("Attempted to set page to unknown page", newPage);
		}
	},
};

setlistener("/ECAM/warning-phase", func() {
	if (SystemDisplayController.mode == 3) {
		SystemDisplayController.autoCall();
	}
}, 0, 0);

setlistener("/controls/gear/gear-down", func() {
	if (SystemDisplayController.mode == 3) {
		SystemDisplayController.autoCall();
	}
}, 0, 0);


var ECAMTimer = maketimer(1, func() {
	SystemDisplayController.update();
});