# A3XX FMGC MCDU Message Generator and Control
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var TypeIMessage = {
	new: func(msgText, isInhibit = 0) {
		var msg = { parents: [TypeIMessage] };
		msg.msgText = msgText;
		msg.colour = "wht";
		msg.inhibitable = isInhibit;
		return msg;
	},
};

var TypeIIMessage = {
	new: func(msgText, colour = "wht", isInhibit = 0) {
		var msg = { parents: [TypeIIMessage] };
		msg.msgText = msgText;
		msg.colour = colour;
		msg.inhibitable = isInhibit;
		return msg;
	},
};

var MessageQueueController = {
	new: func(computer) {
		var msgC = { parents: [MessageQueueController] };
		msgC.computer = computer;
		msgC.messages = std.Vector.new(); # show left to right
		return msgC;
	},
	# first in first out
	addNewMsg: func(msg) {
		if (me.messages.size() < 5) {
			if (!me.messages.contains(msg)) {
				me.messages.append(msg);
			}
		}
	},
	getNextMsg: func() {
		if (me.messages.size() >= 1) {
			return me.messages.vector[0];
		}
		return nil;
	},
	deleteAtIndex: func(index) {
		if (num(me.messages.size()) >= (index + 1)) {
			me.messages.pop(index);
		}
	},
	clearQueue: func() {
		me.messages.clear();
	},
	loop: func() {
		if (me.getNextMsg() != nil) {
			if (!scratchpads[me.computer].showTypeIIMsg) {
				if (scratchpads[me.computer].showTypeII(me.getNextMsg())) {
					me.deleteAtIndex(me.getNextMsg());
				}
			}
		}
	},
};

var scratchpadController = {
	new: func(mcdu) {
		var sp = { parents: [scratchpadController] };
		sp.scratchpad = "";
		sp.scratchpadSave = "";
		sp.scratchpadColour = "wht";
		sp.showTypeIMsg = 0;
		sp.showTypeIIMsg = 0;
		sp.mcdu = mcdu;
		return sp;
	},
	
	addChar: func(character) {
		if (size(me.scratchpad) >= 22) {
			return;
		}
		
		# any shown type ii is hidden
		if (me.showTypeIIMsg) {
			me.clearTypeII();
		}
		
		# any shown type i is hidden
		if (me.showTypeIMsg) {
			me.clearTypeI();
		}
		
		me.scratchpad = me.scratchpad ~ character;
		me.scratchpadColour = "wht";
		me.update();
	},
	showTypeI: func(msg) {
		# any shown type ii is hidden
		if (me.showTypeIIMsg) {
			me.clearTypeII();
		}
		
		if (!me.showTypeIMsg) {
			me.showTypeIMsg = 1;
			
			# save any data entered
			me.scratchpadSave = me.scratchpad;
		}
			
		me.scratchpad = msg.msgText;
		me.scratchpadColour = msg.colour;
		me.update();
	},
	showTypeII: func(msg) {
		# only show if scratchpad empty
		if (me.scratchpad == "") {
			me.showTypeIIMsg = 1;
			me.scratchpad = msg.msgText;
			me.scratchpadColour = msg.colour;
			me.update();
			return 1;
		}
		me.update();
		return 0;
	},
	clearTypeI: func() {
		me.scratchpad = me.scratchpadSave;
		me.scratchpadSave = nil;
		me.showTypeIMsg = 0;
		me.update();
	},
	clearTypeII: func() {
		me.showTypeIIMsg = 0;
		me.empty();
		me.update();
	},
	override: func(str) {
		if (me.scratchpad == "USING COST INDEX N") {
			me.scratchpad = "USING COST INDEX " ~ str;
			me.update();
		}
	},
	empty: func() {
		me.scratchpad = "";
		me.update();
	},
	clear: func() {
		if (me.scratchpad == "CLR") {
			me.empty();
		} elsif (me.showTypeIMsg) {
			me.clearTypeI();
		} elsif (!me.showTypeIIMsg) {
			me.scratchpad = left(me.scratchpad, size(me.scratchpad) - 1);
		} else {
			me.clearTypeII();
		}
		me.update();
	},
	update: func() {	
		if (me.mcdu == 1) {
			canvas_mcdu.MCDU_1.updateScratchpadCall();
		} else {
			canvas_mcdu.MCDU_2.updateScratchpadCall();
		}
	},
};

