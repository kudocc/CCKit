//
//  TestMissalignedViewController.m
//  performance
//
//  Created by KudoCC on 16/1/19.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "TestMissalignedViewController.h"

@interface MissalignedPerformanceCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView1;
@property (nonatomic, strong) UIImageView *imgView2;
@property (nonatomic, strong) UIImageView *imgView3;

@end

@implementation MissalignedPerformanceCell

- (UIImageView *)createImageView {
#if Good
    UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
#else
    UIImageView *v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_ori"]];
#endif
    return v;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView1 = [self createImageView];
        [self.contentView addSubview:_imgView1];
        
        _imgView2 = [self createImageView];
        [self.contentView addSubview:_imgView2];
        
        _imgView3 = [self createImageView];
        [self.contentView addSubview:_imgView3];
    }
    return self;
}

- (void)layoutSubviews {
    CGSize s = self.bounds.size;
    _imgView1.frame = CGRectMake(0.0, 0.0, s.height, s.height);
    _imgView2.frame = CGRectMake(s.height + 10.0, 0.0, s.height, s.height);
    _imgView3.frame = CGRectMake(s.height + 10.0 + s.height + 10.0, 0.0, s.height, s.height);
}

@end

@interface TestMissalignedViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation TestMissalignedViewController

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
        cell = [[MissalignedPerformanceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
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
