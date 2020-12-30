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

var message_arg_types = [
    "ARG_HEADING",
    "ARG_FL_ALT",
    "ARG_SPEED",
    "ARG_NAVPOS",
    "ARG_ROUTE",
    "ARG_XPDR",
    "ARG_CALLSIGN",
    "ARG_FREQ",
];

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

#-- do not add "s" to r_opts, it is added automatically --
var uplink_messages = {
    "ADVU-9":  { txt: "SQUAWK $1", args: ["ARG_XPDR"], r_opts: ["w","u"] }, 
    "ADVU-15": { txt: "SQUAWK IDENT", args: [], r_opts: ["w","u"] }, 
    "COMU-1":  { txt: "CONTACT $1 $2", args: ["ARG_CALLSIGN", "ARG_FREQ"], r_opts: ["w","u"] },
    "LATU-16": { txt: "FLY HEADING $1", args: ["ARG_HEADING"], r_opts: ["w","u"] },
    "LVLU-5": { txt: "MAINTAIN $1", args: ["ARG_FL_ALT"], r_opts: ["w","u"] },
    "LVLU-6": { txt: "CLIMB TO $1", args: ["ARG_FL_ALT"], r_opts: ["w","u"] },
    "LVLU-9": { txt: "DESCENT TO $1", args: ["ARG_FL_ALT"], r_opts: ["w","u"] },
    #"SPDU-4":  { txt: "MAINTAIN $1", args: ["ARG_SPEED"], r_opts: ["w","u"] },
    #"SPDU-5":  { txt: "MAINTAIN PRESENT SPEED", args: [], r_opts: ["w","u"] },
    "SPDU-9":  { txt: "INCREASE SPEED TO $1", args: ["ARG_SPEED"], r_opts: ["w","u"] },
    "SPDU-11": { txt: "REDUCE SPEED TO $1", args: ["ARG_SPEED"], r_opts: ["w","u"] },
    "SPDU-13": { txt: "RESUME NORMAL SPEED", args: [], r_opts: ["w","u"] },
    "RSPU-1": { txt: "UNABLE", args: [], r_opts: [] }, 
    "RSPU-2": { txt: "STANDBY", args: [], r_opts: [] }, 
    "RSPU-4": { txt: "ROGER", args: [], r_opts: [] }, 
    "RSPU-5": { txt: "AFFIRM", args: [], r_opts: [] }, 
    "RSPU-6": { txt: "NEGATIVE", args: [], r_opts: [] },
    "RTEU-2": { txt: "PROCEED DIRECT TO $1", args: ["ARG_NAVPOS"], r_opts: ["w","u"] },
    "RTEU-7": { txt: "CLEARED $1", args: ["ARG_ROUTE"], r_opts: ["w","u"] },
    #"RTEU-11":  { txt: "AT $1 HOLD INBOUND TRACK $2 $3 TURNS $4 LEGS", args: ["ARG_NAVPOS", "ARG_HEADING", "ARG_DIRECTION", "ARG_LEGTYPE"], r_opts: ["w","u"] },
    "TXTU-1":  { txt: "$1", args: ["ARG_TEXT"], r_opts: ["r"] },
    "TXTU-4":  { txt: "$1", args: ["ARG_TEXT"], r_opts: ["w","u"] },
    "TXTU-5":  { txt: "$1", args: ["ARG_TEXT"], r_opts: ["a","n"] },
};

var downlink_messages = {
    "COMD-1": { txt: "REQUEST VOICE CONTACT $1", args: ["ARG_FREQ"], r_opts: ["y"] }, 
    "LVLD-1": { txt: "REQUEST LEVEL $1", args: ["ARG_FL_ALT"], r_opts: ["y"] },
    "RSPD-1": { txt: "WILCO", args: [], r_opts: [] }, 
    "RSPD-2": { txt: "UNABLE", args: [], r_opts: [] }, 
    "RSPD-3": { txt: "STANDBY", args: [], r_opts: [] }, 
    "RSPD-4": { txt: "ROGER", args: [], r_opts: [] }, 
    "RSPD-5": { txt: "AFFIRM", args: [], r_opts: [] }, 
    "RSPD-6": { txt: "NEGATIVE", args: [], r_opts: [] },    
    "RTED-1": { txt: "REQUEST DIRECT TO $1", args: ["ARG_NAVPOS"], r_opts: ["y"] },
    "RTED-3": { txt: "REQUEST CLEARANCE $1", args: ["ARG_ROUTE"], r_opts: ["y"] },
    "RTED-6": { txt: "REQUEST HEADING $1", args: ["ARG_HEADING"], r_opts: ["y"] },
    "SPDD-1": { txt: "REQUEST SPEED $1", args: ["ARG_SPEED"], r_opts: ["y"] },
    "TXTD-1": { txt: "$1", args: ["ARG_TEXT"], r_opts: ["y"] },
};

#
# TODO:
# add message buffer for old messages
# support multi part messages
#
var CPDLCMessageHandler = {

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
    parse: func(message) {
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
                    logprint(DEV_ALERT, "CPDLC arg count mismatch ("~me.mid~") "~
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
        return me.parse(me.pMessage.getValue());
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
