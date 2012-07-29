//
//  PitchMonitor.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PitchMonitor.h"

@implementation PitchMonitor
@synthesize delegate;

static NSString *PITCH_NAME_TABLE[] = {
	@"C0",  @"C#0",  @"D0",  @"D#0",  @"E0",  @"F0",  @"F#0",  @"G0",  @"G#0",  @"A0",  @"A#0",  @"B0", 
	@"C1",  @"C#1",  @"D1",  @"D#1",  @"E1",  @"F1",  @"F#1",  @"G1",  @"G#1",  @"A1",  @"A#1",  @"B1", 
	@"C2",  @"C#2",  @"D2",  @"D#2",  @"E2",  @"F2",  @"F#2",  @"G2",  @"G#2",  @"A2",  @"A#2",  @"B2", 
	@"C3",  @"C#3",  @"D3",  @"D#3",  @"E3",  @"F3",  @"F#3",  @"G3",  @"G#3",  @"A3",  @"A#3",  @"B3", 
	@"C4",  @"C#4",  @"D4",  @"D#4",  @"E4",  @"F4",  @"F#4",  @"G4",  @"G#4",  @"A4",  @"A#4",  @"B4", 
	@"C5",  @"C#5",  @"D5",  @"D#5",  @"E5",  @"F5",  @"F#5",  @"G5",  @"G#5",  @"A5",  @"A#5",  @"B5", 
	@"C6",  @"C#6",  @"D6",  @"D#6",  @"E6",  @"F6",  @"F#6",  @"G6",  @"G#6",  @"A6",  @"A#6",  @"B6", 
	@"C7",  @"C#7",  @"D7",  @"D#7",  @"E7",  @"F7",  @"F#7",  @"G7",  @"G#7",  @"A7",  @"A#7",  @"B7", 
	@"C8",  @"C#8",  @"D8",  @"D#8",  @"E8",  @"F8",  @"F#8",  @"G8",  @"G#8",  @"A8",  @"A#8",  @"B8", 
	@"C9",  @"C#9",  @"D9",  @"D#9",  @"E9",  @"F9",  @"F#9",  @"G9",  @"G#9",  @"A9",  @"A#9",  @"B9", 
	@"C10", @"C#10", @"D10", @"D#10", @"E10", @"F10", @"F#10", @"G10"
};
						
- (void)initializeMIDI
{
	OSStatus err;
	
	NSString *clientName = @"inputClient";
	err = MIDIClientCreate((CFStringRef)clientName, NULL, NULL, &clientRef);
	if (err != noErr) {
		NSLog(@"MIDIClientCreate err = %d", err);
		return;
	}
	
	NSString *outputPortName = @"outputPort";
	err = MIDIOutputPortCreate(clientRef, (CFStringRef)outputPortName, &outPortRef);
	if (err != noErr) {
		NSLog(@"MIDIOutputPortCreate err = %d", err);
		return;
	}
	
	destPointRef = MIDIGetDestination(0);
	
	CFStringRef strRef;
	err = MIDIObjectGetStringProperty(destPointRef, kMIDIPropertyDisplayName, &strRef);
	if (err != noErr) {
		NSLog(@"MIDIObjectGetStringProperty err = %d", err);
		return;
	}
	NSLog(@"connect = %@", strRef);
	CFRelease(strRef);
	
	octave = 5;
}

- (int)keyCode2Pitch:(unsigned short)keyCode
{
	switch (keyCode) {
		case 0x0006: return -3; //A
		case 0x0001: return -2; //A#
		case 0x0007: return -1; //B
		case 0x0008: return 0; //C
		case 0x0003: return 1; //C#
		case 0x0009: return 2; //D
		case 0x0005: return 3; //D#
		case 0x000B: return 4; //E
		case 0x002D: return 5; //F
		case 0x0026: return 6; //F#
		case 0x002E: return 7; //G
		case 0x0028: return 8; //G#
		case 0x002B: return 9; //A
		case 0x0025: return 10; //A#
		case 0x002F: return 11; //B
		case 0x002C: return 12; //C
		default:
			return 9999;
	}
}

- (void)octaveShift:(unsigned short)keyCode
{
	switch (keyCode) {
		case 0x007B:
			--octave;
			if (0 > octave)
				octave = 0;
			break;
		case 0x007C:
			++octave;
			if (10 < octave)
				octave = 10;
			break;
	}
}

- (int)calcPitch:(unsigned short)keyCode
{
	int ret = 9999;
	
	int pitch = [self keyCode2Pitch:keyCode];
	if (9999 != pitch) {
		pitch += octave * 12;
		if (0 <= pitch && pitch < 128) {
			ret = pitch;
		}
	}
	
	return ret;
}

- (id)init
{
	self = [super init];
    if (self) {
		[self initializeMIDI];
    }
    
    return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ([theEvent isARepeat])
		return;
	
	NSLog(@"%04X", [theEvent keyCode]);
	
	int pitch = [self calcPitch:[theEvent keyCode]];
	if (9999 != pitch) {
		ByteCount bufferSize = 128;
		Byte packetListBuffer[bufferSize];
		MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
		MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
		Byte midiData[3] = {0x90, pitch, 127};
		packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, AudioGetCurrentHostTime(), 3, midiData);
		OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
		if (err != noErr)
			NSLog(@"MIDISend err = %d", err);
		
		if ([delegate respondsToSelector:@selector(didSendNoteOn:pitchName:)])
			[delegate didSendNoteOn:self pitchName:PITCH_NAME_TABLE[pitch]];
	}
	
	[self octaveShift:[theEvent keyCode]];
}

- (void)keyUp:(NSEvent *)theEvent
{
	int pitch = [self calcPitch:[theEvent keyCode]];
	if (9999 != pitch) {
		ByteCount bufferSize = 128;
		Byte packetListBuffer[bufferSize];
		MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
		MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
		Byte midiData[3] = {0x80, pitch, 00};
		packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, AudioGetCurrentHostTime(), 3, midiData);
		OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
		if (err != noErr)
			NSLog(@"MIDISend err = %d", err);
	}
}

- (void)dealloc
{
	OSStatus err;
	
	err = MIDIPortDispose(outPortRef);
	if (err != noErr) NSLog(@"MIDIPortDispose err = %d", err);
	
	err = MIDIClientDispose(clientRef);
	if (err != noErr) NSLog(@"MIDIClientDispose err = %d", err);
	[super dealloc];
}

@end
