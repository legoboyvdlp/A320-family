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
		ap.page = 1;
		ap.index = index;
		ap.message = atsu.ATISInstances[index].lastATIS;
		ap._setupPageWithData();
		ap._numPages = 1;
		ap.update();
		return ap;
	},
	del: func() {
		return nil;
	},
	getNumPages: func() {
		me._numPages = math.ceil(size(me.message) / 210);
		return me._numPages;
	},
	scrollUp: func() {
		me.page -= 1;
		if (me.page < 1) {
			me.page = me.getNumPages();
		}
		me.update();
	},
	scrollDown: func() {
		me.page += 1;
		if (me.page > me.getNumPages()) {
			me.page = 1;
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
		me.title = atsu.ATISInstances[me.index].station ~ "/" ~ (atsu.ATISInstances[me.index].type == 0 ? "ARR" : "DEP") ~ " ATIS    ";
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
		var pageMinusOne = (me.page - 1);
		var numberExtraChar = pageMinusOne * 210;
		me.L1 = [substr(message, numberExtraChar, 30), atsu.ATISInstances[me.index].station ~ "/" ~ (atsu.ATISInstances[me.index].type == 0 ? "ARR" : "DEP"), "wht"];
		me.R1 = [" ",atsu.DictionaryString.fetchString1(atsu.ATISInstances[me.index].receivedCode).string2 ~ " " ~ atsu.ATISInstances[me.index].receivedTime ~ "Z", "wht"];
		if (size(message) > 30) {
			me.L2[1] = substr(message, numberExtraChar + 30, 30);
		}
		if (size(message) > 60) {
			me.L2[0] = substr(message, numberExtraChar + 60, 30);
		}
		if (size(message) > 90) {
			me.L3[1] = substr(message, numberExtraChar + 90, 30);
		}
		if (size(message) > 120) {
			me.L3[0] = substr(message, numberExtraChar + 120, 30);
		}
		if (size(message) > 150) {
			me.L4[1] = substr(message, numberExtraChar + 150, 30);
		}
		if (size(message) > 180) {
			me.L4[0] = substr(message, numberExtraChar + 180, 30);
		}
		
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
};