//
//  HomeTableViewController.m
//  demo
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "HomeTableViewController.h"

@interface HomeTableViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation HomeTableViewController

- (void)initView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    if (@available(iOS 11, *)) {
    } else {
        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.bounds.size.height;
        tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    }
    [self.view addSubview:tableView];
    tableView.tableFooterView = [UIView new];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.opaque = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_cellSelectedBlock) {
        _cellSelectedBlock(indexPath);
    } else {
        Class class = _arrayClass[indexPath.row];
        NSString *className = NSStringFromClass(class);
        UIViewController *vc = nil;
        
        NSString *prefix = nil;
        if ([className containsString:@"_"]) {
            prefix = [[className componentsSeparatedByString:@"_"] firstObject];
        }
        if (prefix.length > 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:prefix bundle:nil];
            if (storyboard) {
                vc = [storyboard instantiateViewControllerWithIdentifier:className];
            }
        }
        
        if (!vc) {
            vc = (UIViewController *)[[class alloc] init];
        }
        vc.title = _arrayTitle[indexPath.row];
        id property = _arraySetProperty[indexPath.row];
        if (property != [NSNull null]) {
            NSDictionary<NSString *, id> *dictProperty = property;
            [dictProperty enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [vc setValue:obj forKey:key];
            }];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrayTitle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    }
    cell.textLabel.text = _arrayTitle[indexPath.row];
    return cell;
}

@end
