//
//  AudioQueueRecorder.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioQueueRecorder.h"

#define kNumberBuffers 3

@interface AudioQueueRecorder () {
    @public
    AudioStreamBasicDescription _basicDescription;
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioQueueBuffer[kNumberBuffers];
    UInt32 _bufferByteSize;
    
    BOOL _finished;
}

@end

static void HandleInputBuffer (void *aqData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {
    AudioQueueRecorder *sself = (__bridge AudioQueueRecorder *)aqData;
    
    // call delegate
    [sself.delegate recorder:sself recordBuffer:inBuffer streamPacketDescList:inPacketDesc numberOfPacketDescription:inNumPackets];
    
    // enqueue buffer
    AudioQueueEnqueueBuffer(sself->_audioQueue, inBuffer, 0, NULL);
    
    printf("IN HANDLE INPUT BUFFER\n");
}

@implementation AudioQueueRecorder

- (UInt32)deriveAudioBufferWithSeconds:(Float64)seconds {
    // 0x10000 = 1*16*16*16*16 ~ 64k
    static const int maxBufferSize = 0x10000;
    
    int maxPacketSize = _basicDescription.mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (_audioQueue,
                               kAudioQueueProperty_MaximumOutputPacketSize,
                               &maxPacketSize,
                               &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = _basicDescription.mSampleRate * maxPacketSize * seconds;
    numBytesForTime = numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize;
    return numBytesForTime < maxPacketSize ? maxPacketSize : numBytesForTime;
}

- (instancetype)initWithDelegate:(id<AudioQueueRecorderDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _finished = YES;
        
        // set up `AudioStreamBasicDescription`
        _basicDescription = [_delegate audioStreamBasicDescriptionOfRecorder:self];
        
        // create a record audio queue, callback run in CommonMode of Main Thread
        OSStatus status = AudioQueueNewInput(&_basicDescription, HandleInputBuffer, (__bridge void *)self,
                                    CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &_audioQueue);
        if (status != noErr) {
            // kAudioFormatUnsupportedDataFormatError is 1718449215
            _audioQueue = nil;
            return self;
        }
        
        UInt32 basicDescriptionSize = sizeof(_basicDescription);
        status = AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_StreamDescription, &_basicDescription, &basicDescriptionSize);
        NSAssert(status == noErr, @"get stream description error");
    }
    return self;
}

- (void)dealloc {
    if (_audioQueue) {
        // if audio queue doesn't finish, stop it
        if (!_finished) {
            AudioQueueStop(_audioQueue, true);
        }
        AudioQueueDispose(_audioQueue, true);
        
        _audioQueue = NULL;
    }
}

- (BOOL)record {
    // aq is recording
    if (_recording) {
        return YES;
    }
    
    if (!_finished) {
        return [self resume];
    }
    
    OSStatus status = noErr;
    _bufferByteSize = [self deriveAudioBufferWithSeconds:0.2];
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        status = AudioQueueAllocateBuffer(_audioQueue, _bufferByteSize, &_audioQueueBuffer[i]);
        if (status != noErr) {
            break;
        }
        status = AudioQueueEnqueueBuffer(_audioQueue, _audioQueueBuffer[i], 0, NULL);
        if (status != noErr) {
            break;
        }
    }
    if (status != noErr) {
#ifdef DEBUG
        NSLog(@"Allocate Buffer or Enqueue Buffer error:%d", status);
#endif
        goto Failed_label;
    }
    
    // The second parameter
    // The time at which the audio queue should start.
    // To specify a start time relative to the timeline of the associated audio device, use the mSampleTime field of the AudioTimeStamp structure. Use NULL to indicate that the audio queue should start as soon as possible.
    status = AudioQueueStart(_audioQueue, NULL);
    if (status != noErr) {
        goto Failed_label;
    }
    
    _recording = YES;
    _finished = NO;
    
    return YES;
    
Failed_label:
    if (_audioQueue) {
        AudioQueueDispose(_audioQueue, false);
        _audioQueue = NULL;
    }
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        _audioQueueBuffer[i] = NULL;
    }
    
    return NO;
}

- (void)stop {
    [self stopImmediately:NO];
}

- (void)stopImmediately:(BOOL)immediate {
    // aq is already finished
    if (_finished) {
        return;
    }
    
    if (_audioQueue) {
        Boolean imme = immediate ? true : false;
        AudioQueueStop(_audioQueue, imme);
    }
    _recording = NO;
    _finished = YES;
}

- (BOOL)pause {
    // aq is already paused
    if (!_recording) {
        return YES;
    }
    
    if (_audioQueue) {
        OSStatus status = AudioQueuePause(_audioQueue);
        if (status == noErr) {
            _recording = NO;
        }
        return status == noErr;
    }
    return NO;
}

- (BOOL)resume {
    // aq is recording
    if (_recording) {
        return YES;
    }
    
    if (_audioQueue) {
        OSStatus status = AudioQueueStart(_audioQueue, NULL);
        if (status == noErr) {
            _recording = YES;
        }
        return status != noErr;
    }
    return NO;
}

@end
