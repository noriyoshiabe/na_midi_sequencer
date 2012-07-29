//
//  NoteEvent.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoteEvent.h"

@implementation NoteEvent

@synthesize absTime;
@synthesize pitch;
@synthesize gateTime;
@synthesize step;

+ (id)noteEvemt:(UInt64)absTime pitch:(Byte)pitch
{
	NoteEvent *ret = [[[NoteEvent alloc] init] autorelease];
	ret.absTime = absTime;
	ret.pitch = pitch;
	ret.step = 0;
	ret.gateTime = 0;
	return ret;
}

@end
