//
//  PitchMonitor.h
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MidiClient.h"

@interface PitchMonitor : NSObject {
	UInt64 lastTime;
	BOOL isFinished;
	UInt64 tick;
	UInt64 nextTickTime;
	int timebaseIndex;
}

- (void)keyDown:(NSEvent *)theEvent;
- (void)keyUp:(NSEvent *)theEvent;
- (NSString *)pitch2String:(int)pitch;

@property (assign) id delegate;
@property (retain) MidiClient *midiClient;
@property (retain) NSMutableArray *noteEvents;
@property int octave;
@property int patch;
@property float tempo;
@property int timeBase;
@property int quantize;
@property (retain) NSThread *metronomeThread;
@property BOOL isMetronomeEnable;

@end

@protocol PitchMonitorDelegate <NSObject>

- (void)traceEvent:(PitchMonitor *)sender trace:(NSString *)trace;
- (void)eventListChanged:(PitchMonitor *)sender;
- (void)contextChanged:(PitchMonitor *)sender;
- (void)clickIndicate:(PitchMonitor *)sender color:(NSColor *)color;

@end
