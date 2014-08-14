//
//  AppDelegate.h
//  pitch
//
//  Created by abechan on 12/07/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (retain) MainViewController *mainViewController;

@end
