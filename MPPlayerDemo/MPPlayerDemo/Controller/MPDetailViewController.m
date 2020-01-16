//
//  MPDetailViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2019/12/27.
//  Copyright © 2019 Maple. All rights reserved.
//

#import "MPDetailViewController.h"
#import "ZFDouYinCell.h"
#import "ZFDouYinControlView.h"
#import <ZFPlayer.h>
#import <ZFPlayerControlView.h>
#import "MPTransition.h"

static NSString *kIdentifier = @"kIdentifier";

@interface MPDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) ZFDouYinControlView *controlView;
@property (nonatomic, strong) NSIndexPath *playingIndexPath;
@property (nonatomic, strong) ZFPlayerControlView *preControlView;
@property (nonatomic) BOOL isInited;
@property (nonatomic) BOOL isPassPlayer;
@end

@implementation MPDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.backBtn];
    
    @weakify(self)
    if (!self.player) {
        self.player = [MPPlayerController playrWithContainerView:[UIView new]];
        [self requestData];
        self.player.playableArray = self.dataSource;
    }else {
        for(UIView *subView in self.player.currentPlayerManager.view.subviews) {
            [subView removeFromSuperview];
        }
        self.isPassPlayer = YES;
    }
    
    self.player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
        @strongify(self)
        if (size.width >= size.height) {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
        } else {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        }
    };
    [self.tableView reloadData];
    self.playingIndexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
    [self.tableView scrollToRowAtIndexPath:self.playingIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.backBtn.frame = CGRectMake(15, CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame), 36, 36);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)requestData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"list"];
    for (NSDictionary *dataDic in videoList) {
        ZFTableData *data = [[ZFTableData alloc] init];
        [data setValuesForKeysWithDictionary:dataDic];
        [self.dataSource addObject:data];
    }
    self.player.playableArray = self.dataSource;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isInited) {
        self.isInited = YES;
        if (self.isPassPlayer) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.playingIndexPath];
            UIView *playerView = [cell viewWithTag:10086];
            self.player.controlView = self.controlView;
            if (playerView) {
                [self.player updateNoramlPlayerWithContainerView:playerView];
                [self.controlView resetControlView];
                ZFTableData *data = self.dataSource[self.playingIndexPath.row];
                UIViewContentMode imageMode;
                if (data.thumbnail_width >= data.thumbnail_height) {
                    imageMode = UIViewContentModeScaleAspectFit;
                } else {
                    imageMode = UIViewContentModeScaleAspectFill;
                }
                [self.controlView showCoverViewWithUrl:data.thumbnail_url withImageMode:imageMode];
            }
        }else {
            self.player.controlView = self.controlView;
            [self playTheVideoAtIndexPath:self.playingIndexPath scrollToTop:NO];
        }
    }
    self.navigationController.delegate = self;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        if (self.isPassPlayer) {
            [self.controlView removeFromSuperview];
            for (UIView *subView in self.player.currentPlayerManager.view.subviews) {
                [subView removeFromSuperview];
            }
            self.player.controlView = self.preControlView;
            if (self.popbackBlock) {
                self.popbackBlock();
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate   列表播放必须实现
- (void)cellPlayVideo
{
    if (self.tableView.visibleCells.count && self.tableView.visibleCells.count == 1) {
        UITableViewCell *cell = self.tableView.visibleCells.firstObject;
        NSIndexPath *ip = [self.tableView indexPathForCell:cell];
        NSComparisonResult result = [ip compare:self.playingIndexPath];
        // 判断indexPath是否发生变化
        if (ip && result != NSOrderedSame) {
            [self.player stop];
            [self playTheVideoAtIndexPath:ip scrollToTop:NO];
        }
        if (ip) {
            self.playingIndexPath = ip;
        }
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self cellPlayVideo];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self handlePlayerOutofScreen: scrollView];
}

- (void)handlePlayerOutofScreen: (UIScrollView *)scrollView
{
    // 为了处理快速滑动时，player复用的bug
    UIView *cell = [self.tableView cellForRowAtIndexPath:self.playingIndexPath];
    if (!cell && self.playingIndexPath) {
        [self.player stop];
        return;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFDouYinCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    cell.data = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - private method

- (void)backClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.delegate = self;
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIView *contanier = [cell viewWithTag:10086];
    [self.player updateNoramlPlayerWithContainerView:contanier];
    [self.player playWithPlayable:self.dataSource[indexPath.row]];
    [self.controlView resetControlView];
    ZFTableData *data = self.dataSource[indexPath.row];
    UIViewContentMode imageMode;
    if (data.thumbnail_width >= data.thumbnail_height) {
        imageMode = UIViewContentModeScaleAspectFit;
    } else {
        imageMode = UIViewContentModeScaleAspectFill;
    }
    [self.controlView showCoverViewWithUrl:data.thumbnail_url withImageMode:imageMode];
    self.playingIndexPath = indexPath;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.pagingEnabled = YES;
        [_tableView registerClass:[ZFDouYinCell class] forCellReuseIdentifier:kIdentifier];
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollsToTop = NO;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.frame = self.view.bounds;
        _tableView.rowHeight = _tableView.frame.size.height;
        _tableView.scrollsToTop = NO;
    }
    return _tableView;
}

- (ZFDouYinControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFDouYinControlView new];
    }
    return _controlView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"icon_titlebar_whiteback"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (void)setPlayer:(MPPlayerController *)player
{
    _player = player;
    self.preControlView = (ZFPlayerControlView *)player.controlView;
    [self.preControlView removeFromSuperview];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (self.startView == nil)
        return nil;
    if (self.playingIndexPath &&
        self.playingIndexPath.row != self.index)
        return nil;
    return [MPTransition animationWithDuration:0.3 startView:self.startView startImage:self.startImage player:self.player operation:operation completion:^{
    }];
}


@end
