//
//  MDLMenuLabel.h
//  CCKitDemo
//
//  Created by kudocc on 2017/10/10.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDLMenuLabel : UILabel

@property (nonatomic) IBInspectable UIColor *selectedBackgroundColor;

- (void)forceShowMenu;

@end
