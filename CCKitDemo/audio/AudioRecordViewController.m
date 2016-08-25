//
//  AudioRecordViewController.m
//  audio
//
//  Created by KudoCC on 15/9/21.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AudioRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"

typedef NS_ENUM(NSUInteger, RecordStatus) {
    RecordStatusNone,
    RecordStatusRecording,
    RecordStatusPaused,
    RecordStatusStoped
};

@interface AudioRecordViewController () <AVAudioRecorderDelegate> {
    NSString *_oldAudioSessionCategory;
}

@property (nonatomic) UIButton *buttonRecord;

@property (nonatomic) RecordStatus recordStatus;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation AudioRecordViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_recorder.isRecording) {
        [_recorder stop];
    }
    
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
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
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
    
    CGRect frame = CGRectMake(0.0, 100.0, self.view.bounds.size.width, 44.0);
    
    _buttonRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_buttonRecord];
    [_buttonRecord setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonRecord setTitle:@"Start" forState:UIControlStateNormal];
    [_buttonRecord addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
    _buttonRecord.layer.borderColor = [UIColor blackColor].CGColor;
    _buttonRecord.layer.borderWidth = 1.0;
    _buttonRecord.frame = CGRectInset(frame, 10.0, 0.0);
    
    NSDate *current = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[current timeIntervalSince1970]];
    NSString *filePath = [[NSString cc_documentPath] stringByAppendingPathComponent:fileName];
    NSDictionary *setting = @{AVFormatIDKey:@(kAudioFormatMPEG4AAC), AVSampleRateKey:@(44100.0), AVNumberOfChannelsKey:@2};
    error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:setting error:&error];
    _recorder.delegate = self;
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        _buttonRecord.enabled = NO;
    }
}

- (void)setButtonTitle:(NSString *)title {
    [_buttonRecord setTitle:title forState:UIControlStateNormal];
}

- (void)setRecordStatus:(RecordStatus)recordStatus {
    _recordStatus = recordStatus;
    switch (_recordStatus) {
        case RecordStatusNone:
            [self setButtonTitle:@"Start"];
            break;
        case RecordStatusRecording:
            [self setButtonTitle:@"Pause"];
            break;
        case RecordStatusPaused:
            [self setButtonTitle:@"Resume"];
            break;
        case RecordStatusStoped:
            [self setButtonTitle:@"Can't do anything"];
        default:
            break;
    }
}

- (void)startRecord:(id)obj {
    if (!_recorder.isRecording) {
        BOOL res = [_recorder record];
        if (res) {
            self.recordStatus = RecordStatusRecording;
            self.title = @"Recording";
        } else {
            self.recordStatus = RecordStatusStoped;
            self.title = @"Start record error";
        }
    } else {
        [_recorder pause];
        self.recordStatus = RecordStatusPaused;
        self.title = @"Record paused";
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

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"%@, flag:%@", NSStringFromSelector(_cmd), @(flag));
    
    self.recordStatus = RecordStatusStoped;
    self.title = @"record did finish";
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    NSLog(@"%@, error:%@", NSStringFromSelector(_cmd), error.localizedDescription);
    
    self.recordStatus = RecordStatusStoped;
    self.title = @"encode error did occur";
}

@end
