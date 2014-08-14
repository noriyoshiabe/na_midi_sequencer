//
//  SocketServer.h
//  namidi
//
//  Created by abechan on 2014/06/21.
//  Copyright (c) 2014年 N/A Products. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <sys/un.h>

@interface SocketServer : NSObject {
    int sock;
    struct sockaddr_un unixAddr;
    BOOL isExit;
}

- (int)open;
- (void)close;
- (int)run:(void (^)(Byte *bytes, int length))onRecv;

@end
