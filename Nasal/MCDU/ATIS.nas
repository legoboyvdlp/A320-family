var atisPage = {
	title: nil,
	fontMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsColour: [["ack", "ack", "ack", "ack", "ack", "ack"],["ack", "ack", "ack", "ack", "ack", "ack"]],
	L1: [nil, nil, "ack"], # content, title, colour
	L2: [nil, nil, "ack"],
	L3: [nil, nil, "ack"],
	L4: [nil, nil, "ack"],
	L5: [nil, nil, "ack"],
	L6: [nil, nil, "ack"],
	C1: [nil, nil, "ack"],
	C2: [nil, nil, "ack"],
	C3: [nil, nil, "ack"],
	C4: [nil, nil, "ack"],
	C5: [nil, nil, "ack"],
	C6: [nil, nil, "ack"],
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	computer: nil,
	size: 0,
	new: func(computer, index) {
		var ap = {parents:[atisPage]};
		ap.computer = computer;
		ap.lineOffset = 0;
		ap.index = index;
		ap.message = atsu.ATISInstances[index].lastATIS;
		ap._setupPageWithData();
		ap.update();
		return ap;
	},
	del: func() {
		return nil;
	},
	getNumLines: func() {
		me._numLines = size(me.message) / 30;
		me.lineOffset = math.ceil(me._numLines);
	},
	scrollUp: func() {
		me.lineOffset -= 1;
		if (me.lineOffset < 0) {
			me.lineOffset = me.getNumLines();
		}
		me.update();
	},
	scrollDown: func() {
		me.lineOffset += 1;
		if (me.lineOffset > me.getNumLines()) {
			me.lineOffset = 1;
		}
		me.update();
	},
	_clearPage: func() {
		me.L2 = [nil, nil, "wht"];
		me.L3 = [nil, nil, "wht"];
		me.L4 = [nil, nil, "wht"];
		me.C1 = [nil, nil, "ack"];
		me.C2 = [nil, nil, "ack"];
		me.C3 = [nil, nil, "ack"];
		me.C4 = [nil, nil, "ack"];
		me.C5 = [nil, nil, "ack"];
		me.R2 = [nil, nil, "ack"];
		me.R3 = [nil, nil, "ack"];
		me.R4 = [nil, nil, "ack"];
		me.R5 = [nil, nil, "ack"];
		me.arrowsMatrix = [[0, 0, 0, 0, 1, 1], [0, 0, 0, 0, 0, 0]];
	},
	_setupPageWithData: func() {
		me.title = atsu.ATISInstances[me.index].station ~ "/" ~ (atsu.ATISInstances[me.index].type == 0 ? "ARR" : "DEP") ~ " ATIS";
		me.title = atsu.ATISInstances[me.index].station ~ "/" ~ (atsu.ATISInstances[me.index].type == 0 ? "ARR" : "DEP") ~ " ATIS";
		me.L5 = [" PREV ATIS", nil, "wht"];
		me.L6 = [" RETURN", " ATIS MENU", "wht"];
		me.R6 = ["PRINT ", nil, "blu"];
		me.arrowsMatrix = [[0, 0, 0, 0, 1, 1], [0, 0, 0, 0, 0, 1]];
		me.arrowsColour = [["ack", "ack", "ack", "ack", "wht", "wht"], ["ack", "ack", "ack", "ack", "ack", "blu"]];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	update: func() {
		me._clearPage();
		var message = atsu.ATISInstances[me.index].lastATIS;
		var start = left(message, size(message) > (30 + (me.lineOffset * 30)) ? (30 + (me.lineOffset * 30)) : size(message));
		start = right(start, 30);
		
		me.L1 = [start, atsu.ATISInstances[me.index].station ~ "/" ~ (atsu.ATISInstances[me.index].type == 0 ? "ARR" : "DEP"), "wht"];
		# dictionary for code
		me.R1 = [" ",atsu.ATISInstances[me.index].receivedCode ~ " " ~ atsu.ATISInstances[me.index].receivedTime ~ "Z", "wht"];
		if (size(message) > 30) {
			me.L2[1] = left(split(me.L1[0], message)[1], size(message) > (60 + (me.lineOffset * 30)) ? 30 : size(message) - (30 + (me.lineOffset * 30)));
		}
		if (size(message) > 60) {
			me.L2[0] = left(split(me.L2[1], message)[1], size(message) > (90 + (me.lineOffset * 30)) ? 30 : size(message) - (60 + (me.lineOffset * 30)));
		}
		if (size(message) > 90) {
			me.L3[1] = left(split(me.L2[0], message)[1], size(message) > (120 + (me.lineOffset * 30)) ? 30 : size(message) - (90 + (me.lineOffset * 30)));
		}
		if (size(message) > 120) {
			me.L3[0] = left(split(me.L3[1], message)[1], size(message) > (150 + (me.lineOffset * 30)) ? 30 : size(message) - (120 + (me.lineOffset * 30)));
		}
		if (size(message) > 150) {
			me.L4[1] = left(split(me.L3[0], message)[1], size(message) > (180 + (me.lineOffset * 30)) ? 30 : size(message) - (150 + (me.lineOffset * 30)));
		}
		if (size(message) > 180) {
			me.L4[0] = left(split(me.L4[1], message)[1], size(message) > (210 + (me.lineOffset * 30)) ? 30 : size(message) - (180 + (me.lineOffset * 30)));
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
};