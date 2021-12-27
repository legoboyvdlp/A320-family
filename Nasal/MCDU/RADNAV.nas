# A3XX mCDU by Joshua Davidson (Octal450), Jonathan Redpath, and Matthew Maring (mattmaring)
# Copyright (c) 2020 Josh Davidson (Octal450)

var radNavScratchpad = nil;
var radNavScratchpadSize = nil;

var parseFrequencyVOR = func(scratchpad, i, num) {
	if (size(scratchpad) == 3 or size(scratchpad) == 5 or size(scratchpad) == 6) {
		if (scratchpad >= 108.00 and scratchpad <= 111.95) {
			if (scratchpad == 108.10 or scratchpad == 108.15 or scratchpad == 108.30 or scratchpad == 108.35 or scratchpad == 108.50 or scratchpad == 108.55 or scratchpad == 108.70 or scratchpad == 108.75 or scratchpad == 108.90 or scratchpad == 108.95 
			or scratchpad == 109.10 or scratchpad == 109.15 or scratchpad == 109.30 or scratchpad == 109.35 or scratchpad == 109.50 or scratchpad == 109.55 or scratchpad == 109.70 or scratchpad == 109.75 or scratchpad == 109.90 or scratchpad == 109.95 
			or scratchpad == 110.10 or scratchpad == 110.15 or scratchpad == 110.30 or scratchpad == 110.35 or scratchpad == 110.50 or scratchpad == 110.55 or scratchpad == 110.70 or scratchpad == 110.75 or scratchpad == 110.90 or scratchpad == 110.95 
			or scratchpad == 111.10 or scratchpad == 111.15 or scratchpad == 111.30 or scratchpad == 111.35 or scratchpad == 111.50 or scratchpad == 111.55 or scratchpad == 111.70 or scratchpad == 111.75 or scratchpad == 111.90 or scratchpad == 111.95) {
				return 3;
			} else {
				pts.Instrumentation.Nav.Frequencies.selectedMhz[num].setValue(scratchpad);
				return 4;
			}
		} else if (scratchpad >= 112.00 and scratchpad <= 117.95) {
			pts.Instrumentation.Nav.Frequencies.selectedMhz[num].setValue(scratchpad);
			return 4;
		} else {
			return 2;
		}
	} else {
		return 1;
	}
}

var searchResultVOR = nil;
var parseIdentVOR = func(scratchpad, i, num) {
	# TODO - duplicate names
	if (size(scratchpad) == 2 or size(scratchpad) == 3) {
		searchResultVOR = findNavaidsByID(scratchpad);
		if (size(searchResultVOR) != 0) {
			pts.Instrumentation.Nav.Frequencies.selectedMhz[num].setValue(searchResultVOR[0].frequency / 100);
			return 3;
		} else {
			return 2;
		}
	} else {
		return 1;
	}
};

var splitScratchpadADF = nil;
var parseFrequencyADF = func(scratchpad, i, num) {
	if (size(scratchpad) >= 3 and size(scratchpad) <= 6) {
		if (scratchpad >= 190 and scratchpad <= 1799) {
			if (scratchpad != int(scratchpad)) {
				splitScratchpadADF = split(".",scratchpad);
				if (size(splitScratchpadADF) != 2 or splitScratchpadADF[1] != "5") {
					return 3;
				} else {
					pts.Instrumentation.Adf.Frequencies.selectedKhz[num].setValue(scratchpad);
					return 4;
				}
			} else {
				pts.Instrumentation.Adf.Frequencies.selectedKhz[num].setValue(scratchpad);
				return 4;
			}
		} else {
			return 2;
		}
	} else {
		return 1;
	}
}

var searchResultADF = nil;
var parseIdentADF = func(scratchpad, i, num) {
	# TODO - duplicate names
	if (size(scratchpad) == 2 or size(scratchpad) == 3) {
		searchResultADF = findNavaidsByID(scratchpad);
		if (size(searchResultADF) != 0) {
			pts.Instrumentation.Adf.Frequencies.selectedKhz[num].setValue(searchResultADF[0].frequency / 100);
			return 3;
		} else {
			return 2;
		}
	} else {
		return 1;
	}
};

