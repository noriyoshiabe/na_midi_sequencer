//
//  MainView.m
//  pitch
//
//  Created by abechan on 12/07/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"

@implementation MainView

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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeMIDI];
		[self.window makeFirstResponder:self];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (BOOL)acceptsFirstResponder
{
	return YES;
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
