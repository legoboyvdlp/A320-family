# A3XX Simbrief Parser
# Copyright (c) 2020 Jonathan Redpath (legoboyvdlp)

var SimbriefParser = {
	node: nil,
	fetch: func(username, i) {
		var stamp = systime();
		http.save("https://www.simbrief.com/api/xml.fetcher.php?username=" ~ username, getprop('/sim/fg-home') ~ "/Export/simbrief" ~ stamp ~ ".xml")
			.fail(func mcdu.mcdu_message(i, "SIMBRIEF FAILED"))
			.done(func me.read(getprop('/sim/fg-home') ~ "/Export/simbrief" ~ stamp ~ ".xml"));
	},
	read: func(xml) {
		var data = io.readxml(xml);
		if (data != nil) {
			if (data.getChild("OFP") == nil) {
				print("XML file " ~ xml ~ " not a valid Simbrief file");
			} else {
				me.node = data;
				debug.dump(me.node.getChild("OFP").getChild("fetch").getChild("status"));
			}
		} else {
			print("Error reading " ~ xml);
		}
	},
};