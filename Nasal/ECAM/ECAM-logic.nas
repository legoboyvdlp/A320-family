# A3XX Electronic Centralised Aircraft Monitoring System

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# props.nas:

var dualFailNode = props.globals.initNode("/ECAM/dual-failure-enabled", 0, "BOOL");
var phaseNode    = props.globals.getNode("ECAM/warning-phase", 1);
var apWarn       = props.globals.getNode("it-autoflight/output/ap-warning", 1);
var athrWarn     = props.globals.getNode("it-autoflight/output/athr-warning", 1);
var emerGen      = props.globals.getNode("controls/electrical/switches/emer-gen", 1);

var fac1Node   = props.globals.getNode("controls/fctl/switches/fac1", 1);
var state1Node = props.globals.getNode("engines/engine[0]/state", 1);
var state2Node = props.globals.getNode("engines/engine[1]/state", 1);
var wowNode    = props.globals.getNode("fdm/jsbsim/position/wow", 1);
var apu_rpm    = props.globals.getNode("systems/apu/rpm", 1);
var wing_pb    = props.globals.getNode("controls/switches/wing", 1);
var apumaster  = props.globals.getNode("controls/apu/master", 1);
var apu_bleedSw   = props.globals.getNode("controls/pneumatic/switches/bleedapu", 1);
var gear       = props.globals.getNode("gear/gear-pos-norm", 1);
var cutoff1    = props.globals.getNode("controls/engines/engine[0]/cutoff-switch", 1);
var cutoff2    = props.globals.getNode("controls/engines/engine[1]/cutoff-switch", 1);
var stallVoice = props.globals.initNode("/sim/sound/warnings/stall-voice", 0, "BOOL");
var engOpt     = props.globals.getNode("options/eng", 1);

# local variables
var phaseVar = nil;
var dualFailFACActive = 1;
var emerConfigFACActive = 1;
var gear_agl_cur = nil;
var numberMinutes = nil;
var timeNow = nil;
var timer10secIRS = nil;
var altAlertInhibit = nil;
var alt200 = nil;
var alt750 = nil;
var bigThree = nil;

