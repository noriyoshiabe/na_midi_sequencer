//
//  main.m
//  midi
//
//  Created by abechan on 12/07/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>
#import <CoreAudio/CoreAudio.h>

int main(int argc, const char * argv[])
{
	MIDIClientRef clientRef;
    MIDIPortRef outPortRef;
    MIDIEndpointRef destPointRef;
	
	OSStatus err;
    
    NSString *clientName = @"inputClient";
    err = MIDIClientCreate((CFStringRef)clientName, NULL, NULL, &clientRef);
    if (err != noErr) {
        NSLog(@"MIDIClientCreate err = %d", err);
        return -1;
    }
    
    NSString *outputPortName = @"outputPort";
    err = MIDIOutputPortCreate(clientRef, (CFStringRef)outputPortName, &outPortRef);
    if (err != noErr) {
        NSLog(@"MIDIOutputPortCreate err = %d", err);
        return -1;
    }
    
    destPointRef = MIDIGetDestination(0);
    
    CFStringRef strRef;
    err = MIDIObjectGetStringProperty(destPointRef, kMIDIPropertyDisplayName, &strRef);
    if (err != noErr) {
        NSLog(@"MIDIObjectGetStringProperty err = %d", err);
        return -1;
    }
    NSLog(@"connect = %@", strRef);
    CFRelease(strRef);
	
	ByteCount bufferSize = 1024;
    Byte packetListBuffer[bufferSize];
    MIDIPacketList *packetListPtr = (MIDIPacketList *)packetListBuffer;
    MIDIPacket *packet = MIDIPacketListInit(packetListPtr);
	
#define TICK_TIME() ((((UInt64)kSecondScale * 6000) / (UInt64)(tempo * 100.0f)) / timeBase)
#define NEXT_TICK_TIME() (startTime + TICK_TIME() * (currentTick + 1))

	float tempo = 120.0f;
	UInt64 timeBase = 48;
	
	int currentTick = 0;
	
	UInt64 startTime = AudioGetCurrentHostTime();
	UInt64 currentTime;
	
	char lineBuf[18+1+1];
	Byte midiData[3];
	
	// TODO シグナル取って終了させる
	while (1) {
		if (!fgets(lineBuf, sizeof(lineBuf), stdin))
			continue;
		
		currentTime = AudioGetCurrentHostTime();
		char buf[9]; buf[8] = '\0';
		strncpy(buf, lineBuf, 8);
		long tick = strtol(buf, NULL, 10);
		while (tick > currentTick) {
			currentTime = AudioGetCurrentHostTime();
			if (NEXT_TICK_TIME() < currentTime)
				++currentTick;
			else
				usleep(10);
		}
		
		Byte c;
		switch (lineBuf[8]) {
			case 'N':
				buf[2] = '\0';
				strncpy(buf, &lineBuf[10], 2);
				c = strtol(buf, NULL, 16);
				midiData[0] = 0x90 | (c & 0x0F);
				strncpy(buf, &lineBuf[12], 2);
				midiData[1] = (Byte)strtol(buf, NULL, 16);
				strncpy(buf, &lineBuf[16], 2);
				midiData[2] = (Byte)strtol(buf, NULL, 16);
				
				packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, currentTime, 3, midiData);
				NSLog(@"NOTE ON %02X %02X %02X", midiData[0], midiData[1], midiData[2]);
				
				midiData[0] = 0x80 | (c & 0x0F);
				midiData[2] = 0x00;
				strncpy(buf, &lineBuf[14], 2);
				packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, currentTime + TICK_TIME() * (UInt64)strtol(buf, NULL, 16), 3, midiData);
				NSLog(@"NOTE OFF %02X %02X %02X", midiData[0], midiData[1], midiData[2]);
				
				err = MIDISend(outPortRef, destPointRef, packetListPtr);
				if (err != noErr)
					NSLog(@"MIDISend err = %d", err);
				packet = MIDIPacketListInit(packetListPtr);
				break;
				
			case 'P':
				buf[2] = '\0';
				strncpy(buf, &lineBuf[10], 2);
				c = strtol(buf, NULL, 16);
				
				midiData[0] = 0xB0 | (c & 0x0F);
				midiData[1] = 0x00;
				strncpy(buf, &lineBuf[12], 2);
				midiData[2] = (Byte)strtol(buf, NULL, 16);
				
				packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, currentTime, 3, midiData);
				NSLog(@"BANK SELECT %02X %02X %02X", midiData[0], midiData[1], midiData[2]);
				
				midiData[1] = 0x20;
				strncpy(buf, &lineBuf[14], 2);
				midiData[2] = (Byte)strtol(buf, NULL, 16);
				packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, currentTime, 3, midiData);
				NSLog(@"BANK SELECT %02X %02X %02X", midiData[0], midiData[1], midiData[2]);
				
				midiData[0] = 0xC0 | (c & 0x0F);
				strncpy(buf, &lineBuf[16], 2);
				midiData[1] = (Byte)strtol(buf, NULL, 16);
				packet = MIDIPacketListAdd(packetListPtr, bufferSize, packet, currentTime, 2, midiData);
				NSLog(@"PROGRAM CHANGE %02X %02X", midiData[0], midiData[1]);
				
				err = MIDISend(outPortRef, destPointRef, packetListPtr);
				if (err != noErr)
					NSLog(@"MIDISend err = %d", err);
				packet = MIDIPacketListInit(packetListPtr);
				break;
			case 'T':
				switch (lineBuf[9]) {
					case 'C':
						buf[6] = '\0';
						strncpy(buf, &lineBuf[12], 6);
						tempo = strtof(buf, NULL);
						NSLog(@"TEMPO CHANGE %3.2f", tempo);
						break;
					case 'B':
						buf[3] = '\0';
						strncpy(buf, &lineBuf[12], 3);
						timeBase = strtol(buf, NULL, 10);
						NSLog(@"TIME BASE CHANGE %s %llu", buf, timeBase);
						break;
				}
				break;
		}
	}
	
	err = MIDIPortDispose(outPortRef);
	if (err != noErr) NSLog(@"MIDIPortDispose err = %d", err);
	
	err = MIDIClientDispose(clientRef);
	if (err != noErr) NSLog(@"MIDIClientDispose err = %d", err);
	
    return 0;
}
