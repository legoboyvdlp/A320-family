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
	new: func(msgText, colour, isInhibit: 0,) {
		var msg = { parents: [TypeIIMessage] };
		msg.msgText = msgText;
		msg.colour = colour;
		msg.inhibitable: isInhibit;
		return msg;
	},
};

var MessageQueueController = {
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
	scratchpad: "",
	scratchpadSave: "",
	scratchpadShowTypeIMsg: 0,
	scratchpadShowTypeIIMsg: 0,
	
	addCharToScratchpad: func(character) {
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
	},
	showTypeIMsg: func(msg) {
		# any shown type ii is hidden
		if (me.scratchpadShowTypeIIMsg) {
			me.clearTypeIIMsg();
		}
		
		me.scratchpadShowTypeIMsg = 1;
		# save any data entered
		me.scratchpadSave = me.scratchpad;
		me.scratchpad = msg;
	},
	showTypeIIMsg: func(msg) {
		# only show if scratchpad empty
		if (me.scratchpad = "") {
			me.scratchpadShowTypeIIMsg = 1;
			me.scratchpad = msg;
		}
	},
	clearTypeIMsg: func() {
		me.scratchpad = me.scratchpadSave;
		me.scratchpadSave = nil;
		me.scratchpadShowTypeIMsg = 0;
	},
	clearTypeIIMsg: func() {
		me.scratchpadShowTypeIIMsg = 0;
		me.empty();
	},
	empty: func() {
		me.scratchpad = "";
	},
	clear: func() {
		if (me.showTypeIMsg) {
			me.clearTypeIMsg();
		} elsif (!me.showTypeIIMsg) {
			me.scratchpad = left(me.scratchpad, size(me.scratchpad) - 1);
		} else {
			me.clearTypeIIMsg();
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
		return me.getMsgByText(text, me.typeIMessages);
	},
	getTypeIIMsgByText: func(text) {
		return me.getMsgByText(text, me.typeIIMessages);
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