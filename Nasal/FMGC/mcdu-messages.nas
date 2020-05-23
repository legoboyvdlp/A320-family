# A3XX FMGC MCDU Message Generator and Control
# Copyright (c) 2020 Josh Davidson (Octal450) and Jonathan Redpath (legoboyvdlp)

var TypeIMessage = {
	new: func(msgText) {
		var msg = { parents: [TypeIMessage] };
		msg.msgText = msgText;
		msg.colour = "w";
		return msg;
	},
};

var TypeIIMessage = {
	new: func(msgText, colour = "w", isInhibit = 0) {
		var msg = { parents: [TypeIIMessage] };
		msg.msgText = msgText;
		msg.colour = colour;
		msg.inhibitable = isInhibit;
		return msg;
	},
};

var MessageQueueController = {
	new: func() {
		var msgC = { parents: [MessageQueueController] };
		return msgC;
	},
	messages: std.Vector.new(), # show left to right
	# first in first out
	addNewMsg: func(msg) {
		if (me.messages.size() < 5) {
			if (!me.messages.contains(msg)) {
				me.messages.append(x);
			}
		}
	},
	getNextMsg: func() {
		if (me.messages.size() >= 1) {
			me.messages.pop(0);
		}
	},
	clearQueue: func() {
		me.messages.clear();
	},
};

var scratchpadController = {
	new: func(mcdu) {
		var sp = { parents: [scratchpadController] };
		sp.scratchpad = "";
		sp.scratchpadSave = "";
		sp.scratchpadColour = "w";
		sp.scratchpadShowTypeIMsg = 0;
		sp.scratchpadShowTypeIIMsg = 0;
		sp.mcdu = mcdu;
		return sp;
	},
	
	addChar: func(character) {
		if (size(me.scratchpad) >= 22) {
			return;
		}
		
		# any shown type ii is hidden
		if (me.scratchpadShowTypeIIMsg) {
			me.clearTypeIIMsg();
		}
		
		# any shown type i is hidden
		if (me.scratchpadShowTypeIMsg) {
			me.clearTypeIMsg();
		}
		
		me.scratchpad = me.scratchpad ~ character;
		me.update();
	},
	showTypeI: func(msg) {
		# any shown type ii is hidden
		if (me.scratchpadShowTypeIIMsg) {
			me.clearTypeIIMsg();
		}
		
		me.scratchpadShowTypeIMsg = 1;
		# save any data entered
		me.scratchpadSave = me.scratchpad;
		me.scratchpad = msg;
		me.update();
	},
	showTypeII: func(msg) {
		# only show if scratchpad empty
		if (me.scratchpad = "") {
			me.scratchpadShowTypeIIMsg = 1;
			me.scratchpad = msg;
		}
		me.update();
	},
	clearTypeI: func() {
		me.scratchpad = me.scratchpadSave;
		me.scratchpadSave = nil;
		me.scratchpadShowTypeIMsg = 0;
		me.update();
	},
	clearTypeII: func() {
		me.scratchpadShowTypeIIMsg = 0;
		me.empty();
		me.update();
	},
	empty: func() {
		me.scratchpad = "";
		me.update();
	},
	clear: func() {
		if (me.showTypeIMsg) {
			me.clearTypeIMsg();
		} elsif (!me.showTypeIIMsg) {
			me.scratchpad = left(me.scratchpad, size(me.scratchpad) - 1);
		} else {
			me.clearTypeIIMsg();
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
		TypeIMessage.new("AWY/WPT MISMATCH"),TypeIMessage.new("DEST/ALTN MISMATCH"),TypeIMessage.new("DIR TO IN PROGRESS"),
		TypeIMessage.new("ENTRY OUT OF RANGE"),TypeIMessage.new("FORMAT ERROR"),TypeIMessage.new("INSERT/ERASE TMPY FIRST"),
		TypeIMessage.new("LIST OF 20 IN USE"),TypeIMessage.new("PILOT ELEMENT RETAINED"),TypeIMessage.new("NOT ALLOWED"),
		TypeIMessage.new("NOT IN DATA BASE"),TypeIMessage.new("ONLY SPD ENTRY ALLOWED"),TypeIMessage.new("PLEASE WAIT"),
		TypeIMessage.new("REVISION IN PROGRESS"),TypeIMessage.new("TMPY F-PLN EXISTS"),TypeIMessage.new("SELECT DESIRED SYSTEM"),
		TypeIMessage.new("SELECT HDG/TRK FIRST"),TypeIMessage.new("USING COST INDEX N"),
	]),
	typeIIMessages: std.Vector.new([
	
	]),

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