//
//  AudioPlayAudioQueueFromFileViewController.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioPlayAudioQueueFromFileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"
#import "UIView+CCKit.h"
#import "AudioQueuePlayer.h"

@interface AudioPlayAudioQueueFromFileViewController () <AudioQueuePlayerDelegate> {
    NSString *_oldAudioSessionCategory;
    
    AudioStreamBasicDescription _basicDescription;
    UInt32 _bufferByteSize;
    UInt32 _numPacketRead;
    SInt64 _currentPacket;
}

@property (nonatomic) UIButton *buttonPlay;
@property (nonatomic) AudioQueuePlayer *player;

@property (nonatomic, assign) AudioFileID audioFileID;

@end

@implementation AudioPlayAudioQueueFromFileViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_oldAudioSessionCategory) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:_oldAudioSessionCategory
                                               error:&error];
        if (error) {
            NSLog(@"set category: %@", [error localizedDescription]);
            return;
        }
    }
    
    if (_player.playing) {
        [_player pause];
    }
    
    // When passed in the flags parameter of the setActive:withOptions:error: instance method, indicates that when your audio session deactivates, other audio sessions that had been interrupted by your session can return to their active state
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
    if (error) {
        NSLog(@"deactive audio session: %@", [error localizedDescription]);
    }
    
    if (_audioFileID) {
        AudioFileClose(_audioFileID);
    }
}

- (void)initView {
    
    // set up audio session
    _oldAudioSessionCategory = [AVAudioSession sharedInstance].category;
    NSLog(@"old audio session category:%@", _oldAudioSessionCategory);
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error) {
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
    CGRect frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 44.0);
    
    _buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
    [_buttonPlay setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonPlay addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _buttonPlay.layer.borderColor = [UIColor blackColor].CGColor;
    _buttonPlay.layer.borderWidth = 1.0;
    _buttonPlay.frame = CGRectInset(frame, 10, 0);
    [self.view addSubview:_buttonPlay];
    
    // create audio queue file
    const char *pFilePath = [_audioPath UTF8String];
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)pFilePath, strlen(pFilePath), false);
    OSStatus status = AudioFileOpenURL(audioFileURL, kAudioFileReadPermission, 0, &_audioFileID);
    if (status != noErr) {
        // kAudioFileUnspecifiedError 2003334207
        _audioFileID = NULL;
    }
    
    if (_audioFileID) {
        int seconds = [self getAudioFileDuration];
        NSLog(@"Audio file duration:%d", seconds);
        
        UInt32 dataFormatSize = sizeof (_basicDescription);
        status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyDataFormat, &dataFormatSize, &_basicDescription);
        if (status == noErr) {
            UInt32 maxPacketSize;
            UInt32 propertySize = sizeof(maxPacketSize);
            AudioFileGetProperty(_audioFileID, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
            [self deriveBufferSize:maxPacketSize seconds:1 outBufferSize:&_bufferByteSize outNumPacketsToRead:&_numPacketRead];
            
            _player = [[AudioQueuePlayer alloc] initWithDelegate:self];
            
            // set audio queue magic cookie
            UInt32 cookieSize = sizeof(UInt32);
            bool couldNotGetProperty = AudioFileGetPropertyInfo(_audioFileID, kAudioFilePropertyMagicCookieData, &cookieSize, NULL);
            if (!couldNotGetProperty && cookieSize) {
                char* magicCookie = (char *)malloc(cookieSize);
                OSStatus status = AudioFileGetProperty(_audioFileID, kAudioFilePropertyMagicCookieData, &cookieSize, magicCookie);
#ifdef DEBUG
                if (status != noErr) {
                    NSLog(@"Audio File Get Magic Cookie data fail:%d", (int)status);
                }
#endif
                status = AudioQueueSetProperty(_player.audioQueue, kAudioQueueProperty_MagicCookie, magicCookie, cookieSize);
#ifdef DEBUG
                if (status != noErr) {
                    NSLog(@"Audio Queue set Magic Cookie data fail:%d", (int)status);
                }
#endif
                free(magicCookie);
            }
        }
    }
}

