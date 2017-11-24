//
//  UISearchResultTestViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/9/26.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "UISearchResultTestViewController.h"
#import "CCSearchControllerTableViewCell.h"

@interface UISearchResultTestViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSMutableArray *resultItems;
@property (nonatomic) UITableView *tableView;

@end

@implementation UISearchResultTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.rowHeight = 55;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[CCSearchControllerTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11, *)) {
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeRight|UIRectEdgeBottom;
        [self.tableView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    }
    
    self.resultItems = [@[] mutableCopy];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self.resultItems removeAllObjects];
    NSString *text = searchController.searchBar.text;
    text = [text lowercaseString];
    for (NSString *item in self.items) {
        if ([item containsString:text]) {
            [self.resultItems addObject:item];
        }
    }
    NSLog(@"%@, %@", text, self.resultItems);
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.resultItems[indexPath.row];
    return cell;
}

@end
