//
//  CoreTextChatViewController.m
//  demo
//
//  Created by KudoCC on 16/5/31.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "CoreTextChatViewController.h"
#import <CoreText/CoreText.h>
#import "NSAttributedString+CCKit.h"
#import "UIImage+CCKit.h"
#import "CCFPSLabel.h"
#import "CCTextLayout.h"
#import "CoreTextHelper.h"

@interface CCLine : NSObject

@property (nonatomic) CTLineRef line;
@property (nonatomic) CGPoint position;

- (id)initWithLine:(CTLineRef)line;

@end

@implementation CCLine

- (id)initWithLine:(CTLineRef)line {
    self = [super init];
    if (self) {
        _line = line;
        /*
        CFArrayRef runs = CTLineGetGlyphRuns(_line);
        CFIndex count = CFArrayGetCount(runs);
        for (CFIndex i = 0; i < count; ++i) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, i);
            CFRange range = CTRunGetStringRange(run);
            CGPoint position;
            CTRunGetPositions(run, CFRangeMake(0, 1), &position);
            NSLog(@"CTRunRef index:%@, range.location:%@, range.length:%@, pos.x:%@, pos.y:%@", @(i), @(range.location), @(range.length), @(position.x), @(position.y));
            CGFloat ascent = 0, descent = 0, leading = 0;
            CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            NSLog(@"width:%@, ascent:%@, descent:%@, leading:%@", @(width), @(ascent), @(descent), @(leading));
        }*/
    }
    return self;
}

@end

@interface CoreTextView : UIView
@property (nonatomic) CTFrameRef ctFrame;
@property (nonatomic) NSArray<CCLine *> *lines;
@end

@implementation CoreTextView

- (void)setLines:(NSArray<CCLine *> *)lines {
    _lines = lines;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    for (CCLine *line in _lines) {
        CGContextSetTextPosition(context, line.position.x, line.position.y);
        CTLineDraw(line.line, context);
    }
}

@end

@interface CoreTextMsg : NSObject

+ (CGFloat)constraintWidth;
+ (CGFloat)paddingY;

- (id)initWithContent:(NSString *)strContent left:(BOOL)left;

@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat contentWidth;
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic) BOOL left;

@property (nonatomic, readonly) CTFramesetterRef framesetter;
@property (nonatomic, readonly) CTFrameRef frame;
@property (nonatomic, readonly) CFArrayRef lines;
@property (nonatomic, readonly) NSArray<CCLine *> *ccLines;

@end

@implementation CoreTextMsg

+ (CGFloat)constraintWidth {
    static CGFloat width = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        width = ScreenWidth * 2 / 3;
        width = ceill(width);
    });
    return width;
}

+ (CGFloat)paddingY {
    return 20.0;
}

- (id)initWithContent:(NSString *)strContent left:(BOOL)left {
    self = [super init];
    if (self) {
        _content = [CoreTextHelper attributedStringFromContent:strContent];
        _left = left;
        
        _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_content);
        CGRect constraint = CGRectMake(0, 0, [self.class constraintWidth], 1024);
        CGPathRef path = CGPathCreateWithRect(constraint, NULL);
        _frame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, [_content length]), path, NULL);
        CGPathRelease(path);
        
        _lines = CTFrameGetLines(_frame);
        CFIndex count = CFArrayGetCount(_lines);
        if (count == 0) {
            return self;
        }
        CGPoint positions[count];
        CTFrameGetLineOrigins(_frame, CFRangeMake(0, 0), positions);
        CTLineRef bottomLine = CFArrayGetValueAtIndex(_lines, count-1);
        CGPoint bottomPosition = positions[count-1];
        CGFloat bottomLineDescent, bottomLineLeading;
        CTLineGetTypographicBounds(bottomLine, NULL, &bottomLineDescent, &bottomLineLeading);
        NSMutableArray *mArray = [NSMutableArray array];
        for (CFIndex i = count-1; i >= 0; --i) {
            CTLineRef line = CFArrayGetValueAtIndex(_lines, i);
            CGFloat ascent, descent, leading;
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGPoint po = positions[i];
            CCLine *ccLine = [[CCLine alloc] initWithLine:line];
            ccLine.position = CGPointMake(po.x, (po.y-bottomPosition.y + bottomLineDescent + bottomLineLeading));
            [mArray addObject:ccLine];
        }
        _ccLines = [mArray copy];
        
        CGSize size = [CCTextLayout textBoundsOfFrame:_frame];
//        _contentWidth = ceil(size.width);
        _contentHeight = ceil(size.height);
        _cellHeight = _contentHeight + [self.class paddingY];
    }
    return self;
}

@end


@interface CoreTextChatCell : UITableViewCell

@property (nonatomic) CoreTextMsg *chatCell;
@property (nonatomic) CoreTextView *viewChatMsg;

@end

@implementation CoreTextChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _viewChatMsg = [[CoreTextView alloc] init];
        [self.contentView addSubview:_viewChatMsg];
        _viewChatMsg.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setChatCell:(CoreTextMsg *)chatCell {
    if (_chatCell == chatCell) return;
    
    _chatCell = chatCell;
    _viewChatMsg.ctFrame = chatCell.frame;
    _viewChatMsg.lines = chatCell.ccLines;
    if (_chatCell.left) {
        _viewChatMsg.backgroundColor = [UIColor whiteColor];
    } else {
        _viewChatMsg.backgroundColor = [UIColor greenColor];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, [CoreTextMsg paddingY], [CoreTextMsg constraintWidth], _chatCell.contentHeight);
    if (!_chatCell.left) {
        frame = CGRectOffset(frame, self.contentView.width-frame.size.width, 0);
    }
    _viewChatMsg.frame = frame;
}

@end


@implementation CoreTextChatViewController {
    UITableView *_tableView;
    CCFPSLabel *_labelFps;
    NSArray<CoreTextMsg *> *_chatMsgs;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[CoreTextChatCell class] forCellReuseIdentifier:@"cell"];
    
    _labelFps = [[CCFPSLabel alloc] initWithFrame:CGRectMake(44, ScreenHeight-100, 0, 0)];
    [self.view addSubview:_labelFps];
    
    [self showLoadingMessage:@"Loading"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"plist"];
        NSArray *dataSource = [[NSArray alloc] initWithContentsOfFile:path];
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in dataSource) {
            CoreTextMsg *data = [[CoreTextMsg alloc] initWithContent:dict[@"content"] left:[dict[@"left"] boolValue]];
            [mutableArray addObject:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingMessage];
            
            _chatMsgs = [mutableArray copy];
            [_tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CoreTextMsg *chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    return chatCell.cellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatMsgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CoreTextChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = tableView.backgroundColor;
    return cell;
}

@end
