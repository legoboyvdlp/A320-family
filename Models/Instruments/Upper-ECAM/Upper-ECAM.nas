
var canvas_upperECAM_iae_eis2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_upperECAM_iae_eis2, canvas_upperECAM_base]};
		m.init(canvas_group, file);
		m.updateAFloor();
		m.updateFlx();
		return m;
	},
	
	update: func(notification) {
		N1_1_cur = N1_1.getValue();
		N1_2_cur = N1_2.getValue();
		N1_1_act = pts.Engines.Engine.n1Actual[0].getValue();
		N1_2_act = pts.Engines.Engine.n1Actual[1].getValue();
		N1_lim_cur = N1_lim.getValue();
		EPR_1_cur = EPR_1.getValue();
		EPR_2_cur = EPR_2.getValue();
		EPR_1_act = pts.Engines.Engine.eprActual[0].getValue();
		EPR_2_act = pts.Engines.Engine.eprActual[1].getValue();
		EPR_lim_cur = EPR_lim.getValue();
		EPR_thr_1_act = EPR_thr_1.getValue();
		EPR_thr_2_act = EPR_thr_2.getValue();
		rev_1_act = pts.Engines.Engine.reverser[0].getValue();
		rev_2_act = pts.Engines.Engine.reverser[1].getValue();
		EGT_1_cur = EGT_1.getValue();
		EGT_2_cur = EGT_2.getValue();
		n2cur_1 = pts.Engines.Engine.n2Actual[0].getValue();
		n2cur_2 = pts.Engines.Engine.n2Actual[1].getValue();
		
		# EPR
		obj["EPR1"].setText(sprintf("%1.0f", math.floor(EPR_1_act)));
		obj["EPR1-decimal"].setText(sprintf("%03d", (EPR_1_act - int(EPR_1_act)) * 1000));
		obj["EPR2"].setText(sprintf("%1.0f", math.floor(EPR_2_act)));
		obj["EPR2-decimal"].setText(sprintf("%03d", (EPR_2_act - int(EPR_2_act)) * 1000));
		
		obj["EPR1-needle"].setRotation((EPR_1_cur + 90) * D2R);
		obj["EPR1-thr"].setRotation((EPR_thr_1_act + 90) * D2R);
		obj["EPR1-ylim"].setRotation((EPR_lim_cur + 90) * D2R);
		obj["EPR2-needle"].setRotation((EPR_2_cur + 90) * D2R);
		obj["EPR2-thr"].setRotation((EPR_thr_2_act + 90) * D2R);
		obj["EPR2-ylim"].setRotation((EPR_lim_cur + 90) * D2R);
		
		me.updateBase(notification);
	},
};
