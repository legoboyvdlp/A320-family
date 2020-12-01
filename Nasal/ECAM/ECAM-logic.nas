# A3XX Electronic Centralised Aircraft Monitoring System

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# props.nas:

var dualFailNode = props.globals.initNode("/ECAM/dual-failure-enabled", 0, "BOOL");
var phaseNode    = props.globals.getNode("/ECAM/warning-phase", 1);
var apWarn       = props.globals.getNode("/it-autoflight/output/ap-warning", 1);
var athrWarn     = props.globals.getNode("/it-autoflight/output/athr-warning", 1);
var emerGen      = props.globals.getNode("/controls/electrical/switches/emer-gen", 1);

var state1Node = props.globals.getNode("/engines/engine[0]/state", 1);
var state2Node = props.globals.getNode("/engines/engine[1]/state", 1);
var wing_pb    = props.globals.getNode("/controls/ice-protection/wing", 1);
var apu_bleedSw   = props.globals.getNode("/controls/pneumatics/switches/apu", 1);
var gear       = props.globals.getNode("/gear/gear-pos-norm", 1);
var stallVoice = props.globals.initNode("/sim/sound/warnings/stall-voice", 0, "BOOL");
var engOpt     = props.globals.getNode("/options/eng", 1);

var thrustState = [nil, nil];

# local variables
var transmitFlag1 = 0;
var transmitFlag2 = 0;
var phaseVar3 = nil;
var phaseVar2 = nil;
var phaseVar1 = nil;
var phaseVarMemo = nil;
var phaseVarMemo2 = nil;
var phaseVarMemo3 = nil;
var gear_agl_cur = nil;
var numberMinutes = nil;
var timeNow = nil;
var timer10secIRS = nil;
var altAlertInhibit = nil;
var alt200 = nil;
var alt750 = nil;
var bigThree = nil;

var altAlertSteady = 0;
var altAlertFlash = 0;

