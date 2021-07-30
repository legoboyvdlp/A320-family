# cpdlc.nas --- CPDLC library
# Copyright (C) 2020  Henning Stahlke
#
# This file is part of FlightGear.
#
# FlightGear is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# FlightGear is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FlightGear.  If not, see <http://www.gnu.org/licenses/>.
#
# Author:   Henning Stahlke
# Created:  2020-11-14
#
#--------------------------------------------------------------------------
# Note: this library is work in progress. Once it is stable, it should be 
# added to FGDATA  
#--------------------------------------------------------------------------

#print(caller(0)[2]);

#--------------------------------------------------------------------------
# fgcommands 
# cpdlc-connect
# cpdlc-send
# cpdlc-next-message
# cpdlc-disconnect
#--------------------------------------------------------------------------
# Example:
# var tx = "/network/cpdlc/input/message";
# fgcommand("cpdlc-connect", props.Node.new( {atc: "EDDHgnd"} ));
# fgcommand("cpdlc-send", props.Node.new( {message: "TXTD-1 Hello"} ));
# fgcommand("cpdlc-send", props.Node.new( {property: tx} ));
# fgcommand("cpdlc-disconnect");
#--------------------------------------------------------------------------

var ARG_FL_ALT = 1;
var ARG_SPEED = 2;
var ARG_NAVPOS = 3;
var ARG_ROUTE = 4;
var ARG_XPDR = 5;
var ARG_CALLSIGN = 6;
var ARG_FREQ = 7;
var ARG_TIME = 8;
var ARG_DIRECTION  = 9;
var ARG_DEGREES = 10;
var ARG_ATIS_CODE = 11;
var ARG_DEVIATION_TYPE = 12;
var ARG_ENDURANCE = 13; #remaining fuel as time in seconds
var ARG_LEGTYPE = 14;
var ARG_TEXT = 15;
var ARG_INTEGER = 16;


#keys according to tables in ICAO doc 4444
var responses = {
    # W/U in Doc 4444
    w: {id: "RSPD-1", txt: "WILCO"},    
    u: {id: "RSPD-2", txt: "UNABLE"},   
    # A/N in Doc 4444
    a: {id: "RSPD-5", txt: "AFFIRM"},
    n: {id: "RSPD-6", txt: "NEGATIVE"},

    s: {id: "RSPD-3", txt: "STANDBY"},  
    r: {id: "RSPD-4", txt: "ROGER"},
    # need clarification
    # single Y in Doc 4444 means any?
};

