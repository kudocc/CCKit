//
//  PersistenceViewController.m
//  CCKitDemo
//
//  Created by KudoCC on 2016/12/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "PersistenceViewController.h"
#import "CCMmapUserDefaultsViewController.h"

@interface PersistenceViewController ()

@end

@implementation PersistenceViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"CCMmapUserSettings test"];
    self.arrayClass = @[[CCMmapUserDefaultsViewController class]];
}

@end
