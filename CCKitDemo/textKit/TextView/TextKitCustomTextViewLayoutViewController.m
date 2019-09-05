//
//  TextKitCustomTextViewLayoutViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2018/1/23.
//  Copyright © 2018年 KudoCC. All rights reserved.
//

#import "TextKitCustomTextViewLayoutViewController.h"
#import "NSAttributedString+CCKit.h"
#import "UIColor+CCKit.h"

const NSAttributedStringKey TextKitTimeKey = @"NSAttributedStringKey";

@interface TextKitCustomLayoutManager : NSLayoutManager <NSLayoutManagerDelegate>
@end

@implementation TextKitCustomLayoutManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark -

- (BOOL)layoutManager:(NSLayoutManager *)layoutManager shouldBreakLineByWordBeforeCharacterAtIndex:(NSUInteger)charIndex {
    
    NSString *str = [layoutManager.textStorage attributedSubstringFromRange:NSMakeRange(charIndex, 1)].string;
    NSLog(@"-- %@, %@", str, @(charIndex));
    
    NSString *value = [layoutManager.textStorage attribute:TextKitTimeKey atIndex:charIndex effectiveRange:NULL];
    if (!value || charIndex == 0) {
        return YES;
    }
    
    if ([layoutManager.textStorage attribute:TextKitTimeKey atIndex:charIndex-1 effectiveRange:NULL]) {
        return NO;
    } else {
        return YES;
    }
}

@end


@interface TextKitModel : NSObject

@property (nonatomic) NSString *content;
@property (nonatomic) NSString *date;

@property (nonatomic) NSAttributedString *attributedText;

+ (instancetype)textKitModelWithContent:(NSString *)cn date:(NSString *)date;

@end

@implementation TextKitModel

+ (instancetype)textKitModelWithContent:(NSString *)cn date:(NSString *)date {
    TextKitModel *tk = [[TextKitModel alloc] init];
    tk.content = cn;
    tk.date = date;
    return tk;
}

- (NSAttributedString *)attributedText {
    NSString *str = [NSString stringWithFormat:@"%@ %@", _content, _date];
    NSMutableAttributedString *m = [[NSMutableAttributedString alloc] initWithString:str];
    [m cc_setFont:[UIFont systemFontOfSize:17]];
    [m cc_setAttributes:@{TextKitTimeKey : @"",
                          NSForegroundColorAttributeName : [UIColor redColor],
                          NSFontAttributeName : [UIFont systemFontOfSize:17]
                          }
                  range:NSMakeRange(str.length-_date.length, _date.length)];
    return [m copy];
}

@end


@interface TextKitCustomTextViewLayoutCell : UITableViewCell

@property (nonatomic) NSTextStorage *textStorage;

@property (nonatomic) UILabel *label;
@property (nonatomic) UITextView *textView;

@end


@implementation TextKitCustomTextViewLayoutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        TextKitCustomLayoutManager *layoutManager = [[TextKitCustomLayoutManager alloc] init];
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:@""];
        
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
        textContainer.lineFragmentPadding = 0;
        textContainer.maximumNumberOfLines = 0;
        textContainer.widthTracksTextView = YES;
        textContainer.heightTracksTextView = YES;
        
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) textContainer:textContainer];
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.scrollEnabled = NO;
        self.textView.textContainerInset = UIEdgeInsetsZero;
        [self.contentView addSubview:self.textView];
        [self.textView.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.topAnchor constant:15].active = YES;
        [self.textView.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-15].active = YES;
        [self.textView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:0].active = YES;
        [self.textView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:0].active = YES;
        
        NSLayoutConstraint *centerY = [self.textView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant:0];
        centerY.priority = 999;
        centerY.active = YES;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        [self.label.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15].active = YES;
        [self.label.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-15].active = YES;
        [self.label.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:30].active = YES;
        [self.label.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-30].active = YES;
    }
    return self;
}

@end


@interface TextKitCustomTextViewLayoutViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSArray *array;

@end

@implementation TextKitCustomTextViewLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.array = @[ [TextKitModel textKitModelWithContent:@"good morning, boys and girls" date:@"1000000m"],
                    [TextKitModel textKitModelWithContent:@"good morning, good morning, boys and girls" date:@"1000000m"],
                    [TextKitModel textKitModelWithContent:@"good morning, good morning, good morning, boys and girls" date:@"1000000m"],
                    [TextKitModel textKitModelWithContent:@"good morning, good morning, good morning, good morning, boys and girls" date:@"Just now"],
                    [TextKitModel textKitModelWithContent:@"good morning, boys and girls" date:@"Just now again haha"],
                    ];
    
    UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    tb.translatesAutoresizingMaskIntoConstraints = NO;
    tb.delegate = self;
    tb.dataSource = self;
    tb.estimatedRowHeight = 44;
    tb.rowHeight = UITableViewAutomaticDimension;
    
    [tb registerClass:[TextKitCustomTextViewLayoutCell class] forCellReuseIdentifier:@"cell"];
    
    self.tableView = tb;
    
    [self.view addSubview:tb];
    
    [tb.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [tb.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [tb.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [tb.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [button setImage:[UIImage imageNamed:@"duet"] forState:UIControlStateNormal];
    [button setTitle:@"Start Duet" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor cc_opaqueColorWithHexString:@"#FF2D60"] forState:UIControlStateNormal];
    button.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    button.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    button.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
//    button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.view addSubview:button];
    [button.widthAnchor constraintEqualToConstant:200].active = YES;
    [button.heightAnchor constraintEqualToConstant:100].active = YES;
    [button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [button.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextKitCustomTextViewLayoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TextKitModel *m = [self.array objectAtIndex:indexPath.row];
    cell.textView.attributedText = m.attributedText;
    cell.label.attributedText = m.attributedText;
    
    NSLog(@"text storage : %@", cell.textView.textStorage.string);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