#-- messages from ATC to aircraft --
# do not add "s" to r_opts, it is added automatically 
var uplink_messages = {
    "RTEU-2": { txt: "PROCEED DIRECT TO $1", args: [ARG_NAVPOS], r_opts: ["w","u"] },
    "RTEU-3": { txt: "AT TIME $1 PROCEED DIRECT TO $2", args: [ARG_TIME, ARG_NAVPOS], r_opts: ["w","u"] },
    "RTEU-4": { txt: "AT $1 PROCEED DIRECT TO $2", args: [ARG_NAVPOS, ARG_NAVPOS], r_opts: ["w","u"] },
    "RTEU-6": { txt: "CLEARED TO $1 VIA $2", args: [ARG_NAVPOS, ARG_ROUTE], r_opts: ["w","u"] },
    "RTEU-7": { txt: "CLEARED $1", args: [ARG_ROUTE], r_opts: ["w","u"] },
    "RTEU-11": { txt: "AT $1 HOLD INBOUND TRACK $2 $3 TURNS $4 LEGS", args: [ARG_NAVPOS, ARG_DEGREES, ARG_DIRECTION, ARG_LEGTYPE], r_opts: ["w","u"] },
    "RTEU-12": { txt: "AT $1 HOLD AS PUBLISHED", args: [ARG_NAVPOS], r_opts: ["w","u"] },
    "RTEU-13": { txt: "EXPECT FURTHER CLEARANCE AT $1", args: [ARG_TIME], r_opts: ["w","u"] },
    "RTEU-16": { txt: "REQUEST POSITION REPORT", args: [], r_opts: ["w","u"] },
    "RTEU-17": { txt: "ADVISE ETA $1", args: [ARG_NAVPOS], r_opts: ["w","u"] },

    "LATU-9": { txt: "RESUME OWN NAVIGATION", args: [], r_opts: ["w","u"] },
    "LATU-11": { txt: "TURN $1 HEADING $2", args: [ARG_DIRECTION, ARG_DEGREES], r_opts: ["w","u"] },
    "LATU-12": { txt: "TURN $1 GROUND TRACK $2", args: [ARG_DIRECTION, ARG_DEGREES], r_opts: ["w","u"] },
    "LATU-14": { txt: "CONTINUE PRESENT HEADING", args: [], r_opts: ["w","u"] },
    "LATU-16": { txt: "FLY HEADING $1", args: [ARG_DEGREES], r_opts: ["w","u"] },
    "LATU-19": { txt: "REPORT PASSING $1", args: [ARG_NAVPOS], r_opts: ["w","u"] },

    "LVLU-5": { txt: "MAINTAIN $1", args: [ARG_FL_ALT], r_opts: ["w","u"] },
    "LVLU-6": { txt: "CLIMB TO $1", args: [ARG_FL_ALT], r_opts: ["w","u"] },
    "LVLU-7": { txt: "AT TIME $1 CLIMB TO $2", args: [ARG_TIME, ARG_FL_ALT], r_opts: ["w","u"] },
    "LVLU-8": { txt: "AT $1 CLIMB TO $2", args: [ARG_NAVPOS, ARG_FL_ALT], r_opts: ["w","u"] },
    "LVLU-9": { txt: "DESCENT TO $1", args: [ARG_FL_ALT], r_opts: ["w","u"] },
    "LVLU-10": { txt: "AT TIME $1 DESCENT TO $2", args: [ARG_TIME, ARG_FL_ALT], r_opts: ["w","u"] },
    "LVLU-11": { txt: "AT $1 DESCENT TO $2", args: [ARG_NAVPOS, ARG_FL_ALT], r_opts: ["w","u"] },

    "CSTU-1": { txt: "CROSS $1 AT $2", args: [ARG_NAVPOS, ARG_FL_ALT], r_opts: ["w","u"] },
    "CSTU-2": { txt: "CROSS $1 AT OR ABOVE $2", args: [ARG_NAVPOS, ARG_FL_ALT], r_opts: ["w","u"] },
    "CSTU-3": { txt: "CROSS $1 AT OR BELOW $2", args: [ARG_NAVPOS, ARG_FL_ALT], r_opts: ["w","u"] },
    "CSTU-4": { txt: "CROSS $1 AT TIME $2", args: [ARG_NAVPOS, ARG_TIME], r_opts: ["w","u"] },
    "CSTU-5": { txt: "CROSS $1 BEFORE TIME $2", args: [ARG_NAVPOS, ARG_TIME], r_opts: ["w","u"] },
    "CSTU-6": { txt: "CROSS $1 AFTER TIME $2", args: [ARG_NAVPOS, ARG_TIME], r_opts: ["w","u"] },
    "CSTU-7": { txt: "CROSS $1 BETWEEN TIME $2 AND TIME $3", args: [ARG_NAVPOS, ARG_TIME, ARG_TIME], r_opts: ["w","u"] },

    "SPDU-4":  { txt: "MAINTAIN $1", args: [ARG_SPEED], r_opts: ["w","u"] },
    "SPDU-5":  { txt: "MAINTAIN PRESENT SPEED", args: [], r_opts: ["w","u"] },
    "SPDU-9":  { txt: "INCREASE SPEED TO $1", args: [ARG_SPEED], r_opts: ["w","u"] },
    "SPDU-11": { txt: "REDUCE SPEED TO $1", args: [ARG_SPEED], r_opts: ["w","u"] },
    "SPDU-13": { txt: "RESUME NORMAL SPEED", args: [], r_opts: ["w","u"] },

    "ADVU-2":  { txt: "SERVICE TERMINATED", args: [], r_opts: ["w","u"] }, 
    "ADVU-3":  { txt: "IDENTIFIED $1", args: [], r_opts: ["w","u"] }, 
    "ADVU-4":  { txt: "IDENTIFICATION LOST", args: [], r_opts: ["w","u"] }, 
    "ADVU-5":  { txt: "ATIS $1", args: [ARG_ATIS_CODE], r_opts: ["w","u"] }, 
    "ADVU-9":  { txt: "SQUAWK $1", args: [ARG_XPDR], r_opts: ["w","u"] }, 
    "ADVU-15": { txt: "SQUAWK IDENT", args: [], r_opts: ["w","u"] }, 
    "ADVU-19":  { txt: "$1 DEVIATION DETECTED. VERIFY AND ADVISE", args: [ARG_DEVIATION_TYPE], r_opts: ["w","u"] }, 

    "COMU-1":  { txt: "CONTACT $1 $2", args: [ARG_CALLSIGN, ARG_FREQ], r_opts: ["w","u"] },
    "COMU-2":  { txt: "AT $1 CONTACT $2 $3", args: [ARG_NAVPOS, ARG_CALLSIGN, ARG_FREQ], r_opts: ["w","u"] },
    "COMU-5":  { txt: "MONITOR $1 $2", args: [ARG_CALLSIGN, ARG_FREQ], r_opts: ["w","u"] },
    "COMU-9":  { txt: "CURRENT ATC UNIT $1", args: [ARG_CALLSIGN], r_opts: [] },

    "EMGU-1": { txt: "REPORT ENDURANCE AND POB", args: [], r_opts: ["y"] }, 

    "RSPU-1": { txt: "UNABLE", args: [], r_opts: [] }, 
    "RSPU-2": { txt: "STANDBY", args: [], r_opts: [] }, 
    "RSPU-4": { txt: "ROGER", args: [], r_opts: [] }, 
    "RSPU-5": { txt: "AFFIRM", args: [], r_opts: [] }, 
    "RSPU-6": { txt: "NEGATIVE", args: [], r_opts: [] },
    
    "TXTU-1":  { txt: "$1", args: [ARG_TEXT], r_opts: ["r"] },
    "TXTU-4":  { txt: "$1", args: [ARG_TEXT], r_opts: ["w","u"] },
    "TXTU-5":  { txt: "$1", args: [ARG_TEXT], r_opts: ["a","n"] },
};

