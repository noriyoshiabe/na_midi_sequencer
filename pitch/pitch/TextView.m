//
//  TextView.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TextView.h"

@implementation TextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (void)appendText:(NSString*)text
{
    NSRange	wholeRange;
    NSRange	endRange;
    
	[self selectAll:nil];
    wholeRange = [self selectedRange];
    endRange = NSMakeRange(wholeRange.length, 0);
    [self setSelectedRange:endRange];
    [self insertText:text];
}

@end
