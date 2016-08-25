//
//  ImageMaskViewController.m
//  ImageMask
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ImageMaskViewController.h"
#import "UIImage+CCKit.h"

@implementation ImageMaskViewController

- (void)dealloc {
    NSLog(@"%@", @"dealloc");
}

- (NSString *)kc_description:(CGImageRef)imageRef {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    NSString *strAlphaInfo = @"";
    switch (alphaInfo) {
        case kCGImageAlphaNone:
            strAlphaInfo = @"None";
            break;
        case kCGImageAlphaPremultipliedLast:
            strAlphaInfo = @"PremultipliedLast";
            break;
        case kCGImageAlphaPremultipliedFirst:
            strAlphaInfo = @"PremultipliedFirst";
            break;
        case kCGImageAlphaLast:
            strAlphaInfo = @"AlphaLast";
            break;
        case kCGImageAlphaFirst:
            strAlphaInfo = @"AlphaFirst";
            break;
        case kCGImageAlphaNoneSkipLast:
            strAlphaInfo = @"NoneSkipLast";
            break;
        case kCGImageAlphaNoneSkipFirst:
            strAlphaInfo = @"NoneSkipFirst";
            break;
        case kCGImageAlphaOnly:
            strAlphaInfo = @"AlphaOnly";
            break;
        default:
            break;
    }
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    NSString *des = [NSString stringWithFormat:@"alpha:%@, bitsPerPixel:%@, bitsPerComponent:%@", strAlphaInfo, @(bitsPerPixel), @(bitsPerComponent)];
    return des;
}

- (UIImage *)alphaImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor cc_colorWithRed:0 green:0 blue:100].CGColor);
    CGContextClipToRect(context, CGRectMake(0, 0, size.width/2, size.height/2));
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [UIColor cc_colorWithRed:200 green:0 blue:0].CGColor);
    CGContextClipToRect(context, CGRectMake(size.width/2, 0, size.width/2, size.height/2));
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGContextRestoreGState(context);
    CGContextSetFillColorWithColor(context, [UIColor cc_colorWithRed:0 green:50 blue:0].CGColor);
    CGContextClipToRect(context, CGRectMake(0, size.height/2, size.width, size.height/2));
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)noAlphaImageWithSize:(CGSize)size gray:(BOOL)gray {
    size = CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale);
    
    CGColorSpaceRef colorSpace;
    CGContextRef context;
    if (gray) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        context = CGBitmapContextCreate (NULL, size.width, size.height,
                                         8, size.width, colorSpace, kCGImageAlphaNone);
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        context = CGBitmapContextCreate (NULL, size.width, size.height,
                                         8, size.width * 4, colorSpace, kCGImageAlphaNoneSkipLast);
    }
    
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    rect = CGRectInset(rect, floor(size.width/4), floor(size.height/4));
    CGContextFillEllipseInRect(context, rect);
    
    CGImageRef imageRes = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRes scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRes);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return image;
}

- (UILabel *)labelTipsWithText:(NSString *)text y:(CGFloat)y {
    UILabel *labelImage = [[UILabel alloc] initWithFrame:CGRectMake(0, y, ScreenWidth, 20)];
    labelImage.textAlignment = NSTextAlignmentCenter;
    labelImage.text = text;
    labelImage.font = [UIFont systemFontOfSize:17];
    return labelImage;
}

