//
//  SimpleChatViewController.m
//  demo
//
//  Created by KudoCC on 16/5/31.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "SimpleChatViewController.h"
#import "NSAttributedString+CCKit.h"
#import "UIImage+CCKit.h"
#import "CCFPSLabel.h"
#import "CoreTextHelper.h"

@interface ChatMsgView : UIView

@property (nonatomic) NSAttributedString *content;

@end

@implementation ChatMsgView

- (void)setContent:(NSAttributedString *)content {
    if ([_content isEqualToAttributedString:content]) {
        return;
    }
    _content = content;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (_content) {
        [_content drawInRect:self.bounds];
    }
}

@end

@interface ChatCell : NSObject

+ (CGFloat)constraintWidth;
+ (CGFloat)paddingY;

- (id)initWithContent:(NSString *)strContent left:(BOOL)left;

@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat contentWidth;
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic) BOOL left;

@end

@implementation ChatCell

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
        
        CGSize constraintSize = CGSizeMake([self.class constraintWidth], 1024);
        CGRect boundingRect = [_content boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        _contentWidth = ceil(boundingRect.size.width);
        _contentHeight = (ceil(boundingRect.size.height) > constraintSize.height) ? constraintSize.height : ceil(boundingRect.size.height);
        _cellHeight = _contentHeight + [self.class paddingY];
    }
    return self;
}

@end

@interface SimpleChatCell : UITableViewCell

@property (nonatomic) ChatCell *chatCell;
@property (nonatomic) ChatMsgView *viewChatMsg;

@end

@implementation SimpleChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _viewChatMsg = [[ChatMsgView alloc] init];
        [self.contentView addSubview:_viewChatMsg];
//        NSLog(@"is opaque:%@", @(_viewChatMsg.opaque));
//        _viewChatMsg.alpha = 0.5;
//        NSLog(@"after is opaque:%@", @(_viewChatMsg.opaque));
        _viewChatMsg.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setChatCell:(ChatCell *)chatCell {
    if (_chatCell == chatCell) return;
    
    _chatCell = chatCell;
    if (_chatCell.left) {
        _viewChatMsg.backgroundColor = [UIColor whiteColor];
    } else {
        _viewChatMsg.backgroundColor = [UIColor greenColor];
    }
    _viewChatMsg.content = chatCell.content;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, [ChatCell paddingY], _chatCell.contentWidth, _chatCell.contentHeight);
    if (!_chatCell.left) {
        frame = CGRectOffset(frame, self.contentView.width-frame.size.width, 0);
    }
    _viewChatMsg.frame = frame;
}

@end

@implementation SimpleChatViewController {
    UITableView *_tableView;
    CCFPSLabel *_labelFps;
    NSArray<ChatCell *> *_chatMsgs;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[SimpleChatCell class] forCellReuseIdentifier:@"cell"];
    
    _labelFps = [[CCFPSLabel alloc] initWithFrame:CGRectMake(44, ScreenHeight-100, 0, 0)];
    [self.view addSubview:_labelFps];
    
    [self showLoadingMessage:@"Loading"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"plist"];
        NSArray *dataSource = [[NSArray alloc] initWithContentsOfFile:path];
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in dataSource) {
            ChatCell *data = [[ChatCell alloc] initWithContent:dict[@"content"] left:[dict[@"left"] boolValue]];
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
    ChatCell *chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    return chatCell.cellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatMsgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SimpleChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = tableView.backgroundColor;
    return cell;
}

@end
