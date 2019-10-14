# A3XX mCDU by Joshua Davidson (Octal450) and Jonathan Redpath

# Copyright (c) 2019 Joshua Davidson (Octal450)

var perfCRZInput = func(key, i) {
	if (key == "L6") {
		setprop("/MCDU[" ~ i ~ "]/page", "CLB");
	}
	if (key == "R6") {
		setprop("/MCDU[" ~ i ~ "]/page", "DES");
	}
}
