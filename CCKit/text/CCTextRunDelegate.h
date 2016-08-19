//
//  CCTextRunDelegate.h
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CCTextDefine.h"

@interface CCTextRunDelegate : NSObject

- (CTRunDelegateRef)createCTRunDelegateRef;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat ascent;
@property (nonatomic) CGFloat descent;

@end
