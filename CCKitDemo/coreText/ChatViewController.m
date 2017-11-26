//
//  ChatViewController.m
//  demo
//
//  Created by KudoCC on 16/6/1.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "ChatViewController.h"
#import "CCTextLayout.h"
#import "CCLabel.h"
#import "NSAttributedString+CCKit.h"
#import "UIImage+CCKit.h"
#import "CCFPSLabel.h"
#import "CoreTextHelper.h"

#import <YYLabel.h>

@interface ChatMessage : NSObject

+ (CGFloat)constraintWidth;
+ (CGFloat)paddingY;

- (id)initWithContent:(NSString *)strContent left:(BOOL)left;

@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, readonly) CGFloat contentWidth;
@property (nonatomic, readonly) CGFloat contentHeight;
@property (nonatomic) BOOL left;

@property (nonatomic) CCTextLayout *textLayout;
@property (nonatomic) YYTextLayout *yytextLayout;

@end

@implementation ChatMessage

+ (CGFloat)constraintWidth {
    static CGFloat width = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        width = 186;
        width = [UIScreen mainScreen].bounds.size.width * 0.675 - 20;
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
        
        CGSize constraint = CGSizeMake([self.class constraintWidth], CGFLOAT_MAX);
        _textLayout = [CCTextLayout textLayoutWithSize:constraint attributedText:_content];
        _yytextLayout = [YYTextLayout layoutWithContainerSize:constraint text:_content];
        
        _contentWidth = _textLayout.textBounds.width;
        _contentHeight = _textLayout.textBounds.height;
        _cellHeight = _contentHeight + [self.class paddingY];
        
        _contentWidth = _yytextLayout.textBoundingSize.width;
        _contentHeight = _yytextLayout.textBoundingSize.height;
        _cellHeight = _contentHeight + [self.class paddingY];
    }
    return self;
}

@end


@interface ChatTableViewCell : UITableViewCell

@property (nonatomic) ChatMessage *chatMessage;
@property (nonatomic) CCLabel *label;
@property (nonatomic) YYLabel *yylabel;

@end

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        _label = [[CCLabel alloc] init];
//        [self.contentView addSubview:_label];
        
        _yylabel = [[YYLabel alloc] init];
        [self.contentView addSubview:_yylabel];
    }
    return self;
}

- (void)setChatMessage:(ChatMessage *)chatMessage {
    if (_chatMessage == chatMessage) return;
    
    _chatMessage = chatMessage;
    if (_chatMessage.left) {
//        _label.backgroundColor = [UIColor whiteColor];
        _yylabel.backgroundColor = [UIColor whiteColor];
    } else {
//        _label.backgroundColor = [UIColor greenColor];
        _yylabel.backgroundColor = [UIColor greenColor];
    }
//    _label.textLayout = chatMessage.textLayout;
    _yylabel.textLayout = chatMessage.yytextLayout;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(0, [ChatMessage paddingY], _chatMessage.contentWidth, _chatMessage.contentHeight);
    if (!_chatMessage.left) {
        frame = CGRectOffset(frame, self.contentView.width-frame.size.width, 0);
    }
//    _label.frame = frame;
    _yylabel.frame = frame;
}

@end


@implementation ChatViewController {
    UITableView *_tableView;
    CCFPSLabel *_labelFps;
    NSArray<ChatMessage *> *_chatMsgs;
}

- (void)initView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    _labelFps = [[CCFPSLabel alloc] initWithFrame:CGRectMake(44, ScreenHeight-100, 0, 0)];
    [self.view addSubview:_labelFps];
    
    [self showLoadingMessage:@"Loading"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chat" ofType:@"plist"];
        NSArray *dataSource = [[NSArray alloc] initWithContentsOfFile:path];
        
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (NSDictionary *dict in dataSource) {
            ChatMessage *data = [[ChatMessage alloc] initWithContent:dict[@"content"] left:[dict[@"left"] boolValue]];
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
    ChatMessage *chatCell = [_chatMsgs objectAtIndex:indexPath.row];
    return chatCell.cellHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chatMsgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.chatMessage = [_chatMsgs objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = tableView.backgroundColor;
    return cell;
}

@end
