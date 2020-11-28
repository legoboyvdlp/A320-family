# A3XX Notification System
# Jonathan Redpath

# Copyright (c) 2020 Josh Davidson (Octal450)
var defaultServer = "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=xml&mostRecent=true&hoursBeforeNow=12&stationString=";
var result = nil;

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
	selectedType: "HOURLY WX",
	lastMETAR: nil,
	lastTAF: nil,
	sent: 0,
	sentTime: nil,
	received: 0,
	receivedTime: nil,
	server: props.globals.getNode("/systems/atsu/wxr-server"),
	newStation: func(airport) {
		if (size(airport) == 3 or size(airport) == 4) {
			me.station = airport;
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
		
		if (size(findAirportsByICAO(me.station)) == 0) {
			me.received = 1;
			me.receivedTime = me.sentTime;
			var message = mcdu.ACARSMessage.new(me.receivedTime, "INVALID STATION " ~ me.station);
			mcdu.ReceivedMessagesDatabase.addMessage(message);
			return 0;
		} 
	
		if (me.selectedType == "HOURLY WX") {
			var result = me.fetchMETAR(atsu.AOC.station, i);
			if (result == 0) {
				return 0;
			} elsif (result == 1) {
				return 3;
			} elsif (result == 2) {
				return 4;
			}
		}
		
		if (me.selectedType == "TERM FCST") {
			var result = me.fetchTAF(atsu.AOC.station, i); 
			if (result == 0) {
				return 0;
			} elsif (result == 1) {
				return 3;
			} elsif (result == 2) {
				return 4;
			}
		}
	},
	downloadFail: func(i, r = nil) {
		mcdu.mcdu_message(i,"NO ANSWER TO REQUEST");
		debug.dump("HTTP failure " ~ r.status);
		me.sent = 0;
	},
	fetchMETAR: func(airport, i) {
		if (!ATSU.working or !fmgc.FMGCInternal.flightNumSet) {
			me.sent = 0;
			return 2;
		}
		if (ecam.vhf3_voice.active) {
			me.sent = 0;
			return 1;
		}
		
		var serverString = "";
		if (me.server.getValue() == "vatsim") {
			serverString = "https://api.flybywiresim.com/metar?source=vatsim&icao=";
		} else {
			serverString = defaultServer;
		}
		
		http.load(serverString ~ airport)
			.fail(func(r) me.downloadFail(i, r))
			.done(func(r) {
				var errs = [];
				call(me.processMETAR, [r, i], me, {}, errs); 
				if (size(errs) > 0) {
					print("Failed to parse METAR for " ~ airport);
					debug.dump(r.response);
                    debug.printerror(errs);
					mcdu.mcdu_message(i, "BAD SERVER RESPONSE");
                }
			});
		return 0;
	},
	fetchTAF: func(airport, i) {
		if (!ATSU.working or !fmgc.FMGCInternal.flightNumSet) {
			me.sent = 0;
			return 2;
		}
		if (ecam.vhf3_voice.active) {
			me.sent = 0;
			return 1;
		}
		http.load("https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=tafs&requestType=retrieve&format=xml&timeType=issue&mostRecent=true&hoursBeforeNow=12&stationString=" ~ airport)
			.fail(func(r) me.downloadFail(i))
			.done(func(r) {
				var errs = [];
				call(me.processTAF, [r, i], me, {}, errs); 
				if (size(errs) > 0) {
					print("Failed to parse TAF for " ~ airport);
					debug.dump(r.response);
                    debug.printerror(errs);
					mcdu.mcdu_message(i, "BAD SERVER RESPONSE");
                }
			});
		return 0;
	},
	processMETAR: func(r, i) {
		var raw = r.response;
		if (me.server.getValue() == "vatsim") {
			me.lastMETAR = raw;
		} else if (find("<raw_text>", raw) != -1) {
			raw = split("<raw_text>", raw)[1];
			raw = split("</raw_text>", raw)[0];
			me.lastMETAR = raw;
		} else {
			me.received = 0;
			me.sent = 0;
			mcdu.mcdu_message(i, "BAD SERVER RESPONSE");
			return;
		}
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
		if (find("<raw_text>", raw) != -1) {
			raw = split("<raw_text>", raw)[1];
			raw = split("</raw_text>", raw)[0];
			me.lastTAF = raw;
		} else {
			me.received = 0;
			me.sent = 0;
			mcdu.mcdu_message(i, "BAD SERVER RESPONSE");
			return;
		}
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

var ATIS = {
	serverSel: props.globals.getNode("/systems/atsu/atis-server"),
	new: func() {
		var ATIS = { parents: [ATIS] };
		ATIS.station = nil;
		ATIS.lastATIS = nil;
		ATIS.sent = 0;
		ATIS.received = 0;
		ATIS.receivedTime = nil;
		ATIS.receivedCode = nil;
		ATIS.type = 0; # 0 = arr, 1 = dep
		return ATIS;
	},
	newStation: func(airport) {
		me.sent = 0;
		me.received = 0;
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
		
		result = me.fetchATIS(me.station, i);
		if (result == 0) {
			return 0;
		} elsif (result == 1) {
			return 3;
		} elsif (result == 2) {
			return 4;
		}
	},
	fetchATIS: func(airport, i) {
		if (!ATSU.working) {
			me.sent = 0;
			return 2;
		}
		if (ecam.vhf3_voice.active) {
			me.sent = 0;
			return 1;
		}
		
		var serverString = "https://api.flybywiresim.com/atis/" ~ airport ~ "?source=" ~ me.serverSel.getValue();
		
		http.load(serverString)
			.fail(func(r) return 3)
			.done(func(r) {
				var errs = [];
				call(me.processATIS, [r, i], me, {}, errs); 
				if (size(errs) > 0) {
					print("Failed to parse ATIS for " ~ airport);
					debug.dump(r.response);
                    debug.printerror(errs);
					mcdu.mcdu_message(i, "BAD SERVER RESPONSE");
                }
			});
		return 0;
	},
	processATIS: func(r, i) {
		var raw = r.response;
		if (r.response == "FBW_ERROR: D-ATIS not available at this airport" or find("atis not avail",r.response) != -1 or find('"statusCode":404',r.response) != -1) {
			me.received = 0;
			me.sent = 0;
			mcdu.mcdu_message(i,"NO D-ATIS AVAILABLE");
			return;
		}
		if (find("combined", raw) != -1) {
			raw = split('"combined":"', raw)[1];
			raw = split('"}', raw)[0];
		} else {
			if (me.type == 0) {
				raw = split('{"arr":"', raw)[1];
				raw = split('","dep":', raw)[0];
			} else {
				raw = split('","dep":"', raw)[1];
				raw = split('"}', raw)[0];
			}
		}
		
		var code = "";
		if (find("INFO ", raw) != -1) {
			code = split("INFO ", raw)[1];
			code = split(" ", code)[0];
		} else if (find("information ", raw) != -1) {
			code = split("information ", raw)[1];
			code = split(" ", code)[0];
		} else if (find("INFORMATION ", raw) != -1) {
			code = split("INFORMATION ", raw)[1];
			code = split(" ", code)[0];
		} else if  (find("ATIS ", raw) != -1) {
			code = split("ATIS ", raw)[1];
			code = split(" ", code)[0];
		} else if  (find("info ", raw) != -1) {
			code = split("info ", raw)[1];
			code = split(" ", code)[0];
		} else {
			print("Failed to find a valid ATIS code for " ~ me.station);
			debug.dump(raw);
		}
		
		if (find(".", code) != -1) {
			code = split(".", code)[0];
		}
		
		me.receivedCode = code;
		
		var time = "";
		if (find("Time ", raw) != -1) {
			time = split("Time ", raw)[1];
			time = split(" ", time)[0];
		} else if (find("time ", raw) != -1) {
			time = split("time ", raw)[1];
			time = split(" ", time)[0];
		} else if (find("TIME ", raw) != -1) {
			time = split("TIME ", raw)[1];
			time = split(" ", time)[0];
		} else if (find("Z.", raw) != -1) {
			time = split("Z.", raw)[0];
			time = right(time, 4);
		} else if (find("Z SPECIAL", raw) != -1) {
			time = split("Z SPECIAL", raw)[0];
			time = right(time, 4);
		} else if (find("metreport", raw) != -1) {
			time = split("metreport", raw)[0];
			time = right(time, 4);
		} else if (find((code ~ " "), raw) != -1) {
			if (size(split(" ",split(code ~ " ", raw)[1])[0]) == 4) {
				time = split(" ",split(code ~ " ", raw)[1])[0];
			}
		} else {
			print("Failed to find a valid ATIS time for " ~ me.station);
			debug.dump(raw);
		}
		
		if (size(time) == 3) {
			time ~= " ";
		}
		
		raw = string.uc(raw);
		raw = string.replace(raw, ",", "");
		
		settimer(func() {
			me.sent = 0;
			me.received = 1;
			me.receivedTime = time;
			me.lastATIS = raw;
		}, math.max(rand()*10, 4.5));
	},
};

makeNewDictionaryString("A", "ALPHA");
makeNewDictionaryString("B", "BRAVO");
makeNewDictionaryString("C", "CHARLIE");
makeNewDictionaryString("D", "DELTA");
makeNewDictionaryString("E", "ECHO");
makeNewDictionaryString("F", "FOXTROT");
makeNewDictionaryString("G", "GOLF");
makeNewDictionaryString("H", "HOTEL");
makeNewDictionaryString("I", "INDIA");
makeNewDictionaryString("J", "JULIET");
makeNewDictionaryString("K", "KILO");
makeNewDictionaryString("L", "LIMA");
makeNewDictionaryString("M", "MIKE");
makeNewDictionaryString("N", "NOVEMBER");
makeNewDictionaryString("O", "OSCAR");
makeNewDictionaryString("P", "PAPA");
makeNewDictionaryString("Q", "QUEBEC");
makeNewDictionaryString("R", "ROMEO");
makeNewDictionaryString("S", "SIERRA");
makeNewDictionaryString("T", "TANGO");
makeNewDictionaryString("U", "UNIFORM");
makeNewDictionaryString("V", "VICTOR");
makeNewDictionaryString("W", "WHISKEY");
makeNewDictionaryString("X", "XRAY");
makeNewDictionaryString("Y", "YANKEE");
makeNewDictionaryString("Z", "ZULU");

var ATISInstances = [ATIS.new(), ATIS.new(), ATIS.new(), ATIS.new()];