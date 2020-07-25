# A3XX Notification System
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var notificationSystem = {
	notifyAirport: nil,
	hasNotified: 0,
	inputAirport: func(airport) {
		if (!fmgc.FMGCInternal.flightNumSet or size(airport) != 4) { return 1; }
		var airportList = findAirportsByICAO(airport);
		if (size(airportList) == 0) { return 2; }
		if (me.hasNotified) { me.hasNotified = 0; }
		me.notifyAirport = airportList[0].id;
		return 0;
	},
	notify: func() {
		if (me.notifyAirport != nil) {
			me.hasNotified = 1;
			# todo - send notification to ATC
			return 0;
		} else {
			return 1;
		}
	},
	automaticTransfer: func(station) {
		var airportList = findAirportsByICAO(station);
		if (size(airportList) == 0) { return 2; }
		me.notifyAirport = airportList[0].id;
		return 0;
	},
};

var ADS = {
	state: 1,
	connections: [nil, nil, nil, nil],
	setState: func(state) {
		me.state = state;
	},
	getCount: func() {
		var count = 0;
		for (var i = 0; i < 4; i = i + 1) {
			if (me.connections[i] != nil) {
				count += 1;
			}
		}
		return count;
	},
};

var CompanyCall = {
	activeMsg: "",
	frequency: 999.99,
	received: 0,
	tuned: 0,
	init: func() {
		me.activeMsg = "";
		me.frequency = 999.99;
		me.received = 0;
	},
	newMsg: func(msg, freq) {
		me.activeMsg = msg;
		me.frequency = freq;
		me.received = 0;
	},
	ack: func() {
		me.received = 1;
		## assume that call remains until you receive another one or aircraft is reset
	},
	tune: func() {
		if (!me.received) { me.ack(); }
		if (rmp.act_vhf3.getValue() == 0) { 
			for (var i = 0; i < 3; i = i + 1) {
				if (getprop("/systems/radio/rmp[" ~ i ~ "]/sel_chan") == "vhf3") {
					setprop("/systems/radio/rmp[" ~ i ~ "]/vhf3-standby", me.frequency);
					rmp.transfer(i + 1);
					me.tuned = 1;
				}
			}
		}
	},
};