//
//  CCTextContainer.h
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCTextContainer : NSObject <NSCopying>

+ (CCTextContainer *)textContainerWithContentSize:(CGSize)contentSize contentInsets:(UIEdgeInsets)contentInsets;

@property (nonatomic) CGSize contentSize;
@property (nonatomic) UIEdgeInsets contentInsets;

/// YES is using even-odd rule, or use non-zero winding number rule, default is YES
@property (nonatomic) BOOL useEvenOddFillPathRule;
@property (nonatomic) NSArray<UIBezierPath *> *exclusionPaths;
@property (nonatomic) CGFloat pathWidth;

/// default is 0, no limit
@property (nonatomic) NSInteger maxNumberOfLines;
@property (nonatomic) NSAttributedString *truncationToken;

@end
