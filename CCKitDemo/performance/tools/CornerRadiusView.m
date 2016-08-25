//
//  CornerRadiusView.m
//  performance
//
//  Created by KudoCC on 16/1/21.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CornerRadiusView.h"
#import "UIView+CCKit.h"

@implementation CornerRadiusView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    
    // context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // if there is a corner radius, set clear color as fill color, then fill background and set the clip zone
    if (_cornerRadius > 0.0) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, self.bounds);
        [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:_cornerRadius] addClip];
    }
    
    if (self.image) {
        // draw content
        CGRect frameImage = [UIView cc_frameOfContentWithContentSize:_image.size containerSize:size contentMode:self.contentMode];
        [self.image drawInRect:frameImage];
    }
    
    // draw border
    if (_borderWidth > 0.0 && _borderColor) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(_borderWidth/2, _borderWidth/2, _borderWidth/2, _borderWidth/2)) cornerRadius:_cornerRadius];
        path.lineWidth = _borderWidth;
        [path stroke];
    }
}

@end
