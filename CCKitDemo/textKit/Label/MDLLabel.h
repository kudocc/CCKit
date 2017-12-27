//
//  MDLLabel.h
//  CCKitDemo
//
//  Created by kudocc on 2017/10/17.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSAttributedStringKey MDLHighlightAttributeName;

@interface MDLHighlightAttributeValue : NSObject <NSCopying>

@property (nonatomic) UIColor *highlightTextColor;
@property (nonatomic) UIColor *highlightBackgroundColor;
@property (nonatomic) NSRange effectRange;

@property (nonatomic) NSDictionary *userInfo;

@property (nonatomic, readonly) NSDictionary *attributes;

@end


@interface NSAttributedString (MDLHighlightAttribute)

- (MDLHighlightAttributeValue *)mdl_highlightAttributeValueAtIndex:(NSInteger)index effectiveRange:(NSRangePointer)range;

@end


@interface NSMutableAttributedString (MDLHighlightAttribute)

- (void)mdl_addHighlightAttributeValue:(MDLHighlightAttributeValue *)value range:(NSRange)range;
- (void)mdl_removeHighlightAttributeValueRange:(NSRange)range;

@end

@interface NSAttributedString (MDLTextAttachment)
+ (NSAttributedString *)mdl_attachmentStringWithEmojiImage:(UIImage *)image fontSize:(CGFloat)fontSize;
@end

@interface MDLTextAttachment : NSTextAttachment

+ (instancetype)imageAttachmentWithImage:(UIImage *)image size:(CGSize)size alignFont:(UIFont *)font;
+ (instancetype)imageAttachmentWithImage:(UIImage *)image bounds:(CGRect)bounds contentInsets:(UIEdgeInsets)contentInsets;

@end


@interface MDLLabelLayout : NSObject

@property (nonatomic, readonly) NSLayoutManager *layoutManager;
@property (nonatomic, readonly) NSTextContainer *textContainer;
@property (nonatomic, readonly) NSTextStorage *textStorage;

@property (nonatomic, readonly) CGSize bounds;

- (CGPoint)layoutPositionFromLabelPosition:(CGPoint)pos;

+ (instancetype)labelLayoutWithAttributedText:(NSAttributedString *)text maxSize:(CGSize)size;

@end


/**
 TODO:
 1. 支持传入Layout
 */

@protocol MDLLabelDelegate;

@interface MDLLabel : UIView

@property (nonatomic, copy) IBInspectable NSString *text;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) IBInspectable UIColor *textColor;

@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic) CGSize shadowOffset;

@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic) UIEdgeInsets textContainerInset;


// By default, we detect dataDetectorTypes synchronize on main thread, if this property is YES, we do it in background
@property (nonatomic) BOOL asyncDataDetector;

// Default is `UIDataDetectorTypeNone`
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic) NSDataDetector *customDataDetector;

/// Attributes which apply to link string
@property (nonatomic, strong) NSDictionary<NSString *, id> *linkTextAttributes;


@property (nonatomic, weak) id<MDLLabelDelegate> delegate;

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
