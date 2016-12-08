//
//  AudioRecordAudioQueueToFileViewController.m
//  demo
//
//  Created by KudoCC on 16/8/17.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioRecordAudioQueueToFileViewController.h"
#import "AudioQueueRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"
#import "AudioFileManager.h"

@interface RecordObject : NSObject {
    @public AudioFileID _audioFileID;
}

@property (nonatomic) AudioQueueRecorder *recorder;
@property (nonatomic) NSString *currentAudioFilePath;
@property (nonatomic) AudioFileID audioFileID;
@property (nonatomic) SInt64 currentPacket;

@end

@implementation RecordObject

- (void)dealloc {
    if (_recorder.isRecording) {
        [_recorder pause];
    }
    
    if (_audioFileID) {
        AudioFileClose(_audioFileID);
    }
}

@end

@interface AudioRecordAudioQueueToFileViewController () <AudioQueueRecorderDelegate> {
    NSString *_oldAudioSessionCategory;
    
    AudioStreamBasicDescription _basicDescription;
}

@property (nonatomic) UIButton *buttonRecord;

@property (nonatomic) NSArray<RecordObject *> *recordList;
@property (nonatomic) dispatch_queue_t dispatchQueue;

@end

@implementation AudioRecordAudioQueueToFileViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // make it dealloc first
    _recordList = nil;
    
    if (_oldAudioSessionCategory) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:_oldAudioSessionCategory
                                               error:&error];
        if (error){
            NSLog(@"set category: %@", [error localizedDescription]);
            return;
        }
    }
    
    // When passed in the flags parameter of the setActive:withOptions:error: instance method, indicates that when your audio session deactivates, other audio sessions that had been interrupted by your session can return to their active state
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
    if (error){
        NSLog(@"deactive audio session: %@", [error localizedDescription]);
    }
}

