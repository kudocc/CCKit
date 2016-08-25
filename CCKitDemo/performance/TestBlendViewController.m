//
//  TestBlendViewController.m
//  performance
//
//  Created by KudoCC on 16/1/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "TestBlendViewController.h"

@interface BlendPerformanceCell : UITableViewCell

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;
@property (nonatomic, strong) UILabel *label4;
@property (nonatomic, strong) UILabel *label5;

@end

@implementation BlendPerformanceCell

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
#if Good
    label.backgroundColor = [UIColor whiteColor];
    label.opaque = YES;
#else
    label.backgroundColor = [UIColor clearColor];
#endif
    return label;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        _label1 = [self createLabel];
        [self.contentView addSubview:_label1];
        _label1.text = @"Good performance";
        
        _label2 = [self createLabel];
        [self.contentView addSubview:_label2];
        _label2.text = @"needs hard work";
        
        _label3 = [self createLabel];
        [self.contentView addSubview:_label3];
        _label3.text = @"go forward, well";
        
        _label4 = [self createLabel];
        [self.contentView addSubview:_label4];
        _label4.text = @"go forward, well";
        
        _label5 = [self createLabel];
        [self.contentView addSubview:_label5];
        _label5.text = @"go forward, well";
    }
    return self;
}

- (void)layoutSubviews {
    CGSize s = self.bounds.size;
    _label1.frame = CGRectMake(0.0, 0.0, 60, s.height);
    
    CGFloat x = _label1.frame.origin.x + s.height + 10.0;
    _label2.frame = CGRectMake(x, 0.0, 60, s.height);
    
    x = _label2.frame.origin.x + s.height + 10.0;
    _label3.frame = CGRectMake(x, 0.0, 60, s.height);
    
    x = _label3.frame.origin.x + s.height + 10.0;
    _label4.frame = CGRectMake(x, 0.0, 60, s.height);
    
    x = _label4.frame.origin.x + s.height + 10.0;
    _label5.frame = CGRectMake(x, 0.0, 60, s.height);
}

@end

@interface TestBlendViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TestBlendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor brownColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[BlendPerformanceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return cell;
}
@end
