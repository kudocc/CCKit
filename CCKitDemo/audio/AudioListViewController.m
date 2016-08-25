//
//  AudioListViewController.m
//  demo
//
//  Created by KudoCC on 16/8/16.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AudioListViewController.h"
#import "NSString+CCKit.h"
#import "AudioPlaybackViewController.h"
#import "AudioPlayAudioQueueFromFileViewController.h"

@interface AudioListViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger pageSize;
}

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *arrayFilePath;
@property (nonatomic) NSArray *arrayFileSize;

@end

@implementation AudioListViewController

- (void)initView {
    CGSize size = CGSizeMake(self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height-44-20);
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 64.0, size.width, size.height) style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    
    [self reloadData];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Remote audio files" style:UIBarButtonItemStylePlain target:self action:@selector(removeAudioFile)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)reloadData {
    NSString *path = [NSString cc_documentPath];
    NSArray *files = [self listFileAtPath:path];
    
    NSMutableArray *mFilePaths = [NSMutableArray array];
    NSMutableArray *mFileSizes = [NSMutableArray array];
    for (NSString *file in files) {
        NSString *filePath = [path stringByAppendingPathComponent:file];
        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
        [mFilePaths addObject:filePath];
        [mFileSizes addObject:@(fileSize)];
        
        [mFilePaths addObject:filePath];
        [mFileSizes addObject:@(fileSize)];
    }
    _arrayFilePath = [mFilePaths copy];
    _arrayFileSize = [mFileSizes copy];
    
    [_tableView reloadData];
}

- (void)removeAudioFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [NSString cc_documentPath];
        NSArray *list = [self listFileAtPath:path];
        for (NSString *file in list) {
            NSString *filePath = [path stringByAppendingPathComponent:file];
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

- (NSArray *)listFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row % 2 == 0) {
        AudioPlayAudioQueueFromFileViewController *vc = [[AudioPlayAudioQueueFromFileViewController alloc] init];
        vc.audioPath = _arrayFilePath[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AudioPlaybackViewController *vc = [[AudioPlaybackViewController alloc] init];
        vc.audioPath = _arrayFilePath[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
    if (indexPath.row % 2 == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"Play with audio queue,%@", _arrayFilePath[indexPath.row]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", _arrayFilePath[indexPath.row]];
    }
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", _arrayFileSize[indexPath.row]];
    return cell;
}

@end