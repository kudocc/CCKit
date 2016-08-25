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
        NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:@"http://www.baidu.com"];
        [highlightedText cc_setHighlightedColor:[UIColor redColor] bgColor:[UIColor grayColor] range:NSMakeRange(0, highlightedText.length) tapAction:^(NSRange range) {
            NSLog(@"tap action:%@", NSStringFromRange(range));
        }];
        [highlightedText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [highlightedText cc_setColor:[UIColor blueColor]];
        [mutableAttrString appendAttributedString:highlightedText];
    }
    
    {
        NSMutableAttributedString *simpleText = [[NSMutableAttributedString alloc] initWithString:@"Good to see you again. Well 你奶奶的顿的。哼哼，呵呵o(￣ヘ￣o#)"];
        [simpleText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [mutableAttrString appendAttributedString:simpleText];
    }
    
    {// <a href=''><image src=''></image></a>
        NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] init];
        UIImage *imageName = [UIImage imageNamed:@"avatar_ori"];
        NSAttributedString *attachment = [NSAttributedString cc_attachmentStringWithContent:imageName contentMode:UIViewContentModeScaleToFill contentSize:CGSizeMake(100, 80) alignToFont:[UIFont systemFontOfSize:16] attachmentPosition:CCTextAttachmentPositionTop];
        [mutable appendAttributedString:attachment];
        
        NSMutableAttributedString *highlightedText = [[NSMutableAttributedString alloc] initWithString:@"g.cn"];
        [highlightedText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [highlightedText cc_setColor:[UIColor blueColor]];
        
        [mutable appendAttributedString:highlightedText];
        [mutable cc_setHighlightedColor:[UIColor redColor] bgColor:[UIColor grayColor] range:NSMakeRange(0, mutable.length) tapAction:^(NSRange range) {
            NSLog(@"tap action:%@", NSStringFromRange(range));
        }];
        
        [mutableAttrString appendAttributedString:mutable];
    }
    
    {
        NSMutableAttributedString *simpleText = [[NSMutableAttributedString alloc] initWithString:@"现在下午最困的时候，手机和电脑都要没电了，算了，继续搞吧"];
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
        NSMutableAttributedString *simpleText = [[NSMutableAttributedString alloc] initWithString:@"对了，弄好之后可以看小说了，又找到了一本东野圭吾的小说，叫红手指，一会查查豆瓣评分看看怎么样"];
        [simpleText cc_setFont:[UIFont systemFontOfSize:16.0]];
        [mutableAttrString appendAttributedString:simpleText];
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

#pragma mark - UIGestureRecognizerDelegate

@end
