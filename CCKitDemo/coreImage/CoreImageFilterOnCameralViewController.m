//
//  CoreImageFilterOnCameralViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 16/8/30.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreImageFilterOnCameralViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+CCKit.h"
#import "CIFacePixelFilter.h"
#import "UIView+CCKit.h"

typedef NS_ENUM(NSInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface CoreImageFilterOnCameralViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    UIImageOrientation _orientation;
    CIImage *_ciImage;
    CIFilter *_ciFilter;
    CIContext *_ciContext;
}

@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (strong, nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) CALayer *contentLayer;

@end

@implementation CoreImageFilterOnCameralViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(_sessionQueue, ^{
        if (_setupResult == AVCamSetupResultSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startSession];
            });
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_async(_sessionQueue, ^{
        if (_setupResult == AVCamSetupResultSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopSession];
            });
        }
    });
}

- (void)initView {
    [super initView];
    
    [self configCaptureSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidStart:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    _ciContext = [CIContext contextWithOptions:NULL];
    _ciFilter = [[CIFacePixelFilter alloc] init];
    
    _contentLayer = [[CALayer alloc] init];
    [self.view.layer addSublayer:_contentLayer];
    _contentLayer.frame = self.view.layer.bounds;
}

- (void)sessionDidStart:(id)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", NSStringFromSelector(_cmd));
    });
}

- (void)configCaptureSession {
    // Create the AVCaptureSession.
    self.session = [[AVCaptureSession alloc] init];
    
//    _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
//    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    _preview.frame = [UIScreen mainScreen].bounds;
//    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Communicate with the session and other session objects on this queue.
    self.sessionQueue = dispatch_queue_create("AVCaptureSession.queue", DISPATCH_QUEUE_SERIAL);
    
    self.setupResult = AVCamSetupResultSuccess;
    
    // Check video authorization status. Video access is required and audio access is optional.
    // If audio access is denied, audio is not recorded during movie recording.
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized: {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined: {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    self.setupResult = AVCamSetupResultCameraNotAuthorized;
                }
                dispatch_resume(self.sessionQueue);
            }];
            break;
        }
        default: {
            // The user has previously denied access.
            self.setupResult = AVCamSetupResultCameraNotAuthorized;
            break;
        }
    }
    
    // Setup the capture session.
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
    // so that the main queue isn't blocked, which keeps the UI responsive.
    dispatch_async(self.sessionQueue, ^{
        if (self.setupResult != AVCamSetupResultSuccess) {
            if (self.setupResult == AVCamSetupResultCameraNotAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"相机不可用" message:@"请在iOS的“设置”-“隐私”-“相机”到店中，允许到店访问你的相机。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                });
            }
            return;
        }
        
        NSError *error = nil;
        
        _device = [self.class deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if (!_input) {
            NSLog( @"Could not create video device input: %@", error );
        }
        
        _output = [[AVCaptureVideoDataOutput alloc] init];
        [_output setSampleBufferDelegate:self queue:self.sessionQueue];
        _output.videoSettings = @{(__bridge id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        
        [_session beginConfiguration];
        
        if ([_session canAddInput:_input] ) {
            [_session addInput:_input];
        } else {
            NSLog( @"Could not add video device input to the session" );
            _setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        if ([_session canAddOutput:_output]) {
            [_session addOutput:_output];
            
            AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoOrientationSupported]) {
                [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            }
        } else {
            NSLog( @"Could not add video device output to the session" );
            _setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        [_session commitConfiguration];
    });
}

- (void)startSession {
    if (self.setupResult == AVCamSetupResultSuccess) {
        dispatch_async(self.sessionQueue, ^{
            if (!self.session.isRunning) {
                [self.session startRunning];
            }
        });
    }
}

- (void)stopSession {
    if (self.setupResult == AVCamSetupResultSuccess) {
        dispatch_async(self.sessionQueue, ^{
            if (self.session.isRunning) {
                [self.session stopRunning];
            }
        });
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    static int i = 0;
    if (++i < 24) {
        return;
    }
    i = 0;
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    [_ciFilter setValue:ciImage forKey:kCIInputImageKey];
    CIImage *ciOutputImage = [_ciFilter outputImage];
    CGImageRef cgImage = [_ciContext createCGImage:ciOutputImage fromRect:[ciOutputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    NSLog(@"%@, orientation:%@", NSStringFromCGSize(newImage.size), @(image.imageOrientation));
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize sizeImage = newImage.size;
        CGRect frame = [UIView cc_frameOfContentWithContentSize:sizeImage
                                                  containerSize:self.view.bounds.size
                                                    contentMode:UIViewContentModeScaleAspectFit];
        self.contentLayer.contents = (__bridge id)newImage.CGImage;
        self.contentLayer.frame = frame;
    });
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