var messages_priority_3 = func {
	phaseVar3 = phaseNode.getValue();
	
	# Stall
	# todo - altn law and emer cancel flipflops page 2440
	if (warningNodes.Logic.stallWarn.getValue()) {
		stall.active = 1;
		stallVoice.setValue(1);
	} else {
		ECAM_controller.warningReset(stall);
		stallVoice.setValue(0);
	}
	
	# FCTL FLAPS NOT ZERO
	if (flap_not_zero.clearFlag == 0 and phaseVar3 == 6 and pts.Controls.Flight.flapsInput.getValue() != 0 and pts.Instrumentation.Altimeter.indicatedFt.getValue() > 22000) {
		flap_not_zero.active = 1;
	} else {
		ECAM_controller.warningReset(flap_not_zero);
	}
	
	if ((phaseVar3 == 1 or (phaseVar3 >= 5 and phaseVar3 <= 7)) and getprop("/systems/navigation/adr/output/overspeed")) {
		overspeed.active = 1;
		if (getprop("/systems/navigation/adr/computation/overspeed-vmo") or getprop("/systems/navigation/adr/computation/overspeed-mmo")) {
			overspeedVMO.active = 1;
		} else {
			ECAM_controller.warningReset(overspeedVMO);
		}
		
		if (getprop("/systems/navigation/adr/computation/overspeed-vle")) {
			overspeedGear.active = 1;
		} else {
			ECAM_controller.warningReset(overspeedGear);
		}
		
		if (getprop("/systems/navigation/adr/computation/overspeed-vfe")) {
			overspeedFlap.active = 1;
			overspeedFlap.msg = "-VFE................" ~ (systems.ADIRS.overspeedVFE.getValue() - 4);
		} else {
			ECAM_controller.warningReset(overspeedFlap);
			overspeedFlap.msg = "-VFE................XXX";
		}
	} else {
		ECAM_controller.warningReset(overspeed);
		ECAM_controller.warningReset(overspeedVMO);
		ECAM_controller.warningReset(overspeedGear);
		ECAM_controller.warningReset(overspeedFlap);
		overspeedFlap.msg = "-VFE................XXX";
	}
	
	# ENG ALL ENGINE FAILURE
	
	if (allEngFail.clearFlag == 0 and dualFailNode.getBoolValue()) {
		allEngFail.active = 1;
		
		if (allEngFailElec.clearFlag == 0 and getprop("/systems/electrical/relay/emer-glc/contact-pos") == 0) {
			allEngFailElec.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailElec);
		}
		
		if (allEngFailSPD1.clearFlag == 0 and allEngFailSPD2.clearFlag == 0 and allEngFailSPD3.clearFlag == 0 and allEngFailSPD4.clearFlag == 0) {
			if (find("LEAP", getprop("/MCDUC/eng"))) {
				allEngFailSPD2.active = 1;
				ECAM_controller.warningReset(allEngFailSPD1);
				ECAM_controller.warningReset(allEngFailSPD3);
				ECAM_controller.warningReset(allEngFailSPD4);
			} elsif (find("V2527", getprop("/MCDUC/eng"))) {
				allEngFailSPD3.active = 1;
				ECAM_controller.warningReset(allEngFailSPD1);
				ECAM_controller.warningReset(allEngFailSPD2);
				ECAM_controller.warningReset(allEngFailSPD4);
			} elsif (find("PW11", getprop("/MCDUC/eng"))) {
				allEngFailSPD1.active = 1;
				ECAM_controller.warningReset(allEngFailSPD2);
				ECAM_controller.warningReset(allEngFailSPD3);
				ECAM_controller.warningReset(allEngFailSPD4);
			} else {
				allEngFailSPD4.active = 1;
				ECAM_controller.warningReset(allEngFailSPD1);
				ECAM_controller.warningReset(allEngFailSPD2);
				ECAM_controller.warningReset(allEngFailSPD3);
			}
		} else {
			ECAM_controller.warningReset(allEngFailSPD1);
			ECAM_controller.warningReset(allEngFailSPD2);
			ECAM_controller.warningReset(allEngFailSPD3);
			ECAM_controller.warningReset(allEngFailSPD4);
		}
		
		if (allEngFailAPU.clearFlag == 0 and !systems.APUNodes.Controls.master.getBoolValue() and systems.ELEC.Switch.genApu.getValue() and !systems.APUNodes.Controls.fire.getValue() and !systems.APU.signals.autoshutdown and !systems.APU.signals.emer and pts.Instrumentation.Altimeter.indicatedFt.getValue() < 22500) {
			allEngFailAPU.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailAPU);
		}
		
		if (allEngFailLevers.clearFlag == 0 and (pts.Controls.Engines.Engine.throttleLever[0].getValue() > 0.01 or pts.Controls.Engines.Engine.throttleLever[0].getValue() > 0.01)) {
			allEngFailLevers.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailLevers);
		}
		
		if (allEngFailFAC.clearFlag == 0 and fbw.FBW.Computers.fac1.getBoolValue() == 0) {
			allEngFailFAC.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailFAC);
		}
		
		if (allEngFailGlide.clearFlag == 0) {
			allEngFailGlide.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailGlide);
		}
		
		if (allEngFailDiversion.clearFlag == 0) {
			allEngFailDiversion.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailDiversion);
		}
		
		if (allEngFailProc.clearFlag == 0) {
			allEngFailProc.active = 1;
		} else {
			ECAM_controller.warningReset(allEngFailProc);
		}
	} else {
		ECAM_controller.warningReset(allEngFail);
		ECAM_controller.warningReset(allEngFailElec);
		ECAM_controller.warningReset(allEngFailSPD1);
		ECAM_controller.warningReset(allEngFailSPD2);
		ECAM_controller.warningReset(allEngFailSPD3);
		ECAM_controller.warningReset(allEngFailSPD4);
		ECAM_controller.warningReset(allEngFailAPU);
		ECAM_controller.warningReset(allEngFailLevers);
		ECAM_controller.warningReset(allEngFailFAC);
		ECAM_controller.warningReset(allEngFailGlide);
		ECAM_controller.warningReset(allEngFailDiversion);
		ECAM_controller.warningReset(allEngFailProc);
	}
	
	# ENG ABV IDLE
	if (eng1ThrLvrAbvIdle.clearFlag == 0 and ((phaseVar3 >= 1 and phaseVar3 <= 4) or (phaseVar3 >= 6 and phaseVar3 <= 9)) and warningNodes.Flipflops.eng1ThrLvrAbvIdle.getValue()) { # AND NOT RUNWAY TOO SHORT
		eng1ThrLvrAbvIdle.active = 1;
		if (eng1ThrLvrAbvIdle2.clearFlag == 0) {
			eng1ThrLvrAbvIdle2.active = 1;
		} else {
			ECAM_controller.warningReset(eng1ThrLvrAbvIdle2);
		}
	} else {
		ECAM_controller.warningReset(eng1ThrLvrAbvIdle);
		ECAM_controller.warningReset(eng1ThrLvrAbvIdle2);
	}
	
	if (eng2ThrLvrAbvIdle.clearFlag == 0 and ((phaseVar3 >= 1 and phaseVar3 <= 4) or (phaseVar3 >= 6 and phaseVar3 <= 9)) and warningNodes.Flipflops.eng2ThrLvrAbvIdle.getValue()) { # AND NOT RUNWAY TOO SHORT
		eng2ThrLvrAbvIdle.active = 1;
		if (eng2ThrLvrAbvIdle2.clearFlag == 0) {
			eng2ThrLvrAbvIdle2.active = 1;
		} else {
			ECAM_controller.warningReset(eng2ThrLvrAbvIdle2);
		}
	} else {
		ECAM_controller.warningReset(eng2ThrLvrAbvIdle);
		ECAM_controller.warningReset(eng2ThrLvrAbvIdle2);
	}
	
	# ENG FIRE
	if ((eng1FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine1/warning-active") == 1 and phaseVar3 >= 5 and phaseVar3 <= 7) or (eng1FireGnEvac.clearFlag == 0 and getprop("/systems/fire/engine1/warning-active") == 1 and (phaseVar3 < 5 or phaseVar3 > 7))) {
		eng1Fire.active = 1;
	} else {
		ECAM_controller.warningReset(eng1Fire);
	}
	
	if ((eng2FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine2/warning-active") == 1 and phaseVar3 >= 5 and phaseVar3 <= 7) or (eng2FireGnEvac.clearFlag == 0 and getprop("/systems/fire/engine2/warning-active") == 1 and (phaseVar3 < 5 or phaseVar3 > 7))) {
		eng2Fire.active = 1;
	} else {
		ECAM_controller.warningReset(eng2Fire);
	}
	
	if (apuFireMaster.clearFlag == 0 and getprop("/systems/fire/apu/warning-active")) {
		apuFire.active = 1;
	} else {
		ECAM_controller.warningReset(apuFire);
	}
	
	if (eng1Fire.active == 1) {
		if (phaseVar3 >= 5 and phaseVar3 <= 7) {
			if (eng1FireFllever.clearFlag == 0 and pts.Controls.Engines.Engine.throttleLever[0].getValue() > 0.01) {
				eng1FireFllever.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFllever);
			}
			
			if (eng1FireFlmaster.clearFlag == 0 and pts.Controls.Engines.Engine.cutoffSw[0].getValue() == 0) {
				eng1FireFlmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlmaster);
			}
			
			if (eng1FireFlPB.clearFlag == 0 and getprop("/controls/engines/engine[0]/fire-btn") == 0) {
				eng1FireFlPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlPB);
			}
			
			if (getprop("/systems/fire/engine1/agent1-timer") != 0 and getprop("/systems/fire/engine1/agent1-timer") != 99) {
				eng1FireFlAgent1Timer.msg = " -AGENT AFT " ~ getprop("/systems/fire/engine1/agent1-timer") ~ " S...DISCH";
			}
			
			if (eng1FireFlAgent1.clearFlag == 0 and getprop("/controls/engines/engine[0]/fire-btn") == 1 and !getprop("/systems/fire/engine1/disch1") and getprop("/systems/fire/engine1/agent1-timer") != 0 and getprop("/systems/fire/engine1/agent1-timer") != 99) {
				eng1FireFlAgent1Timer.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent1Timer);
			}
			
			if (eng1FireFlAgent1.clearFlag == 0 and !getprop("/systems/fire/engine1/disch1") and (getprop("/systems/fire/engine1/agent1-timer") == 0 or getprop("/systems/fire/engine1/agent1-timer") == 99)) {
				eng1FireFlAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent1);
			}
			
			if (eng1FireFlATC.clearFlag == 0) {
				eng1FireFlATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlATC);
			}
			
			if (getprop("/systems/fire/engine1/agent2-timer") != 0 and getprop("/systems/fire/engine1/agent2-timer") != 99) {
				eng1FireFl30Sec.msg = "•IF FIRE AFTER " ~ getprop("/systems/fire/engine1/agent2-timer") ~ " S:";
			}
			
			if (eng1FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine1/disch1") and !getprop("/systems/fire/engine1/disch2") and getprop("/systems/fire/engine1/agent2-timer") > 0) {
				eng1FireFl30Sec.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFl30Sec);
			}
			
			if (eng1FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine1/disch1") and !getprop("/systems/fire/engine1/disch2")) {
				eng1FireFlAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent2);
			}
		} else {
			ECAM_controller.warningReset(eng1FireFllever);
			ECAM_controller.warningReset(eng1FireFlmaster);
			ECAM_controller.warningReset(eng1FireFlPB);
			ECAM_controller.warningReset(eng1FireFlAgent1);
			ECAM_controller.warningReset(eng1FireFlATC);
			ECAM_controller.warningReset(eng1FireFl30Sec);
			ECAM_controller.warningReset(eng1FireFlAgent2);
		}
		
		if (phaseVar3 < 5 or phaseVar3 > 7) {
			if (eng1FireGnlever.clearFlag == 0 and pts.Controls.Engines.Engine.throttleLever[0].getValue() > 0.01 and pts.Controls.Engines.Engine.throttleLever[1].getValue() > 0.01) {
				eng1FireGnlever.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnlever);
			}
			
			if (eng1FireGnparkbrk.clearFlag == 0 and pts.Controls.Gear.parkingBrake.getValue() == 0) { 
				eng1FireGnstopped.active = 1;
				eng1FireGnparkbrk.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnstopped);
				ECAM_controller.warningReset(eng1FireGnparkbrk);
			}
			
			if (eng1FireGnATC.clearFlag == 0) {
				eng1FireGnATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnATC);
			}
			
			if (eng1FireGncrew.clearFlag == 0) {
				eng1FireGncrew.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGncrew);
			}
			
			if (eng1FireGnmaster.clearFlag == 0 and pts.Controls.Engines.Engine.cutoffSw[0].getValue() == 0) {
				eng1FireGnmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnmaster);
			}
			
			if (eng1FireGnPB.clearFlag == 0 and getprop("/controls/engines/engine[0]/fire-btn") == 0) {
				eng1FireGnPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnPB);
			}
			
			if (eng1FireGnAgent1.clearFlag == 0 and !getprop("/systems/fire/engine1/disch1")) {
				eng1FireGnAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnAgent1);
			}
			
			if (eng1FireGnAgent2.clearFlag == 0 and !getprop("/systems/fire/engine1/disch2")) {
				eng1FireGnAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnAgent2);
			}
			
			if (eng1FireGnEvac.clearFlag == 0) {
				eng1FireGnEvac.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnEvac);
			}
		} else {
			ECAM_controller.warningReset(eng1FireGnlever);
			ECAM_controller.warningReset(eng1FireGnstopped);
			ECAM_controller.warningReset(eng1FireGnparkbrk);
			ECAM_controller.warningReset(eng1FireGnATC);
			ECAM_controller.warningReset(eng1FireGncrew);
			ECAM_controller.warningReset(eng1FireGnmaster);
			ECAM_controller.warningReset(eng1FireGnPB);
			ECAM_controller.warningReset(eng1FireGnAgent1);
			ECAM_controller.warningReset(eng1FireGnAgent2);
			ECAM_controller.warningReset(eng1FireGnEvac);
		}
	} else {
		ECAM_controller.warningReset(eng1FireFllever);
		ECAM_controller.warningReset(eng1FireFlmaster);
		ECAM_controller.warningReset(eng1FireFlPB);
		ECAM_controller.warningReset(eng1FireFlAgent1);
		ECAM_controller.warningReset(eng1FireFlATC);
		ECAM_controller.warningReset(eng1FireFl30Sec);
		ECAM_controller.warningReset(eng1FireFlAgent2);
		ECAM_controller.warningReset(eng1FireGnlever);
		ECAM_controller.warningReset(eng1FireGnstopped);
		ECAM_controller.warningReset(eng1FireGnparkbrk);
		ECAM_controller.warningReset(eng1FireGnATC);
		ECAM_controller.warningReset(eng1FireGncrew);
		ECAM_controller.warningReset(eng1FireGnmaster);
		ECAM_controller.warningReset(eng1FireGnPB);
		ECAM_controller.warningReset(eng1FireGnAgent1);
		ECAM_controller.warningReset(eng1FireGnAgent2);
		ECAM_controller.warningReset(eng1FireGnEvac);
	}
	
	if (eng2Fire.active == 1) {
		if (phaseVar3 >= 5 and phaseVar3 <= 7) {
			if (eng2FireFllever.clearFlag == 0 and pts.Controls.Engines.Engine.throttleLever[1].getValue() > 0.01) {
				eng2FireFllever.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFllever);
			}
			
			if (eng2FireFlmaster.clearFlag == 0 and pts.Controls.Engines.Engine.cutoffSw[1].getValue() == 0) {
				eng2FireFlmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlmaster);
			}
			
			if (eng2FireFlPB.clearFlag == 0 and getprop("/controls/engines/engine[1]/fire-btn") == 0) {
				eng2FireFlPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlPB);
			}
			
			if (getprop("/systems/fire/engine2/agent1-timer") != 0 and getprop("/systems/fire/engine2/agent1-timer") != 99) {
				eng2FireFlAgent1Timer.msg = " -AGENT AFT " ~ getprop("/systems/fire/engine2/agent1-timer") ~ " S...DISCH";
			}
			
			if (eng2FireFlAgent1.clearFlag == 0 and getprop("/controls/engines/engine[1]/fire-btn") == 1 and !getprop("/systems/fire/engine2/disch1") and getprop("/systems/fire/engine2agent1-timer") != 0 and getprop("/systems/fire/engine2/agent1-timer") != 99) {
				eng2FireFlAgent1Timer.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent1Timer);
			}
			
			if (eng2FireFlAgent1.clearFlag == 0 and !getprop("/systems/fire/engine2/disch1") and (getprop("/systems/fire/engine2/agent1-timer") == 0 or getprop("/systems/fire/engine2/agent1-timer") == 99)) {
				eng2FireFlAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent1);
			}
			
			if (eng2FireFlATC.clearFlag == 0) {
				eng2FireFlATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlATC);
			}
			
			if (getprop("/systems/fire/engine2/agent2-timer") != 0 and getprop("/systems/fire/engine2/agent2-timer") != 99) {
				eng2FireFl30Sec.msg = "•IF FIRE AFTER " ~ getprop("/systems/fire/engine2/agent2-timer") ~ " S:";
			}
			
			if (eng2FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine2/disch1") and !getprop("/systems/fire/engine2/disch2") and getprop("/systems/fire/engine2/agent2-timer") > 0) {
				eng2FireFl30Sec.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFl30Sec);
			}
			
			if (eng2FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine2/disch1") and !getprop("/systems/fire/engine2/disch2")) {
				eng2FireFlAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent2);
			}
		} else {
			ECAM_controller.warningReset(eng2FireFllever);
			ECAM_controller.warningReset(eng2FireFlmaster);
			ECAM_controller.warningReset(eng2FireFlPB);
			ECAM_controller.warningReset(eng2FireFlAgent1);
			ECAM_controller.warningReset(eng2FireFlATC);
			ECAM_controller.warningReset(eng2FireFl30Sec);
			ECAM_controller.warningReset(eng2FireFlAgent2);
		}
		
		if (phaseVar3 < 5 or phaseVar3 > 7) {
			if (eng2FireGnlever.clearFlag == 0 and pts.Controls.Engines.Engine.throttleLever[0].getValue() > 0.01 and pts.Controls.Engines.Engine.throttleLever[1].getValue() > 0.01) {
				eng2FireGnlever.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnlever);
			}
			
			if (eng2FireGnparkbrk.clearFlag == 0 and pts.Controls.Gear.parkingBrake.getValue() == 0) { 
				eng2FireGnstopped.active = 1;
				eng2FireGnparkbrk.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnstopped);
				ECAM_controller.warningReset(eng2FireGnparkbrk);
			}
			
			if (eng2FireGnATC.clearFlag == 0) {
				eng2FireGnATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnATC);
			}
			
			if (eng2FireGncrew.clearFlag == 0) {
				eng2FireGncrew.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGncrew);
			}
			
			if (eng2FireGnmaster.clearFlag == 0 and pts.Controls.Engines.Engine.cutoffSw[1].getValue() == 0) {
				eng2FireGnmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnmaster);
			}
			
			if (eng2FireGnPB.clearFlag == 0 and getprop("/controls/engines/engine[1]/fire-btn") == 0) {
				eng2FireGnPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnPB);
			}
			
			if (eng2FireGnAgent1.clearFlag == 0 and !getprop("/systems/fire/engine2/disch1")) {
				eng2FireGnAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnAgent1);
			}
			
			if (eng2FireGnAgent2.clearFlag == 0 and !getprop("/systems/fire/engine2/disch2")) {
				eng2FireGnAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnAgent2);
			}
			
			if (eng2FireGnEvac.clearFlag == 0) {
				eng2FireGnEvac.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnEvac);
			}
		} else {
			ECAM_controller.warningReset(eng2FireGnlever);
			ECAM_controller.warningReset(eng2FireGnstopped);
			ECAM_controller.warningReset(eng2FireGnparkbrk);
			ECAM_controller.warningReset(eng2FireGnATC);
			ECAM_controller.warningReset(eng2FireGncrew);
			ECAM_controller.warningReset(eng2FireGnmaster);
			ECAM_controller.warningReset(eng2FireGnPB);
			ECAM_controller.warningReset(eng2FireGnAgent1);
			ECAM_controller.warningReset(eng2FireGnAgent2);
			ECAM_controller.warningReset(eng2FireGnEvac);
		}
	} else {
		ECAM_controller.warningReset(eng2FireFllever);
		ECAM_controller.warningReset(eng2FireFlmaster);
		ECAM_controller.warningReset(eng2FireFlPB);
		ECAM_controller.warningReset(eng2FireFlAgent1);
		ECAM_controller.warningReset(eng2FireFlATC);
		ECAM_controller.warningReset(eng2FireFl30Sec);
		ECAM_controller.warningReset(eng2FireFlAgent2);
		ECAM_controller.warningReset(eng2FireGnlever);
		ECAM_controller.warningReset(eng2FireGnstopped);
		ECAM_controller.warningReset(eng2FireGnparkbrk);
		ECAM_controller.warningReset(eng2FireGnATC);
		ECAM_controller.warningReset(eng2FireGncrew);
		ECAM_controller.warningReset(eng2FireGnmaster);
		ECAM_controller.warningReset(eng2FireGnPB);
		ECAM_controller.warningReset(eng2FireGnAgent1);
		ECAM_controller.warningReset(eng2FireGnAgent2);
		ECAM_controller.warningReset(eng2FireGnEvac);
	}
	
	# APU Fire
	if (apuFire.active == 1) {
		if (apuFirePB.clearFlag == 0 and !systems.APUNodes.Controls.fire.getValue()) {
			apuFirePB.active = 1;
		} else {
			ECAM_controller.warningReset(apuFirePB);
		}
		
		if (getprop("/systems/fire/apu/agent-timer") != 0 and getprop("/systems/fire/apu/agent-timer") != 99) {
			apuFireAgentTimer.msg = " -AGENT AFT " ~ getprop("/systems/fire/apu/agent-timer") ~ " S...DISCH";
		}
		
		if (apuFireAgent.clearFlag == 0 and systems.APUNodes.Controls.fire.getValue() and !getprop("/systems/fire/apu/disch") and getprop("/systems/fire/apu/agent-timer") != 0) {
			apuFireAgentTimer.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireAgentTimer);
		}
		
		if (apuFireAgent.clearFlag == 0 and systems.APUNodes.Controls.fire.getValue() and !getprop("/systems/fire/apu/disch") and getprop("/systems/fire/apu/agent-timer") == 0) {
			apuFireAgent.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireAgent);
		}
		
		if (apuFireMaster.clearFlag == 0 and systems.APUNodes.Controls.master.getBoolValue()) {
			apuFireMaster.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireMaster);
		}
	} else {
		ECAM_controller.warningReset(apuFirePB);
		ECAM_controller.warningReset(apuFireAgentTimer);
		ECAM_controller.warningReset(apuFireAgent);
		ECAM_controller.warningReset(apuFireMaster);
	}
	
	if ((getprop("/ECAM/to-config-test") and (phaseVar3 == 1 or phaseVar3 == 2 or phaseVar3 == 9)) or phaseVar3 == 3 or phaseVar3 == 4) {
		takeoffConfig = 1;
	} else {
		takeoffConfig = 0;
	}
	
	if ((pts.Controls.Flight.flapsInput.getValue() == 0 or pts.Controls.Flight.flapsInput.getValue() == 4) and takeoffConfig) {
		if (slats_config.clearFlag == 0) {
			slats_config.active = 1;
			slats_config_1.active = 1;
		} else {
			ECAM_controller.warningReset(slats_config);
			ECAM_controller.warningReset(slats_config_1);
		}
		if (flaps_config.clearFlag == 0) {
			flaps_config.active = 1;
			flaps_config_1.active = 1;
		} else {
			ECAM_controller.warningReset(flaps_config);
			ECAM_controller.warningReset(flaps_config_1);
		}
	} else {
		ECAM_controller.warningReset(slats_config);
		ECAM_controller.warningReset(slats_config_1);
		ECAM_controller.warningReset(flaps_config);
		ECAM_controller.warningReset(flaps_config_1);
	}
	
	if ((spd_brk_config.clearFlag == 0) and pts.Controls.Flight.speedbrake.getValue() != 0 and takeoffConfig) {
		spd_brk_config.active = 1;
		spd_brk_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(spd_brk_config);
		ECAM_controller.warningReset(spd_brk_config_1);
	}
	
	if ((pitch_trim_config.clearFlag == 0) and (getprop("/fdm/jsbsim/hydraulics/elevator-trim/final-deg") > 2.6 or getprop("/fdm/jsbsim/hydraulics/elevator-trim/final-deg") < -2.6) and takeoffConfig) {
		pitch_trim_config.active = 1;
		pitch_trim_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(pitch_trim_config);
		ECAM_controller.warningReset(pitch_trim_config_1);
	}
	
	if ((rud_trim_config.clearFlag == 0) and (getprop("/fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") < -3.6 or getprop("/fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") > 3.6) and takeoffConfig) {
		rud_trim_config.active = 1;
		rud_trim_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(rud_trim_config);
		ECAM_controller.warningReset(rud_trim_config_1);
	}
	
	if ((park_brk_config.clearFlag == 0) and warningNodes.Flipflops.parkBrk.getValue() and phaseVar3 >= 2 and phaseVar3 <= 3) {
		park_brk_config.active = 1;
	} else {
		ECAM_controller.warningReset(park_brk_config);
	}
	
	if (lrElevFault.clearFlag == 0 and warningNodes.Timers.LRElevFault.getValue()) {
		lrElevFault.active = 1;
		if (lrElevFaultSpeed.clearFlag == 0) {
			lrElevFaultSpeed.active = 1;
		} else {
			ECAM_controller.warningReset(lrElevFaultSpeed);
		}
		if (lrElevFaultTrim.clearFlag == 0) {
			lrElevFaultTrim.active = 1;
		} else {
			ECAM_controller.warningReset(lrElevFaultTrim);
		}
		if (lrElevFaultSpdBrk.clearFlag == 0) {
			lrElevFaultSpdBrk.active = 1;
		} else {
			ECAM_controller.warningReset(lrElevFaultSpdBrk);
		}
	} else {
		ECAM_controller.warningReset(lrElevFault);
		ECAM_controller.warningReset(lrElevFaultSpeed);
		ECAM_controller.warningReset(lrElevFaultTrim);
		ECAM_controller.warningReset(lrElevFaultSpdBrk);
	}
	
	if (gearNotDown.clearFlag == 0 and (warningNodes.Logic.gearNotDown1.getBoolValue() or warningNodes.Logic.gearNotDown2.getBoolValue()) and phaseVar3 != 3 and phaseVar3 != 4 and phaseVar3 != 5) {
		if (!gearNotDown.active) {
			gearWarnLight.setValue(1);
		}
		gearNotDown.active = 1;
	} else {
		if (gearNotDown.active) {
			gearWarnLight.setValue(0);
		}
		ECAM_controller.warningReset(gearNotDown);
	}
	
	if (gearNotDownLocked.clearFlag == 0 and warningNodes.Logic.gearNotDownLocked.getBoolValue() and phaseVar3 != 3 and phaseVar3 != 4 and phaseVar3 != 5 and phaseVar3 != 8) {
		gearNotDownLocked.active = 1;
		
		if (gearNotDownLockedRec.clearFlag == 0 and warningNodes.Logic.gearNotDownLockedFlipflop.getBoolValue()) {
			gearNotDownLockedRec.active = 1;
			gearNotDownLockedWork.active = 1;
		} else {
			ECAM_controller.warningReset(gearNotDownLockedRec);
			ECAM_controller.warningReset(gearNotDownLockedWork);
		}
		
		if (gearNotDownLocked120.clearFlag == 0) {
			gearNotDownLocked120.active = 1;
		} else {
			ECAM_controller.warningReset(gearNotDownLocked120);
		}
		
		if (gearNotDownLockedGrav.clearFlag == 0) {
			gearNotDownLockedGrav.active = 1;
		} else {
			ECAM_controller.warningReset(gearNotDownLockedGrav);
		}
	} else {
		ECAM_controller.warningReset(gearNotDownLocked);
		ECAM_controller.warningReset(gearNotDownLockedRec);
		ECAM_controller.warningReset(gearNotDownLockedWork);
		ECAM_controller.warningReset(gearNotDownLocked120);
		ECAM_controller.warningReset(gearNotDownLockedGrav);
	}
	
	# AUTOFLT
	if ((ap_offw.clearFlag == 0) and apWarn.getValue() == 2) {
		ap_offw.active = 1;
	} else {
		ECAM_controller.warningReset(ap_offw);
	}
	
	# C-Chord
	if (warningNodes.Logic.altitudeAlert.getValue()) {
		if (!getprop("/sim/sound/warnings/cchord-inhibit")) {
			aural[4].setValue(1);
		} else {
			aural[4].setValue(0);
		}
	} else {
		aural[4].setValue(0);
		setprop("/sim/sound/warnings/cchord-inhibit", 0);
	}
	
	if (warningNodes.Logic.altitudeAlertSteady.getValue()) {
		altAlertSteady = 1;
	} else {
		altAlertSteady = 0;
	}
	
	if (warningNodes.Logic.altitudeAlertFlash.getValue()) {
		altAlertFlash = 1;
	} else {
		altAlertFlash = 0;
	}
	
	if (!systems.cargoTestBtn.getBoolValue()) {
		if (cargoSmokeFwd.clearFlag == 0 and systems.fwdCargoFireWarn.getBoolValue() and (phaseVar3 <= 3 or phaseVar3 >= 9 or phaseVar3 == 6)) {
			cargoSmokeFwd.active = 1;
		} elsif (cargoSmokeFwd.clearFlag == 1 or systems.cargoTestBtnOff.getBoolValue()) {
			ECAM_controller.warningReset(cargoSmokeFwd);
			cargoSmokeFwd.isMainMsg = 1;
		}
		
		if (cargoSmokeFwdAgent.clearFlag == 0 and cargoSmokeFwd.active == 1 and !getprop("/systems/fire/cargo/disch")) {
			cargoSmokeFwdAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeFwdAgent);
			cargoSmokeFwd.isMainMsg = 0;
		}

		if (cargoSmokeAft.clearFlag == 0 and systems.aftCargoFireWarn.getBoolValue() and (phaseVar3 <= 3 or phaseVar3 >= 9 or phaseVar3 == 6)) {
			cargoSmokeAft.active = 1;
		} elsif (cargoSmokeAft.clearFlag == 1 or systems.cargoTestBtnOff.getBoolValue()) {
			ECAM_controller.warningReset(cargoSmokeAft);
			cargoSmokeAft.isMainMsg = 1;
			systems.cargoTestBtnOff.setBoolValue(0);
		}
		
		if (cargoSmokeAftAgent.clearFlag == 0 and cargoSmokeAft.active == 1 and !getprop("/systems/fire/cargo/disch")) {
			cargoSmokeAftAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeAftAgent);
			cargoSmokeAft.isMainMsg = 0;
		}
	} else {
		if (systems.aftCargoFireWarn.getBoolValue()) {
			cargoSmokeFwd.active = 1;
			cargoSmokeFwdAgent.active = 1;
			cargoSmokeAft.active = 1;
			cargoSmokeAftAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeFwd);
			ECAM_controller.warningReset(cargoSmokeFwdAgent);
			ECAM_controller.warningReset(cargoSmokeAft);
			ECAM_controller.warningReset(cargoSmokeAftAgent);
		}
	}
	
	# ESS on BAT
	if ((!gear.getValue() or !pts.Controls.Gear.gearDown.getValue()) and getprop("/systems/electrical/some-electric-thingie/static-inverter-timer") == 1 and phaseVar3 >= 5 and phaseVar3 <= 7) {
		essBusOnBat.active = 1;
		essBusOnBatLGUplock.active = 1;
		essBusOnBatManOn.active = 1;
		essBusOnBatRetract.active = 1;
		essBusOnBatMinSpeed.active = 1;
		essBusOnBatLGCB.active = 1;
	} else {
		ECAM_controller.warningReset(essBusOnBat);
		ECAM_controller.warningReset(essBusOnBatLGUplock);
		ECAM_controller.warningReset(essBusOnBatManOn);
		ECAM_controller.warningReset(essBusOnBatRetract);
		ECAM_controller.warningReset(essBusOnBatMinSpeed);
		ECAM_controller.warningReset(essBusOnBatLGCB);
	}
	
	# EMER CONFIG
	if (systems.ELEC.EmerElec.getValue() and !dualFailNode.getBoolValue() and phaseVar3 != 4 and phaseVar3 != 8 and emerconfig.clearFlag == 0 and !getprop("/systems/acconfig/autoconfig-running")) {
		emerconfig.active = 1;
		
		if (getprop("/systems/hydraulic/sources/rat/position") != 0 and emerconfigMinRat.clearFlag == 0) {
			emerconfigMinRat.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigMinRat);
		}
		
		if (!(getprop("/systems/electrical/some-electric-thingie/generator-1-reset") and getprop("/systems/electrical/some-electric-thingie/generator-2-reset")) and emerconfigGen.clearFlag == 0) {
			emerconfigGen.active = 1; # EGEN12R TRUE
		} else {
			ECAM_controller.warningReset(emerconfigGen);
		}
		
		if (!(getprop("/systems/electrical/some-electric-thingie/generator-1-reset-bustie") and getprop("/systems/electrical/some-electric-thingie/generator-2-reset-bustie")) and emerconfigGen2.clearFlag == 0) {
			emerconfigGen2.active = 1;
			if (getprop("/controls/electrical/switches/bus-tie")) {
				emerconfigBusTie.active = 1;
			} else {
				ECAM_controller.warningReset(emerconfigBusTie);
			}
			emerconfigGen3.active = 1; #  EGENRESET TRUE
		} else {
			ECAM_controller.warningReset(emerconfigGen2);
			ECAM_controller.warningReset(emerconfigBusTie);
			ECAM_controller.warningReset(emerconfigGen3);
		}
		
		if (getprop("/systems/electrical/relay/emer-glc/contact-pos") == 0 and emerconfigManOn.clearFlag == 0) {
			emerconfigManOn.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigManOn);
		}
		
		if (getprop("/controls/engines/engine-start-switch") != 2 and emerconfigEngMode.clearFlag == 0) {
			emerconfigEngMode.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigEngMode);
		}
		
		if (emerconfigRadio.clearFlag == 0) {
			emerconfigRadio.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigRadio);
		}
		
		if (emerconfigIcing.clearFlag == 0) {
			emerconfigIcing.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigIcing);
		}
		
		if (emerconfigFuelG.clearFlag == 0) {
			emerconfigFuelG.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigFuelG);
		}
		
		if (emerconfigFuelG2.clearFlag == 0) {
			emerconfigFuelG2.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigFuelG2);
		}
		
		if (fbw.FBW.Computers.fac1.getBoolValue() == 0 and emerconfigFAC.clearFlag == 0) {
			emerconfigFAC.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigFAC);
		}
		
		if (!getprop("/controls/electrical/switches/bus-tie") and emerconfigBusTie2.clearFlag == 0) {
			emerconfigBusTie2.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigBusTie2);
		}
		
		if (emerconfigAPU.clearFlag == 0) {
			emerconfigAPU.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigAPU);
		}
		
		if (emerconfigVent.clearFlag == 0) {
			emerconfigVent.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigVent);
		}
		
	} else {
		ECAM_controller.warningReset(emerconfig);
		ECAM_controller.warningReset(emerconfigMinRat);
		ECAM_controller.warningReset(emerconfigGen);
		ECAM_controller.warningReset(emerconfigGen2);
		ECAM_controller.warningReset(emerconfigBusTie);
		ECAM_controller.warningReset(emerconfigGen3);
		ECAM_controller.warningReset(emerconfigManOn);
		ECAM_controller.warningReset(emerconfigEngMode);
		ECAM_controller.warningReset(emerconfigRadio);
		ECAM_controller.warningReset(emerconfigIcing);
		ECAM_controller.warningReset(emerconfigFuelG);
		ECAM_controller.warningReset(emerconfigFuelG2);
		ECAM_controller.warningReset(emerconfigFAC);
		ECAM_controller.warningReset(emerconfigBusTie2);
		ECAM_controller.warningReset(emerconfigAPU);
		ECAM_controller.warningReset(emerconfigVent);
	}
	
	if (hydBYloPr.clearFlag == 0 and phaseVar3 != 4 and phaseVar3 != 5 and warningNodes.Logic.blueYellow.getValue()) {
		hydBYloPr.active = 1;
		if (hydBYloPrRat.clearFlag == 0 and systems.HYD.Rat.position.getValue() != 0) {
			hydBYloPrRat.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrRat);
		}
		
		if (hydBYloPrYElec.clearFlag == 0 and !systems.HYD.Pump.yellowElec.getValue() and systems.ELEC.Bus.ac2.getValue() >= 110 and systems.HYD.Qty.yellow.getValue() >= 3.5) { 
			hydBYloPrYElec.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrYElec);
		}
		
		if (hydBYloPrRatOn.clearFlag == 0 and systems.HYD.Rat.position.getValue() == 0 and systems.HYD.Qty.blue.getValue() >= 2.4) {
			hydBYloPrRatOn.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrRatOn);
		}
		
		if (hydBYloPrBElec.clearFlag == 0 and systems.HYD.Switch.blueElec.getValue()) {
			hydBYloPrBElec.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrBElec);
		}
		
		if (hydBYloPrYEng.clearFlag == 0 and systems.HYD.Switch.yellowEDP.getValue()) {
			hydBYloPrYEng.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrYEng);
		}
		
		if (hydBYloPrMaxSpd.clearFlag == 0) {
			hydBYloPrMaxSpd.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrMaxSpd);
		}
		
		if (hydBYloPrMnvrCare.clearFlag == 0) {
			hydBYloPrMnvrCare.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrMnvrCare);
		}
		
		if (hydBYloPrGaPitch.clearFlag == 0) {
			hydBYloPrGaPitch.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrGaPitch);
		}
		
		if (hydBYloPrFuelCnsmpt.clearFlag == 0 and warningNodes.Logic.blueYellowFuel.getValue()) {
			hydBYloPrFuelCnsmpt.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrFuelCnsmpt);
		}
		
		if (hydBYloPrFmsPredict.clearFlag == 0 and warningNodes.Logic.blueYellowFuel.getValue()) {
			hydBYloPrFmsPredict.active = 1;
		} else {
			ECAM_controller.warningReset(hydBYloPrFmsPredict);
		}
	} else {
		ECAM_controller.warningReset(hydBYloPr);
		ECAM_controller.warningReset(hydBYloPrRat);
		ECAM_controller.warningReset(hydBYloPrYElec);
		ECAM_controller.warningReset(hydBYloPrRatOn);
		ECAM_controller.warningReset(hydBYloPrBElec);
		ECAM_controller.warningReset(hydBYloPrYEng);
		ECAM_controller.warningReset(hydBYloPrMaxSpd);
		ECAM_controller.warningReset(hydBYloPrMnvrCare);
		ECAM_controller.warningReset(hydBYloPrGaPitch);
		ECAM_controller.warningReset(hydBYloPrFuelCnsmpt);
		ECAM_controller.warningReset(hydBYloPrFmsPredict);
	}
	
	if (hydGBloPr.clearFlag == 0 and phaseVar3 != 4 and phaseVar3 != 5 and warningNodes.Logic.blueGreen.getValue()) {
		hydGBloPr.active = 1;
		if (hydGBloPrRat.clearFlag == 0 and systems.HYD.Rat.position.getValue() != 0) {
			hydGBloPrRat.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrRat);
		}
		
		if (hydGBloPrRatOn.clearFlag == 0 and systems.HYD.Rat.position.getValue() == 0 and systems.HYD.Qty.blue.getValue() >= 2.4) {
			hydGBloPrRatOn.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrRatOn);
		}
		
		if (hydGBloPrBElec.clearFlag == 0 and systems.HYD.Switch.blueElec.getValue()) {
			hydGBloPrBElec.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrBElec);
		}
		
		if (hydGBloPrGEng.clearFlag == 0 and systems.HYD.Switch.greenEDP.getValue()) {
			hydGBloPrGEng.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrGEng);
		}
		
		if (hydGBloPrMnvrCare.clearFlag == 0) {
			hydGBloPrMnvrCare.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrMnvrCare);
		}
		
		if (hydGBloPrGaPitch.clearFlag == 0) {
			hydGBloPrGaPitch.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrGaPitch);
		}
		
		if (hydGBloPrFuelCnsmpt.clearFlag == 0 and warningNodes.Logic.blueGreenFuel.getValue()) {
			hydGBloPrFuelCnsmpt.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrFuelCnsmpt);
		}
		
		if (hydGBloPrFmsPredict.clearFlag == 0 and warningNodes.Logic.blueGreenFuel.getValue()) {
			hydGBloPrFmsPredict.active = 1;
		} else {
			ECAM_controller.warningReset(hydGBloPrFmsPredict);
		}
	} else {
		ECAM_controller.warningReset(hydGBloPr);
		ECAM_controller.warningReset(hydGBloPrRat);
		ECAM_controller.warningReset(hydGBloPrRatOn);
		ECAM_controller.warningReset(hydGBloPrBElec);
		ECAM_controller.warningReset(hydGBloPrGEng);
		ECAM_controller.warningReset(hydGBloPrMnvrCare);
		ECAM_controller.warningReset(hydGBloPrGaPitch);
		ECAM_controller.warningReset(hydGBloPrFuelCnsmpt);
		ECAM_controller.warningReset(hydGBloPrFmsPredict);
	}
	
	if (hydGYloPr.clearFlag == 0 and phaseVar3 != 4 and phaseVar3 != 5 and warningNodes.Logic.greenYellow.getValue()) {
		hydGYloPr.active = 1;
		if (hydGYloPrPtu.clearFlag == 0 and systems.HYD.Switch.ptu.getValue() != 0) {
			hydGYloPrPtu.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrPtu);
		}
		
		if (hydGYloPrGEng.clearFlag == 0 and systems.HYD.Switch.greenEDP.getValue()) {
			hydGYloPrGEng.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrGEng);
		}
		
		if (hydGYloPrYEng.clearFlag == 0 and systems.HYD.Switch.yellowEDP.getValue()) {
			hydGYloPrYEng.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrYEng);
		}
		
		if (hydGYloPrYElec.clearFlag == 0 and !systems.HYD.Pump.yellowElec.getValue() and systems.ELEC.Bus.ac2.getValue() >= 110 and systems.HYD.Qty.yellow.getValue() >= 3.5) { 
			hydGYloPrYElec.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrYElec);
		}
		
		if (hydGYloPrMnvrCare.clearFlag == 0) {
			hydGYloPrMnvrCare.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrMnvrCare);
		}
		
		if (hydGYloPrFuelCnsmpt.clearFlag == 0 and warningNodes.Logic.greenYellowFuel.getValue()) {
			hydGYloPrFuelCnsmpt.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrFuelCnsmpt);
		}
		
		if (hydGYloPrFmsPredict.clearFlag == 0 and warningNodes.Logic.greenYellowFuel.getValue()) {
			hydGYloPrFmsPredict.active = 1;
		} else {
			ECAM_controller.warningReset(hydGYloPrFmsPredict);
		}
	} else {
		ECAM_controller.warningReset(hydGYloPr);
		ECAM_controller.warningReset(hydGYloPrPtu);
		ECAM_controller.warningReset(hydGYloPrGEng);
		ECAM_controller.warningReset(hydGYloPrYEng);
		ECAM_controller.warningReset(hydGYloPrYElec);
		ECAM_controller.warningReset(hydGYloPrMnvrCare);
		ECAM_controller.warningReset(hydGYloPrFuelCnsmpt);
		ECAM_controller.warningReset(hydGYloPrFmsPredict);
	}
}

