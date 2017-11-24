//
//  AudioConvertViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/8/8.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "AudioConvertViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioFileManager.h"

@interface AudioConvertViewController () <AVAudioPlayerDelegate>

@property (nonatomic, copy) NSString *convertedFilePath;
@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation AudioConvertViewController

- (void)initView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self convertAudio];
    });
}

- (void)didConvert {
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.convertedFilePath] error:&error];
    self.player.delegate = self;
    
    if (![self.player play]) {
        NSLog(@"Failed to play");
    }
}

- (void)convertAudio {
    NSURL *assetURL = [NSURL fileURLWithPath:self.audioPath];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    NSError *assetError = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                               error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                                                                                     audioSettings:nil];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    
    [assetReader addOutput: assetReaderOutput];
    
    NSString *exportPath = [[AudioFileManager audioDirectory] stringByAppendingPathComponent:@"pcm2m4a.m4a"];
    self.convertedFilePath = [exportPath copy];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL fileType:AVFileTypeAppleM4A error:&assetError];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary *outputSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
     [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
     [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
 //     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
 //     [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
 //     [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
 //     [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
     nil];
    
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^{
                                                while (assetWriterInput.readyForMoreMediaData) {
                                                    CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
                                                    if (nextBuffer) {
                                                        [assetWriterInput appendSampleBuffer: nextBuffer];
                                                        convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                                                        NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];
                                                        [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                                                                               withObject:convertedByteCountNumber
                                                                            waitUntilDone:NO];
                                                    } else {
                                                        // done!
                                                        [assetWriterInput markAsFinished];
                                                        [assetWriter finishWritingWithCompletionHandler:^{
                                                            NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:exportPath error:nil];
                                                            NSLog (@"done. file size is %ld", (long)[outputFileAttributes fileSize]);
                                                            [self performSelectorOnMainThread:@selector(didConvert) withObject:nil waitUntilDone:NO];
                                                        }];
                                                        [assetReader cancelReading];
                                                        break;
                                                    }
                                                }
                                            }];
}

- (void)updateSizeLabel:(id)obj {
    NSLog(@"--%@", obj);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), error);
}

@end
