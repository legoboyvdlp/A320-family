# A3XX Switching Panel
# Jonathan Redpath (legoboyvdlp)

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

var SwitchingPanel = {
	Switches: {
		attHdg: props.globals.getNode("/controls/navigation/switching/att-hdg"),
		airData: props.globals.getNode("/controls/navigation/switching/air-data"),
		eisDmc: props.globals.getNode("/controls/navigation/switching/eis-dmc"),
	},
	
	doAirData: func(newAirData) {
		if (newAirData < -1 or newAirData > 1) { return; }
		me.Switches.airData.setValue(newAirData);
		atc.transponderPanel.updateAirData();
		if (newAirData == -1) {
			dmc.DMController.DMCs[0].changeActiveADIRS(2);
			dmc.DMController.DMCs[1].changeActiveADIRS(1);
		} elsif (newAirData == 1) {
			dmc.DMController.DMCs[0].changeActiveADIRS(0);
			dmc.DMController.DMCs[1].changeActiveADIRS(2);
		} elsif (newAirData == 0) {
			dmc.DMController.DMCs[0].changeActiveADIRS(0);
			dmc.DMController.DMCs[1].changeActiveADIRS(1);
		}
	},
	doEisDMC: func(newDMC) {
		if (newDMC < -1 or newDMC > 1) { return; }
		me.Switches.eisDMC.setValue(newDMC);
	},
};