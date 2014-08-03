//
//  MainViewController.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "NoteEvent.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize pitchMonitor;
@synthesize logOutput;
@synthesize listView;
@synthesize tempoField;
@synthesize timeBaseField;
@synthesize clickIndicator;
@synthesize quantizeField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.pitchMonitor = [[[PitchMonitor alloc] init] autorelease];
		self.pitchMonitor.delegate = self;
    }
    
    return self;
}

- (void)loadView
{
	[super loadView];
	[self contextChanged:nil];
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

- (void)traceEvent:(PitchMonitor *)sender trace:(NSString *)trace
{
	[self.logOutput setString:[NSString stringWithFormat:@"%@\n", trace]];
}

- (void)eventListChanged:(PitchMonitor *)sender
{
	[self.listView reloadData];
	[self.listView scrollToEndOfDocument:self.listView];
}

- (void)contextChanged:(PitchMonitor *)sender
{
	self.tempoField.stringValue = [NSString stringWithFormat:@"%3.2f", self.pitchMonitor.tempo];
	self.timeBaseField.stringValue = [NSString stringWithFormat:@"%d", self.pitchMonitor.timeBase];
	self.quantizeField.stringValue = [NSString stringWithFormat:@"%d", self.pitchMonitor.quantize];
}

- (void)clickIndicate:(PitchMonitor *)sender color:(NSColor *)color
{
	self.clickIndicator.backgroundColor = color;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [self.pitchMonitor.noteEvents count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NoteEvent *evt = [self.pitchMonitor.noteEvents objectAtIndex:row];
	if ([[tableColumn identifier] isEqualToString:@"pitch"]) {
		return [self.pitchMonitor pitch2String:evt.pitch];
	}
	else if ([[tableColumn identifier] isEqualToString:@"gate_time"]) {
		if (0 != evt.gateTime)
			return [NSString stringWithFormat:@"%d", evt.gateTime];
	}
	else if ([[tableColumn identifier] isEqualToString:@"step"]) {
		if (0 != evt.step)
			return [NSString stringWithFormat:@"%d", evt.step];
	}
	
	return @"";
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	return 11.0f;
}

@end
