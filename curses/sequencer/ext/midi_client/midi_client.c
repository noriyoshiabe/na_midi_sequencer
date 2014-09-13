#include <ruby.h>
#include <CoreMIDI/CoreMIDI.h>

#ifdef DEBUG
#define LogDebug(...) printf(__VA_ARGS__),printf("\n")
#else
#define LogDebug(...)
#endif

#define PACKET_LIST_SIZE 1024

struct MidiClient {
    MIDIClientRef clientRef;
    MIDIPortRef outPortRef;
    MIDIEndpointRef destPointRef;
    MIDIPacketList *packetListPtr;
};

static void __MidiClient_free(void *p)
{
    LogDebug("__MidiClient_free()");
    struct MidiClient *self = p;
    free(self->packetListPtr);
}

static VALUE __MidiClient_alloc(VALUE klass)
{
    LogDebug("__MidiClient_alloc()");

    VALUE obj;
    struct MidiClient *ptr;

    obj = Data_Make_Struct(klass, struct MidiClient, NULL, __MidiClient_free, ptr);

    return obj;
}

static VALUE __MidiClient_initialize(VALUE _self)
{
    LogDebug("__MidiClient_initialize()");

    struct MidiClient *self;
    Data_Get_Struct(_self, struct MidiClient, self);

    OSStatus err;

    err = MIDIClientCreate(CFSTR("namidi:MidiClient"), NULL, NULL, &self->clientRef);
    if (err != noErr) {
        rb_raise(rb_eSystemCallError, "MIDIClientCreate err = %d", err);
    }
    
    err = MIDIOutputPortCreate(self->clientRef, CFSTR("namidi:MidiClient:outPort"), &self->outPortRef);
    if (err != noErr) {
        rb_raise(rb_eSystemCallError, "MIDIOutputPortCreate err = %d", err);
    }
    
    self->destPointRef = MIDIGetDestination(0);
    
    CFStringRef strRef;
    err = MIDIObjectGetStringProperty(self->destPointRef, kMIDIPropertyDisplayName, &strRef);
    if (err != noErr) {
        rb_raise(rb_eSystemCallError, "MIDIObjectGetStringProperty err = %d", err);
    }
    
    char cstr[64];
    CFStringGetCString(strRef, cstr, sizeof(cstr), kCFStringEncodingUTF8);
    LogDebug("connected to %s", cstr);
    
    CFRelease(strRef);
    
    self->packetListPtr = (MIDIPacketList *)malloc(PACKET_LIST_SIZE);
    
    return _self;
}

static VALUE __MidiClient_send(VALUE _self, VALUE data)
{
    LogDebug("__MidiClient_send()");

    struct MidiClient *self;
    Data_Get_Struct(_self, struct MidiClient, self);

    Byte *message = (Byte *)RSTRING_PTR(data);
    long length = RSTRING_LEN(data);

    MIDIPacket *packet = MIDIPacketListInit(self->packetListPtr);
    packet = MIDIPacketListAdd(self->packetListPtr, PACKET_LIST_SIZE, packet, 0, length, message);

    OSStatus err = MIDISend(self->outPortRef, self->destPointRef, self->packetListPtr);
    if (err != noErr) {
        LogDebug("MIDISend err = %d", err);
    }

#ifdef DEBUG
    char buf[256] = {0};
    for (int i = 0; i < length; ++i) {
        char s[4];
        sprintf(s, " %02X", message[i]);
        strcat(buf, s);
    }
    LogDebug("message: %s", buf);
#endif

    return _self;
}

static VALUE __MidiClient_close(VALUE _self)
{
    LogDebug("__MidiClient_close()");

    struct MidiClient *self;
    Data_Get_Struct(_self, struct MidiClient, self);

    OSStatus err;
    
    err = MIDIPortDispose(self->outPortRef);
	if (err != noErr) {
        rb_raise(rb_eSystemCallError, "MIDIPortDispose err = %d", err);
    }
	
	err = MIDIClientDispose(self->clientRef);
	if (err != noErr) {
        rb_raise(rb_eSystemCallError, "MIDIClientDispose err = %d", err);
    }

    return _self;
}

void Init_midi_client(void)
{
    LogDebug("Init_midi_client()");

    VALUE cMidiClient;

    cMidiClient = rb_const_get(rb_cObject, rb_intern("MidiClient"));

    rb_define_alloc_func(cMidiClient, __MidiClient_alloc);
    rb_define_method(cMidiClient, "initialize", __MidiClient_initialize, 0);
    rb_define_method(cMidiClient, "send", __MidiClient_send, 1);
    rb_define_method(cMidiClient, "close", __MidiClient_close, 0);
}
