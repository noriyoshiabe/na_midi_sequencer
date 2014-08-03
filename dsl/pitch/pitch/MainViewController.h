//
//  MainViewController.h
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PitchMonitor.h"
#import "TextView.h"

@interface MainViewController : NSViewController<PitchMonitorDelegate, NSTextViewDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (retain) PitchMonitor *pitchMonitor;
@property (assign) IBOutlet TextView *logOutput;
@property (assign) IBOutlet NSTableView *listView;
@property (assign) IBOutlet NSTextField *tempoField;
@property (assign) IBOutlet NSTextField *timeBaseField;
@property (assign) IBOutlet NSTextField *quantizeField;
@property (assign) IBOutlet NSTextField *clickIndicator;

@end
