# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)
# Copyright (c) 2021 Josh Davidson (Octal450)

var radNavScratchpad = nil;
var radNavScratchpadSize = nil;

var radnavInput = func(key, i) {
	radNavScratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	radNavScratchpadSize = size(radNavScratchpad);
	if (!rmp.rmpNav[0].getValue() and !rmp.rmpNav[1].getValue()) {
		if (key == "L1") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.VOR1.freqSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize == 3 or radNavScratchpadSize == 5 or radNavScratchpadSize == 6) {
					if (radNavScratchpad >= 108.00 and radNavScratchpad <= 111.95) {
						if (radNavScratchpad == 108.10 or radNavScratchpad == 108.15 or radNavScratchpad == 108.30 or radNavScratchpad == 108.35 or radNavScratchpad == 108.50 or radNavScratchpad == 108.55 or radNavScratchpad == 108.70 or radNavScratchpad == 108.75 or radNavScratchpad == 108.90 or radNavScratchpad == 108.95 
						or radNavScratchpad == 109.10 or radNavScratchpad == 109.15 or radNavScratchpad == 109.30 or radNavScratchpad == 109.35 or radNavScratchpad == 109.50 or radNavScratchpad == 109.55 or radNavScratchpad == 109.70 or radNavScratchpad == 109.75 or radNavScratchpad == 109.90 or radNavScratchpad == 109.95 
						or radNavScratchpad == 110.10 or radNavScratchpad == 110.15 or radNavScratchpad == 110.30 or radNavScratchpad == 110.35 or radNavScratchpad == 110.50 or radNavScratchpad == 110.55 or radNavScratchpad == 110.70 or radNavScratchpad == 110.75 or radNavScratchpad == 110.90 or radNavScratchpad == 110.95 
						or radNavScratchpad == 111.10 or radNavScratchpad == 111.15 or radNavScratchpad == 111.30 or radNavScratchpad == 111.35 or radNavScratchpad == 111.50 or radNavScratchpad == 111.55 or radNavScratchpad == 111.70 or radNavScratchpad == 111.75 or radNavScratchpad == 111.90 or radNavScratchpad == 111.95) {
							mcdu_message(i, "NOT ALLOWED");
						} else {
							pts.Instrumentation.Nav.Frequencies.selectedMhz[2].setValue(radNavScratchpad);
							fmgc.FMGCInternal.VOR1.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else if (radNavScratchpad >= 112.00 and radNavScratchpad <= 117.95) {
						pts.Instrumentation.Nav.Frequencies.selectedMhz[2].setValue(radNavScratchpad);
						fmgc.FMGCInternal.VOR1.freqSet = 1;
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "L2") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.VOR1.crsSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize >= 1 and radNavScratchpadSize <= 3) {
					if (radNavScratchpad >= 0 and radNavScratchpad <= 360) {
						pts.Instrumentation.Nav.Radials.selectedDeg[2].setValue(radNavScratchpad);
						fmgc.FMGCInternal.VOR1.crsSet = 1;
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "L3") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.ILS.freqSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize == 3 or radNavScratchpadSize == 5 or radNavScratchpadSize == 6) {
					if (radNavScratchpad >= 108.00 and radNavScratchpad <= 111.95) {
						if (radNavScratchpad == 108.10 or radNavScratchpad == 108.15 or radNavScratchpad == 108.30 or radNavScratchpad == 108.35 or radNavScratchpad == 108.50 or radNavScratchpad == 108.55 or radNavScratchpad == 108.70 or radNavScratchpad == 108.75 or radNavScratchpad == 108.90 or radNavScratchpad == 108.95 
						or radNavScratchpad == 109.10 or radNavScratchpad == 109.15 or radNavScratchpad == 109.30 or radNavScratchpad == 109.35 or radNavScratchpad == 109.50 or radNavScratchpad == 109.55 or radNavScratchpad == 109.70 or radNavScratchpad == 109.75 or radNavScratchpad == 109.90 or radNavScratchpad == 109.95 
						or radNavScratchpad == 110.10 or radNavScratchpad == 110.15 or radNavScratchpad == 110.30 or radNavScratchpad == 110.35 or radNavScratchpad == 110.50 or radNavScratchpad == 110.55 or radNavScratchpad == 110.70 or radNavScratchpad == 110.75 or radNavScratchpad == 110.90 or radNavScratchpad == 110.95 
						or radNavScratchpad == 111.10 or radNavScratchpad == 111.15 or radNavScratchpad == 111.30 or radNavScratchpad == 111.35 or radNavScratchpad == 111.50 or radNavScratchpad == 111.55 or radNavScratchpad == 111.70 or radNavScratchpad == 111.75 or radNavScratchpad == 111.90 or radNavScratchpad == 111.95) {
							pts.Instrumentation.Nav.Frequencies.selectedMhz[0].setValue(radNavScratchpad);
							fmgc.FMGCInternal.ILS.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
							if (num(fmgc.FMGCInternal.ILS.freqCalculated) != 0 and num(fmgc.FMGCInternal.ILS.freqCalculated) != num(pts.Instrumentation.Nav.Frequencies.selectedMhz[0].getValue())) {
								mcdu_message(i, "RWY/LS MISMATCH");
							}
						} else {
							mcdu_message(i, "NOT ALLOWED");
						}
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "L4") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.ILS.crsSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize >= 1 and radNavScratchpadSize <= 3) {
					if (radNavScratchpad >= 0 and radNavScratchpad <= 360) {
						pts.Instrumentation.Nav.Radials.selectedDeg[0].setValue(radNavScratchpad);
						fmgc.FMGCInternal.ILS.crsSet = 1;
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "L5") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.ADF1.freqSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize >= 3 and radNavScratchpadSize <= 6) {
					if (radNavScratchpad >= 190 and radNavScratchpad <= 1799) {
						if (radNavScratchpad != int(radNavScratchpad)) {
							var splitradNavScratchpad = split(".",radNavScratchpad);
							if (size(splitradNavScratchpad) != 2 or splitradNavScratchpad[1] != "5") {
								mcdu_message(i, "NOT ALLOWED");
							} else {
								pts.Instrumentation.Adf.Frequencies.selectedKhz[0].setValue(radNavScratchpad);
								fmgc.FMGCInternal.ADF1.freqSet = 1;
								mcdu_scratchpad.scratchpads[i].empty();
							}
						} else {
							pts.Instrumentation.Adf.Frequencies.selectedKhz[0].setValue(radNavScratchpad);
							fmgc.FMGCInternal.ADF1.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "L6") {
			if (fmgc.FMGCInternal.ADF1.freqSet) {
				if (radNavScratchpad == "CLR" and rmp.BFOActive[0].getValue()) {
					rmp.BFOActive[0].setValue(0);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					if (radNavScratchpadSize == 0 and !rmp.BFOActive[0].getValue()) {
						rmp.BFOActive[0].setValue(1);
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else if (key == "R1") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.VOR2.freqSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize == 3 or radNavScratchpadSize == 5 or radNavScratchpadSize == 6) {
					if (radNavScratchpad >= 108.10 and radNavScratchpad <= 111.95) {
						if (radNavScratchpad == 108.10 or radNavScratchpad == 108.15 or radNavScratchpad == 108.30 or radNavScratchpad == 108.35 or radNavScratchpad == 108.50 or radNavScratchpad == 108.55 or radNavScratchpad == 108.70 or radNavScratchpad == 108.75 or radNavScratchpad == 108.90 or radNavScratchpad == 108.95 
						or radNavScratchpad == 109.10 or radNavScratchpad == 109.15 or radNavScratchpad == 109.30 or radNavScratchpad == 109.35 or radNavScratchpad == 109.50 or radNavScratchpad == 109.55 or radNavScratchpad == 109.70 or radNavScratchpad == 109.75 or radNavScratchpad == 109.90 or radNavScratchpad == 109.95 
						or radNavScratchpad == 110.10 or radNavScratchpad == 110.15 or radNavScratchpad == 110.30 or radNavScratchpad == 110.35 or radNavScratchpad == 110.50 or radNavScratchpad == 110.55 or radNavScratchpad == 110.70 or radNavScratchpad == 110.75 or radNavScratchpad == 110.90 or radNavScratchpad == 110.95 
						or radNavScratchpad == 111.10 or radNavScratchpad == 111.15 or radNavScratchpad == 111.30 or radNavScratchpad == 111.35 or radNavScratchpad == 111.50 or radNavScratchpad == 111.55 or radNavScratchpad == 111.70 or radNavScratchpad == 111.75 or radNavScratchpad == 111.90 or radNavScratchpad == 111.95) {
							mcdu_message(i, "NOT ALLOWED");
						} else {
							pts.Instrumentation.Nav.Frequencies.selectedMhz[3].setValue(radNavScratchpad);
							fmgc.FMGCInternal.VOR2.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else if (radNavScratchpad >= 112.00 and radNavScratchpad <= 117.95) {
						pts.Instrumentation.Nav.Frequencies.selectedMhz[3].setValue(radNavScratchpad);
						fmgc.FMGCInternal.VOR2.freqSet = 1;
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "R2") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.VOR2.crsSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize >= 1 and radNavScratchpadSize <= 3) {
					if (radNavScratchpad >= 0 and radNavScratchpad <= 360) {
						pts.Instrumentation.Nav.Radials.selectedDeg[3].setValue(radNavScratchpad);
						fmgc.FMGCInternal.VOR2.crsSet = 1;
						mcdu_scratchpad.scratchpads[i].empty();
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "R5") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.ADF2.freqSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (radNavScratchpadSize >= 3 and radNavScratchpadSize <= 6) {
					if (radNavScratchpad >= 190 and radNavScratchpad <= 1799) {
						if (radNavScratchpad != int(radNavScratchpad)) {
							var splitradNavScratchpad = split(".",radNavScratchpad);
							if (size(splitradNavScratchpad) != 2 or splitradNavScratchpad[1] != "5") {
								mcdu_message(i, "NOT ALLOWED");
							} else {
								pts.Instrumentation.Adf.Frequencies.selectedKhz[1].setValue(radNavScratchpad);
								fmgc.FMGCInternal.ADF2.freqSet = 1;
								mcdu_scratchpad.scratchpads[i].empty();
							}
						} else {
							pts.Instrumentation.Adf.Frequencies.selectedKhz[1].setValue(radNavScratchpad);
							fmgc.FMGCInternal.ADF2.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				} else {
					mcdu_message(i, "NOT ALLOWED");
				}
			}
		} else if (key == "R6") {
			if (fmgc.FMGCInternal.ADF2.freqSet) {
				if (radNavScratchpad == "CLR" and rmp.BFOActive[1].getValue()) {
					rmp.BFOActive[1].setValue(0);
					mcdu_scratchpad.scratchpads[i].empty();
				} else {
					if (radNavScratchpadSize == 0 and !rmp.BFOActive[1].getValue()) {
						rmp.BFOActive[1].setValue(1);
					} else {
						mcdu_message(i, "NOT ALLOWED");
					}
				}
			} else {
				mcdu_message(i, "NOT ALLOWED");
			}
		} else {
			mcdu_message(i, "NOT ALLOWED");
		}
	}
}
