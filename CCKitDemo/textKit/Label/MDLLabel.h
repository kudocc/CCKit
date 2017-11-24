//
//  MDLLabel.h
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSAttributedStringKey MDLHighlightAttributeName;

@interface MDLHighlightAttributeValue : NSObject

@property (nonatomic) UIColor *highlightTextColor;
@property (nonatomic) UIColor *highlightBackgroundColor;
@property (nonatomic) NSRange effectRange;

@property (nonatomic, readonly) NSDictionary *attributes;

@end


@interface NSAttributedString (MDLHighlightAttribute)

- (MDLHighlightAttributeValue *)mdl_highlightAttributeValueAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)range;

@end


@interface NSMutableAttributedString (MDLHighlightAttribute)

- (void)mdl_addHighlightAttributeValue:(MDLHighlightAttributeValue *)value range:(NSRange)range;
- (void)mdl_removeHighlightAttributeValueRange:(NSRange)range;

@end


/**
 坑爹1 text中存在\n，NSTextContainer的maximumNumberOfLines设置1，那么你传给它的size的width是多大，它就用多大(如果设置过大的width，比如9999，用模拟器iPhoneX跑时，绘制时啥都看不到，原因不明，真机是好的iPhone6, iOS11)
 
 2 shadow没有为offset留出空间，考虑要不要支持shadow
 */

@protocol MDLLabelDelegate;

@interface MDLLabel : UIView

@property (nonatomic, weak) id<MDLLabelDelegate> delegate;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic) CGSize shadowOffset;

@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
/// Attributes which apply to link string
@property (nonatomic, strong) NSDictionary<NSString *, id> *linkTextAttributes;

@property (nonatomic) NSInteger numberOfLines;


/*
// these next 3 properties allow the label to be autosized to fit a certain width by scaling the font size(s) by a scaling factor >= the minimum scaling factor
// and to specify how the text baseline moves when it needs to shrink the font.

@property(nonatomic) BOOL adjustsFontSizeToFitWidth;         // default is NO
@property(nonatomic) UIBaselineAdjustment baselineAdjustment; // default is UIBaselineAdjustmentAlignBaselines
@property(nonatomic) CGFloat minimumScaleFactor NS_AVAILABLE_IOS(6_0); // default is 0.0


// Tightens inter-character spacing in attempt to fit lines wider than the available space if the line break mode is one of the truncation modes before starting to truncate.
// The maximum amount of tightening performed is determined by the system based on contexts such as font, line width, etc.
@property(nonatomic) BOOL allowsDefaultTighteningForTruncation NS_AVAILABLE_IOS(9_0); // default is NO

*/

// Support for constraint-based layout (auto layout)
// If nonzero, this is used when determining -intrinsicContentSize for multiline labels
@property(nonatomic) CGFloat preferredMaxLayoutWidth;




@end


@protocol MDLLabelDelegate <NSObject>

@optional
- (BOOL)label:(MDLLabel *)label shouldTapHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange;
- (void)label:(MDLLabel *)label didTapHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange;
- (BOOL)label:(MDLLabel *)label shouldLongPressHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange;
- (void)label:(MDLLabel *)label didLongPressHighlight:(MDLHighlightAttributeValue *)highlight inRange:(NSRange)characterRange;

@end
