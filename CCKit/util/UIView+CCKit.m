#import "UIView+CCKit.h"

@implementation UIView (Coord)

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin
{
    CGRect newFrame = self.frame;
    newFrame.origin = newOrigin;
    self.frame = newFrame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)newSize
{
    CGRect newFrame = self.frame;
    newFrame.size = newSize;
    self.frame = newFrame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = newX;
    self.frame = newFrame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY
{
    CGRect newFrame = self.frame;
    newFrame.origin.y = newY;
    self.frame = newFrame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight
{
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth
{
    CGRect newFrame = self.frame;
    newFrame.size.width = newWidth;
    self.frame = newFrame;
}

- (CGFloat)left
{
    return self.x;
}

- (void)setLeft:(CGFloat)left
{
    self.x = left;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    self.x = right - self.width;
}

- (CGFloat)top
{
    return self.y;
}

- (void)setTop:(CGFloat)top
{
    self.y = top;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    self.y = bottom - self.height;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)newCenterX
{
    self.center = CGPointMake(newCenterX, self.center.y);
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)newCenterY
{
    self.center = CGPointMake(self.center.x, newCenterY);
}

- (CGPoint)middlePoint
{
    return CGPointMake(self.middleX, self.middleY);
}

- (CGFloat)middleX
{
    return self.width / 2;
}

- (CGFloat)middleY
{
    return self.height / 2;
}

- (CGFloat) maxX
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)maxY
{
    return CGRectGetMaxY(self.frame);
}

#pragma mark Recursion All Subviews

- (void)logViewHierarchy
{
    NSLog(@"%@", self);
    for (UIView *subview in self.subviews)
    {
        [subview logViewHierarchy];
    }
}

+ (CGRect)cc_frameOfContentWithContentSize:(CGSize)contentSize
                             containerSize:(CGSize)containerSize
                               contentMode:(UIViewContentMode)contentMode {
    CGFloat (^centerImageOriX)(void) = ^{
        return containerSize.width/2 - contentSize.width/2;
    };
    CGFloat (^centerImageOriY)(void) = ^{
        return containerSize.height/2 - contentSize.height/2;
    };
    
    CGRect frameImage = CGRectMake(0.0, 0.0, contentSize.width, contentSize.height);
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            frameImage = CGRectMake(0, 0, containerSize.width, containerSize.height);
            break;
        case UIViewContentModeScaleAspectFit: {
            CGFloat ratioW = containerSize.width/contentSize.width;
            CGFloat ratioH = containerSize.height/contentSize.height;
            CGFloat ratio = MIN(ratioW, ratioH);
            frameImage.size = CGSizeMake(floor(ratio * contentSize.width), floor(ratio * contentSize.height));
            frameImage.origin.x = containerSize.width/2 - frameImage.size.width/2;
            frameImage.origin.y = containerSize.height/2 - frameImage.size.height/2;
        }
            break;
        case UIViewContentModeScaleAspectFill: {
            CGFloat ratioW = containerSize.width/contentSize.width;
            CGFloat ratioH = containerSize.height/contentSize.height;
            CGFloat ratio = MAX(ratioW, ratioH);
            frameImage.size = CGSizeMake(floor(ratio * contentSize.width), floor(ratio * contentSize.height));
            frameImage.origin.x = containerSize.width/2 - frameImage.size.width/2;
            frameImage.origin.y = containerSize.height/2 - frameImage.size.height/2;
        }
            break;
            
        case UIViewContentModeCenter: {
            frameImage.origin.x = centerImageOriX();
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeTop: {
            frameImage.origin.x = centerImageOriX();
            frameImage.origin.y = 0.0;
        }
            break;
            
        case UIViewContentModeBottom: {
            frameImage.origin.x = centerImageOriX();
            frameImage.origin.y = containerSize.height - contentSize.height;
        }
            break;
            
        case UIViewContentModeLeft: {
            frameImage.origin.x = 0.0;
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeRight: {
            frameImage.origin.x = containerSize.width - contentSize.width;
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeTopLeft: {
            frameImage.origin.x = 0.0;
            frameImage.origin.y = 0.0;
        }
            break;
            
        case UIViewContentModeTopRight: {
            frameImage.origin.x = containerSize.width - contentSize.width;
            frameImage.origin.y = centerImageOriY();
        }
            break;
            
        case UIViewContentModeBottomLeft: {
            frameImage.origin.x = 0.0;
            frameImage.origin.y = containerSize.height - contentSize.height;
        }
            break;
            
        case UIViewContentModeBottomRight: {
            frameImage.origin.x = containerSize.width - contentSize.width;
            frameImage.origin.y = containerSize.height - contentSize.height;
        }
            break;
            
        default:
            break;
    }
    return frameImage;
}

@end
