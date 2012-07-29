//
//  NoteEvent.h
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteEvent : NSObject

@property UInt64 absTime;
@property Byte pitch;
@property int gateTime;
@property int step;

+ (id)noteEvemt:(UInt64)absTime pitch:(Byte)pitch;

@end
