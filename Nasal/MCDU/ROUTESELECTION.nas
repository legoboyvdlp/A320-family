# Copyright (c) 2020 Matthew Maring (mattmaring)
# enhanced inuyaksa*2021

var initInputROUTESEL = func(key, i) {
	if (key == "L6") {
		setprop("MCDU[" ~ i ~ "]/page", "INITA");
	}
}

var RouteSelManager = {

	leglist: nil,

	loadFlightplan: func(path) {
		if (right(path,4) == ".xml") { # plan from SimBrief?
			if (SimBrief.isValid(path)) {
				leglist = SimBrief.readLegs(path);
			}
		}
	}

}