//
//  AudioQueuePlayer.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioQueuePlayer.h"

#define kNumberBuffers 3

@interface AudioQueuePlayer () {
@public
    AudioStreamBasicDescription _basicDescription;
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioQueueBuffer[kNumberBuffers];
    UInt32 _bufferByteSize;
    UInt32 _numPacketRead;
    AudioStreamPacketDescription *_packetDescription;
    
    /*
                                                   |--playing--|
    |--starting--|--playing--|--pause--|--playing--|--stoping--|--stoped--|
                 |---------started-----------------|
    */
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

- (void)stopImmediately:(BOOL)immediate;

- (void)audioQueueStartedCallback;
- (void)audioQueueStoppedCallback;

@end

static void HandleOutputBuffer (void *aqData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer *)aqData;
    if (!player->_starting &&
        !player->_started) {
        return;
    }
    
    UInt32 readPacketNumber = 0;
    UInt32 readByteNumber = 0;
    [player.delegate audioQueuePlayer:player
                          primeBuffer:inBuffer
              streamPacketDescription:player->_packetDescription
                    descriptionNumber:player->_numPacketRead
                     readPacketNumber:&readPacketNumber
                       readByteNumber:&readByteNumber];
#ifdef DEBUG
    NSLog(@"read %@ packets, %@ bytes from file", @(readPacketNumber), @(readByteNumber));
#endif
    
    if (readPacketNumber > 0) {
        inBuffer->mAudioDataByteSize = readByteNumber;
        OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, (player->_packetDescription ? readPacketNumber : 0), player->_packetDescription);
        if (status != noErr) {
#ifdef DEBUG
            NSLog(@"AudioQueueEnqueueBuffer error:%d", status);
#endif
        }
    } else {
#ifdef DEBUG
        NSLog(@"AudioQueueStop");
#endif
        [player stopImmediately:NO];
    }
}

void AudioQueueIsRunningPropertyChange(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    AudioQueuePlayer *player = (__bridge AudioQueuePlayer *)inUserData;
    
    UInt32 isRunning = 0;
    UInt32 size = sizeof(isRunning);
    AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &isRunning, &size);
    if (isRunning) {
        [player audioQueueStartedCallback];
    } else {
        [player audioQueueStoppedCallback];
    }
}

@implementation AudioQueuePlayer

- (instancetype)initWithDelegate:(id<AudioQueuePlayerDelegate>)delegate {
    self = [super init];
    if (self) {
        _starting = NO;
        _started = NO;
        _playing = NO;
        _stopping = NO;
        _stopped = YES;
        
        _delegate = delegate;
        
        _audioQueue = NULL;
        for (NSInteger i = 0; i < kNumberBuffers; ++i) {
            _audioQueueBuffer[i] = NULL;
        }
        
        // set up `AudioStreamBasicDescription`
        _basicDescription = [_delegate audioStreamBasicDescriptionOfPlayer:self];
        
        // create a playback audio queue
        OSStatus status = AudioQueueNewOutput(&_basicDescription, HandleOutputBuffer, (__bridge void *)self,
                                              CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &_audioQueue);
        if (status != noErr) {
            // kAudioFormatUnsupportedDataFormatError is 1718449215
            _audioQueue = NULL;
            
            // Does it cause memory leak?
            return nil;
        }
        
        AudioQueueAddPropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, AudioQueueIsRunningPropertyChange, (__bridge void *)self);
        
        // get max buffer size and packet to read
        [_delegate audioQueuePlayer:self getBufferByteSize:&_bufferByteSize packetToReadNumber:&_numPacketRead];
        
        bool isFormatVBR = (_basicDescription.mBytesPerPacket == 0 ||
                            _basicDescription.mFramesPerPacket == 0);
        
        if (isFormatVBR) {
            _packetDescription = (AudioStreamPacketDescription*)malloc(_numPacketRead * sizeof(AudioStreamPacketDescription));
        } else {
            _packetDescription = NULL;
        }
        
        status = noErr;
        for (NSInteger i = 0; i < kNumberBuffers; ++i) {
            status = AudioQueueAllocateBuffer(_audioQueue, _bufferByteSize, &_audioQueueBuffer[i]);
            if (status != noErr) {
                break;
            }
        }
        
        if (status != noErr) {
            AudioQueueDispose(_audioQueue, false);
            return nil;
        }
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
    
    if (_packetDescription) {
        free(_packetDescription);
        _packetDescription = NULL;
    }
}

- (BOOL)play {
    // already playing
    if (_playing) {
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
    
    // set starting = YES, make HandleOutputBuffer work
    _starting = YES;
    for (NSInteger i = 0; i < kNumberBuffers; ++i) {
        // prime audio
        HandleOutputBuffer((__bridge void *)self, _audioQueue, _audioQueueBuffer[i]);
    }
    
    OSStatus status = noErr;
    
    Float32 gain = 1.0;
    // Optionally, allow user to override gain setting here
    status = AudioQueueSetParameter(_audioQueue, kAudioQueueParam_Volume, gain);
    if (status != noErr) {
#ifdef DEBUG
        NSLog(@"Set Audio Queue Volume error:%d", status);
#endif
    }
    
    // The second parameter
    // The time at which the audio queue should start.
    // To specify a start time relative to the timeline of the associated audio device, use the mSampleTime field of the AudioTimeStamp structure. Use NULL to indicate that the audio queue should start as soon as possible.
    NSLog(@"begin start");
    status = AudioQueueStart(_audioQueue, NULL);
    NSLog(@"end start");
    if (status != noErr) {
#ifdef DEBUG
        NSLog(@"AudioQueueStart failed:%d", status);
#endif
        // -50 其中一个原因查看AVAudioSession的category是否正确设置
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
    
    if (_packetDescription) {
        free(_packetDescription);
        _packetDescription = NULL;
    }
    
    return NO;
}

- (void)stop {
    [self stopImmediately:YES];
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
    if (_playing) {
        // if audio queue is in stopping status, we omit the pause operation and return NO
        if (_stopping) {
#ifdef DEBUG
            NSLog(@"audio queue is in stopping status");
#endif
            return NO;
        }
        
        OSStatus status = AudioQueuePause(_audioQueue);
        if (status == noErr) {
            _playing = NO;
        }
        return status == noErr;
    }
    return NO;
}

- (BOOL)resume {
    if (_started && !_playing) {
        OSStatus status = AudioQueueStart(_audioQueue, NULL);
        if (status == noErr) {
            _playing = YES;
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
    _playing = YES;
}

- (void)audioQueueStoppedCallback {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    _playing = NO;
    _stopping = NO;
    _stopped = YES;
    
    [_delegate audioQueuePlayerDidFinishPlay:self];
}

@end
