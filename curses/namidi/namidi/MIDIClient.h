//
//  MIDIClient.h
//  namidi
//
//  Created by abechan on 2014/06/21.
//  Copyright (c) 2014年 N/A Products. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@interface MIDIClient : NSObject {
    MIDIClientRef clientRef;
    MIDIPortRef outPortRef;
    MIDIEndpointRef destPointRef;
    Byte packetListBuffer[1024];
    MIDIPacketList *packetListPtr;
    MIDIPacket *packet;
}

- (int)open;
- (void)close;
- (void)sendMessage:(Byte *)message length:(int)length;

@end
