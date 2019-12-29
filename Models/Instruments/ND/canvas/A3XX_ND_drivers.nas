# A3XX ND Canvas
# Joshua Davidson (Octal450)
# Based on work by artix

# Copyright (c) 2019 Joshua Davidson (Octal450)

var A3XXRouteDriver = {
	new: func(){
		var m = {
			parents: [A3XXRouteDriver],
		};
		m.init();
		return m;
	},
	init: func(){
		me.update();
	},
	update: func(){
		me.flightplan = fmgc.fp[2];
	},
	getNumberOfFlightPlans: func(){1},
	getFlightPlanType: func(fpNum){"current"},
	getFlightPlan: func(fpNum){me.flightplan},
	getPlanSize: func(fpNum){me.flightplan.getPlanSize()},
	getWP: func(fpNum, idx){me.flightplan.getWP(idx)},
	getPlanModeWP: func(plan_wp_idx){me.flightplan.getWP(plan_wp_idx)},
	hasDiscontinuity: func(fpNum, wptID){0},
	triggerSignal: func(signal){
		setprop(me.signalPath(signal),1);
		setprop(me.signalPath(signal),0);
	},
	signalPath: func(signal){
		"autopilot/route-manager/signals/rd-"~ signal;
	},
	getListeners: func(){[
		me.signalPath("fp-added"),
		me.signalPath("fp-removed")
	]},
	shouldUpdate: func 1
};

var MultiA3XXRouteDriver = {
	parents: [A3XXRouteDriver],
	new: func(){
		var m = {
			parents: [MultiA3XXRouteDriver],
			_flightplans: [],
			currentFlightPlan: 0
		};
		m.init();
		return m;
	},
	addFlightPlan: func(type, plan){
		append(me._flightplans, {
			type: type,
			flightplan: plan
		});
	},
	removeFlightPlanAtIndex: func(idx){
		var sz = size(me._flightplans);
		if(idx < sz){
			if(sz == 1)
				me._flightplans = [];
			elsif(sz == 2 and idx == 0)
				me._flightplans = [me._flightplans[1]];
			elsif(sz == 2 and idx == 1)
				pop(me._flightplans);
			else {
				var subv_l = subvec(me._flightplans, 0, idx);
				var subv_r = subvec(me._flightplans, idx + 1);
				me._flightplans = subv_l ~ subv_r;
			}
		}
		me.triggerSignal("fp-added");
	},
	removeFlightPlanOfType: func(type){
		var new_vec = [];
		foreach(var fp; me._flightplans){
			if(fp["type"] != type)
				append(new_vec, fp);
		}
		me._flightplans = new_vec;
		me.triggerSignal("fp-removed");
	},
	getNumberOfFlightPlans: func(){
		size(me._flightplans);
	},
	getFlightPlanType: func(fpNum){
		if(fpNum >= size(me._flightplans)) return nil;
		var fp = me._flightplans[fpNum];
		return fp.type;
	},
	getFlightPlan: func(fpNum){
		if(fpNum >= size(me._flightplans)) return nil;
		return me._flightplans[fpNum];
	},
	getPlanSize: func(fpNum){
		if(fpNum >= size(me._flightplans)) return 0;
		return me._flightplans[fpNum].getPlanSize();
	},
	getWP: func(fpNum, idx){
		if(fpNum >= size(me._flightplans)) return nil;
		var fp = me._flightplans[fpNum].getPlanSize();
		return fp.getWP(idx);
	},
	getPlanModeWP: func(idx){
		if(me.currentFlightPlan >= size(me._flightplans)) return nil;
		var fp = me._flightplans[me.currentFlightPlan];
		return fp.getWP(idx);
	},
	triggerSignal: func(signal){
		setprop(me.signalPath(signal), 1);
		setprop(me.signalPath(signal), 0);
	},
	signalPath: func(signal){
		"autopilot/route-manager/signals/rd-"~ signal;
	},
	getListeners: func(){[
		me.getSignal("fp-added"),
		me.getSignal("fp-removed")
	]}
};
