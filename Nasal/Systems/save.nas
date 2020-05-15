# Copyright (C) 2020 Merspieler, merspieler _at_ airmail.cc
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Save and restore properties between sessions

# To add more properties to autosave, just add them here.
var default = [
	# CONSUMABLES
	# Fuel
	"/consumables/fuel/tank[0]/level-lbs",
	"/consumables/fuel/tank[1]/level-lbs",
	"/consumables/fuel/tank[2]/level-lbs",
	"/consumables/fuel/tank[3]/level-lbs",
	"/consumables/fuel/tank[4]/level-lbs",
	# apu oil
	"/systems/apu/oil/level-l",
	# CONTROLS
	# rmp
	"/controls/radio/rmp[0]/on",
	"/controls/radio/rmp[1]/on",
	"/controls/radio/rmp[2]/on",
	# efis
	"/instrumentation/efis[0]/inputs/range-nm",
	"/instrumentation/efis[0]/nd/display-mode",
	"/instrumentation/efis[0]/mfd/pnl_mode-num", # The model
	"/instrumentation/efis[0]/input/lh-vor-adf",
	"/instrumentation/efis[0]/input/rh-vor-adf",
	"/instrumentation/efis[1]/inputs/range-nm",
	"/instrumentation/efis[1]/nd/display-mode",
	"/instrumentation/efis[1]/mfd/pnl_mode-num", # The model
	"/instrumentation/efis[1]/input/lh-vor-adf",
	"/instrumentation/efis[1]/input/rh-vor-adf",
	# parking brake
	"/controls/gear/brake-parking",
	# electrics
	"/systems/electrical/sources/bat-1/percent-calc",
	"/systems/electrical/sources/bat-2/percent-calc"
];

var save = func (saved_props, file) {
	print("Saving state...");
	for (var i = 0; i < size(saved_props); i += 1)
	{
		setprop("/save" ~ saved_props[i], getprop(saved_props[i]));
	}

	var saveNode = props.globals.getNode("/save", 0);

	io.write_properties(file, saveNode);
	print("State saved");
}

var restore = func (saved_props, file) {
	print("Loading saved state...");
	var readNode = props.globals.initNode("/save", );

	io.read_properties(file, readNode);

	for (var i = 0; i < size(saved_props); i += 1)
	{
		var val = getprop("/save" ~ saved_props[i]);
		if (val != nil)
		{
			setprop(saved_props[i], val);
		}
	}
	print("Saved state loaded");
}
