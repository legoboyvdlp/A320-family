# Copyright (c) 2020 Matthew Maring (hayden2000)

var perfAPPRInput = func(key, i) {
	if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "DES");
	} else if (key == "R6") {
		setprop("MCDU[" ~ i ~ "]/page", "GA");
	}
}