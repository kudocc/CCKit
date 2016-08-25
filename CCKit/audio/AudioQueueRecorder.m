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
    
    // audio queue need some time to start, so during we call AudioQueueStart and it really starts, _starting is YES
    BOOL _starting;
    // audio queue is started
    BOOL _started;
    
    // audio device may not finish immediately after call AudioQueueStop, if you pass false as its second paramter.
    // during we call AudioQueueStop to it really finishs, _stopping is YES
    BOOL _stopping;
    // YES means finished, NO means started
    BOOL _stopped;
}

- (void)audioQueueStartedCallback;
- (void)audioQueueStoppedCallback;

@end

static void HandleInputBuffer (void *aqData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {
    AudioQueueRecorder *recorder = (__bridge AudioQueueRecorder *)aqData;
    
    // call delegate
    [recorder.delegate audioQueueRecorder:recorder recordBuffer:inBuffer streamPacketDescList:inPacketDesc numberOfPacketDescription:inNumPackets];
    
    // enqueue buffer
    AudioQueueEnqueueBuffer(recorder->_audioQueue, inBuffer, 0, NULL);
    
#ifdef DEBUG
    printf("In audio queue record callback\n");
#endif
}

static void AudioQueueIsRunningPropertyChange(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    AudioQueueRecorder *recorder = (__bridge AudioQueueRecorder *)inUserData;
    
    UInt32 isRunning = 0;
    UInt32 size = sizeof(isRunning);
    AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &isRunning, &size);
    if (isRunning) {
        [recorder audioQueueStartedCallback];
    } else {
        [recorder audioQueueStoppedCallback];
    }
}

@implementation AudioQueueRecorder

- (UInt32)deriveAudioBufferWithSeconds:(Float64)seconds {
    // 0x10000 = 5*16*16*16*16 ~ 320k
    static const int maxBufferSize = 0x50000;
    
    int maxPacketSize = _basicDescription.mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty (_audioQueue,
                               kAudioQueueProperty_MaximumOutputPacketSize,
                               &maxPacketSize,
                               &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = 0;
    if (_basicDescription.mFramesPerPacket > 0) {
        numBytesForTime = (_basicDescription.mSampleRate / _basicDescription.mFramesPerPacket) * maxPacketSize * seconds;
    } else {
        numBytesForTime = _basicDescription.mSampleRate * maxPacketSize * seconds;
    }
    
    // don't exceed maxBufferSize
    numBytesForTime = numBytesForTime < maxBufferSize ? numBytesForTime : maxBufferSize;
    // don't less than maxPacketSize
    return numBytesForTime < maxPacketSize ? maxPacketSize : numBytesForTime;
}

- (instancetype)initWithDelegate:(id<AudioQueueRecorderDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _starting = NO;
        _started = NO;
        _recording = NO;
        _stopping = NO;
        _stopped = YES;
        
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
        
        AudioQueueAddPropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, AudioQueueIsRunningPropertyChange, (__bridge void *)self);
        
        UInt32 basicDescriptionSize = sizeof(_basicDescription);
        status = AudioQueueGetProperty(_audioQueue, kAudioQueueProperty_StreamDescription, &_basicDescription, &basicDescriptionSize);
        NSAssert(status == noErr, @"get stream description error");
    }
    return self;
}

- (void)dealloc {
    if (_audioQueue) {
        AudioQueueRemovePropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, AudioQueueIsRunningPropertyChange, (__bridge void *)self);
        
        if (_started) {
            AudioQueueStop(_audioQueue, true);
        }
        AudioQueueDispose(_audioQueue, true);
        
        _audioQueue = NULL;
    }
}

- (BOOL)record {
    // already recording
    if (_recording) {
        return YES;
    }
    
    // during starting
    if (_starting) {
        return NO;
    }
    
    // during stopping, we can't start it
    if (_stopping) {
        return NO;
    }
    
    // now audio queue is paused, resume play
    if (_started) {
        return [self resume];
    }
    
    OSStatus status = noErr;
    _bufferByteSize = [self deriveAudioBufferWithSeconds:0.1];
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
        NSLog(@"Allocate Buffer or Enqueue Buffer error:%d", (int)status);
#endif
        goto Failed_label;
    }
    
    _starting = YES;
    
    // The second parameter
    // The time at which the audio queue should start.
    // To specify a start time relative to the timeline of the associated audio device, use the mSampleTime field of the AudioTimeStamp structure. Use NULL to indicate that the audio queue should start as soon as possible.
    status = AudioQueueStart(_audioQueue, NULL);
    if (status != noErr) {
        goto Failed_label;
    }
    return YES;
    
Failed_label:
    _starting = NO;
    
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
    if (_started) {
        Boolean imme = immediate ? true : false;
        /*
         we don't get the result of AudioQueueStop because I think it would fail if audio queue is already stopped or audio queue is invalid, no matter what it is, the queue would be stopped
         */
        _started = NO;
        
        // audio queue begin to stop
        _stopping = YES;
        
        AudioQueueStop(_audioQueue, imme);
    }
}

- (BOOL)pause {
    if (_recording) {
        // if audio queue is in stopping status, we omit the pause operation and return NO
        if (_stopping) {
#ifdef DEBUG
            NSLog(@"audio queue is in stopping status");
#endif
            return NO;
        }
        
        OSStatus status = AudioQueuePause(_audioQueue);
        if (status == noErr) {
            _recording = NO;
        }
        return status == noErr;
    }
    return NO;
}

- (BOOL)resume {
    if (_started && !_recording) {
        OSStatus status = AudioQueueStart(_audioQueue, NULL);
        if (status == noErr) {
            _recording = YES;
        }
        return status == noErr;
    }
    return NO;
}

#pragma mark -

- (void)audioQueueStartedCallback {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _starting = NO;
    _started = YES;
    _recording = YES;
}

- (void)audioQueueStoppedCallback {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _recording = NO;
    _stopping = NO;
    _stopped = YES;
    
    [_delegate audioQueueRecorderDidFinishRecord:self];
}

@end
