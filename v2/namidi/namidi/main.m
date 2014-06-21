//
//  main.m
//  namidi
//
//  Created by abechan on 2014/06/21.
//  Copyright (c) 2014年 N/A Products. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#include <signal.h>
#include <errno.h>
#import "MIDIClient.h"
#import "SocketServer.h"

static MIDIClient *midiClient;
static SocketServer *socketServer;

static void signal_handler(int signum)
{
    [socketServer close];
}

int main(int argc, const char * argv[])
{
    if (SIG_ERR == signal(SIGINT, signal_handler)) {
        NSLog(@"register signal handler faled. errno=%d\n", errno);
        return 1;
    }
    
    midiClient = [[MIDIClient alloc] init];
    socketServer = [[SocketServer alloc] init];

    [midiClient open];
    [socketServer open];
    
    [socketServer run:^(Byte *bytes, int length) {
        [midiClient sendMessage:bytes length:length];
    }];
    
    [midiClient close];
    [midiClient release];
    
    [socketServer release];
    
    return 0;
}

