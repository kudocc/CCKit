//
//  iOS11ViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/9/26.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "iOS11ViewController.h"
#import "UISearchControllerTestViewController.h"

@implementation iOS11ViewController

- (void)initView {
    [super initView];
    
    self.arrayTitle = @[@"SearchController"];
    self.arrayClass = @[[UISearchControllerTestViewController class]];
}

@end