var returny = nil;
var radnavInput = func(key, i) {
	radNavScratchpad = mcdu_scratchpad.scratchpads[i].scratchpad;
	radNavScratchpadSize = size(radNavScratchpad);
	if (!rmp.rmpNav[0].getValue() and !rmp.rmpNav[1].getValue()) {
		if (key == "L1") {
			if (radNavScratchpad == "CLR") {
				fmgc.FMGCInternal.VOR1.freqSet = 0;
				mcdu_scratchpad.scratchpads[i].empty();
			} else {
				if (size(split("/", radNavScratchpad)) == 2) {
					if (size(split("/", radNavScratchpad)[0]) != 0) {
						mcdu_message(i, "FORMAT ERROR");
						return;
					} else {
						radNavScratchpad = split("/", radNavScratchpad)[1];
						if (num(radNavScratchpad) != radNavScratchpad) {
							mcdu_message(i, "FORMAT ERROR");
						} else {
							returny = parseFrequencyVOR(radNavScratchpad, i, 2);
							if (returny == 1) {
								mcdu_message(i, "FORMAT ERROR");
							} elsif (returny == 2) {
								mcdu_message(i, "ENTRY OUT OF RANGE");
							} elsif (returny == 3) {
								mcdu_message(i, "NOT ALLOWED");
							} elsif (returny == 4) {
								fmgc.FMGCInternal.VOR1.freqSet = 1;
								mcdu_scratchpad.scratchpads[i].empty();
							}
						}
					}
				} else if (size(split("/", radNavScratchpad)) == 1) {
					if (num(radNavScratchpad) == radNavScratchpad) {
						returny = parseFrequencyVOR(radNavScratchpad, i, 2);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							mcdu_message(i, "ENTRY OUT OF RANGE");
						} elsif (returny == 3) {
							mcdu_message(i, "NOT ALLOWED");
						} elsif (returny == 4) {
							fmgc.FMGCInternal.VOR1.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else if (isstr(radNavScratchpad)) {
						returny = parseIdentVOR(radNavScratchpad, i, 2);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							# TODO - NEW NAVAID page
							mcdu_message(i, "NOT IN DATA BASE");
						} elsif (returny == 3) {
							fmgc.FMGCInternal.VOR1.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					}
				} else {
					mcdu_message(i, "FORMAT ERROR");
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
				if (size(split("/", radNavScratchpad)) == 2) {
					if (size(split("/", radNavScratchpad)[0]) != 0) {
						mcdu_message(i, "FORMAT ERROR");
						return;
					} else {
						radNavScratchpad = split("/", radNavScratchpad)[1];
						if (num(radNavScratchpad) != radNavScratchpad) {
							mcdu_message(i, "FORMAT ERROR");
						} else {
							returny = parseFrequencyADF(radNavScratchpad, i, 0);
							if (returny == 1) {
								mcdu_message(i, "FORMAT ERROR");
							} elsif (returny == 2) {
								mcdu_message(i, "ENTRY OUT OF RANGE");
							} elsif (returny == 3) {
								mcdu_message(i, "NOT ALLOWED");
							} elsif (returny == 4) {
								fmgc.FMGCInternal.ADF1.freqSet = 1;
								mcdu_scratchpad.scratchpads[i].empty();
							}
						}
					}
				} else if (size(split("/", radNavScratchpad)) == 1) {
					if (num(radNavScratchpad) == radNavScratchpad) {
						returny = parseFrequencyADF(radNavScratchpad, i, 0);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							mcdu_message(i, "ENTRY OUT OF RANGE");
						} elsif (returny == 3) {
							mcdu_message(i, "NOT ALLOWED");
						} elsif (returny == 4) {
							fmgc.FMGCInternal.ADF1.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else if (isstr(radNavScratchpad)) {
						returny = parseIdentADF(radNavScratchpad, i, 0);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							# TODO - NEW NAVAID page
							mcdu_message(i, "NOT IN DATA BASE");
						} elsif (returny == 3) {
							fmgc.FMGCInternal.ADF1.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					}
				} else {
					mcdu_message(i, "FORMAT ERROR");
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
				if (size(split("/", radNavScratchpad)) == 2) {
					if (size(split("/", radNavScratchpad)[1]) != 0) {
						mcdu_message(i, "FORMAT ERROR");
						return;
					} else {
						radNavScratchpad = split("/", radNavScratchpad)[0];
						if (num(radNavScratchpad) != radNavScratchpad) {
							mcdu_message(i, "FORMAT ERROR");
						} else {
							returny = parseFrequencyVOR(radNavScratchpad, i, 3);
							if (returny == 1) {
								mcdu_message(i, "FORMAT ERROR");
							} elsif (returny == 2) {
								mcdu_message(i, "ENTRY OUT OF RANGE");
							} elsif (returny == 3) {
								mcdu_message(i, "NOT ALLOWED");
							} elsif (returny == 4) {
								fmgc.FMGCInternal.VOR2.freqSet = 1;
								mcdu_scratchpad.scratchpads[i].empty();
							}
						}
					}
				} else if (size(split("/", radNavScratchpad)) == 1) {
					if (num(radNavScratchpad) == radNavScratchpad) {
						returny = parseFrequencyVOR(radNavScratchpad, i, 3);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							mcdu_message(i, "ENTRY OUT OF RANGE");
						} elsif (returny == 3) {
							mcdu_message(i, "NOT ALLOWED");
						} elsif (returny == 4) {
							fmgc.FMGCInternal.VOR2.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else if (isstr(radNavScratchpad)) {
						returny = parseIdentVOR(radNavScratchpad, i, 3);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							# TODO - NEW NAVAID page
							mcdu_message(i, "NOT IN DATA BASE");
						} elsif (returny == 3) {
							fmgc.FMGCInternal.VOR2.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					}
				} else {
					mcdu_message(i, "FORMAT ERROR");
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
				if (size(split("/", radNavScratchpad)) == 2) {
					if (size(split("/", radNavScratchpad)[1]) != 0) {
						mcdu_message(i, "FORMAT ERROR");
						return;
					} else {
						radNavScratchpad = split("/", radNavScratchpad)[0];
						if (num(radNavScratchpad) != radNavScratchpad) {
							mcdu_message(i, "FORMAT ERROR");
						} else {
							returny = parseFrequencyADF(radNavScratchpad, i, 1);
							if (returny == 1) {
								mcdu_message(i, "FORMAT ERROR");
							} elsif (returny == 2) {
								mcdu_message(i, "ENTRY OUT OF RANGE");
							} elsif (returny == 3) {
								mcdu_message(i, "NOT ALLOWED");
							} elsif (returny == 4) {
								fmgc.FMGCInternal.ADF2.freqSet = 1;
								mcdu_scratchpad.scratchpads[i].empty();
							}
						}
					}
				} else if (size(split("/", radNavScratchpad)) == 1) {
					if (num(radNavScratchpad) == radNavScratchpad) {
						returny = parseFrequencyADF(radNavScratchpad, i, 1);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							mcdu_message(i, "ENTRY OUT OF RANGE");
						} elsif (returny == 3) {
							mcdu_message(i, "NOT ALLOWED");
						} elsif (returny == 4) {
							fmgc.FMGCInternal.ADF2.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					} else if (isstr(radNavScratchpad)) {
						returny = parseIdentADF(radNavScratchpad, i, 1);
						if (returny == 1) {
							mcdu_message(i, "FORMAT ERROR");
						} elsif (returny == 2) {
							# TODO - NEW NAVAID page
							mcdu_message(i, "NOT IN DATA BASE");
						} elsif (returny == 3) {
							fmgc.FMGCInternal.ADF2.freqSet = 1;
							mcdu_scratchpad.scratchpads[i].empty();
						}
					}
				} else {
					mcdu_message(i, "FORMAT ERROR");
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
