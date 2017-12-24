//
//  TextKitLabelDragViewController.m
//  CCKitDemo
//
//  Created by rui yuan on 2017/12/3.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "TextKitLabelDragViewController.h"
#import "MDLLabel.h"
#import "NSAttributedString+CCKit.h"
#import "UIImage+CCKit.h"

@interface TextKitLabelDragViewController () {
    MDLLabel *label;
    UIView *viewDrag;
}

@end

@implementation TextKitLabelDragViewController

- (UIImage *)imageWithLocalFileURL:(NSURL *)url {
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (imageSource) {
        CFDictionaryRef property = CGImageSourceCopyProperties(imageSource, NULL);
        NSDictionary *dictProperty = (__bridge_transfer id)property;
        NSLog(@"container property:%@", dictProperty);
        
        property = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        dictProperty = (__bridge_transfer id)property;
        NSLog(@"image at index 0 property:%@", dictProperty);
        
        UIImageOrientation orientation = UIImageOrientationUp;
        int exifOrientation;
        CFTypeRef val = CFDictionaryGetValue(property, kCGImagePropertyOrientation);
        if (val) {
            CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
            orientation = [UIImage cc_exifOrientationToiOSOrientation:exifOrientation];
        }
        
        CFDictionaryRef gifDict = CFDictionaryGetValue(property, kCGImagePropertyGIFDictionary);
        CGFloat dur = 0.2;
        if (gifDict) {
            CFStringRef val = CFDictionaryGetValue(gifDict, kCGImagePropertyGIFDelayTime);
            NSString *delay = (__bridge NSString *)val;
            dur = [delay doubleValue];
        }
        
        size_t count = CGImageSourceGetCount(imageSource);
        NSLog(@"image count:%zu", count);
        dur = dur * count;
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (size_t i = 0; i < count; ++i) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (img) {
                UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:orientation];
                [mutableArray addObject:image];
                CGImageRelease(img);
            }
        }
        CFRelease(imageSource);
        
        UIImage *result = [UIImage animatedImageWithImages:[mutableArray copy] duration:dur];
        return result;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //    NSString *str = @"02345678901234\n567890123456789012345678901234567890123456789001234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345";
    NSString *str = @"Hello everyone, this label is enhancement of UILabel. It can also detect url and email. For example: This link is https://www.baidu.com, try to email me at rui.yuan@musical.ly. Join two http://www.google.comhttps://www.github.com";
    //    NSString *str = @"👩‍👧‍👦🎒👖🎒🎒👔🎒🎒🎒🎒👔👩‍👧‍👦🎒🎒🎒👔👨‍👧‍👦🎒🎒🎒👔👨‍👧‍👦🎒🎒🎒🎒👨‍👦‍👦🎒🎒🎒🎒🎒🎒👔👨‍👧‍👦🐌🐌🙊🐌🐌🐌🙊🐌🙉🐌🐌🐌🐌🐷🐌🙉🐌🐌🐌🐌🐷🐌🙊🐌🐂🐁🐁🐄🐇🐇🐂🐇🐄🐁🐋🐁🐁🐄🐂🐂🦏🐁🐂🐁🐋🐁🐁🐂🐄🌗🎍🌗🌖🌖🎋🎋🌘🌗🌴🌗🌗";
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:str];
    [mAttr cc_setColor:[UIColor blackColor]];
    [mAttr cc_setFont:[UIFont systemFontOfSize:14]];
    [mAttr cc_addAttributes:@{NSForegroundColorAttributeName:[UIColor yellowColor] ,
                              NSBackgroundColorAttributeName:[UIColor redColor]/*, NSBaselineOffsetAttributeName: @0*/} range:NSMakeRange(0, 30) overrideOldAttribute:YES];
    
    {// paragraph
        [mAttr cc_setLineSpacing:2];
    }
    
    
    {// attachment
        UIFont *font = [mAttr cc_font];
        UIImage *image = [UIImage imageNamed:@"avatar_ori"];
        MDLTextAttachment *imageAttachment = [MDLTextAttachment imageAttachmentWithImage:image size:CGSizeMake(50, 50) alignFont:font];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:1];
    }
    
    {// attachment
        UIFont *font = [mAttr cc_font];
        UIImage *image = [UIImage imageNamed:@"avatar_ori"];
        MDLTextAttachment *imageAttachment = [MDLTextAttachment imageAttachmentWithImage:image size:CGSizeMake(100, 100) alignFont:font];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:1];
    }
    
    {// gif attachment
        NSString *path = [[NSBundle mainBundle] pathForResource:@"image_source" ofType:@"gif"];
        NSURL *url = [NSURL fileURLWithPath:path];
        UIImage *image = [self imageWithLocalFileURL:url];
        UIFont *font = [UIFont systemFontOfSize:14];
        MDLTextAttachment *imageAttachment = [MDLTextAttachment imageAttachmentWithImage:image size:CGSizeMake(60, 80) alignFont:font];
        NSAttributedString *attachment = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [mAttr insertAttributedString:attachment atIndex:4];
    }
    
    {
        UIImage *image = [UIImage imageNamed:@"dl_emoji_angry_big"];
        NSAttributedString *attr = [NSAttributedString mdl_attachmentStringWithEmojiImage:image fontSize:14];
        [mAttr insertAttributedString:attr atIndex:5];

        UIImage *image1 = [UIImage imageNamed:@"dl_emoji_complacent_big"];
        NSAttributedString *attr1 = [NSAttributedString mdl_attachmentStringWithEmojiImage:image1 fontSize:14];
        [mAttr insertAttributedString:attr1 atIndex:6];
    }
    
    label = [[MDLLabel alloc] initWithFrame:CGRectMake(0, 100, 320, 0)];
    label.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    label.layer.borderColor = [UIColor greenColor].CGColor;
    label.layer.borderWidth = PixelToPoint(1);
    [self.view addSubview:label];
    
    label.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width * 0.675 - 20;
    label.attributedText = mAttr;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.dataDetectorTypes = UIDataDetectorTypeAll;
    label.asyncDataDetector = YES;
    
    viewDrag = [[UIView alloc] initWithFrame:CGRectMake(label.right-10, label.bottom-10, 20, 20)];
    viewDrag.backgroundColor = [UIColor greenColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGesture:)];
    pan.maximumNumberOfTouches = 1;
    [viewDrag addGestureRecognizer:pan];
    [self.view addSubview:viewDrag];

    [self showRightBarButtonItemWithName:@"size to fit"];
}

- (void)rightBarButtonItemClick:(UIBarButtonItem *)rightBarButtonItem {
    [label sizeToFit];
}

- (void)dragGesture:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [pan locationInView:self.view];
        if (pos.x-label.left > 100 && pos.y-label.top > 100) {
            label.frame = CGRectMake(label.left, label.top, pos.x-label.left, pos.y-label.top);
            viewDrag.center = pos;
        }
    }
}

@end
