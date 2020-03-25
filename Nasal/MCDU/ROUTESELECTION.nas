# Copyright (c) 2020 Matthew Maring (hayden2000)

var initInputROUTESEL = func(key, i) {
	if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "INITA");
	}
}
