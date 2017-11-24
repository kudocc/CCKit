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
@property (nonatomic) UILabel *categoryLabel;

@property (nonatomic) AVAudioPlayer *player;

@property (nonatomic) UIView *progressView;
@property (nonatomic) NSTimer *timer;

@end

@implementation AudioPlaybackViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_player.isPlaying) {
        [_player pause];
    }
    
    /*
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
    }*/
}

- (void)initView {
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 3)];
    [self.progressView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.progressView];
    
    // set up audio session
    _oldAudioSessionCategory = [AVAudioSession sharedInstance].category;
    NSLog(@"old audio session category:%@", _oldAudioSessionCategory);
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
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
    
    CGFloat y = CGRectGetMaxY(_buttonPlay.frame);
    y += 10;
    self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, _buttonPlay.frame.size.width, _buttonPlay.frame.size.height)];
    self.categoryLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.categoryLabel.textColor = [UIColor blackColor];
    self.categoryLabel.text = [AVAudioSession sharedInstance].category;
    [self.view addSubview:self.categoryLabel];
    
    NSArray *names = @[@"Ambient", @"SoloAmbient", @"Playback", @"Record", @"PlayAndRecord", @"MultiRoute", @"Active Session", @"Deactive Session"];
    
    y = CGRectGetMaxY(self.categoryLabel.frame);
    y += 10;
    NSInteger tag = 1001;
    for (NSString *name in names) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:name forState:UIControlStateNormal];
        [button setTag:tag];
        [button addTarget:self action:@selector(setCategory:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(10, y, _buttonPlay.bounds.size.width, _buttonPlay.bounds.size.height)];
        [self.view addSubview:button];
        ++tag;
        y = CGRectGetMaxY(button.frame) + 10;
    }
}

- (void)setCategory:(UIButton *)sender {
    NSInteger index = sender.tag - 1001;
    NSArray *category = @[AVAudioSessionCategoryAmbient, AVAudioSessionCategorySoloAmbient, AVAudioSessionCategoryPlayback, AVAudioSessionCategoryRecord, AVAudioSessionCategoryPlayAndRecord, AVAudioSessionCategoryMultiRoute, @"On", @"Off"];
    NSString *cate = category[index];
    if ([cate isEqualToString:@"On"]) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        if (error) {
            NSLog(@"set active failed %@", error);
        }
    } else if ([cate isEqualToString:@"Off"]) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
        if (error) {
            NSLog(@"set active failed %@", error);
        }
    } else {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:cate error:&error];
        if (error) {
            NSLog(@"set category %@ failed %@", category[index], error);
        } else {
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            NSLog(@"set active failed %@", error);
        }
        
        self.categoryLabel.text = [AVAudioSession sharedInstance].category;
    }
}

- (void)playButtonPressed:(UIButton *)button {
    if (_player.playing) {
        [_player pause];
        self.title = @"Paused";
        [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
        
        if ([self.timer isValid]) {
            [self.timer invalidate];
        }
    } else {
        if ([_player play]) {
            self.title = @"Playing";
            [_buttonPlay setTitle:@"Pause" forState:UIControlStateNormal];
            
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
                CGFloat f = self.player.currentTime / self.player.duration;
                CGFloat w = self.view.bounds.size.width * f;
                self.progressView.frame = CGRectMake(self.progressView.frame.origin.x,
                                                     self.progressView.frame.origin.y,
                                                     w,
                                                     self.progressView.frame.size.height);
            }];
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
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}

@end

