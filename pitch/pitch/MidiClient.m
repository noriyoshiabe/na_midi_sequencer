//
//  MidiClient.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MidiClient.h"

#define BUFFER_SIZE 32

@implementation MidiClient

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
}

- (id)init
{
	self = [super init];
    if (self) {
		[self initializeMIDI];
    }
    
    return self;
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

- (void)noteOn:(Byte)channel pitch:(Byte)pitch
{
	Byte packetListBuffer[BUFFER_SIZE];
	MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
	MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
	Byte midiData[3] = {0x90 | channel, pitch, 127};
	packet = MIDIPacketListAdd(packetListPtr, BUFFER_SIZE, packet, AudioGetCurrentHostTime(), 3, midiData);
	OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
	if (err != noErr)
		NSLog(@"MIDISend err = %d", err);
}

- (void)noteOff:(Byte)channel pitch:(Byte)pitch
{
	Byte packetListBuffer[BUFFER_SIZE];
	MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
	MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
	Byte midiData[3] = {0x80 | channel, pitch, 00};
	packet = MIDIPacketListAdd(packetListPtr, BUFFER_SIZE, packet, AudioGetCurrentHostTime(), 3, midiData);
	OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
	if (err != noErr)
		NSLog(@"MIDISend err = %d", err);
}

- (void)bankSelect:(Byte)channel msb:(Byte)msb lsb:(Byte)lsb
{
	Byte packetListBuffer[BUFFER_SIZE];
	MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
	MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
	Byte midiData[3] = {0xB0 | channel, 0x00, msb};
	packet = MIDIPacketListAdd(packetListPtr, BUFFER_SIZE, packet, AudioGetCurrentHostTime(), 3, midiData);
	midiData[1] = 0x20;
	midiData[2] = lsb;
	packet = MIDIPacketListAdd(packetListPtr, BUFFER_SIZE, packet, AudioGetCurrentHostTime(), 3, midiData);
	OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
	if (err != noErr)
		NSLog(@"MIDISend err = %d", err);
}

- (void)programChange:(Byte)channel programNo:(Byte)programNo
{
	Byte packetListBuffer[BUFFER_SIZE];
	MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
	MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
	Byte midiData[2] = {0xC0 | channel, programNo};
	packet = MIDIPacketListAdd(packetListPtr, BUFFER_SIZE, packet, AudioGetCurrentHostTime(), 2, midiData);
	OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
	if (err != noErr)
		NSLog(@"MIDISend err = %d", err);
}

- (void)allSoundOff:(Byte)channel
{
	Byte packetListBuffer[BUFFER_SIZE];
	MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
	MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
	Byte midiData[3] = {0xB0 | channel, 0x78, 0x00};
	packet = MIDIPacketListAdd(packetListPtr, BUFFER_SIZE, packet, AudioGetCurrentHostTime(), 3, midiData);
	OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
	if (err != noErr)
		NSLog(@"MIDISend err = %d", err);
}

@end
