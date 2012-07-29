//
//  PitchMonitor.h
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <CoreAudio/CoreAudio.h>

@interface PitchMonitor : NSObject {
	MIDIClientRef clientRef;
	MIDIPortRef outPortRef;
	MIDIEndpointRef destPointRef;
	int octave;
}

- (void)keyDown:(NSEvent *)theEvent;
- (void)keyUp:(NSEvent *)theEvent;

@property (assign) id delegate;

@end

@protocol PitchMonitorDelegate <NSObject>

- (void)didSendNoteOn:(PitchMonitor *)sender pitchName:(NSString *)pitchName;

@end