- (void)initView {
    
    // set up audio session
    _oldAudioSessionCategory = [AVAudioSession sharedInstance].category;
    NSLog(@"old audio session category:%@", _oldAudioSessionCategory);
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                           error:&error];
    if (error){
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error){
        NSLog(@"audioSession: %@", [error localizedDescription]);
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
#if 1
    // set up `AudioStreamBasicDescription`
    _basicDescription.mSampleRate = 44100.0;// 44.1HZ
//    _basicDescription.mFormatID = kAudioFormatMPEG4AAC_HE;
    _basicDescription.mFormatID = kAudioFormatMPEG4AAC;
    _basicDescription.mFormatFlags = 0;
    // The number of bytes in a packet of audio data. To indicate variable packet size, set this field to 0. For a format that uses variable packet size, specify the size of each packet using an AudioStreamPacketDescription structure.
    _basicDescription.mBytesPerPacket = 0;
    // The number of frames in a packet of audio data. For uncompressed audio, the value is 1. For variable bit-rate formats, the value is a larger fixed number, such as 1024 for AAC. For formats with a variable number of frames per packet, such as Ogg Vorbis, set this field to 0.
    // AAC-HE 2048
    _basicDescription.mFramesPerPacket = 1024;
    _basicDescription.mChannelsPerFrame = 2;
    // The number of bytes from the start of one frame to the start of the next frame in an audio buffer. Set this field to 0 for compressed formats.
    // For an audio buffer containing interleaved data for n channels, with each sample of type AudioSampleType, calculate the value for this field as follows:
    //    mBytesPerFrame = n * sizeof (AudioSampleType);
    // For an audio buffer containing noninterleaved (monophonic) data, also using AudioSampleType samples, calculate the value for this field as follows:
    //    mBytesPerFrame = sizeof (AudioSampleType);
    _basicDescription.mBytesPerFrame = 0;
    // The number of bits for one audio sample. For example, for linear PCM audio using the kAudioFormatFlagsCanonical format flags, calculate the value for this field as follows:
    // mBitsPerChannel = 8 * sizeof (AudioSampleType);
    // Set this field to 0 for compressed formats.
    _basicDescription.mBitsPerChannel = 0;
    _basicDescription.mReserved = 0;
#else
    // set up `AudioStreamBasicDescription`
    _basicDescription.mSampleRate = 44100.0;// 44.1HZ
    _basicDescription.mFormatID = kAudioFormatLinearPCM;
    _basicDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _basicDescription.mBytesPerPacket = 2 * sizeof(AudioSampleType);
    _basicDescription.mFramesPerPacket = 1;
    _basicDescription.mChannelsPerFrame = 2;
    _basicDescription.mBytesPerFrame = 2 * sizeof (AudioSampleType);
    _basicDescription.mBitsPerChannel = 8 * sizeof (AudioSampleType);
    _basicDescription.mReserved = 0;
#endif
    
#if 0
    CGRect frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 44.0);
    _buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_buttonRecord];
    [_buttonRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonRecord setTitle:@"Start" forState:UIControlStateNormal];
    [_buttonRecord addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    _buttonRecord.layer.borderColor = [UIColor blackColor].CGColor;
    _buttonRecord.layer.borderWidth = 1.0;
    _buttonRecord.frame = CGRectInset(frame, 10.0, 0.0);
#else
    // touch down to start recording, touch upinside to stop and save file/ touch upinside to cancel
    CGFloat buttonRecordHeight = 45.0;
    UIButton *buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:buttonRecord];
    buttonRecord.frame = CGRectMake(15.0, ScreenHeight-buttonRecordHeight-10, ScreenWidth-30.0, buttonRecordHeight);
    [buttonRecord addTarget:self action:@selector(buttonRecordTouchDown:) forControlEvents:UIControlEventTouchDown];
    [buttonRecord addTarget:self action:@selector(buttonRecordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [buttonRecord addTarget:self action:@selector(buttonRecordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [buttonRecord setTitle:@"touch to record" forState:UIControlStateNormal];
    [buttonRecord setTitle:@"raise inside to stop and outside to cancel" forState:UIControlStateHighlighted];
    [buttonRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonRecord setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    buttonRecord.layer.borderColor = [UIColor blackColor].CGColor;
    buttonRecord.layer.borderWidth = 1.0;
    
    _dispatchQueue = dispatch_queue_create("record.queue", 0);
#endif
}

- (RecordObject *)currentRecord {
    return [_recordList lastObject];
}

- (void)createAudioQueueRecorderAndAudioFile {
    RecordObject *obj = [RecordObject new];
    
    obj.recorder = [[AudioQueueRecorder alloc] initWithDelegate:self];
    obj.recorder.associatedData = obj;
    
    // create audio queue file
    NSDate *current = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[current timeIntervalSince1970]];
    obj.currentAudioFilePath = [[AudioFileManager audioDirectory] stringByAppendingPathComponent:fileName];
    const char *pFilePath = [obj.currentAudioFilePath UTF8String];
    CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8 *)pFilePath, strlen(pFilePath), false);
    OSStatus status = AudioFileCreateWithURL(audioFileURL, kAudioFileCAFType, &_basicDescription, kAudioFileFlags_EraseFile, &obj->_audioFileID);
    if (status != noErr) {
        obj.audioFileID = NULL;
    }
    
    // Set a magic cookie to file
    OSStatus result = noErr;
    UInt32 cookieSize;
    if (AudioQueueGetPropertySize(obj.recorder.audioQueue, kAudioQueueProperty_MagicCookie, &cookieSize) == noErr) {
        char *magicCookie = (char *)malloc(cookieSize);
        if (AudioQueueGetProperty(obj.recorder.audioQueue,
                                  kAudioQueueProperty_MagicCookie,
                                  magicCookie,
                                  &cookieSize) == noErr) {
            result = AudioFileSetProperty(obj.audioFileID, kAudioFilePropertyMagicCookieData, cookieSize, magicCookie);
#ifdef DEBUG
            if (result) {
                NSLog(@"successfully write magic cookie to file");
            }
#endif
        }
        free(magicCookie);
    }
    
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:_recordList];
    [mArray addObject:obj];
    _recordList = [mArray copy];
}