#-- messages from aircraft to ATC --
var downlink_messages = {
    "RTED-1": { txt: "REQUEST DIRECT TO $1", args: [ARG_NAVPOS], r_opts: ["y"] },
    "RTED-3": { txt: "REQUEST CLEARANCE $1", args: [ARG_ROUTE], r_opts: ["y"] },
    "RTED-5": { txt: "POSITION REPORT $1", args: [ARG_NAVPOS], r_opts: ["y"] },
    "RTED-6": { txt: "REQUEST HEADING $1", args: [ARG_DEGREES], r_opts: ["y"] },
    "RTED-7": { txt: "REQUEST GROUND TRACK $1", args: [ARG_DEGREES], r_opts: ["y"] },
    "RTED-8": { txt: "WHEN CAN WE EXPECT BACK ON ROUTE", args: [], r_opts: ["y"] },
    "RTED-10": { txt: "ETA $1 TIME $2", args: [ARG_NAVPOS, ARG_TIME], r_opts: ["n"] },

    "LATD-3": { txt: "CLEAR OF WEATHER", args: [], r_opts: ["n"] },
    "LATD-4": { txt: "BACK ON ROUTE", args: [], r_opts: ["n"] },
    "LATD-8": { txt: "PASSING $1", args: [ARG_NAVPOS], r_opts: ["n"] },

    "LVLD-1": { txt: "REQUEST LEVEL $1", args: [ARG_FL_ALT], r_opts: ["y"] },
    "LVLD-6": { txt: "WHEN CAN WE EXPECT LOWER LEVEL", args: [], r_opts: ["y"] },
    "LVLD-7": { txt: "WHEN CAN WE EXPECT HIGHER LEVEL", args: [], r_opts: ["y"] },
    "LVLD-8": { txt: "LEAVING LEVEL $1", args: [ARG_FL_ALT], r_opts: ["n"] },
    "LVLD-9": { txt: "MAINTAINING LEVEL $1", args: [ARG_FL_ALT], r_opts: ["n"] },

    "SPDD-1": { txt: "REQUEST SPEED $1", args: [ARG_SPEED], r_opts: ["y"] },

    "RSPD-1": { txt: "WILCO", args: [], r_opts: [] }, 
    "RSPD-2": { txt: "UNABLE", args: [], r_opts: [] }, 
    "RSPD-3": { txt: "STANDBY", args: [], r_opts: [] }, 
    "RSPD-4": { txt: "ROGER", args: [], r_opts: [] }, 
    "RSPD-5": { txt: "AFFIRM", args: [], r_opts: [] }, 
    "RSPD-6": { txt: "NEGATIVE", args: [], r_opts: [] },    
    
    "COMD-1": { txt: "REQUEST VOICE CONTACT $1", args: [ARG_FREQ], r_opts: ["y"] }, 
    "EMGD-1": { txt: "PAN PAN PAN", args: [], r_opts: ["y"] }, 
    "EMGD-2": { txt: "MAYDAY MAYDAY MAYDAY", args: [], r_opts: ["y"] }, 
    "EMGD-3": { txt: "$1 ENDURANCE AND $2 POB", args: [ARG_ENDURANCE, ARG_INTEGER], r_opts: ["y"] }, 
    "EMGD-4": { txt: "CANCEL EMERGENCY", args: [], r_opts: ["y"] }, 

    "TXTD-1": { txt: "$1", args: [ARG_TEXT], r_opts: ["y"] },
};

