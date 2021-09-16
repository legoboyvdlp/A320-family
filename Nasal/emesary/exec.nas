 #---------------------------------------------------------------------------
 #
 #	Title                : Emesary based real time executive
 #
 #	File Type            : Implementation File
 #
 #	Description          : Uses emesary notifications to permit nasal subsystems to
 #                       : be invoked in a controlled manner.
 #
 #	Author               : Richard Harrison (richard@zaretto.com)
 #
 #	Creation Date        : 4 June 2018
 #
 #	Version              : 1.0
 #
 #  Copyright (C) 2018 Richard Harrison           Released under GPL V2
 #
 #---------------------------------------------------------------------------*/

#
# real time exec loop.
var frame_inc = 0;
var cur_frame_inc = 0.05;
var execLoop = func
{
    notifications.frameNotification.fetchvars();
    if (notifications.frameNotification.FrameCount > 20) {
        notifications.frameNotification.FrameCount = 0;
    }
    emesary.GlobalTransmitter.NotifyAll(notifications.frameNotification);

    notifications.frameNotification.FrameCount = notifications.frameNotification.FrameCount + 1;
	frame_inc = 0.02; #50 Hz
    if (frame_inc != cur_frame_inc) {
        cur_frame_inc = frame_inc;
    }
    settimer(execLoop, cur_frame_inc);
}

# setup the properties to monitor for this system
input = {
	frame_rate: "/sim/frame-rate",
	elapsedTime: "/sim/time/elapsed-sec",
	FWCPhase: "/ECAM/warning-phase",
	acconfigUnits: "/systems/acconfig/options/weight-kgs",
	
	# Just about everything uses these properties at some stage, lets add them here!
	gear0Wow: "/gear/gear[0]/wow",
	gear1Wow: "/gear/gear[1]/wow",
	gear2Wow: "/gear/gear[2]/wow",
	parkingBrake: "/controls/gear/brake-parking",
	airspeedV: "/velocities/airspeed-kt",
	groundspeed: "/velocities/groundspeed-kt",
	engine1State: "/engines/engine[0]/state",
	engine2State: "/engines/engine[1]/state",
};

foreach (var name; keys(input)) {
    emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("EXEC", name, input[name]));
}
emesary.GlobalTransmitter.OverrunDetection(9);

setlistener("/sim/signals/fdm-initialized", func() {
	execLoop();
}, 0, 0);