- (int)getAudioFileDuration {
    UInt32 dataSize = 0;
    UInt32 writable = 0;
    OSStatus status = AudioFileGetPropertyInfo(_audioFileID, kAudioFilePropertyEstimatedDuration, &dataSize, &writable);
    if (status == noErr) {
        void *duration = malloc(dataSize);
        AudioFileGetProperty(_audioFileID, kAudioFilePropertyEstimatedDuration, &dataSize, duration);
        double seconds = 0;
        memcpy(&seconds, duration, sizeof(seconds));
        free(duration);
        return seconds;
    }
    return 0;
}

- (void)deriveBufferSize:(UInt32)maxPacketSize seconds:(Float64)seconds outBufferSize:(UInt32 *)outBufferSize outNumPacketsToRead:(UInt32 *)outNumPacketsToRead {
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    
    int maxBuffer = maxBufferSize;
    // minBuffer size can't less than one packet size
    int minBuffer = minBufferSize > maxPacketSize ? minBufferSize : maxPacketSize;
    
    if (_basicDescription.mFramesPerPacket != 0) {
        Float64 numPacketsForTime = _basicDescription.mSampleRate / _basicDescription.mFramesPerPacket * seconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    } else {
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
    }
    
    if (*outBufferSize > maxBuffer &&
        *outBufferSize > maxBuffer)
        *outBufferSize = maxBuffer;
    else if (*outBufferSize < minBuffer) {
        *outBufferSize = minBuffer;
    }
    *outNumPacketsToRead = *outBufferSize / maxPacketSize;
}

- (void)playButtonPressed:(UIButton *)button {
    if (_player.playing) {
        [_player pause];
        self.title = @"Paused";
        [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
    } else {
        if ([_player play]) {
            self.title = @"Playing";
            [_buttonPlay setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            self.title = @"Play error";
            [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
            NSLog(@"Play error");
        }
    }
}

#pragma mark -

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        self.title = @"begin interruption";
        NSLog(@"begin interruption");
    } else {
        self.title = @"end interruption";
        NSLog(@"end interruption");
    }
}

#pragma mark - AudioQueuePlayerDelegate

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfPlayer:(AudioQueuePlayer *)player {
    return _basicDescription;
}

- (void)audioQueuePlayer:(AudioQueuePlayer *)player
       getBufferByteSize:(UInt32 *)outBufferSize
      packetToReadNumber:(UInt32 *)outPacketToReadNumber {
    *outBufferSize = _bufferByteSize;
    *outPacketToReadNumber = _numPacketRead;
}

- (void)audioQueuePlayer:(AudioQueuePlayer *)player
             primeBuffer:(AudioQueueBufferRef)inAudioQueueBuffer
 streamPacketDescription:(AudioStreamPacketDescription *)inPacketDesc
       descriptionNumber:(UInt32)inNumPackets
        readPacketNumber:(UInt32 *)outReadPacketNumber
          readByteNumber:(UInt32 *)outReadByteNumber {
    
    UInt32 numPackets = inNumPackets;
    OSStatus status = AudioFileReadPackets(_audioFileID, false, outReadByteNumber, inPacketDesc,
                                           _currentPacket, &numPackets, inAudioQueueBuffer->mAudioData);
    *outReadPacketNumber = numPackets;
    if (status != noErr) {
        NSLog(@"read packets error:%d", (int)status);
    } else if (numPackets == 0) {
        NSLog(@"read file end");
    }
    _currentPacket += numPackets;
}

- (void)audioQueuePlayerDidFinishPlay:(AudioQueuePlayer *)player {
    [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
    self.title = @"finsh play";
    _currentPacket = 0;
}

@end