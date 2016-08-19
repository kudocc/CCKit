//
//  CCLabel.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTextContainer.h"
#import "CCTextLayout.h"
#import "CCAsyncLayer.h"
#import "CCTextDefine.h"

@interface CCLabel : UIView

@property (nonatomic) BOOL asyncDisplay;

@property (nonatomic) UIFont *font;

@property (nonatomic) UIColor *textColor;

// default is NSTextAlignmentNatural
@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic) NSString *text;

@property (nonatomic) NSAttributedString *attributedText;

// from CCTextContainer
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) NSAttributedString *truncationToken;
@property (nonatomic) BOOL useEvenOddFillPathRule;
@property (nonatomic) NSArray<UIBezierPath *> *exclusionPaths;
@property (nonatomic) CGFloat pathWidth;

@property (nonatomic) CCTextVerticalAlignment verticleAlignment;

@property (nonatomic) CCTextLayout *textLayout;

@end