var messages_priority_2 = func {
	phaseVar2 = phaseNode.getValue();
	# DC EMER CONFIG
	if (!systems.ELEC.EmerElec.getValue() and systems.ELEC.Bus.dcEss.getValue() < 25 and systems.ELEC.Bus.dc1.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() < 25 and phaseVar2 != 4 and phaseVar2 != 8 and dcEmerconfig.clearFlag == 0) {
		dcEmerconfig.active = 1;
		dcEmerconfigManOn.active = 1;
	} else {
		ECAM_controller.warningReset(dcEmerconfig);
		ECAM_controller.warningReset(dcEmerconfigManOn);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and !dcEmerconfig.active and systems.ELEC.Bus.dc1.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() < 25 and phaseVar2 != 4 and phaseVar2 != 8 and dcBus12Fault.clearFlag == 0) {
		dcBus12Fault.active = 1;
		dcBus12FaultBlower.active = 1;
		dcBus12FaultExtract.active = 1;
		dcBus12FaultBaroRef.active = 1;
		dcBus12FaultIcing.active = 1;
		dcBus12FaultBrking.active = 1;
	} else {
		ECAM_controller.warningReset(dcBus12Fault);
		ECAM_controller.warningReset(dcBus12FaultBlower);
		ECAM_controller.warningReset(dcBus12FaultExtract);
		ECAM_controller.warningReset(dcBus12FaultBaroRef);
		ECAM_controller.warningReset(dcBus12FaultIcing);
		ECAM_controller.warningReset(dcBus12FaultBrking);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and systems.ELEC.Bus.acEss.getValue() < 110 and phaseVar2 != 4 and phaseVar2 != 8 and AcBusEssFault.clearFlag == 0) {
		AcBusEssFault.active = 1;
		if (!systems.ELEC.Switch.acEssFeed.getBoolValue()) {
			AcBusEssFaultFeed.active = 1;
		} else {
			ECAM_controller.warningReset(AcBusEssFaultFeed);
		}
		AcBusEssFaultAtc.active = 1;
	} else {
		ECAM_controller.warningReset(AcBusEssFault);
		ECAM_controller.warningReset(AcBusEssFaultFeed);
		ECAM_controller.warningReset(AcBusEssFaultAtc);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and systems.ELEC.Bus.ac1.getValue() < 110 and phaseVar2 != 4 and phaseVar2 != 8 and AcBus1Fault.clearFlag == 0) {
		AcBus1Fault.active = 1;
		AcBus1FaultBlower.active = 1;
	} else {
		ECAM_controller.warningReset(AcBus1Fault);
		ECAM_controller.warningReset(AcBus1FaultBlower);
	}
	
	if (!dcEmerconfig.active and systems.ELEC.Bus.dcEss.getValue() < 25 and phaseVar2 != 4 and phaseVar2 != 8 and DcEssBusFault.clearFlag == 0) {
		DcEssBusFault.active = 1;
		DcEssBusFaultRadio.active = 1;
		DcEssBusFaultRadio2.active = 1;
		DcEssBusFaultBaro.active = 1;
		DcEssBusFaultGPWS.active = 1;
	} else {
		ECAM_controller.warningReset(DcEssBusFault);
		ECAM_controller.warningReset(DcEssBusFaultRadio);
		ECAM_controller.warningReset(DcEssBusFaultRadio2);
		ECAM_controller.warningReset(DcEssBusFaultBaro);
		ECAM_controller.warningReset(DcEssBusFaultGPWS);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and systems.ELEC.Bus.ac2.getValue() < 110 and phaseVar2 != 4 and phaseVar2 != 8 and AcBus2Fault.clearFlag == 0) {
		AcBus2Fault.active = 1;
		AcBus2FaultExtract.active = 1;
	} else {
		ECAM_controller.warningReset(AcBus2Fault);
		ECAM_controller.warningReset(AcBus2FaultExtract);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and systems.ELEC.Bus.dc1.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() >= 25 and phaseVar2 != 4 and phaseVar2 != 8 and dcBus1Fault.clearFlag == 0) {
		dcBus1Fault.active = 1;
		dcBus1FaultBlower.active = 1;
		dcBus1FaultExtract.active = 1;
	} else {
		ECAM_controller.warningReset(dcBus1Fault);
		ECAM_controller.warningReset(dcBus1FaultBlower);
		ECAM_controller.warningReset(dcBus1FaultExtract);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and systems.ELEC.Bus.dc1.getValue() >= 25 and systems.ELEC.Bus.dc2.getValue() <= 25 and phaseVar2 != 4 and phaseVar2 != 8 and dcBus2Fault.clearFlag == 0) {
		dcBus2Fault.active = 1;
		dcBus2FaultAirData.active = 1;
		dcBus2FaultBaro.active = 1;
	} else {
		ECAM_controller.warningReset(dcBus2Fault);
		ECAM_controller.warningReset(dcBus2FaultAirData);
		ECAM_controller.warningReset(dcBus2FaultBaro);
	}
	
	if (!systems.ELEC.EmerElec.getValue() and !dcEmerconfig.active and systems.ELEC.Bus.dcBat.getValue() < 25 and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8 and dcBusBatFault.clearFlag == 0) {
		dcBusBatFault.active = 1;
	} else {
		ECAM_controller.warningReset(dcBusBatFault);
	}
	
	if (!(systems.ELEC.EmerElec.getValue() and !getprop("/systems/electrical/relay/emer-glc/contact-pos")) and systems.ELEC.Bus.dcEssShed.getValue() < 25 and systems.ELEC.Bus.dcEss.getValue() >= 25 and phaseVar2 != 4 and phaseVar2 != 8 and dcBusEssShed.clearFlag == 0) {
		dcBusEssShed.active = 1;
		dcBusEssShedExtract.active = 1;
		dcBusEssShedIcing.active = 1;
	} else {
		ECAM_controller.warningReset(dcBusEssShed);
		ECAM_controller.warningReset(dcBusEssShedExtract);
		ECAM_controller.warningReset(dcBusEssShedIcing);
	}
	
	if (!(systems.ELEC.EmerElec.getValue() and !getprop("/systems/electrical/relay/emer-glc/contact-pos")) and systems.ELEC.Bus.acEssShed.getValue() < 110 and systems.ELEC.Bus.acEss.getValue() >= 110 and phaseVar2 != 4 and phaseVar2 != 8 and acBusEssShed.clearFlag == 0) {
		acBusEssShed.active = 1;
		if (!systems.ELEC.EmerElec.getValue()) {
			acBusEssShedAtc.active = 1;
		} else {
			ECAM_controller.warningReset(acBusEssShed);
		}
	} else {
		ECAM_controller.warningReset(acBusEssShed);
		ECAM_controller.warningReset(acBusEssShedAtc);
	}
	
	if (gen1fault.clearFlag == 0 and warningNodes.Flipflops.gen1Fault.getValue() and (phaseVar2 == 2 or phaseVar2 == 3 or phaseVar2 == 6 or phaseVar2 == 9)) {
		gen1fault.active = 1;
		if (!warningNodes.Flipflops.gen1FaultOnOff.getValue()) {
			gen1faultGen.active = 1;
		} else {
			ECAM_controller.warningReset(gen1faultGen);
		}
		
		if (systems.ELEC.Switch.gen1.getBoolValue()) {
			gen1faultGen2.active = 1;
			gen1faultGen3.active = 1;
		} else {
			ECAM_controller.warningReset(gen1faultGen2);
			ECAM_controller.warningReset(gen1faultGen3);
		}
	} else {
		ECAM_controller.warningReset(gen1fault);
		ECAM_controller.warningReset(gen1faultGen);
		ECAM_controller.warningReset(gen1faultGen2);
		ECAM_controller.warningReset(gen1faultGen3);
	}
	
	if (gen2fault.clearFlag == 0 and warningNodes.Flipflops.gen2Fault.getValue() and (phaseVar2 == 2 or phaseVar2 == 3 or phaseVar2 == 6 or phaseVar2 == 9)) {
		gen2fault.active = 1;
		if (!warningNodes.Flipflops.gen2FaultOnOff.getValue()) {
			gen2faultGen.active = 1;
		} else {
			ECAM_controller.warningReset(gen2faultGen);
		}
		
		if (systems.ELEC.Switch.gen2.getBoolValue()) {
			gen2faultGen2.active = 1;
			gen2faultGen3.active = 1;
		} else {
			ECAM_controller.warningReset(gen2faultGen2);
			ECAM_controller.warningReset(gen2faultGen3);
		}
	} else {
		ECAM_controller.warningReset(gen2fault);
		ECAM_controller.warningReset(gen2faultGen);
		ECAM_controller.warningReset(gen2faultGen2);
		ECAM_controller.warningReset(gen2faultGen3);
	}
	
	if (apuGenfault.clearFlag == 0 and warningNodes.Flipflops.apuGenFault.getValue() and (phaseVar2 <= 3 or phaseVar2 == 6 or phaseVar2 >= 9)) {
		apuGenfault.active = 1;
		if (!warningNodes.Flipflops.apuGenFaultOnOff.getValue()) {
			apuGenfaultGen.active = 1;
		} else {
			ECAM_controller.warningReset(apuGenfaultGen);
		}
		
		if (systems.ELEC.Switch.genApu.getBoolValue()) {
			apuGenfaultGen2.active = 1;
			apuGenfaultGen3.active = 1;
		} else {
			ECAM_controller.warningReset(apuGenfaultGen2);
			ECAM_controller.warningReset(apuGenfaultGen3);
		}
	} else {
		ECAM_controller.warningReset(apuGenfault);
		ECAM_controller.warningReset(apuGenfaultGen);
		ECAM_controller.warningReset(apuGenfaultGen2);
		ECAM_controller.warningReset(apuGenfaultGen3);
	}
	
	if (lElevFault.clearFlag == 0 and warningNodes.Timers.leftElevFail.getValue() and phaseVar2 != 4 and phaseVar2 != 5) {
		lElevFault.active = 1;
		if (lElevFaultCare.clearFlag == 0) {
			lElevFaultCare.active = 1;
		} else {
			ECAM_controller.warningReset(lElevFaultCare);
		}
		if (lElevFaultPitch.clearFlag == 0) {
			lElevFaultPitch.active = 1;
		} else {
			ECAM_controller.warningReset(lElevFaultPitch);
		}
	} else {
		ECAM_controller.warningReset(lElevFault);
		ECAM_controller.warningReset(lElevFaultCare);
		ECAM_controller.warningReset(lElevFaultPitch);
	}
	
	if (rElevFault.clearFlag == 0 and warningNodes.Timers.rightElevFail.getValue() and phaseVar2 != 4 and phaseVar2 != 5) {
		rElevFault.active = 1;
		if (rElevFaultCare.clearFlag == 0) {
			rElevFaultCare.active = 1;
		} else {
			ECAM_controller.warningReset(rElevFaultCare);
		}
		if (rElevFaultPitch.clearFlag == 0) {
			rElevFaultPitch.active = 1;
		} else {
			ECAM_controller.warningReset(rElevFaultPitch);
		}
	} else {
		ECAM_controller.warningReset(rElevFault);
		ECAM_controller.warningReset(rElevFaultCare);
		ECAM_controller.warningReset(rElevFaultPitch);
	}
	
	if (directLaw.clearFlag == 0 and warningNodes.Timers.directLaw.getValue() and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8) {
		directLaw.active = 1;
		directLawProt.active = 1;
		if (directLawMaxSpeed.clearFlag == 0 and !fbw.tripleADRFail and pts.Gear.position[1].getValue() == 1) {
			directLawMaxSpeed.active = 1;
		} else {
			ECAM_controller.warningReset(directLawMaxSpeed);
		}
		if (directLawTrim.clearFlag == 0 and (systems.HYD.Psi.green.getValue() >= 1500 or systems.HYD.Psi.yellow.getValue() >= 1500) and !fbw.FBW.Failures.ths.getValue()) {
			directLawTrim.active = 1;
		} else {
			ECAM_controller.warningReset(directLawTrim);
		}
		if (directLawCare.clearFlag == 0 and (fbw.tripleADRFail or pts.Gear.position[1].getValue() == 1)) {
			directLawCare.active = 1;
		} else {
			ECAM_controller.warningReset(directLawCare);
		}
		if (directLawSpdBrk.clearFlag == 0 and !fbw.tripleADRFail and pts.Gear.position[1].getValue() == 1) {
			directLawSpdBrk.active = 1;
		} else {
			ECAM_controller.warningReset(directLawSpdBrk);
		}
		if (directLawSpdBrk2.clearFlag == 0 and fbw.tripleADRFail) {
			directLawSpdBrk2.active = 1;
		} else {
			ECAM_controller.warningReset(directLawSpdBrk2);
		}
	} else {
		ECAM_controller.warningReset(directLaw);
		ECAM_controller.warningReset(directLawProt);
		ECAM_controller.warningReset(directLawMaxSpeed);
		ECAM_controller.warningReset(directLawTrim);
		ECAM_controller.warningReset(directLawCare);
		ECAM_controller.warningReset(directLawSpdBrk);
		ECAM_controller.warningReset(directLawSpdBrk2);
	}
	
	if (altnLaw.clearFlag == 0 and warningNodes.Timers.altnLaw.getValue() and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8) {
		altnLaw.active = 1;
		altnLawProt.active = 1;
		if (altnLawMaxSpeed.clearFlag == 0 and altnLawMaxSpeed2.clearFlag == 0 and !fbw.tripleADRFail) {
			if (!(getprop("/ECAM/warnings/hyd/green-abnorm-lo-pr") and (getprop("/ECAM/warnings/hyd/blue-abnorm-lo-pr") or getprop("/ECAM/warnings/hyd/yellow-abnorm-lo-pr")))) {
				altnLawMaxSpeed.active = 1;
				ECAM_controller.warningReset(altnLawMaxSpeed2);
			} else {
				altnLawMaxSpeed2.active = 1;
				ECAM_controller.warningReset(altnLawMaxSpeed);
			}
		} else {
			ECAM_controller.warningReset(altnLawMaxSpeed);
			ECAM_controller.warningReset(altnLawMaxSpeed2);
		}
		
		if (altnLawMaxSpdBrk.clearFlag == 0 and (fbw.tripleADRFail or warningNodes.Logic.leftElevFail.getValue() or warningNodes.Logic.rightElevFail.getValue())) {
			altnLawMaxSpdBrk.active = 1;
		} else {
			ECAM_controller.warningReset(altnLawMaxSpdBrk);
		}
	} else {
		ECAM_controller.warningReset(altnLaw);
		ECAM_controller.warningReset(altnLawProt);
		ECAM_controller.warningReset(altnLawMaxSpeed);
		ECAM_controller.warningReset(altnLawMaxSpeed2);
		ECAM_controller.warningReset(altnLawMaxSpdBrk);
	}
	
	if ((athr_offw.clearFlag == 0) and athrWarn.getValue() == 2 and phaseVar2 != 4 and phaseVar2 != 8 and phaseVar2 != 10) {
		athr_offw.active = 1;
		athr_offw_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_offw);
		ECAM_controller.warningReset(athr_offw_1);
	}
	
	if ((athr_lock.clearFlag == 0) and phaseVar2 >= 5 and phaseVar2 <= 7 and getprop("/systems/thrust/thr-locked-alert") == 1) {
		if (getprop("/systems/thrust/thr-locked-flash") == 0) {
			athr_lock.msg = " ";
		} else {
			athr_lock.msg = msgSave
		}
		athr_lock.active = 1;
		athr_lock_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_lock);
		ECAM_controller.warningReset(athr_lock_1);
	}
	
	
	if ((athr_lim.clearFlag == 0) and getprop("it-autoflight/output/athr") == 1 and ((getprop("/systems/thrust/eng-out") != 1 and (pts.Systems.Thrust.state[0].getValue() == "MAN" or pts.Systems.Thrust.state[1].getValue() == "MAN")) or (getprop("/systems/thrust/eng-out") == 1 and (pts.Systems.Thrust.state[0].getValue() == "MAN" or pts.Systems.Thrust.state[1].getValue() == "MAN" or (pts.Systems.Thrust.state[0].getValue() == "MAN THR" and getprop("/controls/engines/engine[0]/throttle-pos") <= 0.83) or (pts.Systems.Thrust.state[1].getValue() == "MAN THR" and getprop("/controls/engines/engine[0]/throttle-pos") <= 0.83)))) and (phaseVar2 >= 5 and phaseVar2 <= 7)) {
		athr_lim.active = 1;
		athr_lim_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_lim);
		ECAM_controller.warningReset(athr_lim_1);
	}
	
	if (getprop("/instrumentation/tcas/serviceable") == 0 and phaseVar2 != 1 and phaseVar2 != 3 and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8 and phaseVar2 != 10 and systems.ELEC.Bus.ac1.getValue() >= 110 and pts.Instrumentation.TCAS.Inputs.mode.getValue() != 1 and tcasFault.clearFlag == 0) {
		tcasFault.active = 1;
	} else {
		ECAM_controller.warningReset(tcasFault);
	}
	
	if (phaseVar2 == 6 and pts.Instrumentation.TCAS.Inputs.mode.getValue() == 1 and !tcasFault.active and (atc.Transponders.vector[0].condition != 0 and atc.Transponders.vector[1].condition != 0) and tcasStby.clearFlag == 0) {
		tcasStby.active = 1;
	} else {
		ECAM_controller.warningReset(tcasStby);
	}
	
	if (gpwsTerrFault.clearFlag == 0 and warningNodes.Timers.navTerrFault.getValue() == 1 and (phaseVar2 == 2 or phaseVar2 == 6 or phaseVar2 == 7 or phaseVar2 == 9)) {
		gpwsTerrFault.active = 1;
		
		if (gpwsTerrFaultOff.clearFlag == 0 and !getprop("/instrumentation/mk-viii/inputs/discretes/ta-tcf-inhibit")) {
			gpwsTerrFaultOff.active = 1;
		} else {
			ECAM_controller.warningReset(gpwsTerrFaultOff);
		}
	} else {
		ECAM_controller.warningReset(gpwsTerrFault);
		ECAM_controller.warningReset(gpwsTerrFaultOff);
	}
	
	if (fac12Fault.clearFlag == 0 and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8 and warningNodes.Logic.fac12Fault.getBoolValue()) {
		fac12Fault.active = 1;
		fac12FaultRud.active = 1;
		fac12FaultFac.active = 1;
		fac12FaultSuccess.active = 1;
		fac12FaultFacOff.active = 1;
	} else {
		ECAM_controller.warningReset(fac12Fault);
		ECAM_controller.warningReset(fac12FaultRud);
		ECAM_controller.warningReset(fac12FaultFac);
		ECAM_controller.warningReset(fac12FaultSuccess);
		ECAM_controller.warningReset(fac12FaultFacOff);
	}
	
	if (yawDamperSysFault.clearFlag == 0 and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8 and phaseVar2 != 10 and warningNodes.Logic.yawDamper12Fault.getBoolValue()) {
		yawDamperSysFault.active = 1;
		yawDamperSysFaultFac1.active = 1;
		yawDamperSysFaultFac2.active = 1;
	} else {
		ECAM_controller.warningReset(yawDamperSysFault);
		ECAM_controller.warningReset(yawDamperSysFaultFac1);
		ECAM_controller.warningReset(yawDamperSysFaultFac2);
	}
	
	if (rudTravLimSysFault.clearFlag == 0 and phaseVar2 != 4 and phaseVar2 != 5 and phaseVar2 != 7 and phaseVar2 != 8 and warningNodes.Logic.rtlu12Fault.getBoolValue()) {
		rudTravLimSysFault.active = 1;
		rudTravLimSysFaultRud.active = 1;
		rudTravLimSysFaultFac.active = 1;
	} else {
		ECAM_controller.warningReset(rudTravLimSysFault);
		ECAM_controller.warningReset(rudTravLimSysFaultRud);
		ECAM_controller.warningReset(rudTravLimSysFaultFac);
	}
	
	if (fac1Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.fac1Fault.getBoolValue()) {
		fac1Fault.active = 1;
		fac1FaultFac.active = 1;
		fac1FaultSuccess.active = 1;
		fac1FaultFacOff.active = 1;
	} else {
		ECAM_controller.warningReset(fac1Fault);
		ECAM_controller.warningReset(fac1FaultFac);
		ECAM_controller.warningReset(fac1FaultSuccess);
		ECAM_controller.warningReset(fac1FaultFacOff);
	}
	
	if (fac2Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.fac2Fault.getBoolValue()) {
		fac2Fault.active = 1;
		fac2FaultFac.active = 1;
		fac2FaultSuccess.active = 1;
		fac2FaultFacOff.active = 1;
	} else {
		ECAM_controller.warningReset(fac2Fault);
		ECAM_controller.warningReset(fac2FaultFac);
		ECAM_controller.warningReset(fac2FaultSuccess);
		ECAM_controller.warningReset(fac2FaultFacOff);
	}
	
	if (yawDamper1Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 == 9 or phaseVar2 == 6) and warningNodes.Timers.yawDamper1Fault.getValue() == 1 and !warningNodes.Logic.yawDamper12Fault.getBoolValue()) {
		yawDamper1Fault.active = 1;
	} else {
		ECAM_controller.warningReset(yawDamper1Fault);
	}
	
	if (yawDamper2Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 == 9 or phaseVar2 == 6) and warningNodes.Timers.yawDamper2Fault.getValue() == 1 and !warningNodes.Logic.yawDamper12Fault.getBoolValue()) {
		yawDamper2Fault.active = 1;
	} else {
		ECAM_controller.warningReset(yawDamper2Fault);
	}
	
	if (rudTravLimSys1Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.rtlu1Fault.getBoolValue()) {
		rudTravLimSys1Fault.active = 1;
	} else {
		ECAM_controller.warningReset(rudTravLimSys1Fault);
	}
	
	if (rudTravLimSys2Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.rtlu2Fault.getBoolValue()) {
		rudTravLimSys2Fault.active = 1;
	} else {
		ECAM_controller.warningReset(rudTravLimSys2Fault);
	}
	
	if (fcu.FCUController.FCU1.failed and fcu.FCUController.FCU2.failed and systems.ELEC.Bus.dcEss.getValue() >= 25 and systems.ELEC.Bus.dcEss.getValue() >= 25 and fcuFault.clearFlag == 0) {
		fcuFault.active = 1;
		fcuFaultBaro.active = 1;
	} else {
		ECAM_controller.warningReset(fcuFault);
		ECAM_controller.warningReset(fcuFaultBaro);
	}
	
	if (fcu.FCUController.FCU1.failed and !fcu.FCUController.FCU2.failed and systems.ELEC.Bus.dcEss.getValue() >= 25 and fcuFault1.clearFlag == 0) {
		fcuFault1.active = 1;
		fcuFault1Baro.active = 1;
	} else {
		ECAM_controller.warningReset(fcuFault1);
		ECAM_controller.warningReset(fcuFault1Baro);
	}
	
	if (fcu.FCUController.FCU2.failed and !fcu.FCUController.FCU1.failed and systems.ELEC.Bus.dc2.getValue() >= 25 and fcuFault2.clearFlag == 0) {
		fcuFault2.active = 1;
		fcuFault2Baro.active = 1;
	} else {
		ECAM_controller.warningReset(fcuFault2);
		ECAM_controller.warningReset(fcuFault2Baro);
	}
	
	# APU EMER SHUT DOWN
	if (apuEmerShutdown.clearFlag == 0 and systems.APUController.APU.signals.autoshutdown and systems.APUController.APU.signals.emer and !getprop("/systems/fire/apu/warning-active") and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		apuEmerShutdown.active = 1;
	} elsif (apuEmerShutdown.clearFlag == 1) {
		ECAM_controller.warningReset(apuEmerShutdown);
	}
	
	if (apuEmerShutdownMast.clearFlag == 0 and systems.APUNodes.Controls.master.getBoolValue() and apuEmerShutdown.active == 1) {
		apuEmerShutdownMast.active = 1;
	} else {
		ECAM_controller.warningReset(apuEmerShutdownMast);
	}
	
	# APU AUTO SHUT DOWN
	if (apuAutoShutdown.clearFlag == 0 and systems.APUController.APU.signals.autoshutdown and !systems.APUController.APU.signals.emer and !getprop("/systems/fire/apu/warning-active") and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		apuAutoShutdown.active = 1;
	} elsif (apuAutoShutdown.clearFlag == 1) {
		ECAM_controller.warningReset(apuAutoShutdown);
	}
	
	if (apuAutoShutdownMast.clearFlag == 0 and systems.APUNodes.Controls.master.getValue() and apuAutoShutdown.active == 1) {
		apuAutoShutdownMast.active = 1;
	} else {
		ECAM_controller.warningReset(apuAutoShutdownMast);
	}
	
	# Bleed
	# BLEED 1 FAULT
	if ((FWC.Timer.eng1idleOutput.getBoolValue() == 1 and !pts.Controls.Engines.Engine.cutoffSw[0].getValue()) and (systems.PNEU.Warnings.overpress1.getValue() or systems.PNEU.Warnings.ovht1.getValue())) {
		warningNodes.Timers.bleed1Fault.setValue(1);
	} else {
		warningNodes.Timers.bleed1Fault.setValue(0);
	}
	
	if (bleed1Fault.clearFlag == 0 and (phaseVar2 == 2 or phaseVar2 == 6 or phaseVar2 == 9) and warningNodes.Timers.bleed1FaultOutput.getValue() == 1 and (!systems.PNEU.Switch.pack1.getBoolValue() or !systems.PNEU.Switch.pack2.getBoolValue() or !(getprop("/ECAM/phases/wing-anti-ice-pulse") and getprop("/controls/ice-protection/wing")))) { # inverse pulse
		bleed1Fault.active = 1;
	} else {
		ECAM_controller.warningReset(bleed1Fault);
	}
	
	if (bleed1Fault.active) {
		if (bleed1FaultOff.clearFlag == 0 and systems.PNEU.Switch.bleed1.getBoolValue() and systems.PNEU.Warnings.prv1Disag.getValue()) {
			bleed1FaultOff.active = 1;
		} else {
			ECAM_controller.warningReset(bleed1FaultOff);
		}
		
		if (bleed1FaultPack.clearFlag == 0 and systems.PNEU.Switch.pack1.getBoolValue() and systems.PNEU.Switch.pack2.getBoolValue() and getprop("/ECAM/warnings/logic/wai-on")) {
			bleed1FaultPack.active = 1;
		} else {
			ECAM_controller.warningReset(bleed1FaultPack);
		}
		
		if (bleed1FaultXBleed.clearFlag == 0 and systems.PNEU.Valves.crossbleed.getValue() == 0) {
			bleed1FaultXBleed.active = 1;
		} else {
			ECAM_controller.warningReset(bleed1FaultXBleed);
		}
	} else {
		ECAM_controller.warningReset(bleed1FaultOff);
		ECAM_controller.warningReset(bleed1FaultPack);
		ECAM_controller.warningReset(bleed1FaultXBleed);
	}
	
	# BLEED 2 FAULT
	if ((FWC.Timer.eng2idleOutput.getBoolValue() == 1 and !pts.Controls.Engines.Engine.cutoffSw[1].getValue()) and (systems.PNEU.Warnings.overpress2.getValue() or systems.PNEU.Warnings.ovht2.getValue())) {
		warningNodes.Timers.bleed2Fault.setValue(1);
	} else {
		warningNodes.Timers.bleed2Fault.setValue(0);
	}
	
	if (bleed2Fault.clearFlag == 0 and (phaseVar2 == 2 or phaseVar2 == 6 or phaseVar2 == 9) and warningNodes.Timers.bleed2FaultOutput.getValue() == 1 and (!systems.PNEU.Switch.pack1.getBoolValue() or !systems.PNEU.Switch.pack2.getBoolValue() or !(getprop("/ECAM/phases/wing-anti-ice-pulse") and getprop("/controls/ice-protection/wing")))) { # inverse pulse
		bleed2Fault.active = 1;
	} else {
		ECAM_controller.warningReset(bleed2Fault);
	}
	
	if (bleed2Fault.active) {
		if (bleed2FaultOff.clearFlag == 0 and systems.PNEU.Switch.bleed2.getBoolValue() and systems.PNEU.Warnings.prv2Disag.getValue()) {
			bleed2FaultOff.active = 1;
		} else {
			ECAM_controller.warningReset(bleed2FaultOff);
		}
		
		if (bleed2FaultPack.clearFlag == 0 and systems.PNEU.Switch.pack1.getValue() and systems.PNEU.Switch.pack2.getValue() and getprop("/ECAM/warnings/logic/wai-on")) {
			bleed2FaultPack.active = 1;
		} else {
			ECAM_controller.warningReset(bleed2FaultPack);
		}
		
		if (bleed2FaultXBleed.clearFlag == 0 and systems.PNEU.Valves.crossbleed.getValue() == 0) {
			bleed2FaultXBleed.active = 1;
		} else {
			ECAM_controller.warningReset(bleed2FaultXBleed);
		}
	} else {
		ECAM_controller.warningReset(bleed2FaultOff);
		ECAM_controller.warningReset(bleed2FaultPack);
		ECAM_controller.warningReset(bleed2FaultXBleed);
	}
	
	if (apuBleedFault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.apuFaultOutput.getValue() == 1) {
		apuBleedFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuBleedFault);
	}
	
	# HP Valves
	if (hpValve1Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and systems.PNEU.Fail.hp1Valve.getValue() and systems.ELEC.Bus.dcEssShed.getValue() >= 25) {
		hpValve1Fault.active = 1;
	} else {
		ECAM_controller.warningReset(hpValve1Fault);
	}
	
	if (hpValve2Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and systems.PNEU.Fail.hp2Valve.getValue() and systems.ELEC.Bus.dc2.getValue() >= 25) {
		hpValve2Fault.active = 1;
	} else {
		ECAM_controller.warningReset(hpValve2Fault);
	}
	
	# Crossbleed
	if (xBleedFault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.crossbleedFault.getValue()) {
		xBleedFault.active = 1;
	} else {
		ECAM_controller.warningReset(xBleedFault);
	}
	
	if (xBleedFault.active) {
		if (systems.PNEU.Switch.xbleed.getValue() == 1) {
			xBleedFaultMan.active = 1;
		} else {
			ECAM_controller.warningReset(xBleedFaultMan);
		}
		
		if (warningNodes.Logic.crossbleedWai.getValue()) {
			if (getprop("/controls/ice-protection/wing")) {
				xBleedOff.active = 1;
			} else {	
				ECAM_controller.warningReset(xBleedOff);
			}
			xBleedIcing.active = 1;
		} else {
			ECAM_controller.warningReset(xBleedOff);
			ECAM_controller.warningReset(xBleedIcing);
		}
	} else {
		ECAM_controller.warningReset(xBleedFaultMan);
		ECAM_controller.warningReset(xBleedOff);
		ECAM_controller.warningReset(xBleedIcing);
	}
	
	if (bleed1Off.clearFlag == 0 and (warningNodes.Timers.bleed1Off60Output.getValue() == 1 or warningNodes.Timers.bleed1Off5Output.getValue() == 1) and FWC.Timer.eng1idleOutput.getBoolValue() and (phaseVar2 == 2 or phaseVar2 == 6)) {
		bleed1Off.active = 1;
	} else {
		ECAM_controller.warningReset(bleed1Off);
	}
	
	if (bleed2Off.clearFlag == 0 and (warningNodes.Timers.bleed2Off60Output.getValue() == 1 or warningNodes.Timers.bleed2Off5Output.getValue() == 1) and FWC.Timer.eng2idleOutput.getBoolValue() and (phaseVar2 == 2 or phaseVar2 == 6)) {
		bleed2Off.active = 1;
	} else {
		ECAM_controller.warningReset(bleed2Off);
	}
	
	if (warningNodes.Flipflops.bleed1LowTemp.getValue() and warningNodes.Flipflops.bleed2LowTemp.getValue()) {
		warningNodes.Timers.bleed1And2LoTemp.setValue(1);
	} else {
		warningNodes.Timers.bleed1And2LoTemp.setValue(0);
	}	
	
	if (engBleedLowTemp.clearFlag == 0 and warningNodes.Timers.bleed1And2LoTempOutput.getValue() == 1 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6 or phaseVar2 == 7)) {
		engBleedLowTemp.active = 1;
		
		if (engBleedLowTempAthr.clearFlag == 0 and fmgc.Output.athr.getValue()) {
			engBleedLowTempAthr.active = 1;
		} else {
			ECAM_controller.warningReset(engBleedLowTempAthr);
		}
		
		if (engBleedLowTempAdv.clearFlag == 0) {
			engBleedLowTempAdv.active = 1;
		} else {
			ECAM_controller.warningReset(engBleedLowTempAdv);
		}
		
		if (engBleedLowTempSucc.clearFlag == 0) {
			engBleedLowTempSucc.active = 1;
		} else {
			ECAM_controller.warningReset(engBleedLowTempSucc);
		}
		
		if (engBleedLowTempIce.clearFlag == 0) {
			engBleedLowTempIce.active = 1;
		} else {
			ECAM_controller.warningReset(engBleedLowTempIce);
		}
		
		if (engBleedLowTempIcing.clearFlag == 0) {
			engBleedLowTempIcing.active = 1;
		} else {
			ECAM_controller.warningReset(engBleedLowTempIcing);
		}
	} else {
		ECAM_controller.warningReset(engBleedLowTemp);
		ECAM_controller.warningReset(engBleedLowTempAthr);
		ECAM_controller.warningReset(engBleedLowTempAdv);
		ECAM_controller.warningReset(engBleedLowTempSucc);
		ECAM_controller.warningReset(engBleedLowTempIce);
		ECAM_controller.warningReset(engBleedLowTempIcing);
	}
	
	if (eng1BleedLowTemp.clearFlag == 0 and warningNodes.Flipflops.bleed1LowTemp.getValue() == 1 and warningNodes.Flipflops.bleed2LowTemp.getValue() == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6 or phaseVar2 == 7)) {
		eng1BleedLowTemp.active = 1;
		
		if (eng1BleedLowTempAthr.clearFlag == 0 and fmgc.Output.athr.getValue()) {
			eng1BleedLowTempAthr.active = 1;
		} else {
			ECAM_controller.warningReset(eng1BleedLowTempAthr);
		}
		
		if (eng1BleedLowTempAdv.clearFlag == 0) {
			eng1BleedLowTempAdv.active = 1;
		} else {
			ECAM_controller.warningReset(eng1BleedLowTempAdv);
		}
		
		if (eng1BleedLowTempSucc.clearFlag == 0 and warningNodes.Logic.bleed1LoTempUnsuc.getValue()) {
			eng1BleedLowTempSucc.active = 1;
		} else {	
			ECAM_controller.warningReset(eng1BleedLowTempSucc);
		}
		
		if (eng1BleedLowTempXBld.clearFlag == 0 and warningNodes.Logic.bleed1LoTempXbleed.getValue()) {
			eng1BleedLowTempXBld.active = 1;
		} else {	
			ECAM_controller.warningReset(eng1BleedLowTempXBld);
		}
		
		if (eng1BleedLowTempOff.clearFlag == 0 and warningNodes.Logic.bleed1LoTempBleed.getValue()) {
			eng1BleedLowTempOff.active = 1;
		} else {	
			ECAM_controller.warningReset(eng1BleedLowTempOff);
		}
		
		if (eng1BleedLowTempPack.clearFlag == 0 and warningNodes.Logic.bleed1LoTempPack.getValue()) {
			eng1BleedLowTempPack.active = 1;
		} else {	
			ECAM_controller.warningReset(eng1BleedLowTempPack);
		}
		
		if (eng1BleedLowTempIce.clearFlag == 0 and !warningNodes.Logic.bleed2WaiAvail.getValue()) { # on purpose
			eng1BleedLowTempIce.active = 1;
			eng1BleedLowTempIcing.active = 1;
		} else {
			ECAM_controller.warningReset(eng1BleedLowTempIce);
			ECAM_controller.warningReset(eng1BleedLowTempIcing);
		}
	} else {
		ECAM_controller.warningReset(eng1BleedLowTemp);
		ECAM_controller.warningReset(eng1BleedLowTempAthr);
		ECAM_controller.warningReset(eng1BleedLowTempAdv);
		ECAM_controller.warningReset(eng1BleedLowTempSucc);
		ECAM_controller.warningReset(eng1BleedLowTempXBld);
		ECAM_controller.warningReset(eng1BleedLowTempOff);
		ECAM_controller.warningReset(eng1BleedLowTempPack);
		ECAM_controller.warningReset(eng1BleedLowTempIce);
		ECAM_controller.warningReset(eng1BleedLowTempIcing);
	}
	
	if (eng2BleedLowTemp.clearFlag == 0 and warningNodes.Flipflops.bleed1LowTemp.getValue() == 0 and warningNodes.Flipflops.bleed2LowTemp.getValue() == 1 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6 or phaseVar2 == 7)) {
		eng2BleedLowTemp.active = 1;
		
		if (eng2BleedLowTempAthr.clearFlag == 0 and fmgc.Output.athr.getValue()) {
			eng2BleedLowTempAthr.active = 1;
		} else {
			ECAM_controller.warningReset(eng2BleedLowTempAthr);
		}
		
		if (eng2BleedLowTempAdv.clearFlag == 0) {
			eng2BleedLowTempAdv.active = 1;
		} else {
			ECAM_controller.warningReset(eng2BleedLowTempAdv);
		}
		
		if (eng2BleedLowTempSucc.clearFlag == 0 and warningNodes.Logic.bleed2LoTempUnsuc.getValue()) {
			eng2BleedLowTempSucc.active = 1;
		} else {	
			ECAM_controller.warningReset(eng2BleedLowTempSucc);
		}
		
		if (eng2BleedLowTempXBld.clearFlag == 0 and warningNodes.Logic.bleed2LoTempXbleed.getValue()) {
			eng2BleedLowTempXBld.active = 1;
		} else {	
			ECAM_controller.warningReset(eng2BleedLowTempXBld);
		}
		
		if (eng2BleedLowTempOff.clearFlag == 0 and warningNodes.Logic.bleed2LoTempBleed.getValue()) {
			eng2BleedLowTempOff.active = 1;
		} else {	
			ECAM_controller.warningReset(eng2BleedLowTempOff);
		}
		
		if (eng2BleedLowTempPack.clearFlag == 0 and warningNodes.Logic.bleed2LoTempPack.getValue()) {
			eng2BleedLowTempPack.active = 1;
		} else {	
			ECAM_controller.warningReset(eng2BleedLowTempPack);
		}
		
		if (eng2BleedLowTempIce.clearFlag == 0 and !warningNodes.Logic.bleed1WaiAvail.getValue()) { # on purpose
			eng2BleedLowTempIce.active = 1;
			eng2BleedLowTempIcing.active = 1;
		} else {
			ECAM_controller.warningReset(eng2BleedLowTempIce);
			ECAM_controller.warningReset(eng2BleedLowTempIcing);
		}
	} else {
		ECAM_controller.warningReset(eng2BleedLowTemp);
		ECAM_controller.warningReset(eng2BleedLowTempAthr);
		ECAM_controller.warningReset(eng2BleedLowTempAdv);
		ECAM_controller.warningReset(eng2BleedLowTempSucc);
		ECAM_controller.warningReset(eng2BleedLowTempXBld);
		ECAM_controller.warningReset(eng2BleedLowTempOff);
		ECAM_controller.warningReset(eng2BleedLowTempPack);
		ECAM_controller.warningReset(eng2BleedLowTempIce);
		ECAM_controller.warningReset(eng2BleedLowTempIcing);
	}
	
	if (eng1BleedNotClsd.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.bleed1NotShutOutput.getValue() == 1) {
		eng1BleedNotClsd.active = 1;
		if (systems.PNEU.Switch.bleed1.getBoolValue()) {
			eng1BleedNotClsdOff.active = 1;
		} else {
			ECAM_controller.warningReset(eng1BleedNotClsdOff);
		}
	} else {
		ECAM_controller.warningReset(eng1BleedNotClsd);
		ECAM_controller.warningReset(eng1BleedNotClsdOff);
	}
	
	if (eng2BleedNotClsd.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.bleed2NotShutOutput.getValue() == 1) {
		eng2BleedNotClsd.active = 1;
		if (systems.PNEU.Switch.bleed2.getBoolValue()) {
			eng2BleedNotClsdOff.active = 1;
		} else {
			ECAM_controller.warningReset(eng2BleedNotClsdOff);
		}
	} else {
		ECAM_controller.warningReset(eng2BleedNotClsd);
		ECAM_controller.warningReset(eng2BleedNotClsdOff);
	}
	
	# BMC
	if (bleedMonFault.clearFlag == 0 and systems.PNEU.Fail.bmc1.getValue() and systems.PNEU.Fail.bmc2.getValue() and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6)) {
		bleedMonFault.active = 1;
	} else {
		ECAM_controller.warningReset(bleedMonFault);
	}
	
	if (bleedMon1Fault.clearFlag == 0 and systems.PNEU.Fail.bmc1.getValue() and !systems.PNEU.Fail.bmc2.getValue() and (phaseVar2 <= 2 or phaseVar2 >= 9)) {
		bleedMon1Fault.active = 1;
	} else {
		ECAM_controller.warningReset(bleedMon1Fault);
	}
	
	if (bleedMon2Fault.clearFlag == 0 and !systems.PNEU.Fail.bmc1.getValue() and systems.PNEU.Fail.bmc2.getValue() and (phaseVar2 <= 2 or phaseVar2 >= 9)) {
		bleedMon2Fault.active = 1;
	} else {
		ECAM_controller.warningReset(bleedMon2Fault);
	}
	
	# PACK
	if (pack12Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.pack12Fault.getValue()) { # TODO NOT OUTFLOW OR HOT AIR FAULT
		pack12Fault.active = 1;
		
		if (systems.PNEU.Switch.pack1.getBoolValue()) {
			pack12FaultPackOff1.active = 1;
		} else {
			ECAM_controller.warningReset(pack12FaultPackOff1);
		}
		
		if (systems.PNEU.Switch.pack2.getBoolValue()) {
			pack12FaultPackOff2.active = 1;
		} else {
			ECAM_controller.warningReset(pack12FaultPackOff2);
		}
		
		if (!systems.PNEU.Switch.ramAir.getBoolValue() and !FWC.Timer.gnd.getValue() != 1 and pts.Instrumentation.Altimeter.indicatedFt.getValue() >= 16000) {
			pack12FaultDescend.active = 1;
		} else {
			ECAM_controller.warningReset(pack12FaultDescend);
		}
		
		if (!systems.PNEU.Switch.ramAir.getBoolValue() and FWC.Timer.gnd.getValue() != 1) {
			pack12FaultDiffPr.active = 1;
			pack12FaultDiffPr2.active = 1;
			pack12FaultRam.active = 1;
		} else {
			ECAM_controller.warningReset(pack12FaultDiffPr);
			ECAM_controller.warningReset(pack12FaultDiffPr2);
			ECAM_controller.warningReset(pack12FaultRam);
		}
		
		if (FWC.Timer.gnd.getValue() != 1) {
			pack12FaultMax.active = 1;
		} else {
			ECAM_controller.warningReset(pack12FaultMax);
		}
		
		if (warningNodes.Logic.pack1ResetPb.getBoolValue() or warningNodes.Logic.pack2ResetPb.getBoolValue()) {
			pack12FaultOvht.active = 1;
			
			if (warningNodes.Logic.pack1ResetPb.getBoolValue()) {
				pack12FaultPackOn1.active = 1;
			} else {
				ECAM_controller.warningReset(pack12FaultPackOn1);
			}
			
			if (warningNodes.Logic.pack2ResetPb.getBoolValue()) {
				pack12FaultPackOn2.active = 1;
			} else {
				ECAM_controller.warningReset(pack12FaultPackOn2);
			}
		} else {
			ECAM_controller.warningReset(pack12FaultOvht);
			ECAM_controller.warningReset(pack12FaultPackOn1);
			ECAM_controller.warningReset(pack12FaultPackOn2);
		}
	} else {
		ECAM_controller.warningReset(pack12Fault);
		ECAM_controller.warningReset(pack12FaultPackOff1);
		ECAM_controller.warningReset(pack12FaultPackOff2);
		ECAM_controller.warningReset(pack12FaultDescend);
		ECAM_controller.warningReset(pack12FaultDiffPr);
		ECAM_controller.warningReset(pack12FaultDiffPr2);
		ECAM_controller.warningReset(pack12FaultRam);
		ECAM_controller.warningReset(pack12FaultMax);
		ECAM_controller.warningReset(pack12FaultOvht);
		ECAM_controller.warningReset(pack12FaultPackOn1);
		ECAM_controller.warningReset(pack12FaultPackOn2);
	}
	
	if (pack1Ovht.clearFlag == 0 and (phaseVar2 <= 2  or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Flipflops.pack1Ovht.getValue()) {
		pack1Ovht.active = 1;
		
		if (systems.PNEU.Switch.pack1.getBoolValue()) {
			pack1OvhtOff.active = 1;
		} else {
			ECAM_controller.warningReset(pack1OvhtOff);
		}
		
		pack1OvhtOut.active = 1;
		pack1OvhtPack.active = 1;
	} else {
		ECAM_controller.warningReset(pack1Ovht);
		ECAM_controller.warningReset(pack1OvhtOff);
		ECAM_controller.warningReset(pack1OvhtOut);
		ECAM_controller.warningReset(pack1OvhtPack);
	}
	
	if (pack2Ovht.clearFlag == 0 and (phaseVar2 <= 2  or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Flipflops.pack2Ovht.getValue()) {
		pack2Ovht.active = 1;
		
		if (systems.PNEU.Switch.pack2.getBoolValue()) {
			pack2OvhtOff.active = 1;
		} else {
			ECAM_controller.warningReset(pack2OvhtOff);
		}
		
		pack2OvhtOut.active = 1;
		pack2OvhtPack.active = 1;
	} else {
		ECAM_controller.warningReset(pack2Ovht);
		ECAM_controller.warningReset(pack2OvhtOff);
		ECAM_controller.warningReset(pack2OvhtOut);
		ECAM_controller.warningReset(pack2OvhtPack);
	}
	
	if (pack1Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.pack1Fault.getValue() == 1) {
		pack1Fault.active = 1;
		
		if (systems.PNEU.Switch.pack1.getBoolValue()) {
			pack1FaultOff.active = 1;
		} else {
			ECAM_controller.warningReset(pack1FaultOff);
		}
	} else {
		ECAM_controller.warningReset(pack1Fault);
		ECAM_controller.warningReset(pack1FaultOff);
	}
	
	if (pack2Fault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.pack2Fault.getValue() == 1) {
		pack2Fault.active = 1;
		
		if (systems.PNEU.Switch.pack2.getBoolValue()) {
			pack2FaultOff.active = 1;
		} else {
			ECAM_controller.warningReset(pack2FaultOff);
		}
	} else {
		ECAM_controller.warningReset(pack2Fault);
		ECAM_controller.warningReset(pack2FaultOff);
	}
	
	if (pack1Off.clearFlag == 0 and phaseVar2 == 6 and warningNodes.Timers.pack1Off.getValue() == 1) {
		pack1Off.active = 1;
	} else {
		ECAM_controller.warningReset(pack1Off);
	}
	
	if (pack2Off.clearFlag == 0 and phaseVar2 == 6 and warningNodes.Timers.pack2Off.getValue() == 1) {
		pack2Off.active = 1;
	} else {
		ECAM_controller.warningReset(pack2Off);
	}
	
	# COND
	if (cabFanFault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Logic.cabinFans.getBoolValue()) {
		cabFanFault.active = 1;
		cabFanFaultFlow.active = 1;
	} else {
		ECAM_controller.warningReset(cabFanFault);
		ECAM_controller.warningReset(cabFanFaultFlow);
	}
	
	if (trimAirFault.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.trimAirFault.getValue() == 1) {
		trimAirFault.active = 1;
		
		if (systems.PNEU.Fail.trimValveAft.getBoolValue()) {
			trimAirFaultAft.active = 1; 
		} else {
			ECAM_controller.warningReset(trimAirFaultAft);
		}
		
		if (systems.PNEU.Fail.trimValveFwd.getBoolValue()) {
			trimAirFaultFwd.active = 1; 
		} else {
			ECAM_controller.warningReset(trimAirFaultFwd);
		}
		
		if (systems.PNEU.Fail.trimValveCockpit.getBoolValue()) {
			trimAirFaultCkpt.active = 1; 
		} else {
			ECAM_controller.warningReset(trimAirFaultCkpt);
		}
	} else {
		ECAM_controller.warningReset(trimAirFault);
		ECAM_controller.warningReset(trimAirFaultAft);
		ECAM_controller.warningReset(trimAirFaultFwd);
		ECAM_controller.warningReset(trimAirFaultCkpt);
	}
	
	# ENG AICE
	if (eng1IceClosed.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.eng1AiceNotOpen.getValue() == 1) {
		eng1IceClosed.active = 1;
		eng1IceClosedIcing.active = 1;
	} else {
		ECAM_controller.warningReset(eng1IceClosed);
		ECAM_controller.warningReset(eng1IceClosedIcing);
	}
	
	if (eng2IceClosed.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.eng2AiceNotOpen.getValue() == 1) {
		eng2IceClosed.active = 1;
		eng2IceClosedIcing.active = 1;
	} else {
		ECAM_controller.warningReset(eng2IceClosed);
		ECAM_controller.warningReset(eng2IceClosedIcing);
	}
	
	if (eng1IceOpen.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.eng1AiceNotClsd.getValue() == 1) {
		eng1IceOpen.active = 1;
		eng1IceOpenThrust.active = 1;
	} else {
		ECAM_controller.warningReset(eng1IceOpen);
		ECAM_controller.warningReset(eng1IceOpenThrust);
	}
	
	if (eng2IceOpen.clearFlag == 0 and (phaseVar2 <= 2 or phaseVar2 >= 9 or phaseVar2 == 6) and warningNodes.Timers.eng2AiceNotClsd.getValue() == 1) {
		eng2IceOpen.active = 1;
		eng2IceOpenThrust.active = 1;
	} else {
		ECAM_controller.warningReset(eng2IceOpen);
		ECAM_controller.warningReset(eng2IceOpenThrust);
	}
	
	# Wing anti ice
	if (wingIceSysFault.clearFlag == 0 and warningNodes.Logic.waiSysfault.getBoolValue() and (phaseVar2 <= 2  or phaseVar2 >= 9 or phaseVar2 == 6)) {
		wingIceSysFault.active = 1;
		
		if ((warningNodes.Logic.waiLclosed.getValue() or warningNodes.Logic.waiRclosed.getValue()) and warningNodes.Logic.procWaiShutdown.getValue() == 1) {
			wingIceSysFaultXbld.active = 1;
		} else {
			ECAM_controller.warningReset(wingIceSysFaultXbld);
		}
		if ((warningNodes.Logic.waiLclosed.getValue() or warningNodes.Logic.waiRclosed.getValue()) and getprop("/controls/ice-protection/wing")) {
			wingIceSysFaultOff.active = 1;
		} else {
			ECAM_controller.warningReset(wingIceSysFaultOff);
		}
		
		if (warningNodes.Logic.waiLclosed.getValue() or warningNodes.Logic.waiRclosed.getValue()) {
			wingIceSysFaultIcing.active = 1;
		} else {
			ECAM_controller.warningReset(wingIceSysFaultIcing);
		}
	} else {
		ECAM_controller.warningReset(wingIceSysFault);
		ECAM_controller.warningReset(wingIceSysFaultXbld);
		ECAM_controller.warningReset(wingIceSysFaultOff);
		ECAM_controller.warningReset(wingIceSysFaultIcing);
	}
	
	if (wingIceOpenGnd.clearFlag == 0 and warningNodes.Logic.waiGndFlight.getValue() and (phaseVar2 <= 2  or phaseVar2 >= 9)) {
		wingIceOpenGnd.active = 1;
		
		if (pts.Gear.wow[1].getValue() and getprop("/controls/ice-protection/wing")) {
			wingIceOpenGndShut.active = 1;
		} else {
			ECAM_controller.warningReset(wingIceOpenGndShut);
		}
	} else {
		ECAM_controller.warningReset(wingIceOpenGnd);
		ECAM_controller.warningReset(wingIceOpenGndShut);
	}
	
	if (wingIceLHiPr.clearFlag == 0 and warningNodes.Timers.waiLhiPr.getValue() == 1 and (phaseVar2 <= 2  or phaseVar2 >= 9 or phaseVar2 == 6)) {
		wingIceLHiPr.active = 1;
		wingIceLHiPrThrust.active = 1;
	} else {
		ECAM_controller.warningReset(wingIceLHiPr);
		ECAM_controller.warningReset(wingIceLHiPrThrust);
	}
	
	if (wingIceRHiPr.clearFlag == 0 and warningNodes.Timers.waiRhiPr.getValue() == 1 and (phaseVar2 <= 2  or phaseVar2 >= 9 or phaseVar2 == 6)) {
		wingIceRHiPr.active = 1;
		wingIceRHiPrThrust.active = 1;
	} else {
		ECAM_controller.warningReset(wingIceRHiPr);
		ECAM_controller.warningReset(wingIceRHiPrThrust);
	}
	
	# Eng fire
	if (eng1FireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[0].condition == 0 or (systems.engFireDetectorUnits.vector[0].loopOne == 9 and systems.engFireDetectorUnits.vector[0].loopTwo == 9 and systems.eng1Inop.getBoolValue())) and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		eng1FireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1FireDetFault);
	}
	
	if (eng1LoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[0].loopOne == 9 and systems.engFireDetectorUnits.vector[0].loopTwo != 9 and !systems.eng1Inop.getBoolValue() and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		eng1LoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1LoopAFault);
	}
	
	if (eng1LoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[0].loopOne != 9 and systems.engFireDetectorUnits.vector[0].loopTwo == 9 and !systems.eng1Inop.getBoolValue() and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		eng1LoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1LoopBFault);
	}
	
	if (eng2FireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[1].condition == 0 or (systems.engFireDetectorUnits.vector[1].loopOne == 9 and systems.engFireDetectorUnits.vector[1].loopTwo == 9 and systems.eng2Inop.getBoolValue())) and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		eng2FireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2FireDetFault);
	}
	
	if (eng2LoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[1].loopOne == 9 and systems.engFireDetectorUnits.vector[1].loopTwo != 9 and !systems.eng2Inop.getBoolValue() and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		eng2LoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2LoopAFault);
	}
	
	if (eng2LoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[1].loopOne != 9 and systems.engFireDetectorUnits.vector[1].loopTwo == 9 and !systems.eng2Inop.getBoolValue() and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		eng2LoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2LoopBFault);
	}
	
	if (apuFireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[2].condition == 0 or (systems.engFireDetectorUnits.vector[2].loopOne == 9 and systems.engFireDetectorUnits.vector[2].loopTwo == 9 and systems.apuInop.getBoolValue())) and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		apuFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuFireDetFault);
	}
	
	if (apuLoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[2].loopOne == 9 and systems.engFireDetectorUnits.vector[2].loopTwo != 9 and !systems.apuInop.getBoolValue() and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		apuLoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuLoopAFault);
	}
	
	if (apuLoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[2].loopOne != 9 and systems.engFireDetectorUnits.vector[2].loopTwo == 9 and !systems.apuInop.getBoolValue() and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		apuLoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuLoopBFault);
	}
	
	if (crgAftFireDetFault.clearFlag == 0 and (systems.cargoSmokeDetectorUnits.vector[0].condition == 0 or systems.cargoSmokeDetectorUnits.vector[1].condition == 0) and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		crgAftFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(crgAftFireDetFault);
	}
	
	if (crgFwdFireDetFault.clearFlag == 0 and systems.cargoSmokeDetectorUnits.vector[2].condition == 0 and (phaseVar2 == 6 or phaseVar2 >= 9 or phaseVar2 <= 2)) {
		crgFwdFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(crgFwdFireDetFault);
	}
	
	if (hf1Emitting.clearFlag == 0 and transmitFlag1) {
		hf1Emitting.active = 1;
	} else {
		ECAM_controller.warningReset(hf1Emitting);
	}
	
	if (hf2Emitting.clearFlag == 0 and transmitFlag2) {
		hf2Emitting.active = 1;
	} else {
		ECAM_controller.warningReset(hf2Emitting);
	}
}

