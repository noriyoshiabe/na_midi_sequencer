//
//  AppDelegate.m
//  pitch
//
//  Created by abechan on 12/07/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController;

- (void)dealloc
{
	self.mainViewController = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.mainViewController = [[[MainViewController alloc] initWithNibName:NSStringFromClass([MainViewController class]) bundle:nil] autorelease];
	[self.window.contentView addSubview:self.mainViewController.view];
	[self.window makeFirstResponder:self.mainViewController];
}

@end
