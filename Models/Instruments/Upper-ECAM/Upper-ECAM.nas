
var canvas_upperECAM_iae_eis2 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_upperECAM_iae_eis2, canvas_upperECAM_base]};
		m.init(canvas_group, file);
		m.updateAFloor();
		m.updateFlx();
		return m;
	},
	getKeys: func() {
		return ["EPR1-needle","EPR1-thr","EPR1-ylim","EPR1","EPR1-decpnt","EPR1-decimal","EPR1-box","EPR1-scale","EPR1-scaletick","EPR1-scalenum","EPR1-XX","EPR1-XX2","EGT1-needle","EGT1","EGT1-scale","EGT1-box","EGT1-scale2","EGT1-scaletick","EGT1-XX",
		"N11-needle","N11-thr","N11-ylim","N11","N11-decpnt","N11-decimal","N11-scale","N11-scale2","N11-scaletick","N11-scalenum","N11-XX","N21","N21-decpnt","N21-decimal","N21-XX","FF1","FF1-XX","EPR2-needle","EPR2-thr","EPR2-ylim","EPR2","EPR2-decpnt",
		"EPR2-decimal","EPR2-box","EPR2-scale","EPR2-scaletick","EPR2-scalenum","EPR2-XX","EPR2-XX2","EGT2-needle","EGT2","EGT2-scale","EGT2-scale2","EGT2-box","EGT2-scaletick","EGT2-XX","N12-needle","N12-thr","N12-ylim","N12","N12-decpnt","N12-decimal",
		"N12-scale","N12-scale2","N12-scaletick","N12-scalenum","N12-XX","N22","N22-decpnt","N22-decimal","N22-XX","FF2","FF2-XX","FOB-LBS","FlapTxt","FlapDots","EPRLim-mode","EPRLim","EPRLim-decpnt","EPRLim-decimal","EPRLim-XX","EPRLim-XX2","REV1","REV1-box",
		"REV2","REV2-box","ECAM_Left","ECAML1","ECAML2","ECAML3","ECAML4","ECAML5","ECAML6","ECAML7","ECAML8", "ECAMR1", "ECAMR2", "ECAMR3", "ECAMR4", "ECAMR5", "ECAMR6", "ECAMR7", "ECAMR8", "ECAM_Right",
		"FFlow1-weight-unit", "FFlow2-weight-unit", "FOB-weight-unit","SlatAlphaLock","SlatIndicator","FlapIndicator","SlatLine","FlapLine","aFloor","FlxLimDegreesC","FlxLimTemp"];
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
		
		if (fadec.FADEC.Eng1.epr == 1) {
			obj["EPR1-scale"].setColor(0.8078,0.8039,0.8078);
			obj["EPR1"].show();
			obj["EPR1-decpnt"].show();
			obj["EPR1-decimal"].show();
			obj["EPR1-needle"].show();
			obj["EPR1-ylim"].show();
			obj["EPR1-scaletick"].show();
			obj["EPR1-scalenum"].show();
			obj["EPR1-box"].show();
			obj["EPR1-XX"].hide();
			obj["EPR1-XX2"].hide();
		} else {
			obj["EPR1-scale"].setColor(0.7333,0.3803,0);
			obj["EPR1"].hide();
			obj["EPR1-decpnt"].hide();
			obj["EPR1-decimal"].hide();
			obj["EPR1-needle"].hide();
			obj["EPR1-ylim"].hide();
			obj["EPR1-scaletick"].hide();
			obj["EPR1-scalenum"].hide();
			obj["EPR1-box"].hide();
			obj["EPR1-XX"].show();
			obj["EPR1-XX2"].show();
		}
		
		if (rev_1_act < 0.01 and fadec.FADEC.Eng1.epr == 1) {
			obj["EPR1-thr"].show();
		} else {
			obj["EPR1-thr"].hide();
		}
		
		if (fadec.FADEC.Eng2.epr == 1) {
			obj["EPR2-scale"].setColor(0.8078,0.8039,0.8078);
			obj["EPR2"].show();
			obj["EPR2-decpnt"].show();
			obj["EPR2-decimal"].show();
			obj["EPR2-needle"].show();
			obj["EPR2-ylim"].show();
			obj["EPR2-scaletick"].show();
			obj["EPR2-scalenum"].show();
			obj["EPR2-box"].show();
			obj["EPR2-XX"].hide();
			obj["EPR2-XX2"].hide();
		} else {
			obj["EPR2-scale"].setColor(0.7333,0.3803,0);
			obj["EPR2"].hide();
			obj["EPR2-decpnt"].hide();
			obj["EPR2-decimal"].hide();
			obj["EPR2-needle"].hide();
			obj["EPR2-ylim"].hide();
			obj["EPR2-scaletick"].hide();
			obj["EPR2-scalenum"].hide();
			obj["EPR2-box"].hide();
			obj["EPR2-XX"].show();
			obj["EPR2-XX2"].show();
		}
		
		if (rev_2_act < 0.01 and fadec.FADEC.Eng2.epr == 1) {
			obj["EPR2-thr"].show();
		} else {
			obj["EPR2-thr"].hide();
		}
		
		# EGT
		obj["EGT1"].setText(sprintf("%s", math.round(pts.Engines.Engine.egtActual[0].getValue())));
		obj["EGT2"].setText(sprintf("%s", math.round(pts.Engines.Engine.egtActual[1].getValue())));
		
		obj["EGT1-needle"].setRotation((EGT_1_cur + 90) * D2R);
		obj["EGT2-needle"].setRotation((EGT_2_cur + 90) * D2R);
		
		if (fadec.FADEC.Eng1.egt == 1) {
			obj["EGT1-scale"].setColor(0.8078,0.8039,0.8078);
			obj["EGT1-scale2"].setColor(1,0,0);
			obj["EGT1"].show();
			obj["EGT1-needle"].show();
			obj["EGT1-scaletick"].show();
			obj["EGT1-box"].show();
			obj["EGT1-XX"].hide();
		} else {
			obj["EGT1-scale"].setColor(0.7333,0.3803,0);
			obj["EGT1-scale2"].setColor(0.7333,0.3803,0);
			obj["EGT1"].hide();
			obj["EGT1-needle"].hide();
			obj["EGT1-scaletick"].hide();
			obj["EGT1-box"].hide();
			obj["EGT1-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.egt == 1) {
			obj["EGT2-scale"].setColor(0.8078,0.8039,0.8078);
			obj["EGT2-scale2"].setColor(1,0,0);
			obj["EGT2"].show();
			obj["EGT2-needle"].show();
			obj["EGT2-scaletick"].show();
			obj["EGT2-box"].show();
			obj["EGT2-XX"].hide();
		} else {
			obj["EGT2-scale"].setColor(0.7333,0.3803,0);
			obj["EGT2-scale2"].setColor(0.7333,0.3803,0);
			obj["EGT2"].hide();
			obj["EGT2-needle"].hide();
			obj["EGT2-scaletick"].hide();
			obj["EGT2-box"].hide();
			obj["EGT2-XX"].show();
		}
		
		# N1
		obj["N11"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n1Actual[0].getValue() + 0.05)));
		obj["N11-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n1Actual[0].getValue() + 0.05, 1))));
		
		obj["N12"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n1Actual[1].getValue() + 0.05)));
		obj["N12-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n1Actual[1].getValue() + 0.05, 1))));
		
		obj["N11-needle"].setRotation((N1_1_cur + 90) * D2R);
		obj["N11-thr"].setRotation((N1_thr_1.getValue() + 90) * D2R);
		obj["N11-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		obj["N12-needle"].setRotation((N1_2_cur + 90) * D2R);
		obj["N12-thr"].setRotation((N1_thr_2.getValue() + 90) * D2R);
		obj["N12-ylim"].setRotation((N1_lim_cur + 90) * D2R);
		
		if (fadec.FADEC.Eng1.n1 == 1) {
			obj["N11-scale"].setColor(0.8078,0.8039,0.8078);
			obj["N11-scale2"].setColor(1,0,0);
			obj["N11"].show();
			obj["N11-decimal"].show();
			obj["N11-decpnt"].show();
			obj["N11-needle"].show();
			obj["N11-scaletick"].show();
			obj["N11-scalenum"].show();
			obj["N11-XX"].hide();
		} else {
			obj["N11-scale"].setColor(0.7333,0.3803,0);
			obj["N11-scale2"].setColor(0.7333,0.3803,0);
			obj["N11"].hide();
			obj["N11-decimal"].hide();
			obj["N11-decpnt"].hide();
			obj["N11-needle"].hide();
			obj["N11-scaletick"].hide();
			obj["N11-scalenum"].hide();
			obj["N11-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.n1 == 1) {
			obj["N12-scale"].setColor(0.8078,0.8039,0.8078);
			obj["N12-scale2"].setColor(1,0,0);
			obj["N12"].show();
			obj["N12-decimal"].show();
			obj["N12-decpnt"].show();
			obj["N12-needle"].show();
			obj["N12-scaletick"].show();
			obj["N12-scalenum"].show();
			obj["N12-XX"].hide();
		} else {
			obj["N12-scale"].setColor(0.7333,0.3803,0);
			obj["N12-scale2"].setColor(0.7333,0.3803,0);
			obj["N12"].hide();
			obj["N12-decimal"].hide();
			obj["N12-decpnt"].hide();
			obj["N12-needle"].hide();
			obj["N12-scaletick"].hide();
			obj["N12-scalenum"].hide();
			obj["N12-XX"].show();
		}
		
		if (fadec.FADEC.Eng1.n1 == 1 and fadec.Fadec.n1Mode[0].getValue()) {
			obj["N11-thr"].show();
			obj["N11-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
		} else {
			obj["N11-thr"].hide();
			obj["N11-ylim"].hide();
		}
		
		if (fadec.FADEC.Eng2.n1 == 1 and fadec.Fadec.n1Mode[1].getValue()) {
			obj["N12-thr"].show();
			obj["N12-ylim"].hide(); # Keep it hidden, since N1 mode limit calculation is not done yet
		} else {
			obj["N12-thr"].hide();
			obj["N12-ylim"].hide();
		}
		
		# N2
		obj["N21"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n2Actual[0].getValue() + 0.05)));
		obj["N21-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n2Actual[0].getValue() + 0.05, 1))));
		obj["N22"].setText(sprintf("%s", math.floor(pts.Engines.Engine.n2Actual[1].getValue() + 0.05)));
		obj["N22-decimal"].setText(sprintf("%s", int(10 * math.mod(pts.Engines.Engine.n2Actual[1].getValue() + 0.05, 1))));
		
		if (fadec.FADEC.Eng1.n2 == 1) {
			obj["N21"].show();
			obj["N21-decimal"].show();
			obj["N21-decpnt"].show();
			obj["N21-XX"].hide();
		} else {
			obj["N21"].hide();
			obj["N21-decimal"].hide();
			obj["N21-decpnt"].hide();
			obj["N21-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.n2 == 1) {
			obj["N22"].show();
			obj["N22-decimal"].show();
			obj["N22-decpnt"].show();
			obj["N22-XX"].hide();
		} else {
			obj["N22"].hide();
			obj["N22-decimal"].hide();
			obj["N22-decpnt"].hide();
			obj["N22-XX"].show();
		}
		
		# FF
		fuel1 = pts.Engines.Engine.fuelFlow[0].getValue();
		fuel2 = pts.Engines.Engine.fuelFlow[1].getValue();
		if (acconfig_weight_kgs.getValue()) {
			obj["FF1"].setText(sprintf("%s", math.round(fuel1 * LBS2KGS, 10)));
			obj["FF2"].setText(sprintf("%s", math.round(fuel2 * LBS2KGS, 10)));
			obj["FFlow1-weight-unit"].setText("KG/H");
			obj["FFlow2-weight-unit"].setText("KG/H");
		} else {
			obj["FF1"].setText(sprintf("%s", math.round(fuel1, 10)));
			obj["FF2"].setText(sprintf("%s", math.round(fuel2, 10)));
			obj["FFlow1-weight-unit"].setText("LBS/H");
			obj["FFlow2-weight-unit"].setText("LBS/H");
		}
		
		if (fadec.FADEC.Eng1.ff == 1) {
			obj["FF1"].show();
			obj["FF1-XX"].hide();
		} else {
			obj["FF1"].hide();
			obj["FF1-XX"].show();
		}
		
		if (fadec.FADEC.Eng2.ff == 1) {
			obj["FF2"].show();
			obj["FF2-XX"].hide();
		} else {
			obj["FF2"].hide();
			obj["FF2-XX"].show();
		}
		
		# EPR Limit
		thrLimit = thr_limit.getValue();
		eprLimit = epr_limit.getValue();
		
		obj["EPRLim-mode"].setText(sprintf("%s", thrLimit));
		obj["EPRLim"].setText(sprintf("%1.0f", math.floor(eprLimit)));
		obj["EPRLim-decimal"].setText(sprintf("%03d", (eprLimit - int(eprLimit)) * 1000));
		
		fadecPower1 = fadecpower_1.getValue();
		fadecPower2 = fadecpower_2.getValue();
		fadecPowerStart = fadecpowerup.getValue();
		
		if (fadecPower1 or fadecPower2 or fadecPowerStart) {
			obj["EPRLim-mode"].show();
			obj["EPRLim-XX"].hide();
			obj["EPRLim-XX2"].hide();
		} else {
			obj["EPRLim-mode"].hide();
			obj["EPRLim-XX"].show();
			obj["EPRLim-XX2"].show();
		}
		
		if ((fadecPower1 or fadecPower2 or fadecPowerStart) and thrLimit != "MREV") {
			obj["EPRLim"].show();
			obj["EPRLim-decpnt"].show();
			obj["EPRLim-decimal"].show();
		} else {
			obj["EPRLim"].hide();
			obj["EPRLim-decpnt"].hide();
			obj["EPRLim-decimal"].hide();
		}
		
		me.updateBase(notification);
	},
};