var messages_priority_1 = func {
}

var messages_priority_0 = func {
	if (FWC.Btn.recallStsNormalOutput.getBoolValue()) {
		recallNormal.active = 1;
		recallNormal1.active = 1;
		recallNormal2.active = 1;
	} else {
		ECAM_controller.warningReset(recallNormal);
		ECAM_controller.warningReset(recallNormal1);
		ECAM_controller.warningReset(recallNormal2);
	}
}

var messages_config_memo = func {
	phaseVarMemo = phaseNode.getValue();
	if (pts.Controls.Flight.flapsInput.getValue() == 0 or pts.Controls.Flight.flapsInput.getValue() == 4 or pts.Controls.Flight.speedbrake.getValue() != 0 or getprop("/fdm/jsbsim/hydraulics/elevator-trim/final-deg") > 1.75 or getprop("/fdm/jsbsim/hydraulics/elevator-trim/final-deg") < -3.65 or getprop("/fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") < -3.55 or getprop("/fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") > 3.55) {
		setprop("/ECAM/to-config-normal", 0);
	} else {
		setprop("/ECAM/to-config-normal", 1);
	}
	
	if (getprop("/ECAM/to-config-test") and (phaseVarMemo == 1 or phaseVarMemo == 2 or phaseVarMemo == 9)) {
		setprop("/ECAM/to-config-set", 1);
	} else {
		setprop("/ECAM/to-config-set", 0);
	}
	
	if (!getprop("/ECAM/to-config-normal") or phaseVarMemo == 6) {
		setprop("/ECAM/to-config-reset", 1);
	} else {
		setprop("/ECAM/to-config-reset", 0);
	}
	
	if (getprop("/controls/autobrake/mode") == 3) {
		toMemoLine1.msg = "T.O AUTO BRK MAX";
		toMemoLine1.colour = "g";
	} else {
		toMemoLine1.msg = "T.O AUTO BRK.....MAX";
		toMemoLine1.colour = "c";
	}
	
	if (getprop("/controls/switches/seatbelt-sign") and getprop("/controls/switches/no-smoking-sign")) {
		toMemoLine2.msg = "    SIGNS ON";
		toMemoLine2.colour = "g";
	} else {
		toMemoLine2.msg = "    SIGNS.........ON";
		toMemoLine2.colour = "c";
	}
	
	if (getprop("/controls/flight/speedbrake-arm")) {
		toMemoLine3.msg = "    SPLRS ARM";
		toMemoLine3.colour = "g";
	} else {
		toMemoLine3.msg = "    SPLRS........ARM";
		toMemoLine3.colour = "c";
	}
	
	if (pts.Controls.Flight.flapsPos.getValue() > 0 and pts.Controls.Flight.flapsPos.getValue() < 5) {
		toMemoLine4.msg = "    FLAPS T.O";
		toMemoLine4.colour = "g";
	} else {
		toMemoLine4.msg = "    FLAPS........T.O";
		toMemoLine4.colour = "c";
	}
	
	if (getprop("/ECAM/to-config-flipflop") and getprop("/ECAM/to-config-normal")) {
		toMemoLine5.msg = "    T.O CONFIG NORMAL";
		toMemoLine5.colour = "g";
	} else {
		toMemoLine5.msg = "    T.O CONFIG..TEST";
		toMemoLine5.colour = "c";
	}
	
	if (getprop("/ECAM/to-config-test") and (phaseVarMemo == 2 or phaseVarMemo == 9)) {
		setprop("/ECAM/to-memo-set", 1);
	} else {
		setprop("/ECAM/to-memo-set", 0);
	}
	
	if (phaseVarMemo == 1 or phaseVarMemo == 3 or phaseVarMemo == 6 or phaseVarMemo == 10) {
		setprop("/ECAM/to-memo-reset", 1);
	} else {
		setprop("/ECAM/to-memo-reset", 0);
	}
	
	if ((phaseVarMemo == 2 and getprop("/ECAM/engine-start-time") != 0 and getprop("/ECAM/engine-start-time") + 120 < pts.Sim.Time.elapsedSec.getValue()) or getprop("/ECAM/to-memo-flipflop")) {
		toMemoLine1.active = 1;
		toMemoLine2.active = 1;
		toMemoLine3.active = 1;
		toMemoLine4.active = 1;
		toMemoLine5.active = 1;
	} else {
		ECAM_controller.warningReset(toMemoLine1);
		ECAM_controller.warningReset(toMemoLine2);
		ECAM_controller.warningReset(toMemoLine3);
		ECAM_controller.warningReset(toMemoLine4);
		ECAM_controller.warningReset(toMemoLine5);
	}
	
	if (getprop("/fdm/jsbsim/gear/gear-pos-norm") == 1) {
		ldgMemoLine1.msg = "LDG LDG GEAR DN";
		ldgMemoLine1.colour = "g";
	} else {
		ldgMemoLine1.msg = "LDG LDG GEAR......DN";
		ldgMemoLine1.colour = "c";
	}
	
	if (getprop("/controls/switches/seatbelt-sign") and getprop("/controls/switches/no-smoking-sign")) {
		ldgMemoLine2.msg = "    SIGNS ON";
		ldgMemoLine2.colour = "g";
	} else {
		ldgMemoLine2.msg = "    SIGNS.........ON";
		ldgMemoLine2.colour = "c";
	}
	
	if (getprop("/controls/flight/speedbrake-arm")) {
		ldgMemoLine3.msg = "    SPLRS ARM";
		ldgMemoLine3.colour = "g";
	} else {
		ldgMemoLine3.msg = "    SPLRS........ARM";
		ldgMemoLine3.colour = "c";
	}
	
	if (getprop("/it-fbw/law") == 1 or getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override")) {
		if (pts.Controls.Flight.flapsPos.getValue() == 4) {
			ldgMemoLine4.msg = "    FLAPS CONF 3";
			ldgMemoLine4.colour = "g";
		} else {
			ldgMemoLine4.msg = "    FLAPS.....CONF 3";
			ldgMemoLine4.colour = "c";
		}
	} else {
		if (pts.Controls.Flight.flapsPos.getValue() == 5) {
			ldgMemoLine4.msg = "    FLAPS FULL";
			ldgMemoLine4.colour = "g";
		} else {
			ldgMemoLine4.msg = "    FLAPS.......FULL";
			ldgMemoLine4.colour = "c";
		}
	}
	
	gear_agl_cur = pts.Position.gearAglFt.getValue();
	if (gear_agl_cur < 2000) {
		setprop("/ECAM/ldg-memo-set", 1);
	} else {
		setprop("/ECAM/ldg-memo-set", 0);
	}
	
	if (gear_agl_cur > 2200) {
		setprop("/ECAM/ldg-memo-reset", 1);
	} else {
		setprop("/ECAM/ldg-memo-reset", 0);
	}
	
	if (gear_agl_cur > 2200) {
		setprop("/ECAM/ldg-memo-2200-set", 1);
	} else {
		setprop("/ECAM/ldg-memo-2200-set", 0);
	}
	
	if (phaseVarMemo != 6 and phaseVarMemo != 7 and phaseVarMemo != 8) {
		setprop("/ECAM/ldg-memo-2200-reset", 1);
	} else {
		setprop("/ECAM/ldg-memo-2200-reset", 0);
	}
	
	if ((phaseVarMemo == 6 and getprop("/ECAM/ldg-memo-flipflop") and getprop("/ECAM/ldg-memo-2200-flipflop")) or phaseVarMemo == 7 or phaseVarMemo == 8) {
		ldgMemoLine1.active = 1;
		ldgMemoLine2.active = 1;
		ldgMemoLine3.active = 1;
		ldgMemoLine4.active = 1;
	} else {
		ECAM_controller.warningReset(ldgMemoLine1);
		ECAM_controller.warningReset(ldgMemoLine2);
		ECAM_controller.warningReset(ldgMemoLine3);
		ECAM_controller.warningReset(ldgMemoLine4);
	}
}

