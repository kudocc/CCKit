//
//  AVFoundationVideoViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AVFoundationVideoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AVFoundationVideoViewController ()

@end

@implementation AVFoundationVideoViewController

- (void)initView {
    [self showRightBarButtonItemWithName:@"start video record"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    
}

- (void)configAVSesstion {
    AVCaptureSession *session = [AVCaptureSession new];
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:&error];
    if ([session canAddInput:videoDeviceInput]) {
        [session addInput:videoDeviceInput];
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&error];
    if ([session canAddInput:audioDeviceInput]) {
        [session addInput:audioDeviceInput];
    }
}

@end
