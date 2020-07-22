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
};