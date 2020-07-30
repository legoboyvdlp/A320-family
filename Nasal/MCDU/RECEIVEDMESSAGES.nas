var receivedMessagesPage = {
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
	R1: [nil, nil, "ack"],
	R2: [nil, nil, "ack"],
	R3: [nil, nil, "ack"],
	R4: [nil, nil, "ack"],
	R5: [nil, nil, "ack"],
	R6: [nil, nil, "ack"],
	computer: nil,
	size: 0,
	getPageNumStr: func() {
		return me.curPage ~ "/" ~ ReceivedMessagesDatabase.getCountPages();
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
		me.title = "RECEIVED MESSAGES      ";
		me.L6 = [" RETURN", nil, "wht"];
		me.arrowsMatrix = [[0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0]];
		me.arrowsColour = [["blu", "blu", "blu", "blu", "blu", "wht"], ["ack", "ack", "ack", "ack", "ack", "ack"]];
		me.fontMatrix = [[0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]];
		canvas_mcdu.pageSwitch[me.computer].setBoolValue(0);
	},
	update: func() {
		me._clearPage();
		me.size = ReceivedMessagesDatabase.getSize();
		var message = nil;
		
		if (me.size >= (me.curPage * 5) + -4) {
			message = ReceivedMessagesDatabase.database.vector[-5 + (me.curPage * 5)];
			me.L1[0] = " " ~ left(message.body, 23);
			me.L1[2] = "blu";
			if (!message.viewed) {
				me.L1[1] = " " ~ message.time ~ "                  NEW"; 
			} else {
				me.L1[1] = " " ~ message.time ~ "               VIEWED"; 
			}
			me.arrowsMatrix[0][0] = 1;
		}

		if (me.size >= (me.curPage * 5) + -3) {
			message = ReceivedMessagesDatabase.database.vector[-4 + (me.curPage * 5)];
			me.L2[0] = " " ~ left(message.body, 23);
			me.L2[2] = "blu";
			if (!message.viewed) {
				me.L2[1] = " " ~ message.time ~ "                  NEW"; 
			} else {
				me.L2[1] = " " ~ message.time ~ "               VIEWED"; 
			}
			me.arrowsMatrix[0][1] = 1;
		}
		
		if (me.size >= (me.curPage * 5) + -2) {
			message = ReceivedMessagesDatabase.database.vector[-3 + (me.curPage * 5)];
			me.L3[0] = " " ~ left(message.body, 23);
			me.L3[2] = "blu";
			if (!message.viewed) {
				me.L3[1] = " " ~ message.time ~ "                  NEW"; 
			} else {
				me.L3[1] = " " ~ message.time ~ "               VIEWED"; 
			}
			me.arrowsMatrix[0][2] = 1;
		}
		
		if (me.size >= (me.curPage * 5) + -1) {
			message = ReceivedMessagesDatabase.database.vector[-2 + (me.curPage * 5)];
			me.L4[0] = " " ~ left(message.body, 23);
			me.L4[2] = "blu";
			if (!message.viewed) {
				me.L4[1] = " " ~ message.time ~ "                  NEW"; 
			} else {
				me.L4[1] = " " ~ message.time ~ "               VIEWED"; 
			}
			me.arrowsMatrix[0][3] = 1;
		}
		
		if (me.size >= (me.curPage * 5) + 0) {
			message = ReceivedMessagesDatabase.database.vector[-1 + (me.curPage * 5)];
			me.L5[0] = " " ~ left(message.body, 23);
			me.L5[2] = "blu";
			if (!message.viewed) {
				me.L5[1] = " " ~ message.time ~ "                  NEW"; 
			} else {
				me.L5[1] = " " ~ message.time ~ "               VIEWED"; 
			}
			me.arrowsMatrix[0][4] = 1;
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
	getCountPages: func() {
		return math.ceil(me.database.size() / 5);
	},
	getSize: func() {
		return me.database.size();
	},
	clearDatabase: func() {
		me.database.clear();
	},
};