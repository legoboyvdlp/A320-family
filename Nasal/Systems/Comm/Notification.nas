# A3XX Notification System
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var ATSU = {
	working: 0,
	loop: func() {
		if (systems.ELEC.Bus.ac1.getValue() >= 110 or systems.ELEC.Bus.dc1.getValue() >= 25) {
			me.working = 1;
		} else {
			me.working = 0;
		}
	}
};

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

var AOC = {
	station: nil,
	selectedType: "HOURLY WX", # 0 = METAR 1 = TAF
	lastMETAR: nil,
	lastTAF: nil,
	sent: 0,
	sentTime: nil,
	received: 0,
	receivedTime: nil,
	newStation: func(airport) {
		if (size(airport) == 3 or size(airport) == 4) {
			if (size(findAirportsByICAO(airport)) == 0) {
				return 2;
			} else {
				me.station = airport;
				return 0;
			}
		} else {
			return 1;
		}
	},
	sendReq: func(i) {
		if (me.station == nil or (me.sent and !me.received)) {
			return 1;
		}
		me.sent = 1;
		me.received = 0;
		var sentTime = left(getprop("/sim/time/gmt-string"), 5);
		me.sentTime = split(":", sentTime)[0] ~ "." ~ split(":", sentTime)[1] ~ "Z";
		if (me.selectedType == "HOURLY WX") {
			me.fetchMETAR(atsu.AOC.station, i);
			return 0;
		}
		
		if (me.selectedType == "TERM FCST") {
			me.fetchTAF(atsu.AOC.station, i);
			return 0;
		}
	},
	fetchMETAR: func(airport, i) {
		if (ecam.vhf3_voice.active) {
			mcdu.mcdu_message(i, "VHF3 VOICE MSG NOT GEN");
			return;
		}
		if (!ATSU.working) {
			mcdu.mcdu_message(i, "NO COMM MSG NOT GEN");
			return;
		}
		http.load("https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&mostRecent=true&hoursBeforeNow=12&stationString=" ~ airport)
			.fail(func print("Download failed!"))
			.done(func(r) me.processMETAR(r, i));
	},
	fetchTAF: func(airport, i) {
		if (ecam.vhf3_voice.active) {
			mcdu_message(i, "VHF3 VOICE MSG NOT GEN");
			return;
		}
		if (!ATSU.working) {
			mcdu_message(i, "NO COMM MSG NOT GEN");
			return;
		}
		http.load("https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=tafs&requestType=retrieve&format=xml&timeType=issue&mostRecent=true&hoursBeforeNow=12&stationString=" ~ airport)
			.fail(func print("Download failed!"))
			.done(func(r) me.processTAF(r, i));
	},
	processMETAR: func(r, i) {
		var raw = r.response;
		raw = split("<raw_text>", raw)[1];
		raw = split("</raw_text>", raw)[0];
		me.lastMETAR = raw;
		settimer(func() {
			me.received = 1;
			mcdu.mcdu_message(i, "WX UPLINK");
			
			var receivedTime = left(getprop("/sim/time/gmt-string"), 5);
			me.receivedTime = split(":", receivedTime)[0] ~ "." ~ split(":", receivedTime)[1] ~ "Z";
			var message = mcdu.ACARSMessage.new(me.receivedTime, me.lastMETAR);
			mcdu.ReceivedMessagesDatabase.addMessage(message);
		}, math.max(rand()*6, 2.25));
	},
	processTAF: func(r, i) {
		var raw = r.response;
		raw = split("<raw_text>", raw)[1];
		raw = split("</raw_text>", raw)[0];
		me.lastTAF = raw;
		settimer(func() {
			me.received = 1;
			mcdu.mcdu_message(i, "WX UPLINK");
			
			var receivedTime = left(getprop("/sim/time/gmt-string"), 5);
			me.receivedTime = split(":", receivedTime)[0] ~ "." ~ split(":", receivedTime)[1] ~ "Z";
			var message = mcdu.ACARSMessage.new(me.receivedTime, me.lastTAF);
			mcdu.ReceivedMessagesDatabase.addMessage(message);
		}, math.max(rand()*6, 2.25));
	},
};