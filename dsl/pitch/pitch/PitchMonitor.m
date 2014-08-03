//
//  PitchMonitor.m
//  pitch
//
//  Created by abechan on 12/07/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PitchMonitor.h"
#import "NoteEvent.h"

@implementation PitchMonitor
@synthesize delegate;
@synthesize midiClient;
@synthesize noteEvents;
@synthesize octave = _octave;
@synthesize patch = _patch;
@synthesize tempo = _tempo;
@synthesize timeBase = _timeBase;
@synthesize quantize = _quantize;
@synthesize metronomeThread;
@synthesize isMetronomeEnable = _isMetronomeEnable;

static NSString *PITCH_NAME_TABLE[] = {
	@"C0",  @"C#0",  @"D0",  @"D#0",  @"E0",  @"F0",  @"F#0",  @"G0",  @"G#0",  @"A0",  @"A#0",  @"B0", 
	@"C1",  @"C#1",  @"D1",  @"D#1",  @"E1",  @"F1",  @"F#1",  @"G1",  @"G#1",  @"A1",  @"A#1",  @"B1", 
	@"C2",  @"C#2",  @"D2",  @"D#2",  @"E2",  @"F2",  @"F#2",  @"G2",  @"G#2",  @"A2",  @"A#2",  @"B2", 
	@"C3",  @"C#3",  @"D3",  @"D#3",  @"E3",  @"F3",  @"F#3",  @"G3",  @"G#3",  @"A3",  @"A#3",  @"B3", 
	@"C4",  @"C#4",  @"D4",  @"D#4",  @"E4",  @"F4",  @"F#4",  @"G4",  @"G#4",  @"A4",  @"A#4",  @"B4", 
	@"C5",  @"C#5",  @"D5",  @"D#5",  @"E5",  @"F5",  @"F#5",  @"G5",  @"G#5",  @"A5",  @"A#5",  @"B5", 
	@"C6",  @"C#6",  @"D6",  @"D#6",  @"E6",  @"F6",  @"F#6",  @"G6",  @"G#6",  @"A6",  @"A#6",  @"B6", 
	@"C7",  @"C#7",  @"D7",  @"D#7",  @"E7",  @"F7",  @"F#7",  @"G7",  @"G#7",  @"A7",  @"A#7",  @"B7", 
	@"C8",  @"C#8",  @"D8",  @"D#8",  @"E8",  @"F8",  @"F#8",  @"G8",  @"G#8",  @"A8",  @"A#8",  @"B8", 
	@"C9",  @"C#9",  @"D9",  @"D#9",  @"E9",  @"F9",  @"F#9",  @"G9",  @"G#9",  @"A9",  @"A#9",  @"B9", 
	@"C10", @"C#10", @"D10", @"D#10", @"E10", @"F10", @"F#10", @"G10"
};

static NSString *PITCH_NAME_TABLE_DR[] = {
	@"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None",
	@"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None",
	@"None", @"None", @"None", @"High Q", @"Slap", @"Scratch Push", @"Scratch Pull", @"Sticks", @"Square Click", @"Metronome Click", @"Metronome Bell", @"Kick Drum2",
	@"Bass Drum1", @"Side Stick", @"Snare Drum1", @"Hand Clap", @"Snare Drum2", @"Low Tom2", @"Closed Hi-hat", @"Low Tom1", @"Pedal Hi-hat", @"Mid Tom2", @"Open Hi-hat", @"Mid Tom1",
	@"Hi-Mid Tom", @"Crash Cymbal1", @"High Tom1", @"Ride Cymbal1", @"Chinese Cymbal", @"Ride Bell", @"Tambourine", @"Splash Cymbal", @"Cowbell", @"Crash Cymbal2", @"Vibra-Slap", @"Ride Cymbal2",
	@"Hi Bongo", @"Low Bongo", @"Mute High Conga", @"Open High Conga", @"Low Conga", @"High Timbale", @"Low Timbale", @"High Agogo", @"Low Agogo", @"Cabasa", @"Maracas", @"Short Hi Whistle", @"Long Whistle",
	@"Short Guiro", @"Long Guiro", @"Claves", @"High Wood Block", @"Low Wood Block", @"Mute Cuica", @"Open Cuica", @"Mute Triangle", @"Open Triangle", @"Shaker", @"Jingle Bell", @"Bell Tree", @"Castanets",
	@"Mute Surdo", @"Open Surdo", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None",
	@"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None",
	@"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None", @"None",
	@"None", @"None", @"None", @"None"
};

