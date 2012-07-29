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

@interface MainViewController : NSViewController<PitchMonitorDelegate>

@property (retain) PitchMonitor *pitchMonitor;
@property (assign) IBOutlet TextView *logOutput;

@end
