# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2020 Josh Davidson (Octal450)

var dataInput = func(key, i) {
	if (key == "L1") {
		setprop("MCDU[" ~ i ~ "]/page", "POSMON");
	} elsif (key == "L2") {
		setprop("MCDU[" ~ i ~ "]/page", "IRSMON");
	} elsif (key == "L3") {
		setprop("MCDU[" ~ i ~ "]/page", "GPSMON");
	} elsif (key == "L5") {
		if (canvas_mcdu.myClosestAirport[i] != nil) {
					canvas_mcdu.myClosestAirport[i].del();
		}
		canvas_mcdu.myClosestAirport[i] = nil;
		canvas_mcdu.myClosestAirport[i] = closestAirportPage.new(i);
		setprop("MCDU[" ~ i ~ "]/page", "CLOSESTAIRPORT");
	} elsif (key == "R5") {
		setprop("MCDU[" ~ i ~ "]/page", "PRINTFUNC");
	}
}

var printInput = func(key, i) {
	if (key == "L1") { 
		setprop("FMGC/print/mcdu/page1/L1auto", 1);
	} elsif (key == "L2") { 
		setprop("FMGC/print/mcdu/page1/L2auto", 1);
	} elsif (key == "L3") { 
		setprop("FMGC/print/mcdu/page1/L3auto", 1);
	} elsif (key == "L5") { 
		setprop("MCDU[" ~ i ~ "]/page", "DATA");
	} elsif (key == "R1") { 
		setprop("FMGC/print/mcdu/page1/R1req", 1);
	} elsif (key == "R2") { 
		setprop("FMGC/print/mcdu/page1/R2req", 1);
	} elsif (key == "R3") { 
		setprop("FMGC/print/mcdu/page1/R3req", 1);
	}
}

var printInput2 = func(key, i) {
	if (key == "L1") { 
		setprop("FMGC/print/mcdu/page2/L1auto", 1);
	} elsif (key == "L2") { 
		setprop("FMGC/print/mcdu/page2/L2auto", 1);
	} elsif (key == "L3") { 
		setprop("FMGC/print/mcdu/page2/L3auto", 1);
	} elsif (key == "L4") { 
		setprop("FMGC/print/mcdu/page2/L4auto", 1);
	} elsif (key == "L6") { 
		setprop("MCDU[" ~ i ~ "]/page", "DATA");
	} elsif (key == "R1") { 
		setprop("FMGC/print/mcdu/page2/R1req", 1);
	} elsif (key == "R2") { 
		setprop("FMGC/print/mcdu/page2/R2req", 1);
	} elsif (key == "R3") { 
		setprop("FMGC/print/mcdu/page2/R3req", 1);
	} elsif (key == "R4") { 
		setprop("FMGC/print/mcdu/page2/R4req", 1);
	}
}