- (void)startRecord:(id)obj {
    [self createAudioQueueRecorderAndAudioFile];
    
    RecordObject *record = [self currentRecord];
    
    if (!record.recorder.recording) {
        BOOL res = [record.recorder record];
        if (res) {
            [_buttonRecord setTitle:@"Pause" forState:UIControlStateNormal];
            self.title = @"Recording";
        } else {
            self.title = @"Recording Error";
        }
    } else {
        if ([record.recorder pause]) {
            [_buttonRecord setTitle:@"Start" forState:UIControlStateNormal];
            self.title = @"Record paused";
        } else {
            self.title = @"Paused error";
        }
    }
}

#pragma mark -

- (void)buttonRecordTouchDown:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_async(_dispatchQueue, ^{
        [self createAudioQueueRecorderAndAudioFile];
        
        RecordObject *record = [self currentRecord];
        BOOL res = [record.recorder record];
        if (!res) {
            NSLog(@"fail to start recording");
        }
    });
}

- (void)buttonRecordTouchUpInside:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_async(_dispatchQueue, ^{
        RecordObject *record = [self currentRecord];
        [record.recorder stop];
    });
    
    // close file in delegate
}

- (void)buttonRecordTouchUpOutside:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    dispatch_async(_dispatchQueue, ^{
        RecordObject *record = [self currentRecord];
        [record.recorder stop];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // close and remove the file immediately
            
            if (record.audioFileID) {
                AudioFileID audioFileId = record.audioFileID;
                record.audioFileID = NULL;
                AudioFileClose(audioFileId);
            }
            
            if (record.currentAudioFilePath.length > 0) {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:record.currentAudioFilePath error:&error];
                if (error) {
                    NSLog(@"remove file failed:%@", [error localizedDescription]);
                } else {
                    NSLog(@"remove file successfully");
                }
            }
        });
    });
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

#pragma mark - AudioQueueRecorderDelegate

- (AudioStreamBasicDescription)audioStreamBasicDescriptionOfRecorder:(AudioQueueRecorder *)recorder {
    return _basicDescription;
}

- (void)audioQueueRecorder:(AudioQueueRecorder *)recorder recordBuffer:(AudioQueueBufferRef)buffer streamPacketDescList:(const AudioStreamPacketDescription *)inPacketDesc numberOfPacketDescription:(UInt32)inNumPackets {
    if (inNumPackets == 0 && _basicDescription.mBytesPerPacket != 0)
        inNumPackets = buffer->mAudioDataByteSize / _basicDescription.mBytesPerPacket;
    
    RecordObject *record = recorder.associatedData;
    if (record.audioFileID && inNumPackets > 0) {
        OSStatus status = AudioFileWritePackets(record.audioFileID,
                                                false,
                                                buffer->mAudioDataByteSize,
                                                inPacketDesc, record.currentPacket,
                                                &inNumPackets,
                                                buffer->mAudioData);
        if (status != noErr) {
            NSLog(@"fail write to file with error:%d, inNumPackets:%u, audioDataByteSize:%u", (int)status, (unsigned int)inNumPackets, (unsigned int)buffer->mAudioDataByteSize);
            return;
        }
        NSLog(@"success write audio file packet %d", (int)inNumPackets);
        record.currentPacket += inNumPackets;
    }
}

- (void)audioQueueRecorderDidFinishRecord:(AudioQueueRecorder *)recorder {
    RecordObject *record = recorder.associatedData;
    if (record.audioFileID) {
        AudioFileClose(record.audioFileID);
        record.audioFileID = NULL;
    }
    record.currentPacket = 0;
    recorder.associatedData = nil;
}

@end