var MessageController = {
	typeIMessages: std.Vector.new([
		TypeIMessage.new("AOC DISABLED"),TypeIMessage.new("AWY/WPT MISMATCH"),TypeIMessage.new("DIR TO IN PROGRESS"),
		TypeIMessage.new("ENTRY OUT OF RANGE"),TypeIMessage.new("FORMAT ERROR"),TypeIMessage.new("INSERT/ERASE TMPY FIRST"),
		TypeIMessage.new("LIST OF 20 IN USE"),TypeIMessage.new("PILOT ELEMENT RETAINED"),TypeIMessage.new("NOT ALLOWED"),
		TypeIMessage.new("NOT IN DATA BASE"),TypeIMessage.new("ONLY SPD ENTRY ALLOWED"),TypeIMessage.new("REVISION IN PROGRESS"),
		TypeIMessage.new("TMPY F-PLN EXISTS", 1),TypeIMessage.new("SELECT DESIRED SYSTEM"),TypeIMessage.new("SELECT HDG/TRK FIRST"),
		TypeIMessage.new("USING COST INDEX N", 1),TypeIMessage.new("WAIT FOR SYSTEM RESPONSE"),TypeIMessage.new("RWY/LS MISMATCH"),
		TypeIMessage.new("VHF3 VOICE MSG NOT GEN"),TypeIMessage.new("NO COMM MSG NOT GEN"),TypeIMessage.new("WX UPLINK"),
	]),
	typeIIMessages: std.Vector.new([
		TypeIIMessage.new("LAT DISCONT AHEAD", "amb", 0),TypeIIMessage.new("MORE DRAG"),TypeIIMessage.new("RWY/LS MISMATCH", "amb", 0),TypeIIMessage.new("STEP DELETED"),
		TypeIIMessage.new("STEP NOW"),TypeIIMessage.new("TIME TO EXIT", "amb", 0),TypeIIMessage.new("V1/VR/V2 DISAGREE", "amb", 0),
		TypeIIMessage.new("TO SPEED TOO LOW", "amb", 0),
	]),
	
	# to speed to low - new on a320, margin against vmcg / vs1g

	getTypeIMsgByText: func(text) {
		return me.getMsgByText(text, me.typeIMessages.vector);
	},
	getTypeIIMsgByText: func(text) {
		return me.getMsgByText(text, me.typeIIMessages.vector);
	},
	getMsgByText: func(text, theVector) {
		foreach (var message; theVector) {
			if (message.msgText = text) {
				return message;
			}
		}
		return nil;
	},
};

var scratchpads = [scratchpadController.new(1), scratchpadController.new(2)];
var messageQueues = [MessageQueueController.new(0), MessageQueueController.new(1)];

var loop1MsgTimer = func() {
	if (messageQueues[0].getNextMsg() != nil) {
		if (!scratchpads[messageQueues[0].computer].showTypeIIMsg) {
			if (scratchpads[messageQueues[0].computer].showTypeII(messageQueues[0].getNextMsg())) {
				messageQueues[0].deleteAtIndex(0);
			}
		}
	}
}

var loop2MsgTimer = func() {
	if (messageQueues[1].getNextMsg() != nil) {
		if (!scratchpads[messageQueues[1].computer].showTypeIIMsg) {
			if (scratchpads[messageQueues[1].computer].showTypeII(messageQueues[1].getNextMsg())) {
				messageQueues[1].deleteAtIndex(0);
			}
		}
	}
}

var mcduMsgtimer1 = maketimer(1, loop1MsgTimer);
var mcduMsgtimer2 = maketimer(1, loop2MsgTimer);