//
//  CCFPSLabel.m
//  demo
//
//  Created by KudoCC on 16/6/8.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCFPSLabel.h"
#import "NSAttributedString+CCKit.h"

#define kSize CGSizeMake(55, 20)

@implementation CCFPSLabel {
    CADisplayLink *_displayLink;
    
    NSTimeInterval _lastTime;
    int _count;
}

- (id)initWithFrame:(CGRect)frame {
    if (CGSizeEqualToSize(frame.size, CGSizeZero)) {
        frame.size = kSize;
    }
    self = [super initWithFrame:frame];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkFired:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)displayLinkFired:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    ++_count;
    NSTimeInterval diff = link.timestamp - _lastTime;
    if (diff < 1) {
        return;
    }
    
    int fps = round(_count / diff);
    _count = 0;
    _lastTime = link.timestamp;
    NSString *text = [NSString stringWithFormat:@"%@ fps", @(fps)];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText cc_setFont:[UIFont systemFontOfSize:14.0]];
    [attrText cc_setColor:[UIColor redColor]];
    self.attributedText = attrText;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [_displayLink invalidate];
    }
}

@end