static const int TIMEBASE_TABLE[] = {
	48, 96, 480, 960
};

- (void)notifyTrace:(NSString *)trace
{
	if ([delegate respondsToSelector:@selector(traceEvent:trace:)])
		[delegate traceEvent:self trace:trace];
}

- (void)notifyEventListChanged
{
	if ([delegate respondsToSelector:@selector(eventListChanged:)])
		[delegate eventListChanged:self];
}

- (void)notifyContextChanged
{
	if ([delegate respondsToSelector:@selector(contextChanged:)])
		[delegate contextChanged:self];
}

- (void)notifyClickIndicate:(NSColor *)color
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([delegate respondsToSelector:@selector(clickIndicate:color:)])
			[delegate clickIndicate:self color:color];
	});
}

- (int)keyCode2Pitch:(unsigned short)keyCode
{
	switch (keyCode) {
		case 0x0006: return -3; //A
		case 0x0001: return -2; //A#
		case 0x0007: return -1; //B
		case 0x0008: return 0; //C
		case 0x0003: return 1; //C#
		case 0x0009: return 2; //D
		case 0x0005: return 3; //D#
		case 0x000B: return 4; //E
		case 0x002D: return 5; //F
		case 0x0026: return 6; //F#
		case 0x002E: return 7; //G
		case 0x0028: return 8; //G#
		case 0x002B: return 9; //A
		case 0x0025: return 10; //A#
		case 0x002F: return 11; //B
		case 0x002C: return 12; //C
		case 0x0027: return 13; //C#
		
		case 0x000E: return 7;  //G
		case 0x0014: return 8;  //G#
		case 0x000D: return 9;  //A
		case 0x0013: return 10; //A#
		case 0x000C: return 11; //B
		case 0x000F: return 12; //C
		case 0x0017: return 13; //C#
		case 0x0011: return 14; //D
		case 0x0016: return 15; //D#
		case 0x0010: return 16; //E
		case 0x0020: return 17; //F
		case 0x001C: return 18; //F#
		case 0x0022: return 19; //G
		case 0x0019: return 20; //G#
		case 0x001F: return 21; //A
		case 0x001D: return 22; //A#
		case 0x0023: return 23; //B
		case 0x0021: return 24; //C

		default:
			return 9999;
	}
}

- (NSString *)pitch2String:(int)pitch
{
	if (128 == _patch)
		return PITCH_NAME_TABLE_DR[pitch];
	else
		return PITCH_NAME_TABLE[pitch];
}

- (void)octaveShift:(unsigned short)keyCode
{
	switch (keyCode) {
		case 0x007B:
			--_octave;
			if (0 > _octave)
				_octave = 0;
			[self notifyTrace:[NSString stringWithFormat:@"Octave shift down. %d", _octave]];
			break;
		case 0x007C:
			++_octave;
			if (10 < _octave)
				_octave = 10;
			[self notifyTrace:[NSString stringWithFormat:@"Octave shift up. %d", _octave]];
			break;
	}
}

- (void)patchChange:(unsigned short)keyCode
{
	switch (keyCode) {
		case 0x007E:
			++_patch;
			if (128 < _patch)
				_patch = 0;
			break;
		case 0x007D:
			--_patch;
			if (0 > _patch)
				_patch = 128;
			break;
		default:
			return;
	}
	
	if (128 == _patch) {
		[self.midiClient bankSelect:0 msb:0x7F lsb:0x00];
		[self.midiClient programChange:0 programNo:0x00];
		[self notifyTrace:[NSString stringWithFormat:@"Patch change MSB=0x7F LSB=0x00 PC=0"]];
	}
	else {
		[self.midiClient bankSelect:0 msb:0x00 lsb:0x00];
		[self.midiClient programChange:0 programNo:_patch];
		[self notifyTrace:[NSString stringWithFormat:@"Patch change MSB=0x00 LSB=0x00 PC=%d", _patch]];
	}
	
	[self notifyEventListChanged];
}

- (void)timeBaseUp
{
	++timebaseIndex;
	if (4 <= timebaseIndex)
		timebaseIndex = 0;
	self.timeBase = TIMEBASE_TABLE[timebaseIndex];
	[self setQuantize:self.quantize];
}

- (void)timeBaseDown
{
	--timebaseIndex;
	if (0 > timebaseIndex)
		timebaseIndex = 3;
	self.timeBase = TIMEBASE_TABLE[timebaseIndex];
	[self setQuantize:self.quantize];
}

