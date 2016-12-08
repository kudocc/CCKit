//
//  EasyVideoRecordToFileViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "EasyVideoRecordToFileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AudioFileManager.h"
#import "NSDate+CCKit.h"

@interface UICameralToolView : UIView

@property (nonatomic) UIButton *buttonPlay;
@property (nonatomic) UIButton *buttonCancel;

@end

@implementation UICameralToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_buttonPlay];
        [_buttonPlay setTitle:@"Play" forState:UIControlStateNormal];
        [_buttonPlay setTitle:@"Stop" forState:UIControlStateSelected];
        [_buttonPlay setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_buttonCancel];
        [_buttonCancel setTitle:@"cancel" forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    _buttonCancel.frame = CGRectMake(0, self.height/4, self.width/2, self.height/2);
    _buttonPlay.frame = CGRectMake(self.width/2, self.height/4, self.width/2, self.height/2);
}

@end

@interface EasyVideoRecordToFileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImagePickerController *camera;
@property (nonatomic) UICameralToolView *cameralToolView;
@property (nonatomic) BOOL playing;

@end

@implementation EasyVideoRecordToFileViewController

- (void)initView {
    [self showRightBarButtonItemWithName:@"show image picker"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeMovie]) {
            // Video recording is supported.
            _camera = [UIImagePickerController new];
            _camera.sourceType = UIImagePickerControllerSourceTypeCamera;
            _camera.mediaTypes = @[(NSString *)kUTTypeMovie];
            _camera.delegate = self;
            
            _cameralToolView = [[UICameralToolView alloc] initWithFrame:CGRectMake(0, ScreenHeight-100, ScreenWidth, 100.0)];
            [_cameralToolView.buttonPlay addTarget:self action:@selector(buttonPlay:) forControlEvents:UIControlEventTouchUpInside];
            [_cameralToolView.buttonCancel addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        [_camera setCameraDevice:UIImagePickerControllerCameraDeviceFront];
    }
    
    _camera.videoQuality = UIImagePickerControllerQualityTypeMedium;
    
    _camera.showsCameraControls = NO;
    _camera.cameraOverlayView = _cameralToolView;
    
    if (_camera) {
        [self presentViewController:_camera animated:YES completion:nil];
    }
}

- (void)buttonPlay:(id)sender {
    // selected is recording
    
    if (_cameralToolView.buttonPlay.selected) {
        [_camera stopVideoCapture];
        _cameralToolView.buttonPlay.selected = NO;
    } else {
        BOOL res = [_camera startVideoCapture];
        if (res) {
            _cameralToolView.buttonPlay.selected = YES;
        }
    }
}

- (void)buttonCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), info);
    
    NSURL *urlFile = info[UIImagePickerControllerMediaURL];
    NSString *pathExtention = [urlFile pathExtension];
    NSDate *date = [NSDate date];
    NSString *fileName = [date cc_stringWithFormatterString:@"yyyy-MM-dd-HH-mm-ss"];
    fileName = [fileName stringByAppendingFormat:@".%@", pathExtention];
    NSString *filePath = [[AudioFileManager videoDirectory] stringByAppendingPathComponent:fileName];
    NSURL *urlDest = [NSURL fileURLWithPath:filePath];
    BOOL res = [[NSFileManager defaultManager] moveItemAtURL:urlFile toURL:urlDest error:nil];
    if (res) {
        NSLog(@"success save file to %@", urlDest);
    } else {
        NSLog(@"fail save file to %@", urlDest);
    }
}

@end
