# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)

# Copyright (c) 2022 Josh Davidson (Octal450)

var statusInput = func(key, i) {
	if (key == "L3") {
		fmgc.switchDatabase();
	} elsif (key == "R5") {
		if (fmgc.WaypointDatabase.confirm[i]) {
			fmgc.WaypointDatabase.delete(i);
			fmgc.WaypointDatabase.confirm[i] = 0;
		} else {
			fmgc.WaypointDatabase.confirm[i] = 1;
		}
	}
}
