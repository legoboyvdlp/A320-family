# A3XX MCDU Received Messages Page
# Copyright (c) 2022 Jonathan Redpath (legoboyvdlp)

var receivedMessagesPage = {
	title: nil,
	arrowsMatrix: [[0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0]],
	arrowsColour: [["ack", "ack", "ack", "ack", "ack", "ack"],["ack", "ack", "ack", "ack", "ack", "ack"]],
	L1: [nil, nil, "ack"], # content, title, colour
	L2: [nil, nil, "ack"],
	L3: [nil, nil, "ack"],
	L4: [nil, nil, "ack"],
	L5: [nil, nil, "ack"],
	L6: [nil, nil, "ack"],
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	computer: nil,
	size: 0,
	getPageNumStr: func() {
		return "     " ~ sprintf("%02d",me.curPage) ~ "/" ~ sprintf("%02d",ReceivedMessagesDatabase.getCountPages());
	},
	new: func(computer) {
		var ap = {parents:[receivedMessagesPage]};
		ap.computer = computer;
		ap.curPage = 1;
		ap._setupPageWithData();
		ap.update();
		return ap;
	},
	del: func() {
		return nil;
	},
	scrollLeft: func() {
		me.curPage -= 1;
		if (me.curPage < 1) {
			me.curPage = ReceivedMessagesDatabase.getCountPages();
		}
		me.update();
	},
	scrollRight: func() {
		me.curPage += 1;
		if (me.curPage > ReceivedMessagesDatabase.getCountPages()) {
			me.curPage = 1;
		}
		me.update();
	},
	_clearPage: func() {
		me.L1 = [nil, nil, "ack"];
		me.L2 = [nil, nil, "ack"];
		me.L3 = [nil, nil, "ack"];
		me.L4 = [nil, nil, "ack"];
		me.L5 = [nil, nil, "ack"];
		me.R1 = [nil, nil, "ack"];
		me.R2 = [nil, nil, "ack"];
		me.R3 = [nil, nil, "ack"];
		me.R4 = [nil, nil, "ack"];
		me.R5 = [nil, nil, "ack"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
	},
	_setupPageWithData: func() {
		me.title = "ACARS - RCVD MSGS      ";
		me.L6 = [" RETURN", nil, "wht"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["blu", "blu", "blu", "blu", "blu", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	update: func() {
		me._clearPage();
		me.size = ReceivedMessagesDatabase.getSize();
		var message = nil;
		
		if (me.size >= (me.curPage * 5) + -4) {
			message = ReceivedMessagesDatabase.database.vector[-5 + (me.curPage * 5)];
			me.L1[0] = " " ~ left(message.body, size(message.body) > 17 ? 17 : size(message.body));
			me.L1[2] = "blu";
			if (!message.viewed) {
				me.L1[1] = " " ~ message.time ~ "            NEW"; 
			} else {
				me.L1[1] = " " ~ message.time ~ "         VIEWED"; 
			}
			me.arrowsMatrix[0][0] = 1;
		}

		if (me.size >= (me.curPage * 5) + -3) {
			message = ReceivedMessagesDatabase.database.vector[-4 + (me.curPage * 5)];
			me.L2[0] = " " ~ left(message.body, size(message.body) > 17 ? 17 : size(message.body));
			me.L2[2] = "blu";
			if (!message.viewed) {
				me.L2[1] = " " ~ message.time ~ "            NEW"; 
			} else {
				me.L2[1] = " " ~ message.time ~ "         VIEWED"; 
			}
			me.arrowsMatrix[0][1] = 1;
		}
		
		if (me.size >= (me.curPage * 5) + -2) {
			message = ReceivedMessagesDatabase.database.vector[-3 + (me.curPage * 5)];
			me.L3[0] = " " ~ left(message.body, size(message.body) > 17 ? 17 : size(message.body));
			me.L3[2] = "blu";
			if (!message.viewed) {
				me.L3[1] = " " ~ message.time ~ "            NEW"; 
			} else {
				me.L3[1] = " " ~ message.time ~ "         VIEWED"; 
			}
			me.arrowsMatrix[0][2] = 1;
		}
		
		if (me.size >= (me.curPage * 5) + -1) {
			message = ReceivedMessagesDatabase.database.vector[-2 + (me.curPage * 5)];
			me.L4[0] = " " ~ left(message.body, size(message.body) > 17 ? 17 : size(message.body));
			me.L4[2] = "blu";
			if (!message.viewed) {
				me.L4[1] = " " ~ message.time ~ "            NEW"; 
			} else {
				me.L4[1] = " " ~ message.time ~ "         VIEWED"; 
			}
			me.arrowsMatrix[0][3] = 1;
		}
		
		if (me.size >= (me.curPage * 5) + 0) {
			message = ReceivedMessagesDatabase.database.vector[-1 + (me.curPage * 5)];
			me.L5[0] = " " ~ left(message.body, size(message.body) > 17 ? 17 : size(message.body));
			me.L5[2] = "blu";
			if (!message.viewed) {
				me.L5[1] = " " ~ message.time ~ "            NEW"; 
			} else {
				me.L5[1] = " " ~ message.time ~ "         VIEWED"; 
			}
			me.arrowsMatrix[0][4] = 1;
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	leftKey: func(index) {
		if (ReceivedMessagesDatabase.getSize() >= (-5 + index + (me.curPage * 5))) {
			if (mcdu_scratchpad.scratchpads[me.computer].scratchpad == "CLR") {
				ReceivedMessagesDatabase.removeAtIndex(-6 + index + (me.curPage * 5));
				me.update();
				if (ReceivedMessagesDatabase.getSize() < (me.curPage * 5) and ReceivedMessagesDatabase.getSize() >= 5) {
					me.scrollLeft();
				}
				mcdu_scratchpad.scratchpads[me.computer].empty();
			} elsif (size(mcdu_scratchpad.scratchpads[me.computer].scratchpad) == 0) {
				canvas_mcdu.myReceivedMessage[me.computer] = receivedMessagePage.new(me.computer, (-6 + index + (me.curPage * 5)));
				setprop("MCDU[" ~ me.computer ~ "]/page", "RECEIVEDMSG");
			} else {
				mcdu_message(me.computer, "NOT ALLOWED");
			}
		} else {
			mcdu_message(me.computer, "NOT ALLOWED");
		}
	},
};

var receivedMessagePage = {
	title: nil,
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
		var ap = {parents:[receivedMessagePage]};
		ap.computer = computer;
		ap.curPage = index + 1;
		ReceivedMessagesDatabase.database.vector[ap.curPage - 1].viewed = 1;
		ap._setupPageWithData();
		ap.update();
		return ap;
	},
	del: func() {
		return nil;
	},
	scrollLeft: func() {
		me.curPage -= 1;
		if (me.curPage < 1) {
			me.curPage = ReceivedMessagesDatabase.getSize();
		}
		ReceivedMessagesDatabase.database.vector[me.curPage - 1].viewed = 1;
		me.update();
	},
	scrollRight: func() {
		me.curPage += 1;
		if (me.curPage > ReceivedMessagesDatabase.getSize()) {
			me.curPage = 1;
		}
		ReceivedMessagesDatabase.database.vector[me.curPage - 1].viewed = 1;
		me.update();
	},
	_clearPage: func() {
		me.L1 = [nil, nil, "ack"];
		me.L2 = [nil, nil, "ack"];
		me.L3 = [nil, nil, "ack"];
		me.L4 = [nil, nil, "ack"];
		me.L5 = [nil, nil, "ack"];
		me.C1 = [nil, nil, "ack"];
		me.C2 = [nil, nil, "ack"];
		me.C3 = [nil, nil, "ack"];
		me.C4 = [nil, nil, "ack"];
		me.C5 = [nil, nil, "ack"];
		me.R1 = [nil, nil, "ack"];
		me.R2 = [nil, nil, "ack"];
		me.R3 = [nil, nil, "ack"];
		me.R4 = [nil, nil, "ack"];
		me.R5 = [nil, nil, "ack"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
	},
	_setupPageWithData: func() {
		me.title = "ACARS MESSAGE";
		me.L6 = [" RETURN", nil, "wht"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["blu", "blu", "blu", "blu", "blu", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	update: func() {
		me._clearPage();
		me.size = ReceivedMessagesDatabase.getSize();
		var message = nil;
		if (me.size >= me.curPage) {
			message = ReceivedMessagesDatabase.database.vector[me.curPage - 1];
			me.L1[1] = message.time;
			me.C1[1] = "VIEWED";
			me.C1[2] = "grn";
			me.R1[1] = sprintf("%02d",me.curPage) ~ "/" ~ sprintf("%02d",ReceivedMessagesDatabase.getSize());
			
			me.L1[0] = left(message.body, size(message.body) > 24 ? 24 : size(message.body));
			me.L1[2] = "wht";
			me.L2[2] = "wht";
			me.L3[2] = "wht";
			me.L4[2] = "wht";
			me.L5[2] = "wht";
			if (size(message.body) > 24) {
				me.L2[1] = left(split(me.L1[0], message.body)[1], size(message.body) > 48 ? 24 : size(message.body) - 24);
			}
			if (size(message.body) > 48) {
				me.L2[0] = left(split(me.L2[1], message.body)[1], size(message.body) > 72 ? 24 : size(message.body) - 48);
			}
			if (size(message.body) > 72) {
				me.L3[1] = left(split(me.L2[0], message.body)[1], size(message.body) > 96 ? 24 : size(message.body) - 72);
			}
			if (size(message.body) > 96) {
				me.L3[0] = left(split(me.L3[1], message.body)[1], size(message.body) > 120 ? 24 : size(message.body) - 96);
			}
			if (size(message.body) > 120) {
				me.L4[1] = left(split(me.L3[0], message.body)[1], size(message.body) > 144 ? 24 : size(message.body) - 120);
			}
			if (size(message.body) > 144) {
				me.L4[0] = left(split(me.L4[1], message.body)[1], size(message.body) > 168 ? 24 : size(message.body) - 144);
			}
			if (size(message.body) > 168) {
				me.L5[1] = left(split(me.L4[0], message.body)[1], size(message.body) > 192 ? 24 : size(message.body) - 168);
			}
			if (size(message.body) > 192) {
				me.L5[0] = left(split(me.L5[1], message.body)[1], size(message.body) > 216 ? 24 : size(message.body) - 192);
			}
		}
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
};

var ACARSMessage = {
	new: func(time, body) {
		var message = {parents:[ACARSMessage]};
		message.time = time;
		message.body = body;
		message.viewed = 0;
		return message;
	},
};

var ReceivedMessagesDatabase = {
	database: std.Vector.new(),
	addMessage: func(message) {
		me.database.insert(0, message);
		if (canvas_mcdu.myReceivedMessages[0] != nil) {
			canvas_mcdu.myReceivedMessages[0].update();
		}
		if (canvas_mcdu.myReceivedMessages[1] != nil) {
			canvas_mcdu.myReceivedMessages[1].update();
		}
	},
	firstUnviewed: func() {
		for (var i = 0; i < me.getSize(); i = i + 1) {
			if (!me.database.vector[i].viewed) {
				return i;
			}
		}
		return -99;
	},
	getCountPages: func() {
		return math.ceil(me.getSize() / 5);
	},
	getSize: func() {
		return me.database.size();
	},
	removeAtIndex: func(index) {
		return me.database.pop(index);
	},
	clearDatabase: func() {
		me.database.clear();
	},
};