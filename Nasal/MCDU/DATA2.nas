# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Matthew Maring (mattmaring)

var data2Input = func(key, i) {
	if (key == "L5") {
		if (canvas_mcdu.myCLBWIND[i] == nil) {
			canvas_mcdu.myCLBWIND[i] = windCLBPage.new(i);
		} else {
			canvas_mcdu.myCLBWIND[i].reload();
		}
		fmgc.windController.accessPage[i] = "DATA2";
		setprop("MCDU[" ~ i ~ "]/page", "WINDCLB");
	}
}
