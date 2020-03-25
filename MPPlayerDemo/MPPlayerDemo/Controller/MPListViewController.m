//
//  MPListViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2019/12/27.
//  Copyright © 2019 Maple. All rights reserved.
//

#import "MPListViewController.h"
#import "ZFTableViewCell.h"
#import "ZFTableData.h"
#import "MPPlayerController.h"
#import <ZFPlayerControlView.h>
#import "MPDetailViewController.h"
#import "ZFUtilities.h"

static NSString *kIdentifier = @"kIdentifier";

@interface MPListViewController ()<UITableViewDelegate, UITableViewDataSource, ZFTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MPPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) NSMutableArray *playableArray;
@property (nonatomic) BOOL isInited;

@end

@implementation MPListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    CGFloat y = iPhoneX ? 88 : 64;
    self.tableView.frame = CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height - y);
    [self.tableView registerClass:[ZFTableViewCell class] forCellReuseIdentifier:kIdentifier];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:self.tableView];
    
    self.player = [MPPlayerController playerWithScrollView:self.tableView containerViewTag:100];
    self.controlView = [[ZFPlayerControlView alloc] init];
    self.player.controlView = self.controlView;
    [self setupPlayerDisappearBlock];
    
    /// 停止的时候找出最合适的播放(只能找到设置了tag值cell)
    @weakify(self)
    _tableView.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (!self.player.playingIndexPath) {
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }
    };
    
    [self requestData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.isInited) {
        self.isInited = YES;
        @weakify(self)
        [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
            @strongify(self)
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }];
    }
    
}

- (void)setupPlayerDisappearBlock
{
    @weakify(self)
    self.player.zf_playerDisappearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerDisapperaPercent) {
        @strongify(self)
        // 超出需要播放的百分比时，马上记录播放时间，方便下次seek
        if (playerDisapperaPercent >= self.player.playerDisapperaPercent) {
            ZFTableData *data = self.playableArray[indexPath.row];
            data.current_time = self.player.currentPlayerManager.currentTime;
        }
    };
}

- (void)requestData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    self.playableArray = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"list"];
    for (NSDictionary *dataDic in videoList) {
        ZFTableData *data = [[ZFTableData alloc] init];
        [data setValuesForKeysWithDictionary:dataDic];
        ZFTableViewCellLayout *layout = [[ZFTableViewCellLayout alloc] initWithData:data];
        [self.playableArray addObject:data];
        [self.dataSource addObject:layout];
    }
    self.player.playableArray = self.playableArray;
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    NSInteger index = indexPath.row;
    ZFTableViewCellLayout *layout = self.dataSource[index];
    [self.player playTheIndexPath:indexPath playable:self.playableArray[index]];
    // seek播放记录
    self.player.currentPlayerManager.seekTime = layout.data.current_time;
    [self.controlView showTitle:layout.data.title
                 coverURLString:layout.data.thumbnail_url
                 fullScreenMode:layout.isVerticalVideo?ZFFullScreenModePortrait:ZFFullScreenModeLandscape];
}

#pragma mark - UIScrollViewDelegate   列表播放必须实现
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    [cell setDelegate:self withIndexPath:indexPath];
    cell.layout = self.dataSource[indexPath.row];
    [cell setNormalMode];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFTableViewCellLayout *layout = self.dataSource[indexPath.row];
    return layout.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFTableViewCell *cell = (ZFTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:cell];
    // 点击的不是正在播放的cell，就先播放再跳转
    if ([currentIndexPath compare:self.tableView.zf_playingIndexPath] != NSOrderedSame) {
        [self.player stopCurrentPlayingCell];
        self.tableView.zf_playingIndexPath = currentIndexPath;
        [self playTheVideoAtIndexPath:currentIndexPath scrollToTop:NO];
        [self.player.currentPlayerManager.view layoutIfNeeded];
    }
    self.tableView.zf_playingIndexPath = currentIndexPath;
    
    MPDetailViewController *vc = [[MPDetailViewController alloc] init];
    vc.player = self.player;
    vc.index = indexPath.row;
    vc.startImage = cell.coverImageView.image;
    vc.startView = cell.coverImageView;
    vc.dataSource = [self.playableArray mutableCopy];
    @weakify(self)
    vc.popbackBlock = ^{
        @strongify(self)
        [self.player updateScrollViewPlayerToCell];
        [self.player.currentPlayerManager play];
    };
    self.navigationController.delegate = vc;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}



@end
