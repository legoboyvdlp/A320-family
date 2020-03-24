# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (hayden2000)

# Copyright (c) 2019 Joshua Davidson (Octal450)

var perfDESInput = func(key, i) {
	if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "CRZ");
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "APPR");
	}
}
