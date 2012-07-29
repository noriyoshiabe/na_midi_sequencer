//
//  MainViewController.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize pitchMonitor;
@synthesize logOutput;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.pitchMonitor = [[[PitchMonitor alloc] init] autorelease];
		self.pitchMonitor.delegate = self;
    }
    
    return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
	[self.pitchMonitor keyDown:theEvent];
}

- (void)keyUp:(NSEvent *)theEvent
{
	[self.pitchMonitor keyUp:theEvent];
}

- (void)dealloc
{
	self.pitchMonitor.delegate = nil;
	self.pitchMonitor = nil;
	[super dealloc];
}

- (void)didSendNoteOn:(PitchMonitor *)sender pitchName:(NSString *)pitchName
{
	[self.logOutput appendText:[NSString stringWithFormat:@"%@\n", pitchName]];
}

@end
