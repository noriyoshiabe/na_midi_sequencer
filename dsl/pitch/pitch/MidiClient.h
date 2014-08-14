//
//  MidiClient.h
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <CoreAudio/CoreAudio.h>

@interface MidiClient : NSObject {
	MIDIClientRef clientRef;
	MIDIPortRef outPortRef;
	MIDIEndpointRef destPointRef;
}

- (void)noteOn:(Byte)channel pitch:(Byte)pitch;
- (void)noteOff:(Byte)channel pitch:(Byte)pitch;

- (void)bankSelect:(Byte)channel msb:(Byte)msb lsb:(Byte)lsb;
- (void)programChange:(Byte)channel programNo:(Byte)programNo;

- (void)allSoundOff:(Byte)channel;

@end
