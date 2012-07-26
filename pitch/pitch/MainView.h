//
//  MainView.h
//  pitch
//
//  Created by abechan on 12/07/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>
#import <CoreAudio/CoreAudio.h>

@interface MainView : NSView {
	MIDIClientRef clientRef;
    MIDIPortRef outPortRef;
    MIDIEndpointRef destPointRef;
	int octave;
}

@end