var messages_memo = func {
	phaseVarMemo2 = phaseNode.getValue();
	if (getprop("/services/fuel-truck/enable") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		refuelg.active = 1;
	} else {
		refuelg.active = 0;
	}
	
	if (systems.ADIRS.ADIRunits[0].inAlign == 1 or systems.ADIRS.ADIRunits[1].inAlign == 1 or systems.ADIRS.ADIRunits[2].inAlign == 1) {
		FWC.Logic.IRSinAlign.setValue(1);
	} else {
		FWC.Logic.IRSinAlign.setValue(0);
	}
	
	if ((phaseVarMemo2 == 1 or phaseVarMemo2 == 2) and toMemoLine1.active != 1 and ldgMemoLine1.active != 1 and (systems.ADIRS.ADIRunits[0].inAlign == 1 or systems.ADIRS.ADIRunits[1].inAlign == 1 or systems.ADIRS.ADIRunits[2].inAlign == 1)) {
		irs_in_align.active = 1;
		if (FWC.Timer.eng1or2Output.getValue()) {
			irs_in_align.colour = "a";
		} else {
			irs_in_align.colour = "g";
		}
		
		timeNow = pts.Sim.Time.elapsedSec.getValue();
		numberMinutes = math.round(math.max(systems.ADIRS.ADIRunits[0]._alignTime - timeNow, systems.ADIRS.ADIRunits[1]._alignTime - timeNow, systems.ADIRS.ADIRunits[2]._alignTime - timeNow) / 60);
		
		if (numberMinutes >= 7) {
			irs_in_align.msg = "IRS IN ALIGN > 7 MN";
		} elsif (numberMinutes >= 1) {
			irs_in_align.msg = "IRS IN ALIGN " ~ numberMinutes ~ " MN";
		} else {
			irs_in_align.msg = "IRS IN ALIGN";
		}
	} else {
		if (irs_in_align.active and !timer10secIRS) {
			timer10secIRS = 1;
			irs_in_align.msg = "IRS ALIGNED";
			settimer(func() {
				irs_in_align.active = 0;
				irs_in_align.msg = "IRS IN ALIGN";
				timer10secIRS = 0;
			}, 10);
		} elsif (!timer10secIRS) {
			irs_in_align.active = 0;
			irs_in_align.msg = "IRS IN ALIGN";
		}
	}
	
	if (getprop("/controls/flight/speedbrake-arm") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		gnd_splrs.active = 1;
	} else {
		gnd_splrs.active = 0;
	}
	
	if (getprop("/controls/lighting/seatbelt-sign") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		seatbelts.active = 1;
	} else {
		seatbelts.active = 0;
	}
	
	if (getprop("/controls/lighting/no-smoking-sign") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) { # should go off after takeoff assuming switch is in auto due to old logic from the days when smoking was allowed!
		nosmoke.active = 1;
	} else {
		nosmoke.active = 0;
	}

	if (getprop("/controls/lighting/strobe") == 0 and !pts.Gear.wow[1].getValue() and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) { # todo: use gear branch properties
		strobe_lt_off.active = 1;
	} else {
		strobe_lt_off.active = 0;
	}
	
	if (systems.FUEL.Valves.transfer1.getValue() == 1 or systems.FUEL.Valves.transfer2.getValue() == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		outr_tk_fuel_xfrd.active = 1;
	} else {
		outr_tk_fuel_xfrd.active = 0;
	}

	if (pts.Consumables.Fuel.totalFuelLbs.getValue() < 6000 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) { # assuming US short ton 2000lb
		fob_3T.active = 1;
	} else {
		fob_3T.active = 0;
	}
	
	if (getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		gpws_flap_mode_off.active = 1;
	} else {
		gpws_flap_mode_off.active = 0;
	}
	
	if (!fmgc.FMGCInternal.flightNumSet and toMemoLine1.active != 1 and ldgMemoLine1.active != 1 and (phaseVarMemo2 <= 2 or phaseVarMemo2 == 6 or phaseVarMemo2 >= 9)) {
		company_datalink_stby.active = 1;
	} else {
		company_datalink_stby.active = 0;
	}
}

