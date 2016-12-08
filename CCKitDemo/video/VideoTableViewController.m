//
//  VideoTableViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "VideoTableViewController.h"
#import "EasyVideoRecordToFileViewController.h"

@interface VideoTableViewController ()

@end

@implementation VideoTableViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"Record using UIImagePickerController"];
    self.arrayClass = @[[EasyVideoRecordToFileViewController class]];
}

@end