#
# TODO:
# add message buffer for old messages
# support multi part messages
#
var CPDLCMessageHandler = {
    _msg_separator: "|",

    new: func(prop = "/network/cpdlc/rx/message") {
        var obj = { 
            parents: [me], 
            mid: "",
            mtxt: "",
            margs: [],
            r_opts: [],
            valid: 0,
            pMessage: props.getNode(prop, 1),
        };
        return obj;
    },

    # validate incoming message 
    # returns 'decoded' message 
    parseSingleMessage: func(message) {
        me.margs = split(" ", message);
        me.mid =  me.margs[0];
        # basic validation: 4th char is "U" (for uplink) followed by "-"
        if (size(me.mid) >= 5 and chr(me.mid[3]) == "U" and chr(me.mid[4]) == "-") {
            if (contains(uplink_messages, me.mid)) {            
                var descriptor = uplink_messages[me.mid];
                me.mtxt = descriptor.txt;
                me.r_opts = descriptor.r_opts;
                #always add standby as reply option (should not be given in the message definitions!)
                append(me.r_opts, "s");
                # next assumes a constant number of args per message id
                if (size(me.margs)-1 != size(descriptor.args)) {
                    print(DEV_ALERT, "CPDLC arg count mismatch ("~me.mid~") "~
                        "have "~(size(me.margs)-1)~" expecting "~size(descriptor.args));
                }
                # replace $i with args
                for (var i=1; i <= size(descriptor.args); i += 1) {
                    me.mtxt = string.replace(me.mtxt, "$"~i, me.margs[i]);
                }
                me.valid = 1;
            } else {
                #unknown message id
                me.mtxt = "[unknown id]"~message;
                me.r_opts = [];
                me.valid = 0;
            }
        }
        elsif (size(message)) {
            me.mtxt = "[raw]"~message;
        }
        else {
            me.mtxt = "";
        }
        return me.mtxt;
    },

    getMessage: func() {
        var raw_msg = split(me._msg_separator, me.pMessage.getValue());
        var friendly_msg = "";
        foreach (var part; raw_msg) {
            friendly_msg ~= me.parseSingleMessage(part) ~ me._msg_separator;
        }
        friendly_msg = left(friendly_msg, size(friendly_msg)-size(me._msg_separator));
        return friendly_msg;
    },

    getMessageId: func() {
        return me.mid;
    },

    getReplyOptions: func() {
        return me.r_opts;
    },

    getReplyOptionByIndex: func(i) {
        if (int(i) != nil and i < size(me.r_opts)) {
            return me.r_opts[i];
        }
        else return -1;
    },

    reply: func(r) {
        if (!me.valid) return;
        if (vecindex(me.r_opts, r)) {
            return responses[r];
        }
    },
};
