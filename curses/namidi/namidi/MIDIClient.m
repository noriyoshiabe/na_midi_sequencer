//
//  MIDIClient.m
//  namidi
//
//  Created by abechan on 2014/06/21.
//  Copyright (c) 2014年 N/A Products. All rights reserved.
//

#import "MIDIClient.h"
#import <CoreAudio/CoreAudio.h>

@implementation MIDIClient

- (int)open
{
    NSLog(@"open MIDIClient.");
    
    OSStatus err;
    
    NSString *clientName = @"inputClient";
    err = MIDIClientCreate((__bridge CFStringRef)clientName, NULL, NULL, &clientRef);
    if (err != noErr) {
        NSLog(@"MIDIClientCreate err = %d", err);
        return -1;
    }
    
    NSString *outputPortName = @"outputPort";
    err = MIDIOutputPortCreate(clientRef, (__bridge CFStringRef)outputPortName, &outPortRef);
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
    
    NSLog(@"connected to %@", strRef);
    
    CFRelease(strRef);
    
    packetListPtr = (MIDIPacketList *)packetListBuffer;
    
    return 0;
}

- (void)close
{
    NSLog(@"close MIDIClient.");
    
    OSStatus err;
    
    err = MIDIPortDispose(outPortRef);
	if (err != noErr)
        NSLog(@"MIDIPortDispose err = %d", err);
	
	err = MIDIClientDispose(clientRef);
	if (err != noErr)
        NSLog(@"MIDIClientDispose err = %d", err);
}

- (void)sendMessage:(Byte *)message length:(int)length
{
    packet = MIDIPacketListInit(packetListPtr);
    packet = MIDIPacketListAdd(packetListPtr, sizeof(packetListBuffer), packet, AudioGetCurrentHostTime(), length, message);

    OSStatus err = MIDISend(outPortRef, destPointRef, packetListPtr);
    if (err != noErr)
        NSLog(@"MIDISend err = %d", err);
    
    NSMutableString *dump = [[NSMutableString alloc] init];
    for (int i = 0; i < length; ++i) {
        [dump appendFormat:@" %02X", message[i]];
    }
    NSLog(@"message:%@", dump);
    [dump release];
}

@end
