//
//  ImagePickerViewControllerHelper.h
//  demo
//
//  Created by KudoCC on 16/5/18.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, ImagePickerFlag) {
    ImagePickerFlagAlbum = 1<<0,
    ImagePickerFlagPhoto = 1<<1,
    ImagePickerFlagCameraRear = 1<<2,
    ImagePickerFlagCameraFront = 1<<3,
    ImagePickerFlagAll = 0x0f,
};

typedef void(^ImagePickerInfoCallback)(NSDictionary<NSString *,id> *info);

@interface ImagePickerViewControllerHelper : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (instancetype)sharedHelper;

@property (nonatomic, copy) ImagePickerInfoCallback callback;

- (void)presentImagePickerWithBlock:(ImagePickerInfoCallback)callback viewController:(UIViewController *)vc;
- (void)presentImagePickerWithBlock:(ImagePickerInfoCallback)callback flag:(ImagePickerFlag)flag viewController:(UIViewController *)vc;

@end