- (void)initView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    [self.view addSubview:_scrollView];
    
    /*
     The image to apply the mask parameter to. This image must not be an image mask and may not have an image mask or masking color associated with it.
     */
    UIImage *imageToMask = [UIImage imageNamed:@"ori"];
    
    CGFloat x = ScreenWidth/2-imageToMask.size.width/2;
    CGFloat y = 10;
    UILabel *labelTips = [self labelTipsWithText:@"ori image" y:y];
    [_scrollView addSubview:labelTips];
    y = labelTips.bottom + 10;
    
    _imageViewOri = [[UIImageView alloc] initWithImage:imageToMask];
    [_scrollView addSubview:_imageViewOri];
    _imageViewOri.frame = (CGRect){(CGPoint){x, y}, imageToMask.size};
    y = _imageViewOri.bottom + 10;
    
    /*
     A mask. If the mask is an image, it must be in the DeviceGray color space, must not have an alpha component, and may not itself be masked by an image mask or a masking color. If the mask is not the same size as the image specified by the image parameter, then Quartz scales the mask to fit the image.
    
     The resulting image depends on whether the mask parameter is an image mask or an image. If the mask parameter is an image mask, then the source samples of the image mask act as an inverse alpha value. That is, if the value of a source sample in the image mask is S, then the corresponding region in image is blended with the destination using an alpha value of (1-S). For example, if S is 1, then the region is not painted, while if S is 0, the region is fully painted.
     
     If the mask parameter is an image, then it serves as an alpha mask for blending the image onto the destination. The source samples of mask' act as an alpha value. If the value of the source sample in mask is S, then the corresponding region in image is blended with the destination with an alpha of S. For example, if S is 0, then the region is not painted, while if S is 1, the region is fully painted.
     */
    
    // mask with image, it must be DeviceGray color space, must not have an alpha component
    {
        labelTips = [self labelTipsWithText:@"image as mask" y:y];
        [_scrollView addSubview:labelTips];
        y = labelTips.bottom + 10;
        
        UIImage *imageAsMask = [self noAlphaImageWithSize:imageToMask.size gray:YES];
        _imageViewMaskWithImage = [[UIImageView alloc] initWithImage:imageAsMask];
        [_scrollView addSubview:_imageViewMaskWithImage];
        _imageViewMaskWithImage.frame = (CGRect){(CGPoint){x, y}, imageToMask.size};
        y = _imageViewMaskWithImage.bottom + 10;
        
        labelTips = [self labelTipsWithText:@"result of mask with image" y:y];
        [_scrollView addSubview:labelTips];
        y = labelTips.bottom + 10;
        
        CGImageRef imageMaskedRef = CGImageCreateWithMask(imageToMask.CGImage, imageAsMask.CGImage);
        UIImage *imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
        CGImageRelease(imageMaskedRef);
        _imageViewResultMaskWithImage = [[UIImageView alloc] initWithImage:imageMasked];
        [_scrollView addSubview:_imageViewResultMaskWithImage];
        _imageViewResultMaskWithImage.frame = (CGRect){(CGPoint){x, y}, imageToMask.size};
        y = _imageViewResultMaskWithImage.bottom + 10;
    }
    
    // mask with image mask
    {
        labelTips = [self labelTipsWithText:@"image mask ori image" y:y];
        [_scrollView addSubview:labelTips];
        y = labelTips.bottom + 10;
        
        // The image is used as a mask
        /*
         经测试可以得出以下结论：
         经过imageMask方法处理之后原图如果是黑色，，会使其变成白色，而白色的部分，变成了透明色
         彩色的图片也会变成类似白色的图，并且带有一定的透明色
         imageMask会把图片转换成透明度，黑色的alpha为1，白色为0，其余的在其之间
         不过取出CGImageGetAlphaInfo(CGImage)->kCGImageAlphaNone，让人很困惑...也许mask就不应该作为image显示吧
         
         文档中的Source sample是指被转成image mask之前的图片来说的，这个1 和 0代表什么呢？？？？搞一个alpha值为0.3的图片试试看
         1.我做了一个左边是alpha为0.5的图，右边是1，fill color为黑色，得到的结果是全部图都没有被mask，所以看来S值跟alpha没关系
         2.一个图分成了三部分，分别是red blue green，只有blue的部分被mask掉了...
         3.还是分成了三部分，每一部分都只给一个component设置了大于0的值，只有blue部分是有效的，并且值越大，结果的alpha值越小，即mask的越明显
         
         看来这个S值，在RGB中是Blue
         
         Source samples of an image mask act as an inverse alpha value. An image mask sample value (S):
         Equal to 1 blocks painting the corresponding image sample.
         Equal to 0 allows painting the corresponding image sample at full coverage.
         Greater than 0 and less 1 allows painting the corresponding image sample with an alpha value of (1 – S).
         */
        UIImage *imageOri = [self alphaImageWithSize:imageToMask.size];
        UIImageView *imageViewOri = [[UIImageView alloc] initWithImage:imageOri];
        [_scrollView addSubview:imageViewOri];
        imageViewOri.frame = (CGRect){(CGPoint){x, y}, imageToMask.size};
        y = imageViewOri.bottom + 10;
        
        labelTips = [self labelTipsWithText:@"image mask as mask" y:y];
        [_scrollView addSubview:labelTips];
        y = labelTips.bottom + 10;
        
        // generate a mask
        UIImage *imageMask = [imageOri cc_imageMask];
        _imageViewMaskWithImageMask = [[UIImageView alloc] initWithImage:imageMask];
        [_scrollView addSubview:_imageViewMaskWithImageMask];
        _imageViewMaskWithImageMask.frame = (CGRect){(CGPoint){x, y}, imageToMask.size};
        y = _imageViewMaskWithImageMask.bottom + 10;
        
        labelTips = [self labelTipsWithText:@"result of mask with image mask" y:y];
        [_scrollView addSubview:labelTips];
        y = labelTips.bottom + 10;
        
        CGImageRef imageMaskedRef = CGImageCreateWithMask(imageToMask.CGImage, imageMask.CGImage);
        UIImage *imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
        CGImageRelease(imageMaskedRef);
        
        _imageViewResultMaskWithImageMask = [[UIImageView alloc] initWithImage:imageMasked];
        [_scrollView addSubview:_imageViewResultMaskWithImageMask];
        _imageViewResultMaskWithImageMask.frame = (CGRect){(CGPoint){x, y}, imageToMask.size};
        y = _imageViewResultMaskWithImageMask.bottom + 10;
    }
    
    
    UILabel *labelColor = [self labelTipsWithText:@"mask with color" y:y];
    [_scrollView addSubview:labelColor];
    y = labelColor.bottom + 10;
    
    // mask with color
    {
        /*
         The image to mask. This parameter may not be an image mask, may not already have an image mask or masking color associated with it, and cannot have an alpha component.
         */
        UIImage *imageBg = [self noAlphaImageWithSize:CGSizeMake(200, 200) gray:NO];
        UIImageView *imageViewOri = [[UIImageView alloc] initWithImage:imageBg];
        [_scrollView addSubview:imageViewOri];
        imageViewOri.frame = (CGRect){(CGPoint){x, y}, imageBg.size};
        y = imageViewOri.bottom + 10;
        
        /*
         RGB一定要同时满足在区间内才会被mask out，it's a & not |
         */
        
        // mask out white color
        const CGFloat myMaskingColors[6] = {255, 255, 255, 255, 255, 255};
        // mask out black color
//        const CGFloat myMaskingColors[6] = {0, 0, 0, 0, 0, 0};
        CGImageRef imageMaskedRef = CGImageCreateWithMaskingColors(imageBg.CGImage, myMaskingColors);
        UIImage *imageMasked = [UIImage imageWithCGImage:imageMaskedRef];
        CGImageRelease(imageMaskedRef);
        _imageViewResultMaskWithColor = [[UIImageView alloc] initWithImage:imageMasked];
        _imageViewResultMaskWithColor.frame = (CGRect){(CGPoint){x, y}, imageBg.size};
        [_scrollView addSubview:_imageViewResultMaskWithColor];
        y = _imageViewResultMaskWithColor.bottom + 10;
    }
    
    UILabel *labelImage = [self labelTipsWithText:@"image mask clip" y:y];
    [_scrollView addSubview:labelImage];
    y = labelImage.bottom + 10;
    // use image mask as clip
    {
        UIImage *imageMask = [self noAlphaImageWithSize:_imageViewOri.size gray:NO];
        UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:imageMask];
        [_scrollView addSubview:imageViewMask];
        imageViewMask.origin = CGPointMake(x, y);
        y = imageViewMask.bottom + 10;
        
        imageMask = [imageMask cc_imageMask];
        UIGraphicsBeginImageContextWithOptions(_imageViewOri.bounds.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, _imageViewOri.bounds, imageMask.CGImage);
        [imageToMask drawInRect:_imageViewOri.bounds];
        UIImage *imageMasked = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *imageViewResult = [[UIImageView alloc] initWithImage:imageMasked];
        [_scrollView addSubview:imageViewResult];
        imageViewResult.origin = CGPointMake(x, y);
        y = imageViewResult.bottom + 10;
    }
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth, y);
    _scrollView.delegate = self;
//    _scrollView.bounds = CGRectMake(0, 0, 100, 100);
//    _scrollView.contentInset = UIEdgeInsetsMake(100, 100, 0, 0);
    [self showRightBarButtonItemWithName:@"right"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    
    [self.navigationController popViewControllerAnimated:NO];
    
    // 对UIImageView应用bounds看不出效果...
//    _imageViewResultMaskWithColor.bounds = CGRectMake(100, 100, _imageViewResultMaskWithColor.width, _imageViewResultMaskWithColor.height);
    
    // 对UIView可以看到效果
    //self.view.bounds = CGRectMake(100, 100, self.view.width, self.view.height);
    
    // bounds不变，frame改变
    //self.view.transform = CGAffineTransformMakeTranslation(100, 100);
    //NSLog(@"%@, %@", NSStringFromCGRect(self.view.bounds), NSStringFromCGRect(self.view.frame));
    // {{0, 0}, {375, 667}}, {{100, 100}, {375, 667}}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%@, %@", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGRect(scrollView.bounds));
}

@end
