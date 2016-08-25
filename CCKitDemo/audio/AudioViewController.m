//
//  ViewController.m
//  audio
//
//  Created by KudoCC on 15/9/21.
//  Copyright (c) 2015年 KudoCC. All rights reserved.
//

#import "AudioViewController.h"
#import "AudioRecordViewController.h"
#import "AudioListViewController.h"
#import "AudioRecordAudioQueueToFileViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioViewController ()
@end

@implementation AudioViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Record", @"Record with audio queue to file", @"Playback-Audio list"];
    self.arrayClass = @[[AudioRecordViewController class],
                        [AudioRecordAudioQueueToFileViewController class],
                        [AudioListViewController class]];
    
    [self checkAudioCodeC];
}

- (Boolean)checkAudioCodeC {
    Boolean isAvailable = false;
    OSStatus error;
    
    // get an array of AudioClassDescriptions for all installed encoders for the given format
    // the specifier is the format that we are interested in - this is 'aac ' in our case
    UInt32 encoderSpecifier = kAudioFormatMPEG4AAC;
    UInt32 size;
    
    error = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier),
                                       &encoderSpecifier, &size);
    if (error) {
        printf("AudioFormatGetPropertyInfo kAudioFormatProperty_Encoders error %lu %4.4s\n", (unsigned long)error, (char*)&error);
        return false;
    }
    
    UInt32 numEncoders = size / sizeof(AudioClassDescription);
    AudioClassDescription encoderDescriptions[numEncoders];
    
    error = AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(encoderSpecifier),
                                   &encoderSpecifier, &size, encoderDescriptions);
    if (error) {
        printf("AudioFormatGetProperty kAudioFormatProperty_Encoders error %lu %4.4s\n",
                        (unsigned long)error, (char*)&error);
        return false;
    }
    
    for (UInt32 i=0; i < numEncoders; ++i) {
        if (encoderDescriptions[i].mSubType == kAudioFormatMPEG4AAC &&
            encoderDescriptions[i].mManufacturer == kAppleHardwareAudioCodecManufacturer) isAvailable = true;
    }
    
    return isAvailable;
}

@end