var messages_priority_3 = func {
	phaseVar = phaseNode.getValue();
	
	# Stall
	# todo - altn law and emer cancel flipflops page 2440
	if (phaseVar >= 5 and phaseVar <= 7 and (getprop("fdm/jsbsim/fcs/slat-pos-deg") <= 15 and (getprop("systems/navigation/adr/output/aoa-1") > 15 or getprop("systems/navigation/adr/output/aoa-2") > 15 or getprop("systems/navigation/adr/output/aoa-3") > 15)) or (getprop("fdm/jsbsim/fcs/slat-pos-deg") > 15 and (getprop("systems/navigation/adr/output/aoa-1") > 23 or getprop("systems/navigation/adr/output/aoa-2") > 23 or getprop("systems/navigation/adr/output/aoa-3") > 23))) {
		stall.active = 1;
	} else {
		ECAM_controller.warningReset(stall);
	}
	
	if (stall.active) {
		stallVoice.setValue(1);
	} else {
		stallVoice.setValue(0);
	}
	
	if ((phaseVar == 1 or (phaseVar >= 5 and phaseVar <= 7)) and getprop("systems/navigation/adr/output/overspeed")) {
		overspeed.active = 1;
		if (getprop("systems/navigation/adr/computation/overspeed-vmo") or getprop("systems/navigation/adr/computation/overspeed-mmo")) {
			overspeedVMO.active = 1;
		} else {
			ECAM_controller.warningReset(overspeedVMO);
		}
		
		if (getprop("systems/navigation/adr/computation/overspeed-vle")) {
			overspeedGear.active = 1;
		} else {
			ECAM_controller.warningReset(overspeedGear);
		}
		
		if (getprop("systems/navigation/adr/computation/overspeed-vfe")) {
			overspeedFlap.active = 1;
			overspeedFlap.msg = "-VFE................" ~ (systems.ADIRSnew.overspeedVFE.getValue() - 4);
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
	
	# FCTL FLAPS NOT ZERO
	if ((flap_not_zero.clearFlag == 0) and phaseVar == 6 and getprop("controls/flight/flap-lever") != 0 and getprop("instrumentation/altimeter/indicated-altitude-ft") > 22000) {
		flap_not_zero.active = 1;
	} else {
		ECAM_controller.warningReset(flap_not_zero);
	}
	
	# ENG DUAL FAIL
	
	if (phaseVar >= 5 and phaseVar <= 7 and dualFailNode.getBoolValue() and dualFail.clearFlag == 0) {
		dualFail.active = 1;
	} else {
		ECAM_controller.warningReset(dualFail);
		
		dualFailFACActive = 1; # reset FAC local variable
	}
	
	if (dualFail.active == 1) {
		if (getprop("controls/engines/engine-start-switch") != 2 and dualFailModeSel.clearFlag == 0) {
			dualFailModeSel.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailModeSel);
		}
		
		if (getprop("fdm/jsbsim/fcs/throttle-lever[0]") > 0.01 and getprop("fdm/jsbsim/fcs/throttle-lever[1]") > 0.01 and dualFailLevers.clearFlag == 0) {
			dualFailLevers.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailLevers);
		}
		
		if (engOpt.getValue() == "IAE" and dualFailRelightSPD.clearFlag == 0) {
			dualFailRelightSPD.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRelightSPD);
		}
		
		if (engOpt.getValue() != "IAE" and dualFailRelightSPDCFM.clearFlag == 0) {
			dualFailRelightSPDCFM.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRelightSPDCFM);
		}
		
		if (emerGen.getValue() == 0 and dualFailElec.clearFlag == 0) {
			dualFailElec.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailElec);
		}
		
		if (dualFailRadio.clearFlag == 0) {
			dualFailRadio.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRadio);
		}
		
		if (dualFailFACActive == 1 and dualFailFAC.clearFlag == 0) {
			dualFailFAC.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailFAC);
		}
		
		
		if (dualFailMasters.clearFlag == 0) {
			dualFailRelight.active = 1; # assumption
			dualFailMasters.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRelight);
			ECAM_controller.warningReset(dualFailMasters);
		}
		
		if (dualFailSPDGD.clearFlag == 0) {
			dualFailSuccess.active = 1; # assumption
			dualFailSPDGD.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailSuccess);
			ECAM_controller.warningReset(dualFailSPDGD);
		}
		
		if (dualFailAPU.clearFlag == 0) {
			dualFailAPU.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPU);
		}
		
		if (dualFailAPUwing.clearFlag == 0 and apu_rpm.getValue() > 94.9 and wing_pb.getBoolValue()) {
			dualFailAPUwing.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPUwing);
		}
		
		if (dualFailAPUbleed.clearFlag == 0 and apu_rpm.getValue() > 94.9 and !apu_bleedSw.getBoolValue()) {
			dualFailAPUbleed.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPUbleed);
		}
		
		if (dualFailMastersAPU.clearFlag == 0) {
			dualFailMastersAPU.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailMastersAPU);
		}
		
		if (dualFailflap.clearFlag == 0) {
			dualFailAPPR.active = 1; # assumption
			dualFailflap.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPPR);
			ECAM_controller.warningReset(dualFailflap);
		}
		
		if (dualFailcabin.clearFlag == 0) {
			dualFailcabin.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailcabin);
		}
		
		if (dualFailrudd.clearFlag == 0) {
			dualFailrudd.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailrudd);
		}
		
		if (dualFailgear.clearFlag == 0 and gear.getValue() != 1) {
			dualFail5000.active = 1; # according to doc
			dualFailgear.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailgear);
			ECAM_controller.warningReset(dualFail5000);
		}
		
		if (dualFailfinalspeed.clearFlag == 0) {
			dualFailfinalspeed.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailfinalspeed);
		}
		
		if (dualFailmasteroff.clearFlag == 0 and (!cutoff1.getBoolValue() or !cutoff2.getBoolValue())) {
			dualFailmasteroff.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailmasteroff);
		}
		
		if (dualFailapuoff.clearFlag == 0 and apumaster.getBoolValue()) {
			dualFailapuoff.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailapuoff);
		}
		
		if (dualFailevac.clearFlag == 0) {
			dualFailevac.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailevac);
		}
		
		if (dualFailbatt.clearFlag == 0) { # elec power lost when batt goes off anyway I guess
			dualFailbatt.active = 1;
			dualFailtouch.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailbatt);
			ECAM_controller.warningReset(dualFailtouch);
		}
	} else {
		ECAM_controller.warningReset(dualFailModeSel);
		ECAM_controller.warningReset(dualFailLevers);
		ECAM_controller.warningReset(dualFailRelightSPD);
		ECAM_controller.warningReset(dualFailRelightSPDCFM);
		ECAM_controller.warningReset(dualFailElec);
		ECAM_controller.warningReset(dualFailRadio);
		ECAM_controller.warningReset(dualFailFAC);
		ECAM_controller.warningReset(dualFailRelight);
		ECAM_controller.warningReset(dualFailMasters);
		ECAM_controller.warningReset(dualFailSuccess);
		ECAM_controller.warningReset(dualFailSPDGD);
		ECAM_controller.warningReset(dualFailAPU);
		ECAM_controller.warningReset(dualFailAPUwing);
		ECAM_controller.warningReset(dualFailAPUbleed);
		ECAM_controller.warningReset(dualFailMastersAPU);
		ECAM_controller.warningReset(dualFailAPPR);
		ECAM_controller.warningReset(dualFailflap);
		ECAM_controller.warningReset(dualFailcabin);
		ECAM_controller.warningReset(dualFailrudd);
		ECAM_controller.warningReset(dualFailgear);
		ECAM_controller.warningReset(dualFail5000);
		ECAM_controller.warningReset(dualFailfinalspeed);
		ECAM_controller.warningReset(dualFailmasteroff);
		ECAM_controller.warningReset(dualFailapuoff);
		ECAM_controller.warningReset(dualFailevac);
		ECAM_controller.warningReset(dualFailbatt);
		ECAM_controller.warningReset(dualFailtouch);
	}
	
	# ENG FIRE
	if ((eng1FireFlAgent2.clearFlag == 0 and getprop("systems/fire/engine1/warning-active") == 1 and phaseVar >= 5 and phaseVar <= 7) or (eng1FireGnevacBat.clearFlag == 0 and getprop("systems/fire/engine1/warning-active") == 1 and (phaseVar < 5 or phaseVar > 7))) {
		eng1Fire.active = 1;
	} else {
		ECAM_controller.warningReset(eng1Fire);
	}
	
	if ((eng2FireFlAgent2.clearFlag == 0 and getprop("systems/fire/engine2/warning-active") == 1 and phaseVar >= 5 and phaseVar <= 7) or (eng2FireGnevacBat.clearFlag == 0 and getprop("systems/fire/engine2/warning-active") == 1 and (phaseVar < 5 or phaseVar > 7))) {
		eng2Fire.active = 1;
	} else {
		ECAM_controller.warningReset(eng2Fire);
	}
	
	if (apuFireMaster.clearFlag == 0 and getprop("systems/fire/apu/warning-active")) {
		apuFire.active = 1;
	} else {
		ECAM_controller.warningReset(apuFire);
	}
	
	if (eng1Fire.active == 1) {
		if (phaseVar >= 5 and phaseVar <= 7) {
			if (eng1FireFllever.clearFlag == 0 and getprop("fdm/jsbsim/fcs/throttle-lever[0]") > 0.01) {
				eng1FireFllever.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFllever);
			}
			
			if (eng1FireFlmaster.clearFlag == 0 and getprop("controls/engines/engine[0]/cutoff-switch") == 0) {
				eng1FireFlmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlmaster);
			}
			
			if (eng1FireFlPB.clearFlag == 0 and getprop("controls/engines/engine[0]/fire-btn") == 0) {
				eng1FireFlPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlPB);
			}
			
			if (getprop("systems/fire/engine1/agent1-timer") != 0 and getprop("systems/fire/engine1/agent1-timer") != 99) {
				eng1FireFlAgent1Timer.msg = " -AGENT AFT " ~ getprop("systems/fire/engine1/agent1-timer") ~ " S...DISCH";
			}
			
			if (eng1FireFlAgent1.clearFlag == 0 and getprop("controls/engines/engine[0]/fire-btn") == 1 and !getprop("systems/fire/engine1/disch1") and getprop("systems/fire/engine1/agent1-timer") != 0 and getprop("systems/fire/engine1/agent1-timer") != 99) {
				eng1FireFlAgent1Timer.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent1Timer);
			}
			
			if (eng1FireFlAgent1.clearFlag == 0 and !getprop("systems/fire/engine1/disch1") and (getprop("systems/fire/engine1/agent1-timer") == 0 or getprop("systems/fire/engine1/agent1-timer") == 99)) {
				eng1FireFlAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent1);
			}
			
			if (eng1FireFlATC.clearFlag == 0) {
				eng1FireFlATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlATC);
			}
			
			if (getprop("systems/fire/engine1/agent2-timer") != 0 and getprop("systems/fire/engine1/agent2-timer") != 99) {
				eng1FireFl30Sec.msg = "•IF FIRE AFTER " ~ getprop("systems/fire/engine1/agent2-timer") ~ " S:";
			}
			
			if (eng1FireFlAgent2.clearFlag == 0 and getprop("systems/fire/engine1/disch1") and !getprop("systems/fire/engine1/disch2") and getprop("systems/fire/engine1/agent2-timer") > 0) {
				eng1FireFl30Sec.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFl30Sec);
			}
			
			if (eng1FireFlAgent2.clearFlag == 0 and getprop("systems/fire/engine1/disch1") and !getprop("systems/fire/engine1/disch2")) {
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
		
		if (phaseVar < 5 or phaseVar > 7) {
			if (eng1FireGnlever.clearFlag == 0 and getprop("fdm/jsbsim/fcs/throttle-lever[0]") > 0.01 and getprop("fdm/jsbsim/fcs/throttle-lever[1]") > 0.01) {
				eng1FireGnlever.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnlever);
			}
			
			if (eng1FireGnparkbrk.clearFlag == 0 and getprop("controls/gear/brake-parking") == 0) { 
				eng1FireGnstopped.active = 1;
				eng1FireGnparkbrk.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnstopped);
				ECAM_controller.warningReset(eng1FireGnparkbrk);
			}
			
			if (eng1FireGnmaster.clearFlag == 0 and getprop("controls/engines/engine[0]/cutoff-switch") == 0) {
				eng1FireGnmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnmaster);
			}
			
			if (eng1FireGnPB.clearFlag == 0 and getprop("controls/engines/engine[0]/fire-btn") == 0) {
				eng1FireGnPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnPB);
			}
			
			if (eng1FireGnAgent1.clearFlag == 0 and !getprop("systems/fire/engine1/disch1")) {
				eng1FireGnAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnAgent1);
			}
			
			if (eng1FireGnAgent2.clearFlag == 0 and !getprop("systems/fire/engine1/disch2")) {
				eng1FireGnAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnAgent2);
			}
			
			if (eng1FireGnmaster2.clearFlag == 0 and getprop("controls/engines/engine[1]/cutoff-switch") == 0) {
				eng1FireGnmaster2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnmaster2);
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
			
			if (eng1FireGnevacSw.clearFlag == 0) {
				eng1FireGnevac.active = 1;
				eng1FireGnevacSw.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnevac);
				ECAM_controller.warningReset(eng1FireGnevacSw);
			}
			
			if (eng1FireGnevacApu.clearFlag == 0 and getprop("controls/apu/master") and getprop("systems/apu/rpm") > 99) {
				eng1FireGnevacApu.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnevacApu);
			}
			
			if (eng1FireGnevacBat.clearFlag == 0 and (systems.ELEC.Switch.bat1.getValue() or systems.ELEC.Switch.bat2.getValue())) {
				eng1FireGnevacBat.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnevacBat);
			}
		} else {
			ECAM_controller.warningReset(eng1FireGnlever);
			ECAM_controller.warningReset(eng1FireGnstopped);
			ECAM_controller.warningReset(eng1FireGnparkbrk);
			ECAM_controller.warningReset(eng1FireGnmaster);
			ECAM_controller.warningReset(eng1FireGnPB);
			ECAM_controller.warningReset(eng1FireGnAgent1);
			ECAM_controller.warningReset(eng1FireGnAgent2);
			ECAM_controller.warningReset(eng1FireGnmaster2);
			ECAM_controller.warningReset(eng1FireGnATC);
			ECAM_controller.warningReset(eng1FireGncrew);
			ECAM_controller.warningReset(eng1FireGnevac);
			ECAM_controller.warningReset(eng1FireGnevacSw);
			ECAM_controller.warningReset(eng1FireGnevacApu);
			ECAM_controller.warningReset(eng1FireGnevacBat);
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
		ECAM_controller.warningReset(eng1FireGnmaster);
		ECAM_controller.warningReset(eng1FireGnPB);
		ECAM_controller.warningReset(eng1FireGnAgent1);
		ECAM_controller.warningReset(eng1FireGnAgent2);
		ECAM_controller.warningReset(eng1FireGnmaster2);
		ECAM_controller.warningReset(eng1FireGnATC);
		ECAM_controller.warningReset(eng1FireGncrew);
		ECAM_controller.warningReset(eng1FireGnevac);
		ECAM_controller.warningReset(eng1FireGnevacSw);
		ECAM_controller.warningReset(eng1FireGnevacApu);
		ECAM_controller.warningReset(eng1FireGnevacBat);
	}
	
	if (eng2Fire.active == 1) {
		if (phaseVar >= 5 and phaseVar <= 7) {
			if (eng2FireFllever.clearFlag == 0 and getprop("fdm/jsbsim/fcs/throttle-lever[1]") > 0.01) {
				eng2FireFllever.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFllever);
			}
			
			if (eng2FireFlmaster.clearFlag == 0 and getprop("controls/engines/engine[1]/cutoff-switch") == 0) {
				eng2FireFlmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlmaster);
			}
			
			if (eng2FireFlPB.clearFlag == 0 and getprop("controls/engines/engine[1]/fire-btn") == 0) {
				eng2FireFlPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlPB);
			}
			
			if (getprop("systems/fire/engine2/agent1-timer") != 0 and getprop("systems/fire/engine2/agent1-timer") != 99) {
				eng2FireFlAgent1Timer.msg = " -AGENT AFT " ~ getprop("systems/fire/engine2/agent1-timer") ~ " S...DISCH";
			}
			
			if (eng2FireFlAgent1.clearFlag == 0 and getprop("controls/engines/engine[1]/fire-btn") == 1 and !getprop("systems/fire/engine2/disch1") and getprop("systems/fire/engine2agent1-timer") != 0 and getprop("systems/fire/engine2/agent1-timer") != 99) {
				eng2FireFlAgent1Timer.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent1Timer);
			}
			
			if (eng2FireFlAgent1.clearFlag == 0 and !getprop("systems/fire/engine2/disch1") and (getprop("systems/fire/engine2/agent1-timer") == 0 or getprop("systems/fire/engine2/agent1-timer") == 99)) {
				eng2FireFlAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent1);
			}
			
			if (eng2FireFlATC.clearFlag == 0) {
				eng2FireFlATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlATC);
			}
			
			if (getprop("systems/fire/engine2/agent2-timer") != 0 and getprop("systems/fire/engine2/agent2-timer") != 99) {
				eng2FireFl30Sec.msg = "•IF FIRE AFTER " ~ getprop("systems/fire/engine2/agent2-timer") ~ " S:";
			}
			
			if (eng2FireFlAgent2.clearFlag == 0 and getprop("systems/fire/engine2/disch1") and !getprop("systems/fire/engine2/disch2") and getprop("systems/fire/engine2/agent2-timer") > 0) {
				eng2FireFl30Sec.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFl30Sec);
			}
			
			if (eng2FireFlAgent2.clearFlag == 0 and getprop("systems/fire/engine2/disch1") and !getprop("systems/fire/engine2/disch2")) {
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
		
		if (phaseVar < 5 or phaseVar > 7) {
			if (eng2FireGnlever.clearFlag == 0 and getprop("fdm/jsbsim/fcs/throttle-lever[0]") > 0.01 and getprop("fdm/jsbsim/fcs/throttle-lever[1]") > 0.01) {
				eng2FireGnlever.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnlever);
			}
			
			if (eng2FireGnparkbrk.clearFlag == 0 and getprop("controls/gear/brake-parking") == 0) { 
				eng2FireGnstopped.active = 1;
				eng2FireGnparkbrk.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnstopped);
				ECAM_controller.warningReset(eng2FireGnparkbrk);
			}
			
			if (eng2FireGnmaster.clearFlag == 0 and getprop("controls/engines/engine[1]/cutoff-switch") == 0) {
				eng2FireGnmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnmaster);
			}
			
			if (eng2FireGnPB.clearFlag == 0 and getprop("controls/engines/engine[1]/fire-btn") == 0) {
				eng2FireGnPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnPB);
			}
			
			if (eng2FireGnAgent1.clearFlag == 0 and !getprop("systems/fire/engine2/disch1")) {
				eng2FireGnAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnAgent1);
			}
			
			if (eng2FireGnAgent2.clearFlag == 0 and !getprop("systems/fire/engine2/disch2")) {
				eng2FireGnAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnAgent2);
			}
			
			if (eng2FireGnmaster2.clearFlag == 0 and getprop("controls/engines/engine[0]/cutoff-switch") == 0) {
				eng2FireGnmaster2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnmaster2);
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
			
			if (eng2FireGnevacSw.clearFlag == 0) {
				eng2FireGnevac.active = 1;
				eng2FireGnevacSw.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnevac);
				ECAM_controller.warningReset(eng2FireGnevacSw);
			}
			
			if (eng2FireGnevacApu.clearFlag == 0 and getprop("controls/apu/master") and getprop("systems/apu/rpm") > 99) {
				eng2FireGnevacApu.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnevacApu);
			}
			
			if (eng2FireGnevacBat.clearFlag == 0 and (systems.ELEC.Switch.bat1.getValue() or systems.ELEC.Switch.bat2.getValue())) {
				eng2FireGnevacBat.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnevacBat);
			}
		} else {
			ECAM_controller.warningReset(eng2FireGnlever);
			ECAM_controller.warningReset(eng2FireGnstopped);
			ECAM_controller.warningReset(eng2FireGnparkbrk);
			ECAM_controller.warningReset(eng2FireGnmaster);
			ECAM_controller.warningReset(eng2FireGnPB);
			ECAM_controller.warningReset(eng2FireGnAgent1);
			ECAM_controller.warningReset(eng2FireGnAgent2);
			ECAM_controller.warningReset(eng2FireGnmaster2);
			ECAM_controller.warningReset(eng2FireGnATC);
			ECAM_controller.warningReset(eng2FireGncrew);
			ECAM_controller.warningReset(eng2FireGnevac);
			ECAM_controller.warningReset(eng2FireGnevacSw);
			ECAM_controller.warningReset(eng2FireGnevacApu);
			ECAM_controller.warningReset(eng2FireGnevacBat);
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
		ECAM_controller.warningReset(eng2FireGnmaster);
		ECAM_controller.warningReset(eng2FireGnPB);
		ECAM_controller.warningReset(eng2FireGnAgent1);
		ECAM_controller.warningReset(eng2FireGnAgent2);
		ECAM_controller.warningReset(eng2FireGnmaster2);
		ECAM_controller.warningReset(eng2FireGnATC);
		ECAM_controller.warningReset(eng2FireGncrew);
		ECAM_controller.warningReset(eng2FireGnevac);
		ECAM_controller.warningReset(eng2FireGnevacSw);
		ECAM_controller.warningReset(eng2FireGnevacApu);
		ECAM_controller.warningReset(eng2FireGnevacBat);
	}
	
	# APU Fire
	if (apuFire.active == 1) {
		if (apuFirePB.clearFlag == 0 and !getprop("controls/apu/fire-btn")) {
			apuFirePB.active = 1;
		} else {
			ECAM_controller.warningReset(apuFirePB);
		}
		
		if (getprop("systems/fire/apu/agent-timer") != 0 and getprop("systems/fire/apu/agent-timer") != 99) {
			apuFireAgentTimer.msg = " -AGENT AFT " ~ getprop("systems/fire/apu/agent-timer") ~ " S...DISCH";
		}
		
		if (apuFireAgent.clearFlag == 0 and getprop("controls/apu/fire-btn") and !getprop("systems/fire/apu/disch") and getprop("systems/fire/apu/agent-timer") != 0) {
			apuFireAgentTimer.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireAgentTimer);
		}
		
		if (apuFireAgent.clearFlag == 0 and getprop("controls/apu/fire-btn") and !getprop("systems/fire/apu/disch") and getprop("systems/fire/apu/agent-timer") == 0) {
			apuFireAgent.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireAgent);
		}
		
		if (apuFireMaster.clearFlag == 0 and getprop("controls/apu/master")) {
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
	
	# CONFIG
	if ((slats_config.clearFlag == 0) and (getprop("controls/flight/flap-lever") == 0 or getprop("controls/flight/flap-lever")) == 4 and phaseVar >= 3 and phaseVar <= 4) {
		slats_config.active = 1;
		slats_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(slats_config);
		ECAM_controller.warningReset(slats_config_1);
	}
	
	if ((flaps_config.clearFlag == 0) and (getprop("controls/flight/flap-lever") == 0 or getprop("controls/flight/flap-lever") == 4) and phaseVar >= 3 and phaseVar <= 4) {
		flaps_config.active = 1;
		flaps_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(flaps_config);
		ECAM_controller.warningReset(flaps_config_1);
	}
	
	if ((spd_brk_config.clearFlag == 0) and getprop("controls/flight/speedbrake") != 0 and phaseVar >= 3 and phaseVar <= 4) {
		spd_brk_config.active = 1;
		spd_brk_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(spd_brk_config);
		ECAM_controller.warningReset(spd_brk_config_1);
	}
	
	if ((pitch_trim_config.clearFlag == 0) and (getprop("fdm/jsbsim/hydraulics/elevator-trim/final-deg") > 1.75 or getprop("fdm/jsbsim/hydraulics/elevator-trim/final-deg") < -3.65) and phaseVar >= 3 and phaseVar <= 4) {
		pitch_trim_config.active = 1;
		pitch_trim_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(pitch_trim_config);
		ECAM_controller.warningReset(pitch_trim_config_1);
	}
	
	if ((rud_trim_config.clearFlag == 0) and (getprop("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") < -3.55 or getprop("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") > 3.55) and phaseVar >= 3 and phaseVar <= 4) {
		rud_trim_config.active = 1;
		rud_trim_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(rud_trim_config);
		ECAM_controller.warningReset(rud_trim_config_1);
	}
	
	if ((park_brk_config.clearFlag == 0) and getprop("controls/gear/brake-parking") == 1 and phaseVar >= 3 and phaseVar <= 4) {
		park_brk_config.active = 1;
	} else {
		ECAM_controller.warningReset(park_brk_config);
	}
	
	# AUTOFLT
	if ((ap_offw.clearFlag == 0) and apWarn.getValue() == 2) {
		ap_offw.active = 1;
	} else {
		ECAM_controller.warningReset(ap_offw);
	}
	
	# C-Chord
	if ((pts.Modes.Altimeter.std.getValue() and abs(fcu.altSet.getValue() - getprop("systems/navigation/adr/output/baro-alt-1-capt")) < 200) or !pts.Modes.Altimeter.std.getValue() and abs(fcu.altSet.getValue() - getprop("systems/navigation/adr/output/baro-alt-corrected-1-capt")) < 200) {
		alt200 = 1;
	} else {
		alt200 = 0;
	}
	
	if ((pts.Modes.Altimeter.std.getValue() and abs(fcu.altSet.getValue() - getprop("systems/navigation/adr/output/baro-alt-1-capt")) < 750) or !pts.Modes.Altimeter.std.getValue() and abs(fcu.altSet.getValue() - getprop("systems/navigation/adr/output/baro-alt-corrected-1-capt")) < 750) {
		alt750 = 1;
	} else {
		alt750 = 0;
	}
	
	if (FWC.altChg.getValue() or pts.Gear.position[0].getValue() == 1 or (getprop("controls/gear/gear-down") and pts.JSBSIM.FCS.slatDeg.getValue() > 4) or fmgc.Output.vert.getValue() == 2) {
		altAlertInhibit = 1;
	} else {
		altAlertInhibit = 0;
	}
	
	if (alt750 and !alt200 and !altAlertInhibit) {
		FWC.Monostable.altAlert2.setValue(1);
	} else {
		FWC.Monostable.altAlert2.setValue(0);
	}
	
	if ((!fcu.ap1.getBoolValue() and !fcu.ap2.getBoolValue()) and FWC.Monostable.altAlert2.getValue()) {
		FWC.Monostable.altAlert1.setValue(1);
	} else {
		FWC.Monostable.altAlert1.setValue(0);
	}
	
	if (alt750 and alt200 and !altAlertInhibit) {
		setprop("ECAM/flipflop/alt-alert-2-rs-set", 1);
	} else {
		setprop("ECAM/flipflop/alt-alert-2-rs-set", 0);
	}
	
	if (getprop("ECAM/flipflop/alt-alert-rs-reset") or (!alt750 and !alt200 and !altAlertInhibit)) {
		setprop("ECAM/flipflop/alt-alert-2-rs-reset", 1);
	} else {
		setprop("ECAM/flipflop/alt-alert-2-rs-reset", 0);
	}
	
	if (alt750 and !alt200 and !altAlertInhibit and getprop("ECAM/flipflop/alt-alert-2-rs-output")) {
		setprop("ECAM/flipflop/alt-alert-3-rs-set", 1);
	} else {
		setprop("ECAM/flipflop/alt-alert-3-rs-set", 0);
	}
	
	if ((!alt750 and !alt200 and !altAlertInhibit and getprop("ECAM/flipflop/alt-alert-rs-output")) or (!alt750 and !alt200 and !altAlertInhibit and getprop("ECAM/flipflop/alt-alert-3-rs-output")) or getprop("ECAM/flipflop/alt-alert-3-rs-set")) {
		bigThree = 1;
	} else {
		bigThree = 0;
	}
	
	if (!gnd and (FWC.Monostable.altAlert1Output.getValue() or bigThree)) {
		if (!getprop("sim/sound/warnings/cchord-inhibit")) {
			setprop("sim/sound/warnings/cchord", 1);
		} else {
			setprop("sim/sound/warnings/cchord", 0);
		}
	} else {
		setprop("sim/sound/warnings/cchord", 0);
		setprop("sim/sound/warnings/cchord-inhibit", 0);
	}
	
	if (!gnd and getprop("ECAM/flipflop/alt-alert-3-rs-set") != 1 and alt750 and !alt200 and !altAlertInhibit) {
		setprop("ECAM/alt-alert-steady", 1);
	} else {
		setprop("ECAM/alt-alert-steady", 0);
	}
	
	if (!gnd and bigThree) {
		setprop("ECAM/alt-alert-flash", 1);
	} else {
		setprop("ECAM/alt-alert-flash", 0);
	}
	
	if (!systems.cargoTestBtn.getBoolValue()) {
		if (cargoSmokeFwd.clearFlag == 0 and systems.fwdCargoFireWarn.getBoolValue() and (phaseVar <= 3 or phaseVar >= 9 or phaseVar == 6)) {
			cargoSmokeFwd.active = 1;
		} elsif (cargoSmokeFwd.clearFlag == 1 or systems.cargoTestBtnOff.getBoolValue()) {
			ECAM_controller.warningReset(cargoSmokeFwd);
			cargoSmokeFwd.isMainMsg = 1;
		}
		
		if (cargoSmokeFwdAgent.clearFlag == 0 and cargoSmokeFwd.active == 1 and !getprop("systems/fire/cargo/disch")) {
			cargoSmokeFwdAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeFwdAgent);
			cargoSmokeFwd.isMainMsg = 0;
		}

		if (cargoSmokeAft.clearFlag == 0 and systems.aftCargoFireWarn.getBoolValue() and (phaseVar <= 3 or phaseVar >= 9 or phaseVar == 6)) {
			cargoSmokeAft.active = 1;
		} elsif (cargoSmokeAft.clearFlag == 1 or systems.cargoTestBtnOff.getBoolValue()) {
			ECAM_controller.warningReset(cargoSmokeAft);
			cargoSmokeAft.isMainMsg = 1;
			systems.cargoTestBtnOff.setBoolValue(0);
		}
		
		if (cargoSmokeAftAgent.clearFlag == 0 and cargoSmokeAft.active == 1 and !getprop("systems/fire/cargo/disch")) {
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
	if ((!gear.getValue() or !getprop("controls/gear/gear-down")) and getprop("systems/electrical/some-electric-thingie/static-inverter-timer") == 1 and phaseVar >= 5 and phaseVar <= 7) {
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
	if (getprop("systems/electrical/some-electric-thingie/emer-elec-config") and !dualFailNode.getBoolValue() and phaseVar != 4 and phaseVar != 8 and emerconfig.clearFlag == 0) {
		emerconfig.active = 1;
		
		if (getprop("systems/hydraulic/sources/rat/position") != 0 and emerconfigMinRat.clearFlag == 0) {
			emerconfigMinRat.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigMinRat);
		}
		
		if (!(getprop("systems/electrical/some-electric-thingie/generator-1-reset") and getprop("systems/electrical/some-electric-thingie/generator-2-reset")) and emerconfigGen.clearFlag == 0) {
			emerconfigGen.active = 1; # EGEN12R TRUE
		} else {
			ECAM_controller.warningReset(emerconfigGen);
		}
		
		if (!(getprop("systems/electrical/some-electric-thingie/generator-1-reset-bustie") and getprop("systems/electrical/some-electric-thingie/generator-2-reset-bustie")) and emerconfigGen2.clearFlag == 0) {
			emerconfigGen2.active = 1;
			if (getprop("controls/electrical/switches/bus-tie")) {
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
		
		if (getprop("systems/electrical/relay/emer-glc/contact-pos") == 0 and emerconfigManOn.clearFlag == 0) {
			emerconfigManOn.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigManOn);
		}
		
		if (getprop("controls/engines/engine-start-switch") != 2 and emerconfigEngMode.clearFlag == 0) {
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
		
		if (emerConfigFACActive == 1 and emerconfigFAC.clearFlag == 0) {
			emerconfigFAC.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigFAC);
		}
		
		if (!getprop("controls/electrical/switches/bus-tie") and emerconfigBusTie2.clearFlag == 0) {
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
		
		if (emerconfigAltn.clearFlag == 0) {
			emerconfigAltn.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigAltn);
		}
		
		if (emerconfigProt.clearFlag == 0) {
			emerconfigProt.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigProt);
		}
		
		if (emerconfigMaxSpeed.clearFlag == 0) {
			emerconfigMaxSpeed.active = 1;
		} else {
			ECAM_controller.warningReset(emerconfigMaxSpeed);
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
		ECAM_controller.warningReset(emerconfigAltn);
		ECAM_controller.warningReset(emerconfigProt);
		ECAM_controller.warningReset(emerconfigMaxSpeed);
	}
}

var messages_priority_2 = func {
	phaseVar = phaseNode.getValue();
	# DC EMER CONFIG
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and systems.ELEC.Bus.dcEss.getValue() < 25 and systems.ELEC.Bus.dc1.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() < 25 and phaseVar != 4 and phaseVar != 8 and dcEmerconfig.clearFlag == 0) {
		dcEmerconfig.active = 1;
		dcEmerconfigManOn.active = 1;
	} else {
		ECAM_controller.warningReset(dcEmerconfig);
		ECAM_controller.warningReset(dcEmerconfigManOn);
	}
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and !dcEmerconfig.active and systems.ELEC.Bus.dc1.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() < 25 and phaseVar != 4 and phaseVar != 8 and dcBus12Fault.clearFlag == 0) {
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
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and systems.ELEC.Bus.acEss.getValue() < 110 and phaseVar != 4 and phaseVar != 8 and AcBusEssFault.clearFlag == 0) {
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
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and systems.ELEC.Bus.ac1.getValue() < 110 and phaseVar != 4 and phaseVar != 8 and AcBus1Fault.clearFlag == 0) {
		AcBus1Fault.active = 1;
		AcBus1FaultBlower.active = 1;
	} else {
		ECAM_controller.warningReset(AcBus1Fault);
		ECAM_controller.warningReset(AcBus1FaultBlower);
	}
	
	if (!dcEmerconfig.active and systems.ELEC.Bus.dcEss.getValue() < 25 and phaseVar != 4 and phaseVar != 8 and DcEssBusFault.clearFlag == 0) {
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
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and systems.ELEC.Bus.ac2.getValue() < 110 and phaseVar != 4 and phaseVar != 8 and AcBus2Fault.clearFlag == 0) {
		AcBus2Fault.active = 1;
		AcBus2FaultExtract.active = 1;
	} else {
		ECAM_controller.warningReset(AcBus2Fault);
		ECAM_controller.warningReset(AcBus2FaultExtract);
	}
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and systems.ELEC.Bus.dc1.getValue() < 25 and systems.ELEC.Bus.dc2.getValue() >= 25 and phaseVar != 4 and phaseVar != 8 and dcBus1Fault.clearFlag == 0) {
		dcBus1Fault.active = 1;
		dcBus1FaultBlower.active = 1;
		dcBus1FaultExtract.active = 1;
	} else {
		ECAM_controller.warningReset(dcBus1Fault);
		ECAM_controller.warningReset(dcBus1FaultBlower);
		ECAM_controller.warningReset(dcBus1FaultExtract);
	}
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and systems.ELEC.Bus.dc1.getValue() >= 25 and systems.ELEC.Bus.dc2.getValue() <= 25 and phaseVar != 4 and phaseVar != 8 and dcBus2Fault.clearFlag == 0) {
		dcBus2Fault.active = 1;
		dcBus2FaultAirData.active = 1;
		dcBus2FaultBaro.active = 1;
	} else {
		ECAM_controller.warningReset(dcBus2Fault);
		ECAM_controller.warningReset(dcBus2FaultAirData);
		ECAM_controller.warningReset(dcBus2FaultBaro);
	}
	
	if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config") and !dcEmerconfig.active and systems.ELEC.Bus.dcBat.getValue() < 25 and phaseVar != 4 and phaseVar != 5 and phaseVar != 7 and phaseVar != 8 and dcBusBatFault.clearFlag == 0) {
		dcBusBatFault.active = 1;
	} else {
		ECAM_controller.warningReset(dcBusBatFault);
	}
	
	if (!(getprop("systems/electrical/some-electric-thingie/emer-elec-config") and !getprop("systems/electrical/relay/emer-glc/contact-pos")) and systems.ELEC.Bus.dcEssShed.getValue() < 25 and systems.ELEC.Bus.dcEss.getValue() >= 25 and phaseVar != 4 and phaseVar != 8 and dcBusEssShed.clearFlag == 0) {
		dcBusEssShed.active = 1;
		dcBusEssShedExtract.active = 1;
		dcBusEssShedIcing.active = 1;
	} else {
		ECAM_controller.warningReset(dcBusEssShed);
		ECAM_controller.warningReset(dcBusEssShedExtract);
		ECAM_controller.warningReset(dcBusEssShedIcing);
	}
	
	if (!(getprop("systems/electrical/some-electric-thingie/emer-elec-config") and !getprop("systems/electrical/relay/emer-glc/contact-pos")) and systems.ELEC.Bus.acEssShed.getValue() < 110 and systems.ELEC.Bus.acEss.getValue() >= 110 and phaseVar != 4 and phaseVar != 8 and acBusEssShed.clearFlag == 0) {
		acBusEssShed.active = 1;
		if (!getprop("systems/electrical/some-electric-thingie/emer-elec-config")) {
			acBusEssShedAtc.active = 1;
		} else {
			ECAM_controller.warningReset(acBusEssShed);
		}
	} else {
		ECAM_controller.warningReset(acBusEssShed);
		ECAM_controller.warningReset(acBusEssShedAtc);
	}
	
	if ((athr_offw.clearFlag == 0) and athrWarn.getValue() == 2 and phaseVar != 4 and phaseVar != 8 and phaseVar != 10) {
		athr_offw.active = 1;
		athr_offw_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_offw);
		ECAM_controller.warningReset(athr_offw_1);
	}
	
	if ((athr_lock.clearFlag == 0) and phaseVar >= 5 and phaseVar <= 7 and getprop("systems/thrust/thr-locked-alert") == 1) {
		if (getprop("systems/thrust/thr-locked-flash") == 0) {
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
	
	
	if ((athr_lim.clearFlag == 0) and getprop("it-autoflight/output/athr") == 1 and ((getprop("systems/thrust/eng-out") != 1 and (getprop("systems/thrust/state1") == "MAN" or getprop("systems/thrust/state2") == "MAN")) or (getprop("systems/thrust/eng-out") == 1 and (getprop("systems/thrust/state1") == "MAN" or getprop("systems/thrust/state2") == "MAN" or (getprop("systems/thrust/state1") == "MAN THR" and getprop("controls/engines/engine[0]/throttle-pos") <= 0.83) or (getprop("systems/thrust/state2") == "MAN THR" and getprop("controls/engines/engine[0]/throttle-pos") <= 0.83)))) and (phaseVar >= 5 and phaseVar <= 7)) {
		athr_lim.active = 1;
		athr_lim_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_lim);
		ECAM_controller.warningReset(athr_lim_1);
	}
	
	
	if (getprop("instrumentation/tcas/serviceable") == 0 and phaseVar != 3 and phaseVar != 4 and phaseVar != 7 and systems.ELEC.Bus.ac1.getValue() and pts.Instrumentation.TCAS.Inputs.mode.getValue() != 1 and tcasFault.clearFlag == 0) {
		tcasFault.active = 1;
	} else {
		ECAM_controller.warningReset(tcasFault);
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
	if (apuEmerShutdown.clearFlag == 0 and systems.apuEmerShutdown.getBoolValue() and !getprop("systems/fire/apu/warning-active") and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		apuEmerShutdown.active = 1;
	} elsif (apuEmerShutdown.clearFlag == 1) {
		ECAM_controller.warningReset(apuEmerShutdown);
		apuEmerShutdown.isMainMsg = 1;
	}
	
	if (apuEmerShutdownMast.clearFlag == 0 and getprop("controls/apu/master") and apuEmerShutdown.active == 1) {
		apuEmerShutdownMast.active = 1;
	} else {
		ECAM_controller.warningReset(apuEmerShutdownMast);
		apuEmerShutdown.isMainMsg = 0;
	}
	
	if (eng1FireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[0].condition == 0 or (systems.engFireDetectorUnits.vector[0].loopOne == 9 and systems.engFireDetectorUnits.vector[0].loopTwo == 9 and systems.eng1Inop.getBoolValue())) and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		eng1FireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1FireDetFault);
	}
	
	if (eng1LoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[0].loopOne == 9 and systems.engFireDetectorUnits.vector[0].loopTwo != 9 and !systems.eng1Inop.getBoolValue() and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		eng1LoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1LoopAFault);
	}
	
	if (eng1LoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[0].loopOne != 9 and systems.engFireDetectorUnits.vector[0].loopTwo == 9 and !systems.eng1Inop.getBoolValue() and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		eng1LoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1LoopBFault);
	}
	
	if (eng2FireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[1].condition == 0 or (systems.engFireDetectorUnits.vector[1].loopOne == 9 and systems.engFireDetectorUnits.vector[1].loopTwo == 9 and systems.eng2Inop.getBoolValue())) and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		eng2FireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2FireDetFault);
	}
	
	if (eng2LoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[1].loopOne == 9 and systems.engFireDetectorUnits.vector[1].loopTwo != 9 and !systems.eng2Inop.getBoolValue() and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		eng2LoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2LoopAFault);
	}
	
	if (eng2LoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[1].loopOne != 9 and systems.engFireDetectorUnits.vector[1].loopTwo == 9 and !systems.eng2Inop.getBoolValue() and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		eng2LoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2LoopBFault);
	}
	
	if (apuFireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[2].condition == 0 or (systems.engFireDetectorUnits.vector[2].loopOne == 9 and systems.engFireDetectorUnits.vector[2].loopTwo == 9 and systems.apuInop.getBoolValue())) and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		apuFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuFireDetFault);
	}
	
	if (apuLoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[2].loopOne == 9 and systems.engFireDetectorUnits.vector[2].loopTwo != 9 and !systems.apuInop.getBoolValue() and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		apuLoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuLoopAFault);
	}
	
	if (apuLoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[2].loopOne != 9 and systems.engFireDetectorUnits.vector[2].loopTwo == 9 and !systems.apuInop.getBoolValue() and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		apuLoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuLoopBFault);
	}
	
	if (crgAftFireDetFault.clearFlag == 0 and (systems.cargoSmokeDetectorUnits.vector[0].condition == 0 or systems.cargoSmokeDetectorUnits.vector[1].condition == 0) and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		crgAftFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(crgAftFireDetFault);
	}
	
	if (crgFwdFireDetFault.clearFlag == 0 and systems.cargoSmokeDetectorUnits.vector[2].condition == 0 and (phaseVar == 6 or phaseVar >= 9 or phaseVar <= 2)) {
		crgFwdFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(crgFwdFireDetFault);
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
	phaseVar = phaseNode.getValue();
	if (getprop("controls/flight/flap-lever") == 0 or getprop("controls/flight/flap-lever") == 4 or getprop("controls/flight/speedbrake") != 0 or getprop("fdm/jsbsim/hydraulics/elevator-trim/final-deg") > 1.75 or getprop("fdm/jsbsim/hydraulics/elevator-trim/final-deg") < -3.65 or getprop("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") < -3.55 or getprop("fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") > 3.55) {
		setprop("ECAM/to-config-normal", 0);
	} else {
		setprop("ECAM/to-config-normal", 1);
	}
	
	if (getprop("ECAM/to-config-test") and (phaseVar == 2 or phaseVar == 9)) {
		setprop("ECAM/to-config-set", 1);
	} else {
		setprop("ECAM/to-config-set", 0);
	}
	
	if (!getprop("ECAM/to-config-normal") or phaseVar == 6) {
		setprop("ECAM/to-config-reset", 1);
	} else {
		setprop("ECAM/to-config-reset", 0);
	}
	
	if (getprop("controls/autobrake/mode") == 3) {
		toMemoLine1.msg = "T.O AUTO BRK MAX";
		toMemoLine1.colour = "g";
	} else {
		toMemoLine1.msg = "T.O AUTO BRK.....MAX";
		toMemoLine1.colour = "c";
	}
	
	if (getprop("controls/switches/seatbelt-sign") and getprop("controls/switches/no-smoking-sign")) {
		toMemoLine2.msg = "    SIGNS ON";
		toMemoLine2.colour = "g";
	} else {
		toMemoLine2.msg = "    SIGNS.........ON";
		toMemoLine2.colour = "c";
	}
	
	if (getprop("controls/flight/speedbrake-arm")) {
		toMemoLine3.msg = "    SPLRS ARM";
		toMemoLine3.colour = "g";
	} else {
		toMemoLine3.msg = "    SPLRS........ARM";
		toMemoLine3.colour = "c";
	}
	
	if (getprop("controls/flight/flap-pos") > 0 and getprop("controls/flight/flap-pos") < 5) {
		toMemoLine4.msg = "    FLAPS T.O";
		toMemoLine4.colour = "g";
	} else {
		toMemoLine4.msg = "    FLAPS........T.O";
		toMemoLine4.colour = "c";
	}
	
	if (getprop("ECAM/to-config-flipflop") and getprop("ECAM/to-config-normal")) {
		toMemoLine5.msg = "    T.O CONFIG NORMAL";
		toMemoLine5.colour = "g";
	} else {
		toMemoLine5.msg = "    T.O CONFIG..TEST";
		toMemoLine5.colour = "c";
	}
	
	if (getprop("ECAM/to-config-test") and (phaseVar == 2 or phaseVar == 9)) {
		setprop("ECAM/to-memo-set", 1);
	} else {
		setprop("ECAM/to-memo-set", 0);
	}
	
	if (phaseVar == 1 or phaseVar == 3 or phaseVar == 6 or phaseVar == 10) {
		setprop("ECAM/to-memo-reset", 1);
	} else {
		setprop("ECAM/to-memo-reset", 0);
	}
	
	if ((phaseVar == 2 and getprop("ECAM/engine-start-time") != 0 and getprop("ECAM/engine-start-time") + 120 < getprop("sim/time/elapsed-sec")) or getprop("ECAM/to-memo-flipflop")) {
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
	
	if (getprop("fdm/jsbsim/gear/gear-pos-norm") == 1) {
		ldgMemoLine1.msg = "LDG LDG GEAR DN";
		ldgMemoLine1.colour = "g";
	} else {
		ldgMemoLine1.msg = "LDG LDG GEAR......DN";
		ldgMemoLine1.colour = "c";
	}
	
	if (getprop("controls/switches/seatbelt-sign") and getprop("controls/switches/no-smoking-sign")) {
		ldgMemoLine2.msg = "    SIGNS ON";
		ldgMemoLine2.colour = "g";
	} else {
		ldgMemoLine2.msg = "    SIGNS.........ON";
		ldgMemoLine2.colour = "c";
	}
	
	if (getprop("controls/flight/speedbrake-arm")) {
		ldgMemoLine3.msg = "    SPLRS ARM";
		ldgMemoLine3.colour = "g";
	} else {
		ldgMemoLine3.msg = "    SPLRS........ARM";
		ldgMemoLine3.colour = "c";
	}
	
	if (getprop("it-fbw/law") == 1 or getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override")) {
		if (getprop("controls/flight/flap-pos") == 4) {
			ldgMemoLine4.msg = "    FLAPS CONF 3";
			ldgMemoLine4.colour = "g";
		} else {
			ldgMemoLine4.msg = "    FLAPS.....CONF 3";
			ldgMemoLine4.colour = "c";
		}
	} else {
		if (getprop("controls/flight/flap-pos") == 5) {
			ldgMemoLine4.msg = "    FLAPS FULL";
			ldgMemoLine4.colour = "g";
		} else {
			ldgMemoLine4.msg = "    FLAPS.......FULL";
			ldgMemoLine4.colour = "c";
		}
	}
	
	gear_agl_cur = pts.Position.gearAglFt.getValue();
	if (gear_agl_cur < 2000) {
		setprop("ECAM/ldg-memo-set", 1);
	} else {
		setprop("ECAM/ldg-memo-set", 0);
	}
	
	if (gear_agl_cur > 2200) {
		setprop("ECAM/ldg-memo-reset", 1);
	} else {
		setprop("ECAM/ldg-memo-reset", 0);
	}
	
	if (gear_agl_cur > 2200) {
		setprop("ECAM/ldg-memo-2200-set", 1);
	} else {
		setprop("ECAM/ldg-memo-2200-set", 0);
	}
	
	if (phaseVar != 6 and phaseVar != 7 and phaseVar != 8) {
		setprop("ECAM/ldg-memo-2200-reset", 1);
	} else {
		setprop("ECAM/ldg-memo-2200-reset", 0);
	}
	
	if ((phaseVar == 6 and getprop("ECAM/ldg-memo-flipflop") and getprop("ECAM/ldg-memo-2200-flipflop")) or phaseVar == 7 or phaseVar == 8) {
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
	phaseVar = phaseNode.getValue();
	if (getprop("services/fuel-truck/enable") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		refuelg.active = 1;
	} else {
		refuelg.active = 0;
	}
	
	if ((phaseVar == 1 or phaseVar == 2) and toMemoLine1.active != 1 and ldgMemoLine1.active != 1 and (systems.ADIRSnew.ADIRunits[0].inAlign == 1 or systems.ADIRSnew.ADIRunits[1].inAlign == 1 or systems.ADIRSnew.ADIRunits[2].inAlign == 1)) {
		irs_in_align.active = 1;
		if (getprop("ECAM/phases/timer/eng1or2-output")) {
			irs_in_align.colour = "a";
		} else {
			irs_in_align.colour = "g";
		}
		
		timeNow = pts.Sim.Time.elapsedSec.getValue();
		numberMinutes = math.round(math.max(systems.ADIRSnew.ADIRunits[0]._alignTime - timeNow, systems.ADIRSnew.ADIRunits[1]._alignTime - timeNow, systems.ADIRSnew.ADIRunits[2]._alignTime - timeNow) / 60);
		
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
	
	if (getprop("controls/flight/speedbrake-arm") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		gnd_splrs.active = 1;
	} else {
		gnd_splrs.active = 0;
	}
	
	if (getprop("controls/lighting/seatbelt-sign") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		seatbelts.active = 1;
	} else {
		seatbelts.active = 0;
	}
	
	if (getprop("controls/lighting/no-smoking-sign") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) { # should go off after takeoff assuming switch is in auto due to old logic from the days when smoking was allowed!
		nosmoke.active = 1;
	} else {
		nosmoke.active = 0;
	}

	if (getprop("controls/lighting/strobe") == 0 and getprop("gear/gear[1]/wow") == 0 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) { # todo: use gear branch properties
		strobe_lt_off.active = 1;
	} else {
		strobe_lt_off.active = 0;
	}
	
	if (systems.FUEL.Valves.transfer1.getValue() == 1 or systems.FUEL.Valves.transfer2.getValue() == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		outr_tk_fuel_xfrd.active = 1;
	} else {
		outr_tk_fuel_xfrd.active = 0;
	}

	if (getprop("consumables/fuel/total-fuel-lbs") < 6000 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) { # assuming US short ton 2000lb
		fob_3T.active = 1;
	} else {
		fob_3T.active = 0;
	}
	
	if (getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override") == 1 and toMemoLine1.active != 1 and ldgMemoLine1.active != 1) {
		gpws_flap_mode_off.active = 1;
	} else {
		gpws_flap_mode_off.active = 0;
	}
	
}

var messages_right_memo = func {
	phaseVar = phaseNode.getValue();
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
	
	if ((getprop("gear/gear[1]/wow") == 0) and (getprop("systems/electrical/some-electric-thingie/emer-elec-config") or getprop("systems/fire/engine1/warning-active") == 1 or getprop("systems/fire/engine2/warning-active") == 1 or getprop("systems/fire/apu/warning-active") == 1 or getprop("systems/failures/cargo-aft-fire") == 1 or getprop("systems/failures/cargo-fwd-fire") == 1) or (((getprop("systems/hydraulic/green-psi") < 1500 and getprop("engines/engine[0]/state") == 3) and (getprop("systems/hydraulic/yellow-psi") < 1500 and getprop("engines/engine[1]/state") == 3)) or ((getprop("systems/hydraulic/green-psi") < 1500 or getprop("systems/hydraulic/yellow-psi") < 1500) and getprop("engines/engine[0]/state") == 3 and getprop("engines/engine[1]/state") == 3) and phaseVar >= 3 and phaseVar <= 8)) {
		# todo: emer elec
		land_asap_r.active = 1;
	} else {
		land_asap_r.active = 0;
	}
	
	if (land_asap_r.active == 0 and getprop("gear/gear[1]/wow") == 0 and ((getprop("fdm/jsbsim/propulsion/tank[0]/contents-lbs") < 1650 and getprop("fdm/jsbsim/propulsion/tank[1]/contents-lbs") < 1650) or ((getprop("systems/electrical/bus/dc-2") < 25 and (getprop("systems/failures/elac1") == 1 or getprop("systems/failures/sec1") == 1)) or (getprop("systems/hydraulic/green-psi") < 1500 and (getprop("systems/failures/elac1") == 1 and getprop("systems/failures/sec1") == 1)) or (getprop("systems/hydraulic/yellow-psi") < 1500 and (getprop("systems/failures/elac1") == 1 and getprop("systems/failures/sec1") == 1)) or (getprop("systems/hydraulic/blue-psi") < 1500 and (getprop("systems/failures/elac2") == 1 and getprop("systems/failures/sec2") == 1))) or (phaseVar >= 3 and phaseVar <= 8 and (getprop("engines/engine[0]/state") != 3 or getprop("engines/engine[1]/state") != 3)))) {
		land_asap_a.active = 1;
	} else {
		land_asap_a.active = 0;
	}
	
	if (libraries.ap_active == 1 and apWarn.getValue() == 1) {
		ap_off.active = 1;
	} else {
		ap_off.active = 0;
	}
	
	if (libraries.athr_active == 1 and athrWarn.getValue() == 1) {
		athr_off.active = 1;
	} else {
		athr_off.active = 0;
	}
	
	if ((phaseVar >= 2 and phaseVar <= 7) and getprop("controls/flight/speedbrake") != 0) {
		spd_brk.active = 1;
	} else {
		spd_brk.active = 0;
	}
	
	if (getprop("systems/thrust/state1") == "IDLE" and getprop("systems/thrust/state2") == "IDLE" and phaseVar >= 6 and phaseVar <= 7) {
		spd_brk.colour = "g";
	} else if ((phaseVar >= 2 and phaseVar <= 5) or ((getprop("systems/thrust/state1") != "IDLE" or getprop("systems/thrust/state2") != "IDLE") and (phaseVar >= 6 and phaseVar <= 7))) {
		spd_brk.colour = "a";
	}
	
	if (getprop("controls/gear/brake-parking") == 1 and phaseVar != 3) {
		park_brk.active = 1;
	} else {
		park_brk.active = 0;
	}
	if (phaseVar >= 4 and phaseVar <= 8) {
		park_brk.colour = "a";
	} else {
		park_brk.colour = "g";
	}
	
	if (getprop("controls/gear/brake-fans") == 1) {
		brk_fan.active = 1;
	} else {
		brk_fan.active = 0;
	}
	
	if (getprop("controls/hydraulic/ptu") == 1 and ((getprop("systems/hydraulic/yellow-psi") < 1450 and getprop("systems/hydraulic/green-psi") > 1450 and getprop("controls/hydraulic/elec-pump-yellow") == 0) or (getprop("systems/hydraulic/yellow-psi") > 1450 and getprop("systems/hydraulic/green-psi") < 1450))) {
		ptu.active = 1;
	} else {
		ptu.active = 0;
	}
	
	if (getprop("systems/hydraulic/sources/rat/position") != 0) {
		rat.active = 1;
	} else {
		rat.active = 0;
	}
	
	if (phaseVar >= 1 and phaseVar <= 2) {
		rat.colour = "a";
	} else {
		rat.colour = "g";
	}
	
	if (getprop("systems/electrical/relay/emer-glc/contact-pos") == 1 and getprop("systems/hydraulic/sources/rat/position") != 0 and getprop("gear/gear[1]/wow") == 0) {
		emer_gen.active = 1;
	} else {
		emer_gen.active = 0;
	}
	
	if (getprop("sim/model/autopush/enabled") == 1) { # this message is only on when towing - not when disc with switch
		nw_strg_disc.active = 1;
	} else {
		nw_strg_disc.active = 0;
	}
	
	if (getprop("engines/engine[0]/state") == 3 or getprop("engines/engine[1]/state") == 3) {
		nw_strg_disc.colour = "a";
	} else {
		nw_strg_disc.colour = "g";
	}
	
	if (getprop("controls/pneumatic/switches/ram-air") == 1) {
		ram_air.active = 1;
	} else {
		ram_air.active = 0;
	}

	if (getprop("controls/engines/engine[0]/igniter-a") == 1 or getprop("controls/engines/engine[0]/igniter-b") == 1 or getprop("controls/engines/engine[1]/igniter-a") == 1 or getprop("controls/engines/engine[1]/igniter-b") == 1) {
		ignition.active = 1;
	} else {
		ignition.active = 0;
	}
	
	if (getprop("controls/pneumatic/switches/bleedapu") == 1 and getprop("systems/apu/rpm") >= 95) {
		apu_bleed.active = 1;
	} else {
		apu_bleed.active = 0;
	}

	if (apu_bleed.active == 0 and getprop("systems/apu/rpm") >= 95) {
		apu_avail.active = 1;
	} else {
		apu_avail.active = 0;
	}

	if (getprop("controls/lighting/landing-lights[1]") > 0 or getprop("controls/lighting/landing-lights[2]") > 0) {
		ldg_lt.active = 1;
	} else {
		ldg_lt.active = 0;
	}

	if (getprop("controls/switches/leng") == 1 or getprop("controls/switches/reng") == 1 or getprop("systems/electrical/bus/dc-1") == 0 or getprop("systems/electrical/bus/dc-2") == 0) {
		eng_aice.active = 1;
	} else {
		eng_aice.active = 0;
	}
	
	if (getprop("controls/switches/wing") == 1) {
		wing_aice.active = 1;
	} else {
		wing_aice.active = 0;
	}
	
	if (getprop("instrumentation/comm[2]/frequencies/selected-mhz") != 0 and (phaseVar == 1 or phaseVar == 2 or phaseVar == 6 or phaseVar == 9 or phaseVar == 10)) {
		vhf3_voice.active = 1;
	} else {
		vhf3_voice.active = 0;
	}
	if (getprop("controls/autobrake/mode") == 1 and (phaseVar == 7 or phaseVar == 8)) {
		auto_brk_lo.active = 1;
	} else {
		auto_brk_lo.active = 0;
	}

	if (getprop("controls/autobrake/mode") == 2 and (phaseVar == 7 or phaseVar == 8)) {
		auto_brk_med.active = 1;
	} else {
		auto_brk_med.active = 0;
	}

	if (getprop("controls/autobrake/mode") == 3 and (phaseVar == 7 or phaseVar == 8)) {
		auto_brk_max.active = 1;
	} else {
		auto_brk_max.active = 0;
	}
	
	if (getprop("systems/fuel/valves/crossfeed-valve") != 0 and getprop("controls/fuel/switches/crossfeed") == 1) {
		fuelx.active = 1;
	} else {
		fuelx.active = 0;
	}
	
	if (phaseVar >= 3 and phaseVar <= 5) {
		fuelx.colour = "a";
	} else {
		fuelx.colour = "g";
	}
	
	if (getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override") == 1) { # todo: emer elec
		gpws_flap3.active = 1;
	} else {
		gpws_flap3.active = 0;
	}
	
	if (phaseVar >= 2 and phaseVar <= 9 and systems.ELEC.Bus.ac1.getValue() >= 110 and systems.ELEC.Bus.ac2.getValue() >= 110 and (getprop("systems/fuel/feed-center-1") or getprop("systems/fuel/feed-center-2"))) {
		ctr_tk_feedg.active = 1;
	} else {
		ctr_tk_feedg.active = 0;
	}
}

# Listeners
setlistener("/controls/fctl/switches/fac1", func() {
	if (dualFail.active == 0 and emerconfig.active == 0) { return; }
	
	if (fac1Node.getBoolValue() and dualFail.active == 1) {
		dualFailFACActive = 0;
	} else {
		dualFailFACActive = 1;
	}
	
	if (fac1Node.getBoolValue() and emerconfig.active == 1) {
		emerConfigFACActive = 0;
	} else {
		emerConfigFACActive = 1;
	}
}, 0, 0);

setlistener("/engines/engine[0]/state", func() {
	if ((state1Node.getValue() != 3 and state2Node.getValue() != 3) and wowNode.getValue() == 0) {
		dualFailNode.setBoolValue(1);
	} else {
		dualFailNode.setBoolValue(0);
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if ((state1Node.getValue() != 3 and state2Node.getValue() != 3) and wowNode.getValue() == 0) {
		dualFailNode.setBoolValue(1);
	} else {
		dualFailNode.setBoolValue(0);
	}
}, 0, 0);
