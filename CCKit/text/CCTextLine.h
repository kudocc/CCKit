//
//  CCTextLine.h
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreText/CoreText.h"

@class CCTextAttachment;
@class CCTextRun;
@interface CCTextLine : NSObject

+ (CCTextLine *)textLineWithOrigin:(CGPoint)origin frame:(CGRect)frame line:(CTLineRef)line;

/// line's origin in CCTextContainer's coordinate, UP and Right
@property (nonatomic) CGPoint origin;
/// line's frame in CCTextContainer's coordinate, UP and Right
@property (nonatomic) CGRect frame;

@property (nonatomic) CTLineRef line;

@property (nonatomic) NSArray<CCTextAttachment *> *attachments;
/// array of attachment frame in CCTextContainer's coordinate, UP and Right
@property (nonatomic) NSArray<NSValue *> *attachmentFrames;
/// array of CCTextRun
@property (nonatomic) NSArray<CCTextRun *> *textRuns;

@end


@interface CCTextRun : NSObject

/// text frame in Core Text Coordinate, zero position is the last line's leading position
@property (nonatomic) CGRect frame;

@property (nonatomic, strong) id run;

@end