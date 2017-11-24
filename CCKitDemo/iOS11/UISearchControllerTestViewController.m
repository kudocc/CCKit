//
//  UISearchControllerTestViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/9/26.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "UISearchControllerTestViewController.h"
#import "CCSearchControllerTableViewCell.h"
#import "UISearchResultTestViewController.h"

#import "UIImage+CCKit.h"

@interface UISearchControllerTestViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UISearchController *searchController;

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSMutableArray *resultItems;
@property (nonatomic) UITableView *tableView;

@end

@implementation UISearchControllerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIImage *image = [UIImage cc_imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] size:CGSizeMake(1, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    self.resultItems = [@[] mutableCopy];
    self.items = [@[@"visual c++", @"tuber c++", @"code block", @"xcode", @"visual studio", @"hello", @"world", @"c", @"c++", @"java", @"visual basic", @"python", @"perl", @"javascript", @"c#"] mutableCopy];
    
    if (@available(iOS 11, *)) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.rowHeight = 55;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[CCSearchControllerTableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:self.tableView];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        
        UISearchResultTestViewController *searchResultController = [[UISearchResultTestViewController alloc] init];
        searchResultController.items = self.items;
        
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultController];
        self.searchController.searchResultsUpdater = searchResultController;
        self.searchController.obscuresBackgroundDuringPresentation = YES;
        self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
        self.navigationItem.searchController = self.searchController;
        self.definesPresentationContext = YES;
    } else {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.rowHeight = 55;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[CCSearchControllerTableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:self.tableView];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        
        UISearchResultTestViewController *searchResultController = [[UISearchResultTestViewController alloc] init];
        searchResultController.items = self.items;
        
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultController];
        self.searchController.searchResultsUpdater = searchResultController;
        self.searchController.obscuresBackgroundDuringPresentation = YES;
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.definesPresentationContext = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

@end
