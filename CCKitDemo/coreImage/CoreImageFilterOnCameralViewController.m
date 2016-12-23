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
#import "CIFaceAnimateFilter.h"
#import "UIView+CCKit.h"
#import <GLKit/GLKit.h>

typedef NS_ENUM(NSInteger, AVCamSetupResult) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface CoreImageView : GLKView {
    CIContext *_context;
}

@property (nonatomic) CIImage *image;

@end

@implementation CoreImageView

- (id)initWithFrame:(CGRect)frame {
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self = [self initWithFrame:frame context:eaglContext];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    _context = [CIContext contextWithEAGLContext:context];
    self = [super initWithFrame:frame context:context];
    if (self) {
        self.enableSetNeedsDisplay = NO;
    }
    return self;
}

- (void)setImage:(CIImage *)image {
    _image = image;
    [self display];
}

- (void)drawRect:(CGRect)rect {
    if (_image) {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGRect destRect = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(scale, scale));
        [_context drawImage:_image inRect:destRect fromRect:_image.extent];
    }
}

@end

@interface CoreImageFilterOnCameralViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    CIFilter *_ciFilter;
}

@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;

@property (strong, nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCamSetupResult setupResult;
@property (nonatomic) CoreImageView *coreImageView;

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
    
#define USE_FACE_A_FILTER

#ifdef USE_FACE_A_FILTER
    CIFaceAnimateFilter *faceFilter = [[CIFaceAnimateFilter alloc] init];
    _ciFilter = faceFilter;
#else
    _ciFilter = [CIFilter filterWithName:@"CIHueAdjust"];
    CGFloat f = M_PI * 3/4;
    [_ciFilter setValue:@(f) forKey:kCIInputAngleKey];
#endif
    _coreImageView = [[CoreImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_coreImageView];
}

- (void)sessionDidStart:(id)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", NSStringFromSelector(_cmd));
    });
}

- (void)configCaptureSession {
    // Create the AVCaptureSession.
    self.session = [[AVCaptureSession alloc] init];
    
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
        [_output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        _output.alwaysDiscardsLateVideoFrames = YES;
        _output.videoSettings = @{(__bridge id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
//        _output.videoSettings = @{(__bridge id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        
        [_session beginConfiguration];
        
        if ([_session canAddInput:_input] ) {
            [_session addInput:_input];
        } else {
            NSLog( @"Could not add video device input to the session" );
            _setupResult = AVCamSetupResultSessionConfigurationFailed;
        }
        
        if ([_session canAddOutput:_output]) {
            [_session addOutput:_output];
            
//            AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
//            if ([connection isVideoOrientationSupported]) {
//                [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//            }
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

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"number of media samples:%ld", CMSampleBufferGetNumSamples(sampleBuffer));
    
    CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBufferRef];
    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeRotation(-M_PI/2)];
#if 0
    [_ciFilter setValue:ciImage forKey:kCIInputImageKey];
    CIImage *ciOutputImage = [_ciFilter outputImage];
    _coreImageView.image = ciOutputImage;
#else
    // no filter used
    _coreImageView.image = ciImage;
#endif
}

@end
