//
//  DrawImagePerformanceViewController.m
//  demo
//
//  Created by KudoCC on 16/6/22.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "DrawImagePerformanceViewController.h"

@implementation DrawView

- (void)setImage:(UIImage *)image {
    if (_image == image) {
        return;
    }
    _image = image;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!_image) {
        return;
    }
    [_image drawInRect:self.bounds];
}

@end

@implementation DrawImagePerformanceCell

+ (CGFloat)cellHeight {
    return 88.0;
}

+ (CGFloat)imageHeight {
    return 66.0;
}

- (DrawView *)createImageView {
    DrawView *v = [[DrawView alloc] initWithFrame:CGRectMake(0.0, 0.0, [self.class imageHeight], [self.class imageHeight])];
    v.backgroundColor = [UIColor clearColor];
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
    _imgView1.frame = CGRectMake(0.0, 10.0, _imgView1.bounds.size.height, _imgView1.bounds.size.height);
    _imgView2.frame = CGRectMake(s.height + 10.0, 10.0, _imgView2.bounds.size.height, _imgView2.bounds.size.height);
    _imgView3.frame = CGRectMake(s.height + 10.0 + s.height + 10.0, 10.0, _imgView3.bounds.size.height, _imgView3.bounds.size.height);
}

@end


@interface DrawImagePerformanceViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation DrawImagePerformanceViewController

- (void)initView {
    [super initView];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenHeight, ScreenHeight-64)];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.estimatedRowHeight = 20.0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DrawImagePerformanceCell cellHeight];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 400;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DrawImagePerformanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[DrawImagePerformanceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
        cell.opaque = YES;
        cell.separatorInset = UIEdgeInsetsZero;
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    NSInteger index = indexPath.row % _images.count;
    UIImage *img = _images[index];
    cell.imgView1.image = img;
    cell.imgView2.image = img;
    cell.imgView3.image = img;
    if (_cornerRadius > 0) {
        cell.imgView1.layer.cornerRadius = _cornerRadius;
        cell.imgView1.layer.masksToBounds = YES;
        cell.imgView2.layer.cornerRadius = _cornerRadius;
        cell.imgView2.layer.masksToBounds = YES;
        cell.imgView3.layer.cornerRadius = _cornerRadius;
        cell.imgView3.layer.masksToBounds = YES;
    }
    return cell;
}

@end