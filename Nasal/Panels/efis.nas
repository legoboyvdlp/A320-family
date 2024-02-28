# A3XX EFIS Controller
# Copyright (c) 2024 Josh Davidson (Octal450)

var mode = "NAV";
var rng = 20;

setlistener("/sim/signals/fdm-initialized", func {
	pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(2);
	pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(2);
	pts.Instrumentation.Efis.Nd.displayMode[0].setValue("NAV");
	pts.Instrumentation.Efis.Nd.displayMode[1].setValue("NAV");
});

var setCptND = func(d) {
	mode = pts.Instrumentation.Efis.Nd.displayMode[0].getValue();
	if (d == 1) {
		if (mode == "ILS") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("VOR");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(1);
		} else if (mode == "VOR") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("NAV");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(2);
		} else if (mode == "NAV") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("ARC");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(3);
		} else if (mode == "ARC") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("PLAN");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(4);
		}
	} else if (d == -1) {
		if (mode == "PLAN") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("ARC");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(3);
		} else if (mode == "ARC") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("NAV");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(2);
		} else if (mode == "NAV") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("VOR");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(1);
		} else if (mode == "VOR") {
			pts.Instrumentation.Efis.Nd.displayMode[0].setValue("ILS");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[0].setValue(0);
		}
	}
}

var setFoND = func(d) {
	mode = pts.Instrumentation.Efis.Nd.displayMode[1].getValue();
	if (d == 1) {
		if (mode == "ILS") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("VOR");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(1);
		} else if (mode == "VOR") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("NAV");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(2);
		} else if (mode == "NAV") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("ARC");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(3);
		} else if (mode == "ARC") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("PLAN");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(4);
		}
	} else if (d == -1) {
		if (mode == "PLAN") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("ARC");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(3);
		} else if (mode == "ARC") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("NAV");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(2);
		} else if (mode == "NAV") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("VOR");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(1);
		} else if (mode == "VOR") {
			pts.Instrumentation.Efis.Nd.displayMode[1].setValue("ILS");
			pts.Instrumentation.Efis.Mfd.pnlModeNum[1].setValue(0);
		}
	}
}

var setNDRange = func(n, d) {
	rng = pts.Instrumentation.Efis.Inputs.rangeNm[n].getValue();
	if (d == 1) {
		rng = rng * 2;
		if (rng > 320) {
			rng = 320;
		}
	} else if (d == -1){
		rng = rng / 2;
		if (rng < 10) {
			rng = 10;
		}
	}
	pts.Instrumentation.Efis.Inputs.rangeNm[n].setValue(rng);
}

var cpt_efis_btns = func(i) {
	if (i == "cstr") {
		setEfisOptions(0, 0, 1, 0, 0, 0, 0);
	} else if (i == "wpt") {
		setEfisOptions(0, 0, 0, 0, 0, 0, 1);
	} else if (i == "vord") {
		setEfisOptions(0, 0, 0, 1, 0, 1, 0);
	} else if (i == "ndb") {
		setEfisOptions(0, 0, 0, 0, 1, 0, 0);
	} else if (i == "arpt") {
		setEfisOptions(0, 1, 0, 0, 0, 0, 0);
	} else if (i == "off") {
		setEfisOptions(0, 0, 0, 0, 0, 0, 0);
	}
}

var fo_efis_btns = func(i) {
	if (i == "cstr") {
		setEfisOptions(1, 0, 1, 0, 0, 0, 0);
	} else if (i == "wpt") {
		setEfisOptions(1, 0, 0, 0, 0, 0, 1);
	} else if (i == "vord") {
		setEfisOptions(1, 0, 0, 1, 0, 1, 0);
	} else if (i == "ndb") {
		setEfisOptions(1, 0, 0, 0, 1, 0, 0);
	} else if (i == "arpt") {
		setEfisOptions(1, 1, 0, 0, 0, 0, 0);
	} else if (i == "off") {
		setEfisOptions(1, 0, 0, 0, 0, 0, 0);
	}
}

var setEfisOptions = func(n, a, b, c, d, e, f) {
	pts.Instrumentation.Efis.Inputs.arpt[n].setBoolValue(a);
	pts.Instrumentation.Efis.Inputs.cstr[n].setBoolValue(b);
	pts.Instrumentation.Efis.Inputs.dme[n].setBoolValue(c);
	pts.Instrumentation.Efis.Inputs.ndb[n].setBoolValue(d);
	pts.Instrumentation.Efis.Inputs.vord[n].setBoolValue(e);
	pts.Instrumentation.Efis.Inputs.wpt[n].setBoolValue(f);
};
