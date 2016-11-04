//
//  CCLabelDemoViewController.m
//  demo
//
//  Created by KudoCC on 16/6/3.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CCLabelDemoViewController.h"
#import "CCLabel.h"
#import "NSAttributedString+CCKit.h"

@interface CCLabelDemoViewController ()
@end

@implementation CCLabelDemoViewController {
    CCLabel *label;
    
    UIView *viewDrag;
}

- (void)initView {
    NSMutableAttributedString *mutableAttrString = [[NSMutableAttributedString alloc] init];
    
    {
        NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:@"百度"];
        [highlightedText cc_setHighlightedColor:[UIColor redColor] bgColor:[UIColor grayColor] range:NSMakeRange(0, highlightedText.length) tapAction:^(NSRange range) {
            NSLog(@"tap action:%@", NSStringFromRange(range));
        }];
        [highlightedText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [highlightedText cc_setColor:[UIColor blueColor]];
        [mutableAttrString appendAttributedString:highlightedText];
    }
    
    {// <a href=''><image src=''></image></a>
        NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] init];
        UIImage *imageName = [UIImage imageNamed:@"avatar_ori"];
        NSAttributedString *attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeScaleToFill contentSize:CGSizeMake(50, 45) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutable appendAttributedString:attachment];
        
        NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:@"GOOGLE"];
        [highlightedText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [highlightedText cc_setColor:[UIColor blueColor]];
        
        [mutable appendAttributedString:highlightedText];
        [mutable cc_setHighlightedColor:[UIColor redColor] bgColor:[UIColor grayColor] range:NSMakeRange(0, mutable.length) tapAction:^(NSRange range) {
            NSLog(@"tap action:%@", NSStringFromRange(range));
        }];
        
        [mutableAttrString appendAttributedString:mutable];
    }
    
    {
        NSAttributedString *simpleText = [NSAttributedString cc_attributedStringWithString:@"Good to see you again. System font with 16 point size and #cecece color" textColor:[UIColor cc_opaqueColorWithHexString:@"#cecece"] font:[UIFont systemFontOfSize:16.0]];
        [mutableAttrString appendAttributedString:simpleText];
    }
    
    {
        NSMutableAttributedString *simpleText = [[NSMutableAttributedString alloc] initWithString:@"Text with background color"];
        [simpleText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [simpleText cc_setBgColor:[UIColor greenColor]];
        [mutableAttrString appendAttributedString:simpleText];
    }
    
    {
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"seg1", @"seg2"]];
        NSAttributedString *attachment = [NSAttributedString cc_attachmentStringWithContent:segmentedControl contentMode:UIViewContentModeTop contentSize:segmentedControl.size alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionCenter];
        [mutableAttrString appendAttributedString:attachment];
    }
    
    {
        NSMutableAttributedString *simpleText = [NSMutableAttributedString cc_attributedStringWithString:@"System font with 18 point size and blue color" textColor:[UIColor blueColor]];
        [simpleText cc_setFont:[UIFont systemFontOfSize:18.0]];
        [mutableAttrString appendAttributedString:simpleText];
    }
    
    {
        UIImage *imageName = [UIImage imageNamed:@"avatar_ori"];
        NSAttributedString *attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeTop contentSize:CGSizeMake(100, 90) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutableAttrString appendAttributedString:attachment];
        
        attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeBottom contentSize:CGSizeMake(100, 90) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutableAttrString appendAttributedString:attachment];
        
        attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeLeft contentSize:CGSizeMake(100, 90) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutableAttrString appendAttributedString:attachment];
        
        attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeRight contentSize:CGSizeMake(100, 90) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutableAttrString appendAttributedString:attachment];
        
        attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeScaleToFill contentSize:CGSizeMake(100, 90) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutableAttrString appendAttributedString:attachment];
        
        attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeScaleAspectFit contentSize:CGSizeMake(100, 90) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionBottom];
        [mutableAttrString appendAttributedString:attachment];
    }
    
    label = [[CCLabel alloc] initWithFrame:CGRectMake(10, 100, 300, 200)];
    label.layer.borderColor = [UIColor greenColor].CGColor;
    label.layer.borderWidth = PixelToPoint(1);
    label.attributedText = mutableAttrString;
    label.asyncDisplay = NO;
    label.truncationToken = [NSAttributedString cc_attributedStringWithString:@"øøø"];
    label.verticleAlignment = CCTextVerticalAlignmentCenter;
    [self.view addSubview:label];
    
    viewDrag = [[UIView alloc] initWithFrame:CGRectMake(label.right-10, label.bottom-10, 20, 20)];
    viewDrag.backgroundColor = [UIColor greenColor];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGesture:)];
    pan.maximumNumberOfTouches = 1;
    [viewDrag addGestureRecognizer:pan];
    [self.view addSubview:viewDrag];
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
