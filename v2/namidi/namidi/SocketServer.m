//
//  SocketServer.m
//  namidi
//
//  Created by abechan on 2014/06/21.
//  Copyright (c) 2014年 N/A Products. All rights reserved.
//

#import "SocketServer.h"
#include <errno.h>

#define	SOCK_FILE	"/tmp/namidi.sock"

@implementation SocketServer

- (int)open
{
    NSLog(@"open SocketServer.");
    
    if (-1 == (sock = socket(AF_UNIX, SOCK_STREAM, 0))) {
        NSLog(@"socket create faled. errno=%d\n", errno);
        return -1;
    }
    
    unixAddr.sun_family = AF_UNIX;
    strcpy(unixAddr.sun_path, SOCK_FILE);
    
    if (-1 == bind(sock, (struct sockaddr *)&unixAddr, sizeof(unixAddr))) {
        NSLog(@"socket bind faled. errno=%d\n", errno);
        return -1;
    }
    
    return 0;
}

- (void)close
{
    NSLog(@"close SocketServer.");
    
    isExit = YES;
    shutdown(sock, SHUT_RDWR);
    close(sock);
    unlink(SOCK_FILE);
}

- (int)run:(void (^)(Byte *bytes, int length))onRecv
{
    NSLog(@"start SocketServer.");
    
    while (0 == listen(sock, 64)) {
        socklen_t len = sizeof(unixAddr);
        int fd = accept(sock, (struct sockaddr *)&unixAddr, &len);
        if (-1 == fd) {
            if (!isExit) {
                NSLog(@"accept faild. errno=%d\n", errno);
                return -1;
            }
            return 0;
        }
        
        Byte buf[256] = {0};
        ssize_t length;
        if (0 > (length = recv(fd, buf, sizeof(buf), 0))) {
            NSLog(@"recv faild. errno=%d\n", errno);
        } else {
            onRecv(buf, (int)length);
        }
        
        close(fd);
    }
    
    return 0;
}

@end
