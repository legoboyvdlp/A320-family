# A3XX ADIRS System
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var _NUMADIRU = 3;

var ADR = {
	outputDisc: 0, # 0 = disc, 1 = normal
	mode: 0, # 0 = off, 1 = nav, 2 = att
	energised: 0, # 0 = off, 1 = on
	input: [],
    new: func() {
		var adr = { parents:[ADR] };
		return adr;
    },
	updateEnergized: func(mode) {
		me.energized = mode != 0 ? 1 : 0;
	},
};

var IR = {
	outputDisc: 0, # 0 = disc, 1 = normal
	mode: 0, # 0 = off, 1 = nav, 2 = att
	energised: 0, # 0 = off, 1 = on
	input: [],
    new: func() {
		var ir = { parents:[IR] };
		return ir;
    },
	updateEnergized: func(mode) {
		me.energized = mode != 0 ? 1 : 0;
	},
};

var ADIRSControlPanel = {
	# local vars
	_adrSwitchState: 0,
	_irSwitchState: 0,
	_irModeSwitchState: 0,
	
	# ADIRS Units
	ADRunits: [nil, nil, nil],
	IRunits: [nil, nil, nil],
	
	# PTS
	Switches: {
		adrSw: [props.globals.getNode("/controls/navigation/adirscp/switches/adr-1"), props.globals.getNode("/controls/navigation/adirscp/switches/adr-2"), props.globals.getNode("/controls/navigation/adirscp/switches/adr-3")],
		irModeSw: [props.globals.getNode("/controls/navigation/adirscp/switches/ir-1-mode"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-2-mode"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-3-mode")],
		irSw: [props.globals.getNode("/controls/navigation/adirscp/switches/ir-1"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-2"), props.globals.getNode("/controls/navigation/adirscp/switches/ir-3")],
	},
	Lights: {
		adrFault: [props.globals.getNode("/controls/navigation/adirscp/lights/adr-1-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-2-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-3-fault")],
		adrOff: [props.globals.getNode("/controls/navigation/adirscp/lights/adr-1-off"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-2-off"), props.globals.getNode("/controls/navigation/adirscp/lights/adr-3-off")],
		irFault: [props.globals.getNode("/controls/navigation/adirscp/lights/ir-1-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-2-fault"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-3-fault")],
		irOff: [props.globals.getNode("/controls/navigation/adirscp/lights/ir-1-off"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-2-off"), props.globals.getNode("/controls/navigation/adirscp/lights/ir-3-off")],
		onBat: props.globals.getNode("/controls/navigation/adirscp/lights/on-bat"),
	},
	
	# Methods
	adrSw: func(n) { 
		if (n < 0 or n > _NUMADIRU) { return; }
		me._adrSwitchState = me.Switches.adrSw[n].getValue();
		print("Switching adr unit " ~ n ~ " to " ~ !me._adrSwitchState);
		me.Switches.adrSw[n].setValue(!me._adrSwitchState);
		if (me.ADRunits[n] != nil) { 
			me.ADRunits[n].outputDisc = !me._adrSwitchState;
		}
	},
	adrSw: func(n) { 
		if (n < 0 or n > _NUMADIRU) { return; }
		me._irSwitchState = me.Switches.irSw[n].getValue();
		print("Switching ir unit " ~ n ~ " to " ~ !me._irSwitchState);
		me.Switches.irSw[n].setValue(!me._irSwitchState);
		if (me.IRunits[n] != nil) { 
			me.IRunits[n].outputDisc = !me._irSwitchState;
		}
	},
	irModeSw: func(n, mode) {
		if (mode < 0 or mode > 2) { return; }
		me._irModeSwitchState = me.Switches.irModeSw[n].getValue();
		print("Switching adirs " ~ n ~ " to mode " ~ mode);
		if (me.ADRunits[n] != nil) { 
			me.ADRunits[n].mode = mode;
			me.ADRunits[n].updateEnergized(mode);
		}
		if (me.IRunits[n] != nil) { 
			me.IRunits[n].mode = mode;
			me.IRunits[n].updateEnergized(mode);
		}
	}
};

var SwitchingPanel = {
	Switches: {
		attHdg: props.globals.getNode("/controls/navigation/switching/att-hdg"),
		airData: props.globals.getNode("/controls/navigation/switching/air-data"),
	},
};


var ADIRSnew = {
	_flapPos: nil,
	_slatPos: nil,
	overspeedVFE: props.globals.initNode("/systems/navigation/adr/computation/overspeed-vfe-spd", 0, "INT"),
	init: func() {
		for (i = 0; i < _NUMADIRU; i = i + 1) {
			print("Creating new ADR unit " ~ i);
			ADIRSControlPanel.ADRunits[i] = ADR.new();
		}
	}, 
	update_items: [
		props.UpdateManager.FromPropertyHashList(["/fdm/jsbsim/fcs/flap-pos-deg","/fdm/jsbsim/fcs/slat-pos-deg"], 0.1, func(notification)
			{
				me._flapPos = pts.JSBSIM.FCS.flapDeg.getValue();
				me._slatPos = pts.JSBSIM.FCS.slatDeg.getValue();
				
				if (me._flapPos >= 23 and me._slatPos >= 25) {
					ADIRSnew.overspeedVFE.setValue(181);
				} elsif (me._flapPos >= 18) {
					ADIRSnew.overspeedVFE.setValue(189);
				} elsif (me._flapPos >= 13 or me._slatPos > 20) {
					ADIRSnew.overspeedVFE.setValue(204);
				} elsif (me._slatPos <= 20 and me._flapPos > 2) {
					ADIRSnew.overspeedVFE.setValue(219);
				} elsif (me._slatPos >= 2 and me._slatPos <= 20) {
					ADIRSnew.overspeedVFE.setValue(234);
				} else {
					ADIRSnew.overspeedVFE.setValue(1024);
				}
			}
		),
	],
	loop: func() {
		notification = nil;
		foreach (var update_item; me.update_items) {
			update_item.update(notification);
		}
	},
};
