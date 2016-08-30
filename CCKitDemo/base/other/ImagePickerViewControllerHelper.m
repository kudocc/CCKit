//
//  ImagePickerViewControllerHelper.m
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImagePickerViewControllerHelper.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImagePickerViewControllerHelper () <UIActionSheetDelegate> {
    UIViewController *_viewController;
}
@end

@implementation ImagePickerViewControllerHelper

+ (instancetype)sharedHelper {
    static dispatch_once_t onceToken;
    static ImagePickerViewControllerHelper *helper;
    dispatch_once(&onceToken, ^{
        helper = [[ImagePickerViewControllerHelper alloc] init];
    });
    return helper;
}

- (void)presentImagePickerWithBlock:(ImagePickerInfoCallback)callback viewController:(UIViewController *)vc {
    [self presentImagePickerWithBlock:callback flag:ImagePickerFlagAll viewController:vc];
}

- (void)presentImagePickerWithBlock:(ImagePickerInfoCallback)callback
                               flag:(ImagePickerFlag)flag
                     viewController:(UIViewController *)vc {
    _callback = callback;
    _viewController = vc;
    
    UIAlertController *alertController = nil;
    UIActionSheet *actionSheet = nil;
    BOOL systemVersionBelow8 = [[UIDevice currentDevice].systemVersion floatValue] < 8.0;
    if (!systemVersionBelow8) {
        alertController = [UIAlertController alertControllerWithTitle:@"选择" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    } else {
        // 在后面设置cancelButton，因为如果在这里设置，cancel button就会排在第一位，而不是最后一位
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    
    if (((flag & ImagePickerFlagAlbum) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) ||
        ((flag & ImagePickerFlagPhoto) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])) {
        // check 相册
        ALAuthorizationStatus al_status = [ALAssetsLibrary authorizationStatus];
        if (al_status == ALAuthorizationStatusAuthorized ||
            al_status == ALAuthorizationStatusNotDetermined) {
            if ((flag & ImagePickerFlagAlbum) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                if (!systemVersionBelow8) {
                    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"相册-PhotosAlbum" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        [vc presentViewController:imagePicker animated:YES completion:nil];
                    }];
                    [alertController addAction:actionPhoto];
                } else {
                    [actionSheet addButtonWithTitle:@"相册-PhotosAlbum"];
                }
            }
            if ((flag & ImagePickerFlagPhoto) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                if (!systemVersionBelow8) {
                    UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"相册-PhotoLibrary" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        imagePicker.delegate = self;
                        [vc presentViewController:imagePicker animated:YES completion:nil];
                    }];
                    [alertController addAction:actionPhoto];
                } else {
                    [actionSheet addButtonWithTitle:@"相册-PhotoLibrary"];
                }
            }
        } else {
            // ALAuthorizationStatusRestricted || ALAuthorizationStatusDenied
            // can't access
            if (al_status == ALAuthorizationStatusDenied) {
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
                NSString *message = [NSString stringWithFormat:@"请在iOS的“设置”-“隐私”-“照片”%@中，允许%@访问你的照片。", appName, appName];
                if (!systemVersionBelow8) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:action];
                    [vc presentViewController:alert animated:YES completion:nil];
                    return;
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法访问相册" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
        }
    }
    
    if (((flag & ImagePickerFlagCameraFront) || (flag & ImagePickerFlagCameraRear)) &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // check 相机
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized ||
            status == AVAuthorizationStatusNotDetermined) {
            
            if ((flag & ImagePickerFlagCameraRear) &&
                [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                if (!systemVersionBelow8) {
                    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"相机-后置相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                        imagePicker.delegate = self;
                        [vc presentViewController:imagePicker animated:YES completion:nil];
                    }];
                    [alertController addAction:actionCamera];
                } else {
                    [actionSheet addButtonWithTitle:@"相机-后置相机"];
                }
            }
            if ((flag & ImagePickerFlagCameraFront) &&
                [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                if (!systemVersionBelow8) {
                    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"相机-前置相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                        imagePicker.delegate = self;
                        [vc presentViewController:imagePicker animated:YES completion:nil];
                    }];
                    [alertController addAction:actionCamera];
                } else {
                    [actionSheet addButtonWithTitle:@"相机-前置相机"];
                }
            }
        } else {
            // can't access
            if (status == AVAuthorizationStatusDenied) {
                NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
                NSString *message = [NSString stringWithFormat:@"请在iOS的“设置”-“隐私”-“相机”%@中，允许%@访问你的相机。", appName, appName];
                if (!systemVersionBelow8) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机不可用" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:action];
                    [vc presentViewController:alert animated:YES completion:nil];
                    return;
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机不可用" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
        }
    }
    
    if (actionSheet) {
        [actionSheet addButtonWithTitle:@"取消"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    }
    
    if ((!systemVersionBelow8 && [alertController.actions count] == 0) ||
        (systemVersionBelow8 && actionSheet.numberOfButtons == 1)) {
        // what's the fuxx
        return;
    }
    
    if (!systemVersionBelow8) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [vc presentViewController:alertController animated:YES completion:nil];
    } else {
        [actionSheet showInView:vc.view];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), info);
    
    if (_callback) {
        _callback(info);
    }
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title hasPrefix:@"相册"]) {
        if ([title hasSuffix:@"PhotosAlbum"]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imagePicker.delegate = self;
            [_viewController presentViewController:imagePicker animated:YES completion:nil];
        } else {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            [_viewController presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if ([title hasPrefix:@"相机"]) {
        UIImagePickerControllerCameraDevice device = UIImagePickerControllerCameraDeviceRear;
        if ([title hasSuffix:@"前置相机"]) {
            device = UIImagePickerControllerCameraDeviceFront;
        }
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = device;
        imagePicker.delegate = self;
        [_viewController presentViewController:imagePicker animated:YES completion:nil];
    }
}

@end