- (void)setTempo:(float)tempo
{
	_tempo = tempo;
	if (30.0 > _tempo) _tempo = 30.0;
	if (300.0 < _tempo) _tempo = 300.0;
	[self notifyContextChanged];
}

- (float)tempo
{
	return _tempo;
}

- (void)setQuantize:(int)quantize
{
	_quantize = quantize;
	if (1 > _quantize) _quantize = 1;
	if (_timeBase < _quantize) _quantize = _timeBase;
	[self notifyContextChanged];
}

- (int)quantize
{
	return _quantize;
}

- (void)pasteBorad
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSMutableString *result = [NSMutableString string];
	for (NoteEvent *evt in self.noteEvents) {
		NSMutableString *pitchName = [NSMutableString stringWithFormat:@"'%@'", [self pitch2String:evt.pitch]];
		for (int i = 0, append = 18 - [pitchName length]; i < append; ++i)
			[pitchName appendFormat:@" "];
		[result appendFormat:@"note :n => %@", pitchName];
		if (0 < evt.gateTime)
			[result appendFormat:@", :g => %4d", evt.gateTime];
		if (0 < evt.step)
			[result appendFormat:@", :s => %4d", evt.step];
		[result appendString:@"\n"];
	}
	
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[pasteboard setString:result forType:NSStringPboardType];
	
	[self notifyTrace:@"Copied event list to paste borad."];
}

- (BOOL)modifierKeyDown:(NSEvent *)event
{
	if (NSControlKeyMask & [event modifierFlags]) {
		switch ([event keyCode]) {
			case 0x002E: //M
				if ([event isARepeat])
					return false;
				_isMetronomeEnable = !_isMetronomeEnable;
				[self notifyTrace:[NSString stringWithFormat:@"Metronome is %s", _isMetronomeEnable ? "ON" : "OFF"]];
				break;
		}
		return YES;
	}
	else if (NSCommandKeyMask & [event modifierFlags]) {
		switch ([event keyCode]) {
			case 0x0008: //C
				if ([event isARepeat])
					break;
				[self pasteBorad];
				break;
			case 0x007E: //↑
				if (NSShiftKeyMask & [event modifierFlags]) {
					self.tempo = self.tempo + 0.05;
				}
				else {
					self.tempo = self.tempo + 1.0;
				}
				break;
			case 0x007D: //↓
				if (NSShiftKeyMask & [event modifierFlags]) {
					self.tempo = self.tempo - 0.05;
				}
				else {
					self.tempo = self.tempo - 1.0;
				}
				break;
		}
		return YES;
	}
	else if (NSAlternateKeyMask & [event modifierFlags]) {
		switch ([event keyCode]) {
			case 0x007E: //↑
				[self timeBaseUp];
				break;
			case 0x007D: //↓
				[self timeBaseDown];
				break;
		}
		return YES;
	}
	else if (NSShiftKeyMask & [event modifierFlags]) {
		switch ([event keyCode]) {
			case 0x007E: //↑
				[self setQuantize:self.quantize + 1];
				break;
			case 0x007D: //↓
				[self setQuantize:self.quantize - 1];
				break;
		}
		return YES;
	}
	else if (0x0035 == [event keyCode]) { //ESC
		[self.noteEvents removeAllObjects];
		[self notifyEventListChanged];
		[self.midiClient allSoundOff:0];
		[self notifyTrace:@"Clear!!"];
		return YES;
	}
	
	return NO;
}

- (BOOL)modifierKeyUp:(NSEvent *)event
{
	if (NSControlKeyMask & [event modifierFlags]) {
		return YES;
	}
	else if (NSCommandKeyMask & [event modifierFlags]) {
		return YES;
	}
	else if (NSAlternateKeyMask & [event modifierFlags]) {
		return YES;
	}
	else if (NSShiftKeyMask & [event modifierFlags]) {
		return YES;
	}
	else if (0x0035 == [event keyCode]) { //ESC
		return YES;
	}
	
	return NO;
}

- (int)calcPitch:(unsigned short)keyCode
{
	int ret = 9999;
	
	int pitch = [self keyCode2Pitch:keyCode];
	if (9999 != pitch) {
		pitch += _octave * 12;
		if (0 <= pitch && pitch < 128) {
			ret = pitch;
		}
	}
	
	return ret;
}

- (UInt64)calcNextBeatTime:(UInt64)time
{
	return time + ((UInt64)kSecondScale * 6000) / (UInt64)(_tempo * 100.0f);
}

