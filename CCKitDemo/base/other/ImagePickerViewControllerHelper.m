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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (((flag & ImagePickerFlagAlbum) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) ||
        ((flag & ImagePickerFlagPhoto) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])) {
        // check 相册
        ALAuthorizationStatus al_status = [ALAssetsLibrary authorizationStatus];
        if (al_status == ALAuthorizationStatusAuthorized ||
            al_status == ALAuthorizationStatusNotDetermined) {
            if ((flag & ImagePickerFlagAlbum) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"相册-PhotosAlbum" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    imagePicker.delegate = self;
                    [vc presentViewController:imagePicker animated:YES completion:nil];
                }];
                [alertController addAction:actionPhoto];
            }
            if ((flag & ImagePickerFlagPhoto) && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIAlertAction *actionPhoto = [UIAlertAction actionWithTitle:@"相册-PhotoLibrary" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker.delegate = self;
                    [vc presentViewController:imagePicker animated:YES completion:nil];
                }];
                
                [alertController addAction:actionPhoto];
            }
        } else {
            // ALAuthorizationStatusRestricted || ALAuthorizationStatusDenied
            // can't access
            if (al_status == ALAuthorizationStatusDenied) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在iOS的“设置”-“隐私”-“照片”Demo中，允许Demo访问你的照片。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [vc presentViewController:alert animated:YES completion:nil];
                return;
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
                UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"后置相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                    imagePicker.delegate = self;
                    [vc presentViewController:imagePicker animated:YES completion:nil];
                }];
                [alertController addAction:actionCamera];
            }
            if ((flag & ImagePickerFlagCameraFront) &&
                [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
                UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:@"前置相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                    imagePicker.delegate = self;
                    [vc presentViewController:imagePicker animated:YES completion:nil];
                }];
                [alertController addAction:actionCamera];
            }
        } else {
            // can't access
            if (status == AVAuthorizationStatusDenied) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"相机不可用" message:@"请在iOS的“设置”-“隐私”-“相机”Demo中，允许Demo访问你的相机。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:action];
                [vc presentViewController:alert animated:YES completion:nil];
                return;
            }
        }
    }
    
    if ([alertController.actions count] == 0) {
        // what's the fuxx
        return;
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancel];
    [vc presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), info);
    
    if (_callback) {
        _callback(info);
    }
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
