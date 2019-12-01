# A3XX Electronic Centralised Aircraft Monitoring System

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# messages stored in vectors

# Lights: 0 = red, 1 = yellow, 9 = none
# Sounds: 0 = master warn, 1 = chime, 9 = other

# Left E/WD

var warnings				  = std.Vector.new([
	var stall                 = warning.new(msg: "", aural: 2),
	var flap_not_zero         = warning.new(msg: "F/CTL FLAP LVR NOT ZERO",   colour: "r", aural: 0, light: 0),
	
	var overspeed          = warning.new(msg: "OVER SPEED",                colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var overspeedVMO       = warning.new(msg: "-VMO/MMO.......350 /.82",   colour: "r"),
	var overspeedGear      = warning.new(msg: "-VLE...........280 /.67",   colour: "r"),
	var overspeedFlap      = warning.new(msg: "-VFE................XXX",   colour: "r"),
	
	# DUAL ENG FAIL
	var dualFail              = warning.new(msg: "ENG DUAL FAILURE",          colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var dualFailModeSel       = warning.new(msg: " -ENG MODE SEL.......IGN",  colour: "c"),
	var dualFailLevers        = warning.new(msg: " -THR LEVERS........IDLE",  colour: "c"),
	var dualFailRelightSPD    = warning.new(msg: " OPTIMUM RELIGHT SPD.280",  colour: "c"),
	var dualFailRelightSPDCFM = warning.new(msg: " OPTIMUM RELIGHT SPD.300",  colour: "c"),
	var dualFailElec          = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	var dualFailRadio         = warning.new(msg: " -VHF1/ATC1..........USE",  colour: "c"),
	var dualFailFAC           = warning.new(msg: " -FAC 1......OFF THEN ON",  colour: "c"),
	var dualFailRelight       = warning.new(msg: "•IF NO RELIGHT AFTER 30S",  colour: "w", hasSubmsg: 1),
	var dualFailMasters       = warning.new(msg: " -ENG MASTERS.OFF 30S/ON",  colour: "c"),
	var dualFailSuccess       = warning.new(msg: "   •IF UNSUCCESSFUL :   ",  colour: "w", hasSubmsg: 1),
	var dualFailAPU           = warning.new(msg: " -APU (IF AVAIL)...START",  colour: "c"),
	var dualFailAPUwing       = warning.new(msg: " -WING ANTI ICE......OFF",  colour: "c"),
	var dualFailAPUbleed      = warning.new(msg: " -APU BLEED...........ON",  colour: "c"),
	var dualFailMastersAPU    = warning.new(msg: " -ENG MASTERS.OFF 30S/ON",  colour: "c"),
	var dualFailSPDGD         = warning.new(msg: " OPTIMUM SPEED.....G DOT",  colour: "c"),
	var dualFailAPPR          = warning.new(msg: "    •EARLY IN APPR :    ",  colour: "w", hasSubmsg: 1),
	var dualFailcabin         = warning.new(msg: " -CAB SECURE.......ORDER",  colour: "c"),
	var dualFailrudd          = warning.new(msg: " -USE RUDDER WITH CARE  ",  colour: "c"),
	var dualFailflap          = warning.new(msg: " -FOR LDG.....USE FLAP 3",  colour: "c"),
	var dualFail5000          = warning.new(msg: "   •AT 5000 FT AGL :    ",  colour: "w", hasSubmsg: 1),
	var dualFailgear          = warning.new(msg: " -L/G.........GRVTY EXTN",  colour: "c"),
	var dualFailfinalspeed    = warning.new(msg: " TARGET SPEED.....150 KT",  colour: "c"),
	var dualFailtouch         = warning.new(msg: "    •AT TOUCH DOWN :    ",  colour: "w", hasSubmsg: 1),
	var dualFailmasteroff     = warning.new(msg: " -ENG MASTERS........OFF",  colour: "c"),
	var dualFailapuoff        = warning.new(msg: " -APU MASTER SW......OFF",  colour: "c"),
	var dualFailevac          = warning.new(msg: " -EVAC..........INITIATE",  colour: "c"),
	var dualFailbatt          = warning.new(msg: " -BAT 1+2............OFF",  colour: "c"),
	
	# ENG 1 FIRE (flight)
	var eng1Fire              = warning.new(msg: "ENG 1 FIRE",                colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var eng1FireFllever       = warning.new(msg: " -THR LEVER 1.......IDLE",  colour: "c"),
	var eng1FireFlmaster      = warning.new(msg: " -ENG MASTER 1.......OFF",  colour: "c"),
	var eng1FireFlPB          = warning.new(msg: " -ENG 1 FIRE P/B....PUSH",  colour: "c"),
	var eng1FireFlAgent1Timer = warning.new(msg: " -AGENT 1 AFT 10 S.DISCH",  colour: "w"),
	var eng1FireFlAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng1FireFlATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng1FireFl30Sec       = warning.new(msg: "  •IF FIRE AFTER 30 S:",    colour: "w", hasSubmsg: 1),
	var eng1FireFlAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	
	# ENG 1 FIRE (ground)
	var eng1FireGnlever       = warning.new(msg: " -THR LEVERS........IDLE",  colour: "c"),
	var eng1FireGnstopped     = warning.new(msg: "  •WHEN A/C IS STOPPED:",   colour: "w", hasSubmsg: 1),
	var eng1FireGnparkbrk     = warning.new(msg: " -PARKING BRK.........ON",  colour: "c"),
	var eng1FireGnmaster      = warning.new(msg: " -ENG MASTER 1.......OFF",  colour: "c"),
	var eng1FireGnPB          = warning.new(msg: " -ENG 1 FIRE P/B....PUSH",  colour: "c"),
	var eng1FireGnAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng1FireGnAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	var eng1FireGnmaster2     = warning.new(msg: " -ENG MASTER 2.......OFF",  colour: "c"),
	var eng1FireGnATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng1FireGncrew        = warning.new(msg: " -CABIN CREW.......ALERT",  colour: "c"),
	var eng1FireGnevac        = warning.new(msg: "    •IF EVAC RQRD:",        colour: "w", hasSubmsg: 1),
	var eng1FireGnevacSw      = warning.new(msg: " -EVAC COMMAND........ON",  colour: "c"),
	var eng1FireGnevacApu     = warning.new(msg: " -APU MASTER SW......OFF",  colour: "c"),
	var eng1FireGnevacBat     = warning.new(msg: " -BAT 1+2............OFF",  colour: "c"),
	
	# ENG 2 FIRE (flight)
	var eng2Fire              = warning.new(msg: "ENG 2 FIRE",                colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var eng2FireFllever       = warning.new(msg: " -THR LEVER 2.......IDLE",  colour: "c"),
	var eng2FireFlmaster      = warning.new(msg: " -ENG MASTER 2.......OFF",  colour: "c"),
	var eng2FireFlPB          = warning.new(msg: " -ENG 2 FIRE P/B....PUSH",  colour: "c"),
	var eng2FireFlAgent1Timer = warning.new(msg: " -AGENT 1 AFT 10 S.DISCH",  colour: "w"),
	var eng2FireFlAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng2FireFlATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng2FireFl30Sec       = warning.new(msg: "  •IF FIRE AFTER 30 S:",    colour: "w", hasSubmsg: 1),
	var eng2FireFlAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	
	# ENG 2 FIRE (ground)
	var eng2FireGnlever       = warning.new(msg: " -THR LEVERS........IDLE",  colour: "c"),
	var eng2FireGnstopped     = warning.new(msg: "  •WHEN A/C IS STOPPED:",   colour: "w", hasSubmsg: 1),
	var eng2FireGnparkbrk     = warning.new(msg: " -PARKING BRK.........ON",  colour: "c"),
	var eng2FireGnmaster      = warning.new(msg: " -ENG MASTER 2.......OFF",  colour: "c"),
	var eng2FireGnPB          = warning.new(msg: " -ENG 2 FIRE P/B....PUSH",  colour: "c"),
	var eng2FireGnAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng2FireGnAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	var eng2FireGnmaster2     = warning.new(msg: " -ENG MASTER 1.......OFF",  colour: "c"),
	var eng2FireGnATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng2FireGncrew        = warning.new(msg: " -CABIN CREW.......ALERT",  colour: "c"),
	var eng2FireGnevac        = warning.new(msg: "    •IF EVAC RQRD:",        colour: "w", hasSubmsg: 1),
	var eng2FireGnevacSw      = warning.new(msg: " -EVAC COMMAND........ON",  colour: "c"),
	var eng2FireGnevacApu     = warning.new(msg: " -APU MASTER SW......OFF",  colour: "c"),
	var eng2FireGnevacBat     = warning.new(msg: " -BAT 1+2............OFF",  colour: "c"),
	
	# APU FIRE
	var apuFire               = warning.new(msg: "APU FIRE                ",  colour: "r", aural: 0, light: 0, hasSubmsg: 1, sdPage: "apu"),
	var apuFirePB             = warning.new(msg: " -APU FIRE P/B......PUSH",  colour: "c"),
	var apuFireAgentTimer     = warning.new(msg: " -AGENT AFT 10 S...DISCH",  colour: "c"),
	var apuFireAgent          = warning.new(msg: " -AGENT............DISCH",  colour: "c"),
	var apuFireMaster         = warning.new(msg: " -MASTER SW..........OFF",  colour: "c"),
	
	# Config
	var slats_config          = warning.new(msg: "CONFIG",                    colour: "r", aural: 0, light: 0),
	var slats_config_1        = warning.new(msg: "SLATS NOT IN T.O. CONFIG",  colour: "r", aural: 0, light: 0),
	var flaps_config          = warning.new(msg: "CONFIG",                    colour: "r", aural: 0, light: 0),
	var flaps_config_1        = warning.new(msg: "FLAPS NOT IN T.O. CONFIG",  colour: "r", aural: 0, light: 0),
	var spd_brk_config        = warning.new(msg: "CONFIG",                    colour: "r", aural: 0, light: 0),
	var spd_brk_config_1      = warning.new(msg: "SPD BRK NOT RETRACTED",     colour: "r", aural: 0, light: 0),
	var pitch_trim_config     = warning.new(msg: "CONFIG PITCH TRIM",         colour: "r", aural: 0, light: 0),
	var pitch_trim_config_1   = warning.new(msg: "   NOT IN T.O. RANGE",      colour: "r", aural: 0, light: 0),
	var rud_trim_config       = warning.new(msg: "CONFIG RUD TRIM",           colour: "r", aural: 0, light: 0),
	var rud_trim_config_1     = warning.new(msg: "   NOT IN T.O. RANGE",      colour: "r", aural: 0, light: 0),
	var park_brk_config       = warning.new(msg: "CONFIG PARK BRK ON",        colour: "r", aural: 0, light: 0),
	
	# Autopilot
	var ap_offw				  = warning.new(msg: "AUTO FLT AP OFF",			  colour: "r", light: 0),
	var athr_offw			  = warning.new(msg: "AUTO FLT A/THR OFF", 	      colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var athr_offw_1			  = warning.new(msg: "-THR LEVERS........MOVE",   colour: "c"),
	var athr_lock			  = warning.new(msg: "ENG THRUST LOCKED", 		  colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var athr_lock_1			  = warning.new(msg: "-THR LEVERS........MOVE",   colour: "c"),
	var athr_lim			  = warning.new(msg: "AUTO FLT A/THR LIMITED",    colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var athr_lim_1			  = warning.new(msg: "-THR LEVERS........MOVE",   colour: "c"),
	
	# Cargo smoke
	var cargoSmokeFwd         = warning.new(msg: "SMOKE FWD CARGO SMOKE",     colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var cargoSmokeFwdAgent    = warning.new(msg: "-AGENT............DISCH",   colour: "c"),
	var cargoSmokeAft         = warning.new(msg: "SMOKE AFT CARGO SMOKE",     colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var cargoSmokeAftAgent    = warning.new(msg: "-AGENT............DISCH",   colour: "c"),
	
	# ESS Bus on Bat
	var essBusOnBat           = warning.new(msg: "ELEC ESS BUSES ON BAT",     colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var essBusOnBatLGUplock   = warning.new(msg: "  •WHEN L/G UPLOCKED :",    colour: "w"),
	var essBusOnBatManOn      = warning.new(msg: "-EMER ELEC PWR...MAN ON",   colour: "c"),
	var essBusOnBatRetract    = warning.new(msg: " •IF L/G RETRACT FAULT:",   colour: "w"),
	var essBusOnBatMinSpeed   = warning.new(msg: "MIN RAT SPD......180 KT",   colour: "c"),
	var essBusOnBatLGCB       = warning.new(msg: "-LGCIU1 C/B (C09)..PULL",   colour: "c"),
	var essBusOnBatManOn2     = warning.new(msg: "-EMER ELEC PWR...MAN ON",   colour: "c"),
	
	# Emer Config
	var emerconfig            = warning.new(msg: "ELEC EMER CONFIG",          colour: "r", aural: 0, light: 0, hasSubmsg: 1),
	var emerconfigMinRat      = warning.new(msg: "MIN RAT SPD......140 KT",   colour: "c"),
	var emerconfigGen         = warning.new(msg: "-GEN 1+2....OFF THEN ON",   colour: "c"),
	var emerconfigGen2        = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var emerconfigBusTie      = warning.new(msg: "-BUS TIE............OFF",   colour: "c"),
	var emerconfigGen3        = warning.new(msg: "-GEN 1+2....OFF THEN ON",   colour: "c"),
	var emerconfigManOn       = warning.new(msg: "-EMER ELEC PWR...MAN ON",   colour: "c"),
	var emerconfigEngMode     = warning.new(msg: "-ENG MODE SEL.......IGN",   colour: "c"),
	var emerconfigRadio       = warning.new(msg: "-VHF1/ATC1..........USE",   colour: "c"),
	var emerconfigIcing       = warning.new(msg: "AVOID ICING CONDITIONS",    colour: "c"),
	var emerconfigFuelG       = warning.new(msg: "FUEL GRVTY FEED",           colour: "c"),
	var emerconfigFuelG2      = warning.new(msg: "PROC:GRVTY FUEL FEEDING",   colour: "c"),
	var emerconfigFAC         = warning.new(msg: "-FAC 1......OFF THEN ON",   colour: "c"),
	var emerconfigBusTie2     = warning.new(msg: "-BUS TIE...........AUTO",   colour: "c"),
	var emerconfigAPU         = warning.new(msg: "-APU (IF AVAIL)...START",   colour: "c"),
	var emerconfigVent        = warning.new(msg: "-BLOWER + EXTRACT..OVRD",   colour: "c"),
	var emerconfigAltn        = warning.new(msg: "F/CTL ALTN LAW",            colour: "a"),
	var emerconfigProt        = warning.new(msg: "     (PROT LOST)",          colour: "a"),
	var emerconfigMaxSpeed    = warning.new(msg: " MAX SPEED........320 KT",  colour: "c"),
	
	# DC EMER CONFIG
	var dcEmerconfig          = warning.new(msg: "ELEC DC EMER CONFIG",       colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var dcEmerconfigManOn     = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	
	# DC BUS 1 OR 2 FAULT
	var dcBus12Fault          = warning.new(msg: "ELEC DC BUS 1+2 FAULT",     colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var dcBus12FaultBlower    = warning.new(msg: " -BLOWER............OVRD",  colour: "c"),
	var dcBus12FaultExtract   = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	var dcBus12FaultBaroRef   = warning.new(msg: " -BARO REF.........CHECK",  colour: "c"),
	var dcBus12FaultIcing     = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var dcBus12FaultBrking    = warning.new(msg: " MAX BRK........1000 PSI",  colour: "c"),
	
	# AC ESS BUS FAULT
	var AcBusEssFault         = warning.new(msg: "ELEC AC ESS BUS FAULT",     colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var AcBusEssFaultFeed     = warning.new(msg: " -AC ESS FEED.......ALTN",  colour: "c"),
	var AcBusEssFaultAtc      = warning.new(msg: " -ATC..............SYS 2",  colour: "c"),
	
	# AC BUS 1 FAULT
	var AcBus1Fault           = warning.new(msg: "ELEC AC BUS 1 FAULT",       colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var AcBus1FaultBlower     = warning.new(msg: " -BLOWER............OVRD",  colour: "c"),
	
	# DC ESS BUS FAULT
	var DcEssBusFault         = warning.new(msg: "ELEC DC ESS BUS FAULT",     colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var DcEssBusFaultRadio    = warning.new(msg: " -VHF 2 OR 3.........USE",  colour: "c"),
	var DcEssBusFaultRadio2   = warning.new(msg: " -AUDIO SWTG......SELECT",  colour: "c"),
	var DcEssBusFaultBaro     = warning.new(msg: " -BARO REF.........CHECK",  colour: "c"),
	var DcEssBusFaultGPWS     = warning.new(msg: " -GPWS...............OFF",  colour: "c"),
	
	# AC BUS 2 FAULT
	var AcBus2Fault           = warning.new(msg: "ELEC AC BUS 2 FAULT",       colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var AcBus2FaultExtract    = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	
	# DC BUS 1 FAULT
	var dcBus1Fault           = warning.new(msg: "ELEC DC BUS 1 FAULT",       colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var dcBus1FaultBlower     = warning.new(msg: " -BLOWER............OVRD",  colour: "c"),
	var dcBus1FaultExtract    = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	
	# DC BUS 2 FAULT
	var dcBus2Fault           = warning.new(msg: "ELEC DC BUS 2 FAULT",       colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var dcBus2FaultAirData    = warning.new(msg: " -AIR DATA SWTG......F/O",  colour: "c"),
	var dcBus2FaultBaro       = warning.new(msg: " -BARO REF.........CHECK",  colour: "c"),
	
	# DC BAT BUS FAULT
	var dcBusBatFault         = warning.new(msg: "ELEC DC BAT BUS FAULT",     colour: "a", aural: 1, light: 1),
	
	# DC ESS BUS SHED
	var dcBusEssShed          = warning.new(msg: "ELEC DC ESS BUS SHED",      colour: "a", aural: 1, light: 1),
	var dcBusEssShedExtract   = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	var dcBusEssShedIcing     = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	
	# AC ESS BUS SHED
	var acBusEssShed          = warning.new(msg: "ELEC DC ESS BUS SHED",      colour: "a", aural: 1, light: 1),
	var acBusEssShedAtc       = warning.new(msg: " -ATC..............SYS 2",  colour: "c"),
	
	# TCAS FAULT
	var tcasFault             = warning.new(msg: "NAV TCAS FAULT",            colour: "a", aural: 1, light: 1),
	
	# FCU fault
	var fcuFault              = warning.new(msg: "AUTO FLT FCU 1+2 FAULT",    colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var fcuFaultBaro          = warning.new(msg: " -PFD BARO REF: STD ONLY",  colour: "c"),
	var fcuFault1             = warning.new(msg: "AUTO FLT FCU 1 FAULT",      colour: "a", hasSubmsg: 1),
	var fcuFault1Baro         = warning.new(msg: " -BARO REF.......X CHECK",  colour: "c"),
	var fcuFault2             = warning.new(msg: "AUTO FLT FCU 2 FAULT",      colour: "a", hasSubmsg: 1),
	var fcuFault2Baro         = warning.new(msg: " -BARO REF.......X CHECK",  colour: "c"),
	
	# APU shutdown
	var apuEmerShutdown       = warning.new(msg: "APU EMER SHUT DOWN",        colour: "a", aural: 1, light: 1, hasSubmsg: 1),
	var apuEmerShutdownMast   = warning.new(msg: " -MASTER SW..........OFF",  colour: "c"),

	# FIRE det fault
	var eng1FireDetFault      = warning.new(msg: "ENG 1 FIRE DET FAULT",      colour: "a", aural: 1, light: 1), 
	var eng1LoopAFault        = warning.new(msg: "ENG 1 FIRE LOOP A FAULT",   colour: "a"),
	var eng1LoopBFault        = warning.new(msg: "ENG 1 FIRE LOOP B FAULT",   colour: "a"),
	var eng2FireDetFault      = warning.new(msg: "ENG 2 FIRE DET FAULT",      colour: "a", aural: 1, light: 1),
	var eng2LoopAFault        = warning.new(msg: "ENG 2 FIRE LOOP A FAULT",   colour: "a"),
	var eng2LoopBFault        = warning.new(msg: "ENG 2 FIRE LOOP B FAULT",   colour: "a"),
	var apuFireDetFault       = warning.new(msg: "APU FIRE DET FAULT",        colour: "a", aural: 1, light: 1), 
	var apuLoopAFault         = warning.new(msg: "APU FIRE LOOP A FAULT",     colour: "a"),
	var apuLoopBFault         = warning.new(msg: "APU FIRE LOOP B FAULT",     colour: "a"),
	var crgFwdFireDetFault    = warning.new(msg: "FWD CRG DET FAULT",         colour: "a"), 
	var crgAftFireDetFault    = warning.new(msg: "AFT CRG DET FAULT",         colour: "a"), 
	# Recall
	var recallNormal          = warning.new(msg: "                    ", colour: "g", hasSubmsg: 1),
	var recallNormal1         = warning.new(msg: "                    ", colour: "g", hasSubmsg: 1),
	var recallNormal2         = warning.new(msg: "               NORMAL", colour: "g", hasSubmsg: 1),
]);

var configmemos               = std.Vector.new([
	var toMemoLine1           = warning.new(msg: "T.O AUTO BRK.....MAX",      colour: "c", isMemo: 1),
	var toMemoLine2           = warning.new(msg: "    SIGNS.........ON",      colour: "c", isMemo: 1),
	var toMemoLine3           = warning.new(msg: "    SPLRS........ARM",      colour: "c", isMemo: 1),
	var toMemoLine4           = warning.new(msg: "    FLAPS........T.O",      colour: "c", isMemo: 1),
	var toMemoLine5           = warning.new(msg: "    T.O CONFIG..TEST",      colour: "c", isMemo: 1),
	
	var ldgMemoLine1          = warning.new(msg: "LDG LDG GEAR......DN",      colour: "c", isMemo: 1),
	var ldgMemoLine2          = warning.new(msg: "    SIGNS.........ON",      colour: "c", isMemo: 1),
	var ldgMemoLine3          = warning.new(msg: "    SPLRS........ARM",      colour: "c", isMemo: 1),
	var ldgMemoLine4          = warning.new(msg: "    FLAPS.......FULL",      colour: "c", isMemo: 1),
]);

var leftmemos                 = std.Vector.new([
	var company_alert         = warning.new(msg: "COMPANY ALERT"        ), # Not yet implemented, buzzer sound
	var refuelg               = warning.new(msg: "REFUELG"              ),
	var irs_in_align          = warning.new(msg: "IRS IN ALIGN"         ), # Not yet implemented
	var gnd_splrs             = warning.new(msg: "GND SPLRS ARMED"      ),
	var seatbelts             = warning.new(msg: "SEAT BELTS"           ),
	var nosmoke               = warning.new(msg: "NO SMOKING"           ),
	var strobe_lt_off         = warning.new(msg: "STROBE LT OFF"        ),
	var outr_tk_fuel_xfrd     = warning.new(msg: "OUTR TK FUEL XFRD"    ),
	var fob_3T                = warning.new(msg: "FOB BELOW 3T"         ),
	var gpws_flap_mode_off    = warning.new(msg: "GPWS FLAP MODE OFF"   ),
	var atc_datalink_stby     = warning.new(msg: "ATC DATALINK STBY"    ), # Not yet implemented
	var company_datalink_stby = warning.new(msg: "COMPANY DATALINK STBY"),  # Not yet implemented
]);

# Right E/WD

var specialLines         = std.Vector.new([
	var to_inhibit       = memo.new(msg: "T.O. INHIBIT",  colour: "m"),
	var ldg_inhibit      = memo.new(msg: "LDG INHIBIT",   colour: "m"),
	var land_asap_r      = memo.new(msg: "LAND ASAP",     colour: "r"),
	var land_asap_a      = memo.new(msg: "LAND ASAP",     colour: "a"),
	var ap_off           = memo.new(msg: "AP OFF",        colour: "r"),
	var athr_off         = memo.new(msg: "A/THR OFF",     colour: "a")
]);

var secondaryFailures    = std.Vector.new([
	var secondary_bleed  = memo.new(msg: "•AIR BLEED",   colour: "a"), # Not yet implemented
	var secondary_press  = memo.new(msg: "•CAB PRESS",   colour: "a"), # Not yet implemented
	var secondary_vent   = memo.new(msg: "•AVNCS VENT",  colour: "a"), # Not yet implemented
	var secondary_elec   = memo.new(msg: "•ELEC",        colour: "a"), # Not yet implemented
	var secondary_hyd    = memo.new(msg: "•HYD",         colour: "a"), # Not yet implemented
	var secondary_fuel   = memo.new(msg: "•FUEL",        colour: "a"), # Not yet implemented
	var secondary_cond   = memo.new(msg: "•AIR COND",    colour: "a"), # Not yet implemented
	var secondary_brake  = memo.new(msg: "•BRAKES",      colour: "a"), # Not yet implemented
	var secondary_wheel  = memo.new(msg: "•WHEEL",       colour: "a"), # Not yet implemented
	var secondary_fctl   = memo.new(msg: "•F/CTL",       colour: "a")  # Not yet implemented
]);

var memos                = std.Vector.new([
	var spd_brk          = memo.new(msg: "SPEED BRK"   ),  
	var park_brk         = memo.new(msg: "PARK BRK"    ),
	var ptu              = memo.new(msg: "HYD PTU"     ),
	var rat              = memo.new(msg: "RAT OUT"     ),
	var emer_gen         = memo.new(msg: "EMER GEN"    ),
	var ram_air          = memo.new(msg: "RAM AIR ON"  ),
	var nw_strg_disc     = memo.new(msg: "NW STRG DISC"),
	var ignition         = memo.new(msg: "IGNITION"    ),
	var cabin_ready      = memo.new(msg: "CABIN READY" ), # Not yet implemented
	var pred_ws_off      = memo.new(msg: "PRED W/S OFF"), # Not yet implemented
	var terr_stby        = memo.new(msg: "TERR STBY"   ), # Not yet implemented
	var tcas_stby        = memo.new(msg: "TCAS STBY"   ), # Not yet implemented
	var acars_call       = memo.new(msg: "ACARS CALL"  ), # Not yet implemented
	var company_call     = memo.new(msg: "COMPANY CALL"), # Not yet implemented
	var satcom_alert     = memo.new(msg: "SATCOM ALERT"), # Not yet implemented
	var acars_msg        = memo.new(msg: "ACARS MSG"   ), # Not yet implemented
	var company_msg      = memo.new(msg: "COMPANY MSG" ), # Not yet implemented
	var eng_aice         = memo.new(msg: "ENG A.ICE"   ),
	var wing_aice        = memo.new(msg: "WING A.ICE"  ),
	var ice_not_det      = memo.new(msg: "ICE NOT DET" ), # Not yet implemented
	var hi_alt           = memo.new(msg: "HI ALT"      ), # Not yet implemented
	var apu_avail        = memo.new(msg: "APU AVAIL"   ),
	var apu_bleed        = memo.new(msg: "APU BLEED"   ),
	var ldg_lt           = memo.new(msg: "LDG LT"      ),
	var brk_fan          = memo.new(msg: "BRK FAN"     ), # Not yet implemented
	var audio3_xfrd      = memo.new(msg: "AUDIO 3 XFRD"), # Not yet implemented
	var switchg_pnl      = memo.new(msg: "SWITCHG PNL" ), # Not yet implemented
	var gpws_flap3       = memo.new(msg: "GPWS FLAP 3" ), 
	var hf_data_ovrd     = memo.new(msg: "HF DATA OVRD"), # Not yet implemented
	var hf_voice         = memo.new(msg: "HF VOICE"    ), # Not yet implemented
	var acars_stby       = memo.new(msg: "ACARS STBY"  ), # Not yet implemented
	var vhf3_voice       = memo.new(msg: "VHF3 VOICE"  ),
	var auto_brk_lo      = memo.new(msg: "AUTO BRK LO" ),
	var auto_brk_med     = memo.new(msg: "AUTO BRK MED"),
	var auto_brk_max     = memo.new(msg: "AUTO BRK MAX"),
	var auto_brk_off     = memo.new(msg: "AUTO BRK OFF"), # Not yet implemented
	var man_ldg_elev     = memo.new(msg: "MAN LDG ELEV"), # Not yet implemented
	var ctr_tk_feedg     = memo.new(msg: "CTR TK FEEDG"),
	var fuelx            = memo.new(msg: "FUEL X FEED" )
]);

var clearWarnings        = std.Vector.new();

# Status SD page
var statusLim            = std.Vector.new([
	var min_rat_spd      = status.new(msg: "MIN RAT SPD.....140 KT",     colour: "c"), # Not yet implemented
	var max_spd_gear     = status.new(msg: "MAX SPD........280/.67",     colour: "c"), # Not yet implemented
	var max_spd_rev      = status.new(msg: "MAX SPD........300/.78",     colour: "c"), # Not yet implemented
	var buffet_rev       = status.new(msg: "   •IF BUFFET :",            colour: "w"), # Not yet implemented
	var max_spd_rev_buf  = status.new(msg: "MAX SPD.............240",    colour: "c"), # Not yet implemented
	var max_spd_fctl     = status.new(msg: "MAX SPD........320/.77",     colour: "c"), # Not yet implemented
	var max_spd_fctl2    = status.new(msg: "MAX SPD.........300 KT",     colour: "c"), # Not yet implemented
	var max_spd_gr_door  = status.new(msg: "MAX SPD 250/.60",            colour: "c"), # Not yet implemented
	var max_alt_press    = status.new(msg: "MAX FL : 100/MEA",           colour: "c"), # Not yet implemented
	var gravity_fuel     = status.new(msg: "-PROC:GRAVTY FUEL FEEDING",  colour: "c"), # Not yet implemented
	var gear_kp_dn       = status.new(msg: "L/G............KEEP DOWN",   colour: "c"), # Not yet implemented
	var park_brk_only    = status.new(msg: "PARK BRK ONLY",              colour: "c"), # Not yet implemented
	var park_brk_only    = status.new(msg: "MAX BRK PR........1000PSI",  colour: "c"), # Not yet implemented
	var fuel_gravity     = status.new(msg: "FUEL GRAVTY FEED",           colour: "c"), # Not yet implemented
	var fctl_manvr       = status.new(msg: "MANOEUVER WITH CARE",        colour: "c"), # Not yet implemented
	var fctl_spdbrk_care = status.new(msg: "USE SPD BRK WITH CARE",      colour: "c"), # Not yet implemented
	var fctl_spdbrk_dont = status.new(msg: "SPD BRK......DO NOT USE",    colour: "c"), # Not yet implemented
	var fctl_rud_care    = status.new(msg: "RUD WITH CARE ABV 160KT",    colour: "c"), # Not yet implemented
	var eng_thr_changes  = status.new(msg: "AVOID RAPID THR CHANGES",    colour: "c"), # Not yet implemented
	var avoid_neg_g_fac  = status.new(msg: "AVOID NEGATIVE G FACTOR",    colour: "c"), # Not yet implemented
	var avoid_icing      = status.new(msg: "AVOID ICING CONDITONS",      colour: "c"), # Not yet implemented
	var severe_icing     = status.new(msg: " IF A/C ICING SEVERE :",     colour: "w"), # Not yet implemented, a319 only
	var severe_icing_2   = status.new(msg: "MIN SPD ALPHA PROT",         colour: "c"), # Not yet implemented, a319 only
	var avoid_thr_chg    = status.new(msg: "AVOID THR CHANGES",          colour: "c"), # Not yet implemented, iae only
	var avoid_thr_chg_2  = status.new(msg: "AVOID RAPID THR CHANGES",    colour: "c"), # Not yet implemented, iae only
	var avoid_adv_cond   = status.new(msg: "AVOID ADVERSE CONDITIONS",   colour: "c"), # Not yet implemented, iae only
	var atc_com_voice    = status.new(msg: "ATC COM VOICE ONLY",         colour: "c") # Not yet implemented, iae only
]);

var statusApprProc       = std.Vector.new([
	var dual_hyd_b_g     = status.new(msg: "APPR PROC DUAL HYD LO PR",              colour: "r"), # Not yet implemented
	var dual_hyd_b_g_2   = status.new(msg: "   •IF BLUE OVHT OUT:",                 colour: "w"), # Not yet implemented
	var dual_hyd_b_g_3   = status.new(msg: "-BLUE ELEC PUMP.....AUTO",              colour: "c"), # Not yet implemented
	var dual_hyd_b_g_4   = status.new(msg: "   •IF GREEN OVHT OUT:",                colour: "w"), # Not yet implemented
	var dual_hyd_b_g_5   = status.new(msg: "-GREEN ENG 1 PUMP.....ON",              colour: "c"), # Not yet implemented
	var dual_hyd_b_g_6   = status.new(msg: "-PTU................AUTO",              colour: "c"), # Not yet implemented
	
	var dual_hyd_b_y     = status.new(msg: "APPR PROC DUAL HYD LO PR",              colour: "r"), # Not yet implemented
	var dual_hyd_b_y_2   = status.new(msg: "   •IF BLUE OVHT OUT:",                 colour: "w"), # Not yet implemented
	var dual_hyd_b_y_3   = status.new(msg: "-BLUE ELEC PUMP.....AUTO",              colour: "c"), # Not yet implemented
	var dual_hyd_b_y_4   = status.new(msg: "   •IF YELLOW OVHT OUT:",               colour: "w"), # Not yet implemented
	var dual_hyd_b_y_5   = status.new(msg: "-YELLOW ENG 2 PUMP....ON",              colour: "c"), # Not yet implemented
	var dual_hyd_b_y_6   = status.new(msg: "-PTU................AUTO",              colour: "c"), # Not yet implemented
	
	var dual_hyd_g_y     = status.new(msg: "APPR PROC DUAL HYD LO PR",              colour: "r"), # Not yet implemented
	var dual_hyd_g_y_2   = status.new(msg: "   •IF GREEN OVHT OUT:",                colour: "w"), # Not yet implemented
	var dual_hyd_b_y_3   = status.new(msg: "-GREEN ENG 1 PUMP.....ON",              colour: "c"), # Not yet implemented
	var dual_hyd_g_y_4   = status.new(msg: "   •IF YELLOW OVHT OUT:",               colour: "w"), # Not yet implemented
	var dual_hyd_g_y_5   = status.new(msg: "-YELLOW ENG 2 PUMP....ON",              colour: "c"), # Not yet implemented
	var dual_hyd_g_y_6   = status.new(msg: "-PTU................AUTO",              colour: "c"), # Not yet implemented
	
	var single_hyd_b     = status.new(msg: "APPR PROC HYD LO PR",                   colour: "a"), # Not yet implemented
	var single_hyd_b_2   = status.new(msg: "   •IF BLUE OVHT OUT:",                 colour: "w"), # Not yet implemented
	var single_hyd_b_3   = status.new(msg: "-BLUE ELEC PUMP.....AUTO",              colour: "c"), # Not yet implemented
	
	var single_hyd_g     = status.new(msg: "APPR PROC HYD LO PR",                   colour: "a"), # Not yet implemented
	var single_hyd_g_2   = status.new(msg: "   •IF GREEN OVHT OUT:",                colour: "w"), # Not yet implemented
	var single_hyd_g_3   = status.new(msg: "-GREEN ENG 1 PUMP.....ON",              colour: "c"), # Not yet implemented
	var single_hyd_g_4   = status.new(msg: "-PTU................AUTO",              colour: "c"), # Not yet implemented
	
	var single_hyd_y     = status.new(msg: "APPR PROC HYD LO PR",                   colour: "a"), # Not yet implemented
	var single_hyd_y_2   = status.new(msg: "   •IF YELLOW OVHT OUT:",               colour: "w"), # Not yet implemented
	var single_hyd_y_3   = status.new(msg: "-YELLOW ENG 1 PUMP....ON",              colour: "c"), # Not yet implemented
	var single_hyd_y_4   = status.new(msg: "-PTU................AUTO",              colour: "c"), # Not yet implemented
	
	var avionics_smk     = status.new(msg: "APPR PROC:",                            colour: "w"), # Not yet implemented
	var avionics_smk_2   = status.new(msg: "   •BEFORE L/G EXTENSION :",            colour: "w"), # Not yet implemented
	var avionics_smk_2   = status.new(msg: "-GEN 2...............ON",               colour: "c"), # Not yet implemented
	var avionics_smk_4   = status.new(msg: "-EMER ELEC GEN1 LINE ON",               colour: "c"), # Not yet implemented
	
	var ths_stuck        = status.new(msg: "APPR PROC:",                            colour: "w"), # Not yet implemented
	var ths_stuck_2      = status.new(msg: "-FOR LDG.....USE FLAP 3",               colour: "c"), # Not yet implemented
	var ths_stuck_3      = status.new(msg: "-GPWS LDG FLAP 3.....ON",               colour: "c"), # Not yet implemented
	var ths_stuck_4      = status.new(msg: " •IF MAN TRIM NOT AVAIL:",              colour: "w"), # Not yet implemented
	var ths_stuck_5      = status.new(msg: " •WHEN CONF3 AND VAPP  :",              colour: "w"), # Not yet implemented
	var ths_stuck_6      = status.new(msg: "-L/G.................DN",               colour: "c"), # Not yet implemented
	
	var flap_stuck       = status.new(msg: "APPR PROC:",                            colour: "w"), # Not yet implemented
	var flap_stuck_2     = status.new(msg: "-FOR LDG.....USE FLAP 3",               colour: "c"), # Not yet implemented
	var flap_stuck_3     = status.new(msg: "-FLAPS...KEEP CONF FULL",               colour: "c"), # Not yet implemented
	var flap_stuck_4     = status.new(msg: "-GPWS FLAP MODE.....OFF",               colour: "c"), # Not yet implemented
	var flap_stuck_5     = status.new(msg: "-GPWS LDG FLAP 3.....ON",               colour: "c"), # Not yet implemented
	
	var slat_stuck       = status.new(msg: "APPR PROC:",                            colour: "w"), # Not yet implemented
	var slat_stuck_2     = status.new(msg: "-FOR LDG.....USE FLAP 1",               colour: "c"), # Not yet implemented
	var slat_stuck_3     = status.new(msg: "-FOR LDG.....USE FLAP 3",               colour: "c"), # Not yet implemented
	var slat_stuck_4     = status.new(msg: "-CTR TK PUMPS.......OFF",               colour: "c"), # Not yet implemented
	var slat_stuck_5     = status.new(msg: "-GPWS LDG FLAP 3.....ON",               colour: "c"), # Not yet implemented
	var slat_stuck_6     = status.new(msg: "-GPWS FLAP MODE.....OFF",               colour: "c"), # Not yet implemented

	var fctl_proc        = status.new(msg: "APPR PROC:",                            colour: "w"), # Not yet implemented
	var fctl_proc_2      = status.new(msg: " •IF BUFFET:",                          colour: "w"), # Not yet implemented
	var fctl_proc_3      = status.new(msg: "-FOR LDG.....USE FLAP 3",               colour: "c"), # Not yet implemented
	var fctl_proc_4      = status.new(msg: "-GPWS LDG FLAP 3.....ON",               colour: "c"), # Not yet implemented
	var fctl_proc_5      = status.new(msg: "-AT 1000FT AGL:L/G...DN",               colour: "c"), # Not yet implemented
	
	var rev_unlc_proc    = status.new(msg: "APPR PROC:",                            colour: "w"), # Not yet implemented
	var rev_unlc_proc_2  = status.new(msg: " •IF BUFFET:",                          colour: "w"), # Not yet implemented
	var rev_unlc_proc_3  = status.new(msg: "-FOR LDG.....USE FLAP 3",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_4  = status.new(msg: "-APPR SPD : VREF + 55KT",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_5  = status.new(msg: "-APPR SPD : VREF + 60KT",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_6  = status.new(msg: "-RUD TRIM.......5 DEG R",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_7  = status.new(msg: "-RUD TRIM.......5 DEG L",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_8  = status.new(msg: "-ATHR...............OFF",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_9  = status.new(msg: "-GPWS FLAP MODE.....OFF",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_10 = status.new(msg: " •WHEN LDG ASSURED:",                   colour: "w"), # Not yet implemented
	var rev_unlc_proc_11 = status.new(msg: "-L/G...............DOWN",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_12 = status.new(msg: " •AT 800FT AGL:",                       colour: "w"), # Not yet implemented
	var rev_unlc_proc_13 = status.new(msg: "-TARGET SPD : VREF+40KT",               colour: "c"), # Not yet implemented
	var rev_unlc_proc_14 = status.new(msg: "-TARGET SPD : VREF+45KT",               colour: "c"), # Not yet implemented
	
	var thr_lvr_flt      = status.new(msg: "APPR PROC THR LEVER",                   colour: "a"), # Not yet implemented
	var thr_lvr_flt_2    = status.new(msg: "-AUTOLAND...........USE",               colour: "c"), # Not yet implemented
	var thr_lvr_flt_3    = status.new(msg: " •IF AUTOLAND NOT USED:",               colour: "w"), # Not yet implemented
	var thr_lvr_flt_4    = status.new(msg: "   •AT 500FT AGL :",                    colour: "w"), # Not yet implemented
	var thr_lvr_flt_5    = status.new(msg: "-ENG MASTER 1.......OFF",               colour: "c"), # Not yet implemented
	var thr_lvr_flt_6    = status.new(msg: "-ENG MASTER 2.......OFF",               colour: "c"), # Not yet implemented
	
	var fuel_ctl_flt     = status.new(msg: "APPR PROC FUEL CTL FAULT",              colour: "a"), # Not yet implemented
	var fuel_ctl_flt_2   = status.new(msg: "REV 1........DO NOT USE",               colour: "w"), # Not yet implemented
	var fuel_ctl_flt_3   = status.new(msg: "REV 2........DO NOT USE",               colour: "w"), # Not yet implemented
	var fuel_ctl_flt_4   = status.new(msg: " •AFTER TOUCHDOWN:",                    colour: "w"), # Not yet implemented
	var fuel_ctl_flt_5   = status.new(msg: "-ENG MASTER 1.......OFF",               colour: "c"), # Not yet implemented
	var fuel_ctl_flt_6   = status.new(msg: "-ENG MASTER 2.......OFF",               colour: "c")  # Not yet implemented
]);

var statusProc           = std.Vector.new();
var statusInfo           = std.Vector.new();
var statusCancelled      = std.Vector.new();
var statusInop           = std.Vector.new();
var statusMaintenance    = std.Vector.new();

# hack thrust lock message:
var msgSave = athr_lock.msg;