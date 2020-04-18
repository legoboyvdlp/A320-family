# A3XX ND Canvas
# Joshua Davidson (Octal450)
# Based on work by artix

# Copyright (c) 2020 Josh Davidson (Octal450)

canvas.RouteDriver = {
    new: func(){
        var m = {
            parents: [canvas.RouteDriver],
        };
        m.init();
        return m;
    },
    init: func(){
        me.update();
    },
    update: func(){
        me.flightplan = flightplan();
    },
    getNumberOfFlightPlans: func(){1},
    getFlightPlanType: func(fpNum){"active"},
    getFlightPlan: func(fpNum){me.flightplan},
    getPlanSize: func(fpNum){me.flightplan.getPlanSize()},
    getWP: func(fpNum, idx){me.flightplan.getWP(idx)},
    getListeners: func(){[]},
    getPlanModeWP: func(plan_wp_idx){me.flightplan.getWP(plan_wp_idx)},
    hasDiscontinuity: func(fpNum, wpt){0},
    getHoldPattern: func(fpNum, wpt){nil},
    getHoldPatterns: func(fpNum){[]},
    shouldUpdate: func 1,
    shouldDisplayWP: func(fpNum, idx) 1,
    getCurrentWPIdx: func(fpNum) getprop("autopilot/route-manager/current-wp"),
    getTimeConstraint: func (fpNum, wp_idx) {nil}
};

canvas.MultiRouteDriver = {
    parents: [canvas.RouteDriver],
    new: func(){
        var m = {
            parents: [MultiRouteDriver],
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
        var fp = me._flightplans[fpNum];
        return fp.getWP(idx);
    },
    getPlanModeWP: func(idx){
        if(me.currentFlightPlan >= size(me._flightplans)) return nil;
        var fp = me._flightplans[me.currentFlightPlan];
        return fp.getWP(idx);
    },
    triggerSignal: func(signal){
        setprop(me.signalPath(signal));
    },
    signalPath: func(signal){
        "autopilot/route-manager/signals/rd-"~ signal;
    },
    getListeners: func(){[
        me.getSignal("fp-added"),
        me.getSignal("fp-removed")
    ]},
    getCurrentWPIdx: func(fpNum) {
        var fp = me.getFlightPlan(fpNum);
        var wp = fp.getWP();
        if (wp == nil) return -1;
        return wp.index;
    }
};
