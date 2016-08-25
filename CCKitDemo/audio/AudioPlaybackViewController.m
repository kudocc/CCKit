//
//  AudioPlaybackViewController.m
//  audio
//
//  Created by KudoCC on 15/9/21.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AudioPlaybackViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+CCKit.h"
#import "UIView+CCKit.h"

@interface AudioPlaybackViewController () <AVAudioPlayerDelegate> {
    NSString *_oldAudioSessionCategory;
}

@property (nonatomic) UIButton *buttonPlay;
@property (nonatomic) AVAudioPlayer *player;

@end

@implementation AudioPlaybackViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_player.isPlaying) {
        [_player pause];
    }
    
    if (_oldAudioSessionCategory) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:_oldAudioSessionCategory
                                               error:&error];
        if (error) {
            NSLog(@"set category: %@", [error localizedDescription]);
            return;
        }
    }
    
    // When passed in the flags parameter of the setActive:withOptions:error: instance method, indicates that when your audio session deactivates, other audio sessions that had been interrupted by your session can return to their active state
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
    if (error) {
        NSLog(@"deactive audio session: %@", [error localizedDescription]);
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
    
    NSURL *url = [NSURL fileURLWithPath:_audioPath];
    error = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _player.delegate = self;
    if (error) {
        NSLog(@"error[%@] when play %@", error, _audioPath);
    }
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

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    self.title = @"begin interruption";
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    self.title = @"end interruption";
    [_player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.title = @"play finished";
    [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
}

@end

