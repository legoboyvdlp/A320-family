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



# to add properties to the FrameNotification simply send a FrameNotificationAddProperty
# to the global transmitter. This will be received by the frameNotifcation object and
# included in the update.
#emesary.GlobalTransmitter.NotifyAll(new FrameNotificationAddProperty("MODULE", "wow","gear/gear[0]/wow"));
#emesary.GlobalTransmitter.NotifyAll(new FrameNotificationAddProperty("MODULE", "engine_n2", "engines/engine[0]/n2"));
#    


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
    #
    # framecount
    # 0: HUD targets, Radar, RWR
    # 1: HUD targets, RDR, VSD
    # 2: HUD targets, HUD trig, HUD text
    # 3: HUD targets, VSD, RDR
    # 
    
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
FrameRate                 : "/sim/frame-rate",
frame_rate                : "/sim/frame-rate",
frame_rate_worst          : "/sim/frame-rate-worst",
elapsed_seconds           : "/sim/time/elapsed-sec",
};

foreach (var name; keys(input)) {
    emesary.GlobalTransmitter.NotifyAll(notifications.FrameNotificationAddProperty.new("EXEC", name, input[name]));
}