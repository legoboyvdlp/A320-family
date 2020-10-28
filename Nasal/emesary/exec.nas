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
    #    
    notifications.frameNotification.fetchvars();
    if (notifications.frameNotification.FrameCount >= 4) {
        notifications.frameNotification.FrameCount = 0;
    }
    emesary.GlobalTransmitter.NotifyAll(notifications.frameNotification);
    #    

    notifications.frameNotification.FrameCount = notifications.frameNotification.FrameCount + 1;
	
	if (notifications.frameNotification.frame_rate < 5) {
        frame_inc = 0.25;#4 Hz
    } elsif (notifications.frameNotification.frame_rate < 10) {
        frame_inc = 0.125;#8 Hz
    } elsif (notifications.frameNotification.frame_rate < 15) {
        frame_inc = 0.10;#10 Hz
    } elsif (notifications.frameNotification.frame_rate < 20) {
        frame_inc = 0.075;#13.3 Hz
    } elsif (notifications.frameNotification.frame_rate < 25) {
        frame_inc = 0.05;#20 Hz
    } elsif (notifications.frameNotification.frame_rate < 40) {
        frame_inc = 0.0333;#30 Hz
    } else {
        frame_inc = 0.02;#50 Hz
    }
	
    if (frame_inc != cur_frame_inc) {
        cur_frame_inc = frame_inc;
    }
    settimer(execLoop, cur_frame_inc);
}

# setup the properties to monitor for this system
input = {
frame_rate                : "/sim/frame-rate",
elapsed_seconds           : "/sim/time/elapsed-sec",
};

foreach (var name; keys(input)) {
    emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("EXEC", name, input[name]));
}
emesary.GlobalTransmitter.OverrunDetection(9);

setlistener("/sim/signals/fdm-initialized", func() {
	execLoop();
}, 0, 0);