var messages_right_memo = func {
	phaseVarMemo3 = phaseNode.getValue();
	if (FWC.Timer.toInhibitOutput.getValue() == 1) {
		to_inhibit.active = 1;
	} else {
		to_inhibit.active = 0;
	}
	
	if (FWC.Timer.ldgInhibitOutput.getValue() == 1) {
		ldg_inhibit.active = 1;
	} else {
		ldg_inhibit.active = 0;
	}
	
	if ((!pts.Gear.wow[1].getValue()) and (systems.ELEC.EmerElec.getValue() or getprop("/systems/fire/engine1/warning-active") == 1 or getprop("/systems/fire/engine2/warning-active") == 1 or getprop("/systems/fire/apu/warning-active") == 1 or getprop("/systems/failures/cargo-aft-fire") == 1 or getprop("/systems/failures/cargo-fwd-fire") == 1) or (((systems.HYD.Psi.green.getValue() < 1500 and pts.Engines.Engine.state[0].getValue() == 3) and (systems.HYD.Psi.yellow.getValue() < 1500 and pts.Engines.Engine.state[1].getValue() == 3)) or ((systems.HYD.Psi.green.getValue() < 1500 or systems.HYD.Psi.yellow.getValue() < 1500) and pts.Engines.Engine.state[0].getValue() == 3 and pts.Engines.Engine.state[1].getValue() == 3) and phaseVarMemo3 >= 3 and phaseVarMemo3 <= 8)) {
		# todo: emer elec
		land_asap_r.active = 1;
	} else {
		land_asap_r.active = 0;
	}
	
	if (land_asap_r.active == 0 and !pts.Gear.wow[1].getValue() and ((getprop("/fdm/jsbsim/propulsion/tank[0]/contents-lbs") < 1650 and getprop("/fdm/jsbsim/propulsion/tank[1]/contents-lbs") < 1650) or ((getprop("/systems/electrical/bus/dc-2") < 25 and (getprop("/systems/failures/fctl/elac1") == 1 or getprop("/systems/failures/fctl/sec1") == 1)) or (systems.HYD.Psi.green.getValue() < 1500 and (getprop("/systems/failures/fctl/elac1") == 1 and getprop("/systems/failures/fctl/sec1") == 1)) or (systems.HYD.Psi.yellow.getValue() < 1500 and (getprop("/systems/failures/fctl/elac1") == 1 and getprop("/systems/failures/fctl/sec1") == 1)) or (systems.HYD.Psi.blue.getValue() < 1500 and (getprop("/systems/failures/fctl/elac2") == 1 and getprop("/systems/failures/fctl/sec2") == 1))) or (phaseVarMemo3 >= 3 and phaseVarMemo3 <= 8 and (pts.Engines.Engine.state[0].getValue() != 3 or pts.Engines.Engine.state[1].getValue() != 3)))) {
		land_asap_a.active = 1;
	} else {
		land_asap_a.active = 0;
	}
	
	if (ecam.ap_active == 1 and apWarn.getValue() == 1) {
		ap_off.active = 1;
	} else {
		ap_off.active = 0;
	}
	
	if (ecam.athr_active == 1 and athrWarn.getValue() == 1) {
		athr_off.active = 1;
	} else {
		athr_off.active = 0;
	}
	
	if ((phaseVarMemo3 >= 2 and phaseVarMemo3 <= 7) and pts.Controls.Flight.speedbrake.getValue() != 0) {
		spd_brk.active = 1;
	} else {
		spd_brk.active = 0;
	}
	
	thrustState = [pts.Systems.Thrust.state[0].getValue(), pts.Systems.Thrust.state[1].getValue()];
	if (thrustState[0] == "IDLE" and thrustState[1] == "IDLE" and phaseVarMemo3 >= 6 and phaseVarMemo3 <= 7) {
		spd_brk.colour = "g";
	} else if ((phaseVarMemo3 >= 2 and phaseVarMemo3 <= 5) or ((thrustState[0] != "IDLE" or thrustState[1]) != "IDLE") and (phaseVarMemo3 >= 6 and phaseVarMemo3 <= 7)) {
		spd_brk.colour = "a";
	}
	
	if (pts.Controls.Gear.parkingBrake.getValue() == 1 and phaseVarMemo3 != 3) {
		park_brk.active = 1;
	} else {
		park_brk.active = 0;
	}
	if (phaseVarMemo3 >= 4 and phaseVarMemo3 <= 8) {
		park_brk.colour = "a";
	} else {
		park_brk.colour = "g";
	}
	
	if (getprop("/controls/gear/brake-fans") == 1) {
		brk_fan.active = 1;
	} else {
		brk_fan.active = 0;
	}
	
	if (systems.HYD.Switch.ptu.getValue() == 1 and ((systems.HYD.Psi.yellow.getValue() < 1450 and systems.HYD.Psi.green.getValue() > 1450 and getprop("/controls/hydraulic/elec-pump-yellow") == 0) or (systems.HYD.Psi.yellow.getValue() > 1450 and systems.HYD.Psi.green.getValue() < 1450))) {
		ptu.active = 1;
	} else {
		ptu.active = 0;
	}
	
	if (getprop("/systems/hydraulic/sources/rat/position") != 0) {
		rat.active = 1;
	} else {
		rat.active = 0;
	}
	
	if (phaseVarMemo3 >= 1 and phaseVarMemo3 <= 2) {
		rat.colour = "a";
	} else {
		rat.colour = "g";
	}
	
	if (getprop("/systems/electrical/relay/emer-glc/contact-pos") == 1 and getprop("/systems/hydraulic/sources/rat/position") != 0 and !pts.Gear.wow[1].getValue()) {
		emer_gen.active = 1;
	} else {
		emer_gen.active = 0;
	}
	
	if (getprop("/sim/model/autopush/enabled") == 1) { # this message is only on when towing - not when disc with switch
		nw_strg_disc.active = 1;
	} else {
		nw_strg_disc.active = 0;
	}
	
	if (pts.Engines.Engine.state[0].getValue() == 3 or pts.Engines.Engine.state[1].getValue() == 3) {
		nw_strg_disc.colour = "a";
	} else {
		nw_strg_disc.colour = "g";
	}
	
	if (getprop("/controls/pneumatics/switches/ram-air") == 1) {
		ram_air.active = 1;
	} else {
		ram_air.active = 0;
	}

	if (getprop("/controls/engines/engine[0]/igniter-a") == 1 or getprop("/controls/engines/engine[0]/igniter-b") == 1 or getprop("/controls/engines/engine[1]/igniter-a") == 1 or getprop("/controls/engines/engine[1]/igniter-b") == 1) {
		ignition.active = 1;
	} else {
		ignition.active = 0;
	}
	
	if ((atc.Transponders.vector[0].condition == 0 and atc.Transponders.vector[1].condition == 0) or (!getprop("/systems/navigation/adr/operating-1") and !getprop("/systems/navigation/adr/operating-2") and !getprop("/systems/navigation/adr/operating-3")) or pts.Instrumentation.TCAS.Inputs.mode.getValue() == 1) {
		if (phaseVarMemo3 == 6) {
			tcas_stby.colour = "a";
		} else {
			tcas_stby.colour = "g";
		}
		tcas_stby.active = 1;
	} else {
		tcas_stby.active = 0;
	}
	
	if ((phaseVarMemo3 <= 2 or phaseVarMemo3 == 6 or phaseVarMemo3 >= 9) and atsu.CompanyCall.frequency != 999.99 and !atsu.CompanyCall.received) {
		company_call.active = 1;
	} else {
		company_call.active = 0;
	}
	
	if (getprop("/controls/pneumatics/switches/apu") == 1 and pts.APU.rpm.getValue() >= 95) {
		apu_bleed.active = 1;
	} else {
		apu_bleed.active = 0;
	}

	if (apu_bleed.active == 0 and pts.APU.rpm.getValue() >= 95) {
		apu_avail.active = 1;
	} else {
		apu_avail.active = 0;
	}

	if (getprop("/controls/lighting/landing-lights[1]") > 0 or getprop("/controls/lighting/landing-lights[2]") > 0) {
		ldg_lt.active = 1;
	} else {
		ldg_lt.active = 0;
	}
	
	if (mcdu.ReceivedMessagesDatabase.firstUnviewed() != -99 and (phaseVarMemo2 <= 2 or phaseVarMemo2 == 6 or phaseVarMemo2 >= 9)) {
		company_msg.active = 1;
	} else {
		company_msg.active = 0;
	}
	
	if (getprop("/controls/ice-protection/leng") == 1 or getprop("/controls/ice-protection/reng") == 1 or getprop("/systems/electrical/bus/dc-1") == 0 or getprop("/systems/electrical/bus/dc-2") == 0) {
		eng_aice.active = 1;
	} else {
		eng_aice.active = 0;
	}
	
	if (getprop("/controls/ice-protection/wing") == 1) {
		wing_aice.active = 1;
	} else {
		wing_aice.active = 0;
	}
	
	if (getprop("instrumentation/comm[2]/frequencies/selected-mhz") != 0 and (phaseVarMemo3 == 1 or phaseVarMemo3 == 2 or phaseVarMemo3 == 6 or phaseVarMemo3 == 9 or phaseVarMemo3 == 10)) {
		vhf3_voice.active = 1;
	} else {
		vhf3_voice.active = 0;
	}
	
	if (getprop("/controls/autobrake/mode") == 1 and (phaseVarMemo3 == 7 or phaseVarMemo3 == 8)) {
		auto_brk_lo.active = 1;
	} else {
		auto_brk_lo.active = 0;
	}

	if (getprop("/controls/autobrake/mode") == 2 and (phaseVarMemo3 == 7 or phaseVarMemo3 == 8)) {
		auto_brk_med.active = 1;
	} else {
		auto_brk_med.active = 0;
	}

	if (getprop("/controls/autobrake/mode") == 3 and (phaseVarMemo3 == 7 or phaseVarMemo3 == 8)) {
		auto_brk_max.active = 1;
	} else {
		auto_brk_max.active = 0;
	}
	
	if (systems.FUEL.Valves.crossfeed.getValue() != 0 and systems.FUEL.Switches.crossfeed.getValue()) {
		fuelx.active = 1;
	} else {
		fuelx.active = 0;
	}
	
	if (phaseVarMemo3 >= 3 and phaseVarMemo3 <= 5) {
		fuelx.colour = "a";
	} else {
		fuelx.colour = "g";
	}
	
	if (getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override") == 1) { # todo: emer elec
		gpws_flap3.active = 1;
	} else {
		gpws_flap3.active = 0;
	}
	
	if (phaseVarMemo3 >= 2 and phaseVarMemo3 <= 9 and systems.ELEC.Bus.ac1.getValue() >= 110 and systems.ELEC.Bus.ac2.getValue() >= 110 and (getprop("/systems/fuel/feed-center-1") or getprop("/systems/fuel/feed-center-2"))) {
		ctr_tk_feedg.active = 1;
	} else {
		ctr_tk_feedg.active = 0;
	}
}

setlistener("/engines/engine[0]/state", func() {
	if ((state1Node.getValue() != 3 and state2Node.getValue() != 3) and !pts.Fdm.JSBsim.Position.wow.getBoolValue()) {
		dualFailNode.setBoolValue(1);
	} else {
		dualFailNode.setBoolValue(0);
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if ((state1Node.getValue() != 3 and state2Node.getValue() != 3) and !pts.Fdm.JSBsim.Position.wow.getBoolValue()) {
		dualFailNode.setBoolValue(1);
	} else {
		dualFailNode.setBoolValue(0);
	}
}, 0, 0);