- (int)calcStep:(UInt64)time
{
	UInt64 tickTime = (((UInt64)kSecondScale * 6000) / (UInt64)(_tempo * 100.0f)) / _timeBase;
	return (int)(time / tickTime);
}

- (int)quantize:(int)step
{
	return ((step + _quantize / 2) / _quantize) * _quantize;
}

- (void)noteOn:(Byte)pitch
{
	UInt64 currentTime = AudioGetCurrentHostTime();
	int step = 0 == lastTime ? 0 : [self calcStep:currentTime - lastTime];
	step = [self quantize:step];
	lastTime = currentTime;
	NoteEvent *evt = [self.noteEvents lastObject];
	if (evt)
		evt.step = step;
	
	[self.noteEvents addObject:[NoteEvent noteEvemt:currentTime pitch:pitch]];
	[self notifyEventListChanged];
}

- (void)noteOff:(Byte)pitch
{
	for (int i = [self.noteEvents count] - 1; 0 <= i; --i) {
		NoteEvent *evt = [self.noteEvents objectAtIndex:i];
		if (pitch == evt.pitch) {
			int step = [self calcStep:AudioGetCurrentHostTime() - evt.absTime];
			step = [self quantize:step];
			evt.gateTime = step;
			break;
		}
	}
	[self notifyEventListChanged];
}

- (void)metronome
{
	while (!isFinished) {
		usleep(100);
		UInt64 time = AudioGetCurrentHostTime();
		if (nextTickTime < time) {
			++tick;
			if (0 == tick % 4) {
				if (_isMetronomeEnable) {
					[self.midiClient noteOn:1 pitch:84];
					[self.midiClient noteOff:1 pitch:84];
				}
				[self notifyClickIndicate:[NSColor redColor]];
			}
			else {
				if (_isMetronomeEnable) {
					[self.midiClient noteOn:1 pitch:72];
					[self.midiClient noteOff:1 pitch:72];
				}
				[self notifyClickIndicate:[NSColor greenColor]];
			}
			nextTickTime = [self calcNextBeatTime:nextTickTime];
		}
		else if ((nextTickTime - time) < (((UInt64)kSecondScale * 6000) / (UInt64)(_tempo * 100.0f) / 4 * 3)) {
			[self notifyClickIndicate:[NSColor whiteColor]];
		}
	}
}

- (id)init
{
	self = [super init];
    if (self) {
		self.midiClient = [[[MidiClient alloc] init] autorelease];
		self.noteEvents = [NSMutableArray array];
		self.octave = 5;
		self.tempo = 120.0;
		self.timeBase = 48;
		self.quantize = 1;
		
		[self.midiClient bankSelect:0 msb:0x00 lsb:0x00];
		[self.midiClient programChange:0 programNo:0];
		[self.midiClient bankSelect:1 msb:0x00 lsb:0x00];
		[self.midiClient programChange:1 programNo:115];
		self.metronomeThread = [[NSThread alloc] initWithTarget:self selector:@selector(metronome) object:nil];
		nextTickTime = [self calcNextBeatTime:AudioGetCurrentHostTime()];
		[self.metronomeThread start];
    }
    
    return self;
}

- (void)dealloc
{
	isFinished = YES;
	while (![self.metronomeThread isFinished])
		usleep(1000); 
	self.noteEvents = nil;
	self.midiClient = nil;
	[super dealloc];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ([self modifierKeyDown:theEvent])
		return;
	
	[self patchChange:[theEvent keyCode]];
	
	if ([theEvent isARepeat])
		return;
	
	int pitch = [self calcPitch:[theEvent keyCode]];
	if (9999 != pitch) {
		[self.midiClient noteOn:0 pitch:pitch];
		[self notifyTrace:[NSString stringWithFormat:@"Note On pitch=%@", [self pitch2String:pitch]]];
		[self noteOn:pitch];
	}
	
	[self octaveShift:[theEvent keyCode]];
}

- (void)keyUp:(NSEvent *)theEvent
{
	if ([self modifierKeyUp:theEvent])
		return;
	
	int pitch = [self calcPitch:[theEvent keyCode]];
	if (9999 != pitch) {
		[self.midiClient noteOff:0 pitch:pitch];
		[self notifyTrace:[NSString stringWithFormat:@"Note Off pitch=%@", [self pitch2String:pitch]]];
		[self noteOff:pitch];
	}
}

@end
