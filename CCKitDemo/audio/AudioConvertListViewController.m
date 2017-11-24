//
//  AudioConvertListViewController.m
//  CCKitDemo
//
//  Created by kudocc on 2017/8/8.
//  Copyright © 2017年 KudoCC. All rights reserved.
//

#import "AudioConvertListViewController.h"
#import "AudioConvertViewController.h"
#import "NSString+CCKit.h"
#import "AudioFileManager.h"
#import <AVFoundation/AVFoundation.h>


@interface AudioConvertListViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger pageSize;
}

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *arrayFilePath;
@property (nonatomic) NSArray *arrayFileSize;

@end

@implementation AudioConvertListViewController

- (void)initView {
    CGSize size = CGSizeMake(self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height-44-20);
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, size.width, size.height) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    
    [self reloadData];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove audio files" style:UIBarButtonItemStylePlain target:self action:@selector(removeAudioFile)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)reloadData {
    NSArray *files = [AudioFileManager audioFilePathInAudioDirectory];
    
    NSMutableArray *mFilePaths = [NSMutableArray array];
    NSMutableArray *mFileSizes = [NSMutableArray array];
    for (NSString *filePath in files) {
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
        [mFilePaths addObject:filePath];
        [mFileSizes addObject:@(fileSize)];
    }
    _arrayFilePath = [mFilePaths copy];
    _arrayFileSize = [mFileSizes copy];
    
    [_tableView reloadData];
}

- (void)removeAudioFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *files = [AudioFileManager audioFilePathInAudioDirectory];
        for (NSString *filePath in files) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"remote file error:%@", [error localizedDescription]);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AudioConvertViewController *vc = [[AudioConvertViewController alloc] init];
    vc.audioPath = _arrayFilePath[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrayFilePath count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", _arrayFilePath[indexPath.row]];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _arrayFileSize[indexPath.row]];
    return cell;
}

@end
