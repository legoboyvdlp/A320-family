# A3XX Electronic Centralised Aircraft Monitoring System

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# messages stored in vectors

# Lights: 0 = red, 1 = yellow, 9 = none
# Sounds: 0 = master warn, 1 = chime, 9 = other

# Left E/WD

var warnings				  = std.Vector.new([
	var stall                 = warning.new(msg: "", aural: 2),
	var flap_not_zero         = warning.new(msg: "F/CTL FLAP LVR NOT ZERO",   colour: "r", aural: 0, light: 0, isMainMsg: 1),
	
	var overspeed             = warning.new(msg: "OVER SPEED",                colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var overspeedVMO          = warning.new(msg: "-VMO/MMO.......350 /.82",   colour: "r"),
	var overspeedGear         = warning.new(msg: "-VLE...........280 /.67",   colour: "r"),
	var overspeedFlap         = warning.new(msg: "-VFE................XXX",   colour: "r"),
	
	var allEngFail            = warning.new(msg: "ENG ALL ENGINES FAILURE",   colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var allEngFailElec        = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	var allEngFailSPD1        = warning.new(msg: " OPT RELIGHT SPD.260/.77",  colour: "c"),
	var allEngFailSPD2        = warning.new(msg: " OPT RELIGHT SPD.270/.77",  colour: "c"),
	var allEngFailSPD3        = warning.new(msg: " OPT RELIGHT SPD.280/.77",  colour: "c"),
	var allEngFailSPD4        = warning.new(msg: " OPT RELIGHT SPD.300/.77",  colour: "c"),
	var allEngFailAPU         = warning.new(msg: " -APU..............START",  colour: "c"),
	var allEngFailLevers      = warning.new(msg: " -THR LEVERS........IDLE",  colour: "c"),
	var allEngFailFAC         = warning.new(msg: " -FAC 1......OFF THEN ON",  colour: "c"),
	var allEngFailGlide       = warning.new(msg: " GLDG DIST: 2NM/1000FT",    colour: "c"),
	var allEngFailDiversion   = warning.new(msg: " -DIVERSION.....INITIATE",  colour: "c"),
	var allEngFailProc        = warning.new(msg: " -ALL ENG FAIL PROC.APPLY", colour: "c"),
	
	# ENG 1 THR LEVER ABV IDLE
	var eng1ThrLvrAbvIdle     = warning.new(msg: "ENG 1 THR LEVER ABV IDLE", colour: "r", aural: 3, light: 0, isMainMsg: 1),
	var eng1ThrLvrAbvIdle2    = warning.new(msg: " -THR LEVER 1.......IDLE", colour: "c"),
	
	# ENG 2 THR LEVER ABV IDLE
	var eng2ThrLvrAbvIdle     = warning.new(msg: "ENG 2 THR LEVER ABV IDLE", colour: "r", aural: 3, light: 0, isMainMsg: 1),
	var eng2ThrLvrAbvIdle2    = warning.new(msg: " -THR LEVER 2.......IDLE", colour: "c"),
	
	# ENG 1 FIRE (flight)
	var eng1Fire              = warning.new(msg: "ENG 1 FIRE",                colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var eng1FireFllever       = warning.new(msg: " -THR LEVER 1.......IDLE",  colour: "c"),
	var eng1FireFlmaster      = warning.new(msg: " -ENG MASTER 1.......OFF",  colour: "c"),
	var eng1FireFlPB          = warning.new(msg: " -ENG 1 FIRE P/B....PUSH",  colour: "c"),
	var eng1FireFlAgent1Timer = warning.new(msg: " -AGENT 1 AFT 10 S.DISCH",  colour: "w"),
	var eng1FireFlAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng1FireFlATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng1FireFl30Sec       = warning.new(msg: "  •IF FIRE AFTER 30 S:",    colour: "w", isMainMsg: 1),
	var eng1FireFlAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	
	# ENG 1 FIRE (ground)
	var eng1FireGnlever       = warning.new(msg: " -THR LEVERS........IDLE",  colour: "c"),
	var eng1FireGnstopped     = warning.new(msg: "  •WHEN A/C IS STOPPED:",   colour: "w", isMainMsg: 1),
	var eng1FireGnparkbrk     = warning.new(msg: " -PARKING BRK.........ON",  colour: "c"),
	var eng1FireGnATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng1FireGncrew        = warning.new(msg: " -CABIN CREW.......ALERT",  colour: "c"),
	var eng1FireGnmaster      = warning.new(msg: " -ENG MASTER 1.......OFF",  colour: "c"),
	var eng1FireGnPB          = warning.new(msg: " -ENG 1 FIRE P/B....PUSH",  colour: "c"),
	var eng1FireGnAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng1FireGnAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	var eng1FireGnEvac        = warning.new(msg: " -EMER EVAC PROC...APPLY",  colour: "c"),
	
	# ENG 2 FIRE (flight)
	var eng2Fire              = warning.new(msg: "ENG 2 FIRE",                colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var eng2FireFllever       = warning.new(msg: " -THR LEVER 2.......IDLE",  colour: "c"),
	var eng2FireFlmaster      = warning.new(msg: " -ENG MASTER 2.......OFF",  colour: "c"),
	var eng2FireFlPB          = warning.new(msg: " -ENG 2 FIRE P/B....PUSH",  colour: "c"),
	var eng2FireFlAgent1Timer = warning.new(msg: " -AGENT 1 AFT 10 S.DISCH",  colour: "w"),
	var eng2FireFlAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng2FireFlATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng2FireFl30Sec       = warning.new(msg: "  •IF FIRE AFTER 30 S:",    colour: "w", isMainMsg: 1),
	var eng2FireFlAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	
	# ENG 2 FIRE (ground)
	var eng2FireGnlever       = warning.new(msg: " -THR LEVERS........IDLE",  colour: "c"),
	var eng2FireGnstopped     = warning.new(msg: "  •WHEN A/C IS STOPPED:",   colour: "w", isMainMsg: 1),
	var eng2FireGnparkbrk     = warning.new(msg: " -PARKING BRK.........ON",  colour: "c"),
	var eng2FireGnATC         = warning.new(msg: " -ATC.............NOTIFY",  colour: "c"),
	var eng2FireGncrew        = warning.new(msg: " -CABIN CREW.......ALERT",  colour: "c"),
	var eng2FireGnmaster      = warning.new(msg: " -ENG MASTER 2.......OFF",  colour: "c"),
	var eng2FireGnPB          = warning.new(msg: " -ENG 2 FIRE P/B....PUSH",  colour: "c"),
	var eng2FireGnAgent1      = warning.new(msg: " -AGENT 1..........DISCH",  colour: "c"),
	var eng2FireGnAgent2      = warning.new(msg: " -AGENT 2..........DISCH",  colour: "c"),
	var eng2FireGnEvac        = warning.new(msg: " -EMER EVAC PROC...APPLY",  colour: "c"),
	
	# APU FIRE
	var apuFire               = warning.new(msg: "APU FIRE                ",  colour: "r", aural: 0, light: 0, isMainMsg: 1, sdPage: "apu"),
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
	
	# FCTL L+R ELEV FAULT
	var lrElevFault           = warning.new(msg: "F/CTL L+R ELEV FAULT",      colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var lrElevFaultSpeed      = warning.new(msg: " MAX SPEED.......320/.77",  colour: "c"),
	var lrElevFaultTrim       = warning.new(msg: " -MAN PITCH TRIM.....USE",  colour: "c"),
	var lrElevFaultSpdBrk     = warning.new(msg: " SPD BRK......DO NOT USE",  colour: "c"),
	
	# Gear not down
	var gearNotDown           = warning.new(msg: "L/G GEAR NOT DOWN",         colour: "r", aural: 0, light: 0, isMainMsg: 1),
	
	var gearNotDownLocked     = warning.new(msg: "L/G GEAR NOT DOWNLOCKED",   colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var gearNotDownLockedRec  = warning.new(msg: " -L/G LEVER......RECYCLE",  colour: "c"),
	var gearNotDownLockedWork = warning.new(msg: "  •IF UNSUCCESSFUL:",       colour: "c"),
	var gearNotDownLocked120  = warning.new(msg: "    AFTER 120S:",           colour: "c"),
	var gearNotDownLockedGrav = warning.new(msg: " -L/G.........GRVTY EXTN",  colour: "c"),
	
	# Autopilot off involuntary
	var ap_offw				  = warning.new(msg: "AUTO FLT AP OFF",			  colour: "r", light: 0, isMainMsg: 1),
	
	# Cargo smoke
	var cargoSmokeFwd         = warning.new(msg: "SMOKE FWD CARGO SMOKE",     colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var cargoSmokeFwdAgent    = warning.new(msg: " -AGENT............DISCH",  colour: "c"),
	var cargoSmokeAft         = warning.new(msg: "SMOKE AFT CARGO SMOKE",     colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var cargoSmokeAftAgent    = warning.new(msg: " -AGENT............DISCH",  colour: "c"),
	
	# ESS Bus on Bat
	var essBusOnBat           = warning.new(msg: "ELEC ESS BUSES ON BAT",     colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var essBusOnBatLGUplock   = warning.new(msg: "   •WHEN L/G UPLOCKED :",   colour: "w"),
	var essBusOnBatManOn      = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	var essBusOnBatRetract    = warning.new(msg: "  •IF L/G RETRACT FAULT:",  colour: "w"),
	var essBusOnBatMinSpeed   = warning.new(msg: " MIN RAT SPD......180 KT",  colour: "c"),
	var essBusOnBatLGCB       = warning.new(msg: " -LGCIU1 C/B (C09)..PULL",  colour: "c"),
	var essBusOnBatManOn2     = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	
	# Emer Config
	var emerconfig            = warning.new(msg: "ELEC EMER CONFIG",          colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var emerconfigMinRat      = warning.new(msg: " MIN RAT SPD......140 KT",  colour: "c"),
	var emerconfigGen         = warning.new(msg: " -GEN 1+2....OFF THEN ON",  colour: "c"),
	var emerconfigGen2        = warning.new(msg: "    •IF UNSUCCESSFUL :",    colour: "w"),
	var emerconfigBusTie      = warning.new(msg: " -BUS TIE............OFF",  colour: "c"),
	var emerconfigGen3        = warning.new(msg: " -GEN 1+2....OFF THEN ON",  colour: "c"),
	var emerconfigManOn       = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	var emerconfigEngMode     = warning.new(msg: " -ENG MODE SEL.......IGN",  colour: "c"),
	var emerconfigRadio       = warning.new(msg: " -VHF1/ATC1..........USE",  colour: "c"),
	var emerconfigIcing       = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var emerconfigFuelG       = warning.new(msg: " FUEL GRVTY FEED",          colour: "c"),
	var emerconfigFuelG2      = warning.new(msg: " PROC:GRVTY FUEL FEEDING",  colour: "c"),
	var emerconfigFAC         = warning.new(msg: " -FAC 1......OFF THEN ON",  colour: "c"),
	var emerconfigBusTie2     = warning.new(msg: " -BUS TIE...........AUTO",  colour: "c"),
	var emerconfigAPU         = warning.new(msg: " -APU (IF AVAIL)...START",  colour: "c"),
	var emerconfigVent        = warning.new(msg: " -BLOWER + EXTRACT..OVRD",  colour: "c"),
	
	# B + Y LO PR
	var hydBYloPr             = warning.new(msg: "HYD B+Y SYS LO PR",         colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var hydBYloPrRat          = warning.new(msg: " MIN RAT SPD......140 KT",  colour: "c"),
	var hydBYloPrYElec        = warning.new(msg: " -YELLOW ELEC PUMP....ON",  colour: "c"),
	var hydBYloPrRatOn        = warning.new(msg: " -RAT.............MAN ON",  colour: "c"),
	var hydBYloPrBElec        = warning.new(msg: " -BLUE ELEC PUMP.....OFF",  colour: "c"),
	var hydBYloPrYEng         = warning.new(msg: " -YELLOW ENG 2 PUMP..OFF",  colour: "c"),
	var hydBYloPrMaxSpd       = warning.new(msg: " MAX SPEED.......320/.77",  colour: "c"),
	var hydBYloPrMnvrCare     = warning.new(msg: " MANEUVER WITH CARE",       colour: "c"),
	var hydBYloPrGaPitch      = warning.new(msg: " FOR GA:MAX PITCH 15 DEG",  colour: "c"),
	var hydBYloPrFuelCnsmpt   = warning.new(msg: " FUEL CONSUMPT INCRSD",     colour: "c"),
	var hydBYloPrFmsPredict   = warning.new(msg: " FMS PRED UNRELIABLE",      colour: "c"),
	
	# G + B LO PR
	var hydGBloPr             = warning.new(msg: "HYD G+B SYS LO PR",         colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var hydGBloPrRat          = warning.new(msg: " MIN RAT SPD......140 KT",  colour: "c"),
	var hydGBloPrRatOn        = warning.new(msg: " -RAT.............MAN ON",  colour: "c"),
	var hydGBloPrBElec        = warning.new(msg: " -BLUE ELEC PUMP.....OFF",  colour: "c"),
	var hydGBloPrGEng         = warning.new(msg: " -GREEN ENG 1 PUMP...OFF",  colour: "c"),
	var hydGBloPrMnvrCare     = warning.new(msg: " MANEUVER WITH CARE",       colour: "c"),
	var hydGBloPrGaPitch      = warning.new(msg: " FOR GA:MAX PITCH 15 DEG",  colour: "c"),
	var hydGBloPrFuelCnsmpt   = warning.new(msg: " FUEL CONSUMPT INCRSD",     colour: "c"),
	var hydGBloPrFmsPredict   = warning.new(msg: " FMS PRED UNRELIABLE",      colour: "c"),
	
	# G + Y LO PR
	var hydGYloPr             = warning.new(msg: "HYD G+Y SYS LO PR",         colour: "r", aural: 0, light: 0, isMainMsg: 1),
	var hydGYloPrPtu          = warning.new(msg: " -PTU................OFF",  colour: "c"),
	var hydGYloPrGEng         = warning.new(msg: " -GREEN ENG 1 PUMP...OFF",  colour: "c"),
	var hydGYloPrYEng         = warning.new(msg: " -YELLOW ENG 2 PUMP..OFF",  colour: "c"),
	var hydGYloPrYElec        = warning.new(msg: " -YELLOW ELEC PUMP....ON",  colour: "c"),
	var hydGYloPrMnvrCare     = warning.new(msg: " MANEUVER WITH CARE",       colour: "c"),
	var hydGYloPrFuelCnsmpt   = warning.new(msg: " FUEL CONSUMPT INCRSD",     colour: "c"),
	var hydGYloPrFmsPredict   = warning.new(msg: " FMS PRED UNRELIABLE",      colour: "c"),
	
	# DC EMER CONFIG
	var dcEmerconfig          = warning.new(msg: "ELEC DC EMER CONFIG",       colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var dcEmerconfigManOn     = warning.new(msg: " -EMER ELEC PWR...MAN ON",  colour: "c"),
	
	# DC BUS 1 OR 2 FAULT
	var dcBus12Fault          = warning.new(msg: "ELEC DC BUS 1+2 FAULT",     colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var dcBus12FaultBlower    = warning.new(msg: " -BLOWER............OVRD",  colour: "c"),
	var dcBus12FaultExtract   = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	var dcBus12FaultBaroRef   = warning.new(msg: " -BARO REF.........CHECK",  colour: "c"),
	var dcBus12FaultIcing     = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var dcBus12FaultBrking    = warning.new(msg: " MAX BRK........1000 PSI",  colour: "c"),
	
	# AC ESS BUS FAULT
	var AcBusEssFault         = warning.new(msg: "ELEC AC ESS BUS FAULT",     colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var AcBusEssFaultFeed     = warning.new(msg: " -AC ESS FEED.......ALTN",  colour: "c"),
	var AcBusEssFaultAtc      = warning.new(msg: " -ATC..............SYS 2",  colour: "c"),
	
	# AC BUS 1 FAULT
	var AcBus1Fault           = warning.new(msg: "ELEC AC BUS 1 FAULT",       colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var AcBus1FaultBlower     = warning.new(msg: " -BLOWER............OVRD",  colour: "c"),
	
	# DC ESS BUS FAULT
	var DcEssBusFault         = warning.new(msg: "ELEC DC ESS BUS FAULT",     colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var DcEssBusFaultRadio    = warning.new(msg: " -VHF 2 OR 3.........USE",  colour: "c"),
	var DcEssBusFaultRadio2   = warning.new(msg: " -AUDIO SWTG......SELECT",  colour: "c"),
	var DcEssBusFaultBaro     = warning.new(msg: " -BARO REF.........CHECK",  colour: "c"),
	var DcEssBusFaultGPWS     = warning.new(msg: " -GPWS...............OFF",  colour: "c"),
	
	# AC BUS 2 FAULT
	var AcBus2Fault           = warning.new(msg: "ELEC AC BUS 2 FAULT",       colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var AcBus2FaultExtract    = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	
	# DC BUS 1 FAULT
	var dcBus1Fault           = warning.new(msg: "ELEC DC BUS 1 FAULT",       colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var dcBus1FaultBlower     = warning.new(msg: " -BLOWER............OVRD",  colour: "c"),
	var dcBus1FaultExtract    = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	
	# DC BUS 2 FAULT
	var dcBus2Fault           = warning.new(msg: "ELEC DC BUS 2 FAULT",       colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var dcBus2FaultAirData    = warning.new(msg: " -AIR DATA SWTG......F/O",  colour: "c"),
	var dcBus2FaultBaro       = warning.new(msg: " -BARO REF.........CHECK",  colour: "c"),
	
	# DC BAT BUS FAULT
	var dcBusBatFault         = warning.new(msg: "ELEC DC BAT BUS FAULT",     colour: "a", aural: 1, light: 1, isMainMsg: 1),
	
	# DC ESS BUS SHED
	var dcBusEssShed          = warning.new(msg: "ELEC DC ESS BUS SHED",      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var dcBusEssShedExtract   = warning.new(msg: " -EXTRACT...........OVRD",  colour: "c"),
	var dcBusEssShedIcing     = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	
	# AC ESS BUS SHED
	var acBusEssShed          = warning.new(msg: "ELEC AC ESS BUS SHED",      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var acBusEssShedAtc       = warning.new(msg: " -ATC..............SYS 2",  colour: "c"),
	
	# GEN 1 FAULT
	var gen1fault             = warning.new(msg: "ELEC GEN 1 FAULT",          colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var gen1faultGen          = warning.new(msg: "-GEN 1......OFF THEN ON",   colour: "c"),
	var gen1faultGen2         = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var gen1faultGen3         = warning.new(msg: "-GEN 1..............OFF",   colour: "c"),
	
	# GEN 2 FAULT
	var gen2fault             = warning.new(msg: "ELEC GEN 2 FAULT",          colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var gen2faultGen          = warning.new(msg: "-GEN 2......OFF THEN ON",   colour: "c"),
	var gen2faultGen2         = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var gen2faultGen3         = warning.new(msg: "-GEN 2..............OFF",   colour: "c"),
	
	# APU GEN FAULT
	var apuGenfault           = warning.new(msg: "ELEC APU GEN FAULT",        colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var apuGenfaultGen        = warning.new(msg: "-APU GEN....OFF THEN ON",   colour: "c"),
	var apuGenfaultGen2       = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var apuGenfaultGen3       = warning.new(msg: "-APU GEN............OFF",   colour: "c"),
	
	# L ELEV FAULT
	var lElevFault            = warning.new(msg: "F/CTL L ELEV FAULT",        colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var lElevFaultCare        = warning.new(msg: " MANEUVER WITH CARE",       colour: "c"),
	var lElevFaultPitch       = warning.new(msg: " FOR GA:MAX PITCH 15 DEG",  colour: "c"),
	
	# R ELEV FAULT
	var rElevFault            = warning.new(msg: "F/CTL R ELEV FAULT",        colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var rElevFaultCare        = warning.new(msg: " MANEUVER WITH CARE",       colour: "c"),
	var rElevFaultPitch       = warning.new(msg: " FOR GA:MAX PITCH 15 DEG",  colour: "c"),
	
	# DIRECT LAW
	var directLaw             = warning.new(msg: "F/CTL DIRECT LAW",          colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var directLawProt         = warning.new(msg: "     (PROT LOST)",          colour: "a"),
	var directLawMaxSpeed     = warning.new(msg: " MAX SPEED........320/.77", colour: "c"),
	var directLawTrim         = warning.new(msg: " -MAN PITCH TRIM.....USE",  colour: "c"),
	var directLawCare         = warning.new(msg: " MANEUVER WITH CARE",       colour: "c"),
	var directLawSpdBrk       = warning.new(msg: " USE SPD BRK WITH CARE",    colour: "c"),
	var directLawSpdBrk2      = warning.new(msg: " SPD BRK.......DO NOT USE", colour: "c"),
	
	# ALTN LAW
	var altnLaw               = warning.new(msg: "F/CTL ALTN LAW",            colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var altnLawProt           = warning.new(msg: "     (PROT LOST)",          colour: "a"),
	var altnLawMaxSpeed       = warning.new(msg: " MAX SPEED........320 KT",  colour: "c"),
	var altnLawMaxSpeed2      = warning.new(msg: " MAX SPEED........320/.77", colour: "c"),
	var altnLawMaxSpdBrk      = warning.new(msg: " SPD BRK.......DO NOT USE", colour: "c"),
	
	# Autothrust
	var athr_offw			  = warning.new(msg: "AUTO FLT A/THR OFF", 	      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var athr_offw_1			  = warning.new(msg: "-THR LEVERS........MOVE",   colour: "c"),
	var athr_lock			  = warning.new(msg: "ENG THRUST LOCKED", 		  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var athr_lock_1			  = warning.new(msg: "-THR LEVERS........MOVE",   colour: "c"),
	var athr_lim			  = warning.new(msg: "AUTO FLT A/THR LIMITED",    colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var athr_lim_1			  = warning.new(msg: "-THR LEVERS........MOVE",   colour: "c"),
	
	# TCAS FAULT
	var tcasFault             = warning.new(msg: "NAV TCAS FAULT",            colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var tcasStby              = warning.new(msg: "NAV TCAS STBY",             colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var gpwsFault             = warning.new(msg: "NAV GPWS FAULT",            colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var gpwsFaultOff		  = warning.new(msg: "-GPWS...............OFF",   colour: "c"),
	var gpwsTerrFault         = warning.new(msg: "NAV GPWS TERR DET FAULT",   colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var gpwsTerrFaultOff	  = warning.new(msg: "-GPWS TERR..........OFF",   colour: "c"),
	
	# FAC and Rudder System
	var fac12Fault            = warning.new(msg: "AUTO FLT FAC 1+2 FAULT",    colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var fac12FaultRud         = warning.new(msg: "RUD WITH CARE ABV 160 KT",  colour: "c"),
	var fac12FaultFac         = warning.new(msg: " -FAC 1+2....OFF THEN ON",  colour: "c"),
	var fac12FaultSuccess     = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var fac12FaultFacOff      = warning.new(msg: " -FAC 1+2............OFF",  colour: "c"),
	var yawDamperSysFault     = warning.new(msg: "AUTO FLT YAW DAMPER SYS",   colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var yawDamperSysFaultFac1 = warning.new(msg: " -FAC 1......OFF THEN ON",  colour: "c"),
	var yawDamperSysFaultFac2 = warning.new(msg: " -FAC 2......OFF THEN ON",  colour: "c"),
	# var rudderTrimSysFault    = warning.new(msg: "AUTO FLT RUD TRIM SYS",     colour: "a", aural: 1, light: 1, isMainMsg: 1), not implemented
	# var rudderTrimSysFaultFac = warning.new(msg: " -FAC 1+2....OFF THEN ON",  colour: "c"),
	var rudTravLimSysFault    = warning.new(msg: "AUTO FLT RUD TRV LIM SYS",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var rudTravLimSysFaultRud = warning.new(msg: "RUD WITH CARE ABV 160 KT",  colour: "c"),
	var rudTravLimSysFaultFac = warning.new(msg: " -FAC 1+2....OFF THEN ON",  colour: "c"),
	var fac1Fault             = warning.new(msg: "AUTO FLT FAC 1 FAULT",      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var fac1FaultFac          = warning.new(msg: " -FAC 1......OFF THEN ON",  colour: "c"),
	var fac1FaultSuccess      = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var fac1FaultFacOff       = warning.new(msg: " -FAC 1..............OFF",  colour: "c"),
	var fac2Fault             = warning.new(msg: "AUTO FLT FAC 2 FAULT",      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var fac2FaultFac          = warning.new(msg: " -FAC 2......OFF THEN ON",  colour: "c"),
	var fac2FaultSuccess      = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "w"),
	var fac2FaultFacOff       = warning.new(msg: " -FAC 2..............OFF",  colour: "c"),
	
	var yawDamper1Fault       = warning.new(msg: "AUTO FLT YAW DAMPER 1",     colour: "a", isMainMsg: 1),
	var yawDamper2Fault       = warning.new(msg: "AUTO FLT YAW DAMPER 2",     colour: "a", isMainMsg: 1),
	# var rudTrim1Fault         = warning.new(msg: "AUTO FLT RUD TRIM1 FAULT",  colour: "a", isMainMsg: 1), not implemented
	# var rudTrim2Fault         = warning.new(msg: "AUTO FLT RUD TRIM2 FAULT",  colour: "a", isMainMsg: 1), not implemented
	var rudTravLimSys1Fault   = warning.new(msg: "AUTO FLT RUD TRV LIM 1",    colour: "a", isMainMsg: 1),
	var rudTravLimSys2Fault   = warning.new(msg: "AUTO FLT RUD TRV LIM 2",    colour: "a", isMainMsg: 1),
	
	# FCU fault
	var fcuFault              = warning.new(msg: "AUTO FLT FCU 1+2 FAULT",    colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var fcuFaultBaro          = warning.new(msg: " -PFD BARO REF: STD ONLY",  colour: "c"),
	var fcuFault1             = warning.new(msg: "AUTO FLT FCU 1 FAULT",      colour: "a", isMainMsg: 1),
	var fcuFault1Baro         = warning.new(msg: " -BARO REF.......X CHECK",  colour: "c"),
	var fcuFault2             = warning.new(msg: "AUTO FLT FCU 2 FAULT",      colour: "a", isMainMsg: 1),
	var fcuFault2Baro         = warning.new(msg: " -BARO REF.......X CHECK",  colour: "c"),
	
	# APU shutdown
	var apuEmerShutdown       = warning.new(msg: "APU EMER SHUT DOWN",        colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var apuEmerShutdownMast   = warning.new(msg: " -MASTER SW..........OFF",  colour: "c"),
	var apuAutoShutdown       = warning.new(msg: "APU AUTO SHUT DOWN",        colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var apuAutoShutdownMast   = warning.new(msg: " -MASTER SW..........OFF",  colour: "c"),

	# Bleed
	var bleed1Fault           = warning.new(msg: "AIR ENG 1 BLEED FAULT",     colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var bleed1FaultOff        = warning.new(msg: " -ENG 1 BLEED........OFF",  colour: "c"),
	var bleed1FaultPack       = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var bleed1FaultXBleed     = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var bleed2Fault           = warning.new(msg: "AIR ENG 2 BLEED FAULT",     colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var bleed2FaultOff        = warning.new(msg: " -ENG 2 BLEED........OFF",  colour: "c"),
	var bleed2FaultPack       = warning.new(msg: " -PACK 2.............OFF",  colour: "c"),
	var bleed2FaultXBleed     = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var apuBleedFault         = warning.new(msg: "AIR APU BLEED FAULT",       colour: "a", aural: 1, light: 1),
	var hpValve1Fault         = warning.new(msg: "AIR ENG 1 HP VALVE FAULT",  colour: "a"),
	var hpValve2Fault         = warning.new(msg: "AIR ENG 2 HP VALVE FAULT",  colour: "a"),
	var xBleedFault           = warning.new(msg: "AIR X BLEED FAULT",         colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var xBleedFaultMan        = warning.new(msg: " -X BLEED........MAN CTL",  colour: "c"),
	var xBleedOff             = warning.new(msg: " -WING ANTI ICE......OFF",  colour: "c"),
	var xBleedIcing           = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var bleed1Off             = warning.new(msg: "AIR BLEED 1 OFF",           colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var bleed2Off             = warning.new(msg: "AIR BLEED 2 OFF",           colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var engBleedLowTemp       = warning.new(msg: "AIR ENG 1+2 BLEED LO TEMP", colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var engBleedLowTempAthr   = warning.new(msg: " -A/THR..............OFF",  colour: "c"),
	var engBleedLowTempAdv    = warning.new(msg: " -THR LEVERS.....ADVANCE",  colour: "c"),
	var engBleedLowTempSucc   = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "c"),
	var engBleedLowTempIce    = warning.new(msg: " -WING A.ICE.........OFF",  colour: "c"),
	var engBleedLowTempIcing  = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var eng1BleedLowTemp      = warning.new(msg: "AIR ENG 1 BLEED LO TEMP",   colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng1BleedLowTempAthr  = warning.new(msg: " -A/THR..............OFF",  colour: "c"),
	var eng1BleedLowTempAdv   = warning.new(msg: " -THR LEVER 1....ADVANCE",  colour: "c"),
	var eng1BleedLowTempSucc  = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "c"),
	var eng1BleedLowTempXBld  = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var eng1BleedLowTempOff   = warning.new(msg: " -ENG 1 BLEED........OFF",  colour: "c"),
	var eng1BleedLowTempPack  = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var eng1BleedLowTempIce   = warning.new(msg: " -WING A.ICE.........OFF",  colour: "c"),
	var eng1BleedLowTempIcing = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var eng2BleedLowTemp      = warning.new(msg: "AIR ENG 2 BLEED LO TEMP",   colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng2BleedLowTempAthr  = warning.new(msg: " -A/THR..............OFF",  colour: "c"),
	var eng2BleedLowTempAdv   = warning.new(msg: " -THR LEVER 2....ADVANCE",  colour: "c"),
	var eng2BleedLowTempSucc  = warning.new(msg: "   •IF UNSUCCESSFUL :",     colour: "c"),
	var eng2BleedLowTempXBld  = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var eng2BleedLowTempOff   = warning.new(msg: " -ENG 2 BLEED........OFF",  colour: "c"),
	var eng2BleedLowTempPack  = warning.new(msg: " -PACK 2.............OFF",  colour: "c"),
	var eng2BleedLowTempIce   = warning.new(msg: " -WING A.ICE.........OFF",  colour: "c"),
	var eng2BleedLowTempIcing = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var eng1BleedAbPress      = warning.new(msg: "AIR ENG 1 BLEED ABNORM PR", colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng1BleedAbPressPack  = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var eng1BleedAbPressXBld  = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var eng2BleedAbPress      = warning.new(msg: "AIR ENG 2 BLEED ABNORM PR", colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng2BleedAbPressPack  = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var eng2BleedAbPressXBld  = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var eng1BleedNotClsd      = warning.new(msg: "AIR ENG 1 BLEED NOT CLSD",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng1BleedNotClsdOff   = warning.new(msg: " -ENG 1 BLEED........OFF",  colour: "c"),
	var eng2BleedNotClsd      = warning.new(msg: "AIR ENG 2 BLEED NOT CLSD",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng2BleedNotClsdOff   = warning.new(msg: " -ENG 2 BLEED........OFF",  colour: "c"),
	var bleedMonFault         = warning.new(msg: "BLEED MONITORING FAULT",    colour: "a", isMainMsg: 1),
	var bleedMon1Fault        = warning.new(msg: "BLEED MONIT SYS 1 FAULT",   colour: "a", isMainMsg: 1),
	var bleedMon2Fault        = warning.new(msg: "BLEED MONIT SYS 2 FAULT",   colour: "a", isMainMsg: 1),
	
	# PACK
	var pack12Fault           = warning.new(msg: "AIR PACK 1+2 FAULT",        colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var pack12FaultPackOff1   = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var pack12FaultPackOff2   = warning.new(msg: " -PACK 2.............OFF",  colour: "c"),
	var pack12FaultDescend    = warning.new(msg: " -DESCENT TO FL 100/MEA ",  colour: "c"),
	var pack12FaultDiffPr     = warning.new(msg: " •WHEN DIFF PR <1 PSI",     colour: "w"),
	var pack12FaultDiffPr2    = warning.new(msg: "    AND FL BELOW 100 :",    colour: "w"),
	var pack12FaultRam        = warning.new(msg: " -RAM AIR...........OPEN",  colour: "c"),
	var pack12FaultMax        = warning.new(msg: " MAX FL..........100/MEA",  colour: "c"),
	var pack12FaultOvht       = warning.new(msg: " •WHEN PACK OVHT OUT:",     colour: "w"),
	var pack12FaultPackOn1    = warning.new(msg: " -PACK 1..............ON",  colour: "c"),
	var pack12FaultPackOn2    = warning.new(msg: " -PACK 2..............ON",  colour: "c"),
	var pack1Ovht             = warning.new(msg: "AIR PACK 1 OVHT",           colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var pack1OvhtOff          = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var pack1OvhtOut          = warning.new(msg: "  •WHEN PACK OVHT OUT:",    colour: "w"),
	var pack1OvhtPack         = warning.new(msg: " -PACK 1..............ON",  colour: "c"),
	var pack2Ovht             = warning.new(msg: "AIR PACK 2 OVHT",           colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var pack2OvhtOff          = warning.new(msg: " -PACK 2.............OFF",  colour: "c"),
	var pack2OvhtOut          = warning.new(msg: "  •WHEN PACK OVHT OUT:",    colour: "w"),
	var pack2OvhtPack         = warning.new(msg: " -PACK 2..............ON",  colour: "c"),
	var pack1Fault            = warning.new(msg: "AIR PACK 1 FAULT",          colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var pack1FaultOff         = warning.new(msg: " -PACK 1.............OFF",  colour: "c"),
	var pack2Fault            = warning.new(msg: "AIR PACK 2 FAULT",          colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var pack2FaultOff         = warning.new(msg: " -PACK 2.............OFF",  colour: "c"),
	var pack1Off              = warning.new(msg: "AIR PACK 1 OFF",            colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var pack2Off              = warning.new(msg: "AIR PACK 2 OFF",            colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var cabFanFault           = warning.new(msg: "COND L+R CAB FAN FAULT",    colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var cabFanFaultFlow       = warning.new(msg: " -PACK FLOW...........HI",  colour: "c"),
	var trimAirFault          = warning.new(msg: "COND TRIM AIR SYS FAULT",   colour: "a", isMainMsg: 1),
	var trimAirFaultAft       = warning.new(msg: " -AFT CAB TRIM VALVE",      colour: "c"),
	var trimAirFaultFwd       = warning.new(msg: " -FWD CAB TRIM VALVE",      colour: "c"),
	var trimAirFaultCkpt      = warning.new(msg: " -CKPT TRIM VALVE",         colour: "c"),
	
	# Eng AICE
	var eng1IceClosed         = warning.new(msg: "ANTI ICE ENG1 VALVE CLSD",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng1IceClosedIcing    = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var eng2IceClosed         = warning.new(msg: "ANTI ICE ENG2 VALVE CLSD",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng2IceClosedIcing    = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var eng1IceOpen           = warning.new(msg: "ANTI ICE ENG1 VALVE OPEN",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng1IceOpenThrust     = warning.new(msg: " THRUST LIM PENALTY",       colour: "c"),
	var eng2IceOpen           = warning.new(msg: "ANTI ICE ENG2 VALVE OPEN",  colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng2IceOpenThrust     = warning.new(msg: " THRUST LIM PENALTY",       colour: "c"),
	
	# Wing AICE
	var wingIceSysFault       = warning.new(msg: "WING A.ICE SYS FAULT",      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var wingIceSysFaultXbld   = warning.new(msg: " -X BLEED...........OPEN",  colour: "c"),
	var wingIceSysFaultOff    = warning.new(msg: " -WING ANTI ICE......OFF",  colour: "c"),
	var wingIceSysFaultIcing  = warning.new(msg: " AVOID ICING CONDITIONS",   colour: "c"),
	var wingIceLOpen          = warning.new(msg: "WING A.ICE L VALVE OPEN",   colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var wingIceLOpenOff       = warning.new(msg: " -WING ANTI ICE......OFF",  colour: "c"),
	var wingIceLOpenEngOff    = warning.new(msg: " -ENG1 BLEED.........OFF",  colour: "c"),
	var wingIceLOpenXbld      = warning.new(msg: " -X BLEED...........SHUT",  colour: "c"),
	var wingIceLOpenApuOff    = warning.new(msg: " -APU BLEED..........OFF",  colour: "c"),
	var wingIceLOpenSpacer    = warning.new(msg: "                        ",  colour: "c"),
	var wingIceLOpenFlt       = warning.new(msg: " WAI AVAIL IN FLT",         colour: "c"),
	var wingIceLOpenEngOn     = warning.new(msg: " -ENG1 BLEED.........OFF",  colour: "c"),
	var wingIceLOpenIceReq    = warning.new(msg: " -WING ANTI ICE..AS RQRD",  colour: "c"),
	var wingIceLOpenThrust    = warning.new(msg: " THRUST LIM PENALTY",       colour: "c"),
	var wingIceROpen          = warning.new(msg: "WING A.ICE R VALVE OPEN",   colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var wingIceROpenOff       = warning.new(msg: " -WING ANTI ICE......OFF",  colour: "c"),
	var wingIceROpenEngOff    = warning.new(msg: " -ENG2 BLEED.........OFF",  colour: "c"),
	var wingIceROpenXbld      = warning.new(msg: " -X BLEED...........SHUT",  colour: "c"),
	var wingIceROpenApuOff    = warning.new(msg: " -APU BLEED..........OFF",  colour: "c"),
	var wingIceROpenSpacer    = warning.new(msg: "                        ",  colour: "c"),
	var wingIceROpenFlt       = warning.new(msg: " WAI AVAIL IN FLT",         colour: "c"),
	var wingIceROpenEngOn     = warning.new(msg: " -ENG2 BLEED.........OFF",  colour: "c"),
	var wingIceROpenIceReq    = warning.new(msg: " -WING ANTI ICE..AS RQRD",  colour: "c"),
	var wingIceROpenThrust    = warning.new(msg: " THRUST LIM PENALTY",       colour: "c"),
	var wingIceOpenGnd        = warning.new(msg: "WING A.ICE OPEN ON GND",    colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var wingIceOpenGndShut    = warning.new(msg: " -WING ANTI ICE......OFF",  colour: "c"),
	var wingIceLHiPr          = warning.new(msg: "WING A.ICE L HI PR",        colour: "a", isMainMsg: 1),
	var wingIceLHiPrThrust    = warning.new(msg: " THRUST LIM PENTALTY",      colour: "c"),
	var wingIceRHiPr          = warning.new(msg: "WING A.ICE R HI PR",        colour: "a", isMainMsg: 1),
	var wingIceRHiPrThrust    = warning.new(msg: " THRUST LIM PENTALTY",      colour: "c"),
	
	# FIRE det fault
	var eng1FireDetFault      = warning.new(msg: "ENG 1 FIRE DET FAULT",      colour: "a", aural: 1, light: 1, isMainMsg: 1), 
	var eng1LoopAFault        = warning.new(msg: "ENG 1 FIRE LOOP A FAULT",   colour: "a", isMainMsg: 1),
	var eng1LoopBFault        = warning.new(msg: "ENG 1 FIRE LOOP B FAULT",   colour: "a", isMainMsg: 1),
	var eng2FireDetFault      = warning.new(msg: "ENG 2 FIRE DET FAULT",      colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var eng2LoopAFault        = warning.new(msg: "ENG 2 FIRE LOOP A FAULT",   colour: "a", isMainMsg: 1),
	var eng2LoopBFault        = warning.new(msg: "ENG 2 FIRE LOOP B FAULT",   colour: "a", isMainMsg: 1),
	var apuFireDetFault       = warning.new(msg: "APU FIRE DET FAULT",        colour: "a", aural: 1, light: 1, isMainMsg: 1), 
	var apuLoopAFault         = warning.new(msg: "APU FIRE LOOP A FAULT",     colour: "a", isMainMsg: 1),
	var apuLoopBFault         = warning.new(msg: "APU FIRE LOOP B FAULT",     colour: "a", isMainMsg: 1),
	var crgFwdFireDetFault    = warning.new(msg: "FWD CRG DET FAULT",         colour: "a", isMainMsg: 1), 
	var crgAftFireDetFault    = warning.new(msg: "AFT CRG DET FAULT",         colour: "a", isMainMsg: 1), 
	
	# Radios
	var hf1Emitting           = warning.new(msg: "COM HF 1 EMITTING",         colour: "a", aural: 1, light: 1, isMainMsg: 1),
	var hf2Emitting           = warning.new(msg: "COM HF 2 EMITTING",         colour: "a", aural: 1, light: 1, isMainMsg: 1),
	
	# Recall
	var recallNormal          = warning.new(msg: "                    ", colour: "g", isMainMsg: 1),
	var recallNormal1         = warning.new(msg: "                    ", colour: "g", isMainMsg: 1),
	var recallNormal2         = warning.new(msg: "               NORMAL", colour: "g", isMainMsg: 1),
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
	var irs_in_align          = warning.new(msg: "IRS IN ALIGN"         ),
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
	var tcas_stby        = memo.new(msg: "TCAS STBY"   ),
	var company_call     = memo.new(msg: "COMPANY CALL"),
	var satcom_alert     = memo.new(msg: "SATCOM ALERT"), # Not yet implemented
	var company_msg      = memo.new(msg: "COMPANY MSG" ),
	var eng_aice         = memo.new(msg: "ENG A.ICE"   ),
	var wing_aice        = memo.new(msg: "WING A.ICE"  ),
	var ice_not_det      = memo.new(msg: "ICE NOT DET" ), # Not yet implemented
	var hi_alt           = memo.new(msg: "HI ALT"      ), # Not yet implemented
	var apu_avail        = memo.new(msg: "APU AVAIL"   ),
	var apu_bleed        = memo.new(msg: "APU BLEED"   ),
	var ldg_lt           = memo.new(msg: "LDG LT"      ),
	var brk_fan          = memo.new(msg: "BRK FAN"     ),
	var audio3_xfrd      = memo.new(msg: "AUDIO 3 XFRD"), # Not yet implemented
	var switchg_pnl      = memo.new(msg: "SWITCHG PNL" ), # Not yet implemented
	var gpws_flap3       = memo.new(msg: "GPWS FLAP 3" ), 
	var hf_data_ovrd     = memo.new(msg: "HF DATA OVRD"), # Not yet implemented
	var hf_voice         = memo.new(msg: "HF VOICE"    ), # Not yet implemented
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
