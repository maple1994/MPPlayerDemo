//
//  XSTPlayerController.m
//  XStarSDK
//
//  Created by Beauty-ruanjian on 2019/7/4.
//

#import "MPPlayerController.h"
#import "XSTPlayerAttributeManager.h"
#import <KTVHTTPCache.h>
#import "XSTPreLoaderModel.h"
#import <ZFUtilities.h>

@interface MPPlayerController()<KTVHCDataLoaderDelegate>

@property (nonatomic, strong) ZFPlayerController *player;
/// 预加载的模型数组
@property (nonatomic, strong) NSMutableArray<XSTPreLoaderModel *> *preloadArr;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

@implementation MPPlayerController

// MARK: - Init
+ (instancetype)playrWithContainerView:(UIView *)containerView
{
    return [[self alloc] initWithContainerView: containerView];
}

- (instancetype)initWithContainerView:(UIView *)containerView
{
    if (self = [super init])
    {
        XSTPlayerAttributeManager *mgr = [[XSTPlayerAttributeManager alloc] init];
        _player = [[ZFPlayerController alloc] initWithPlayerManager:mgr containerView:containerView];
        _player.playerDisapperaPercent = 1.0;
        [_player setCustomAudioSession:YES];
        [self setup];
    }
    return self;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView containerViewTag:(NSInteger)containerViewTag
{
    return [[self alloc] initWithScrollView:scrollView containerViewTag:containerViewTag];
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView containerViewTag:(NSInteger)containerViewTag
{
    if (self = [super init])
    {
        XSTPlayerAttributeManager *mgr = [[XSTPlayerAttributeManager alloc] init];
        _player = [[ZFPlayerController alloc] initWithScrollView:scrollView playerManager:mgr containerViewTag:containerViewTag];
        _player.disableGestureTypes = ZFPlayerDisableGestureTypesPan;
        _player.playerDisapperaPercent = 1.0;
        [_player setCustomAudioSession:YES];
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self setup];
    }
    return self;
}

/// 初始化
- (void)setup
{
    _preLoadNum = 2;
    _nextLoadNum = 2;
    _preloadPrecent = 0.1;
    _initPreloadNum = 3;
    _player.allowOrentitaionRotation = NO;
    _player.playerDisapperaPercent = 0.5;
    _player.playerApperaPercent = 0.5;
    @weakify(self)
    _player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        @strongify(self)
        [self.player.currentPlayerManager replay];
    };
}

// MARK: - Method
- (void)stop
{
    self.player.scrollView.zf_playingIndexPath = nil;
    [self.player stop];
}

- (void)stopCurrentPlayingCell
{
    [self.player stopCurrentPlayingCell];
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath playable: (id<XSTPlayable>)playable
{
    // 播放前，先停止所有的预加载任务
    [self cancelAllPreload];
    _currentPlayable = playable;
    [self.player playTheIndexPath:indexPath assetURL:[NSURL URLWithString:playable.video_url] scrollToTop:NO];
    __weak typeof(self) weakSelf = self;
    self.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        [weakSelf preload: playable];
    };
}

- (void)playWithPlayable: (id<XSTPlayable>)playable
{
    _currentPlayable = playable;
    self.player.assetURL = [NSURL URLWithString:playable.video_url];
}

- (void)setDisapperaPercent: (CGFloat)disappearPercent appearPercent: (CGFloat)appearPercent
{
    self.player.playerDisapperaPercent = disappearPercent;
    self.player.playerApperaPercent = appearPercent;
}

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated
{
    CGFloat cellHeight = iPhoneX ? ZFPlayer_ScreenHeight - 83 : ZFPlayer_ScreenHeight;
    if (self.isAnimating) {
        return;
    }
    if (self.orientation == orientation) {
        return;
    }
    if (self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying ||self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused
        ) {
        self.isAnimating = YES;
    }
    self.orientation = orientation;
    CGFloat rotation = 0;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        rotation = M_PI_2;
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        rotation = M_PI_2 * 3;
    }
    UIView *presentView = self.player.currentPlayerManager.view;
    CGRect landRect = CGRectMake(0, 0, cellHeight, ZFPlayer_ScreenWidth);
    [UIView animateWithDuration:0.35 animations:^{
        presentView.layer.affineTransform = CGAffineTransformMakeRotation(rotation);
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
    presentView.layer.bounds = landRect;
}

- (void)exitFullScreen: (BOOL)isAnimated
{
    CGFloat cellHeight = iPhoneX ? ZFPlayer_ScreenHeight - 49 : ZFPlayer_ScreenHeight;
    if (self.isAnimating) {
        return;
    }
    if (self.orientation == UIInterfaceOrientationPortrait) {
        return;
    }
    CGRect frame = CGRectMake(0, 0, ZFPlayer_ScreenWidth, cellHeight);
    UIView *presentView = self.player.currentPlayerManager.view;
    if (!isAnimated) {
        presentView.layer.affineTransform = CGAffineTransformIdentity;
        self.orientation = UIInterfaceOrientationPortrait;
    }else {
        self.isAnimating = YES;
        self.orientation = UIInterfaceOrientationPortrait;
        [UIView animateWithDuration:0.35 animations:^{
            presentView.layer.affineTransform = CGAffineTransformIdentity;
        }completion:^(BOOL finish){
            self.isAnimating = NO;
        }];
    }
    self.player.currentPlayerManager.view.layer.bounds = frame;
}

/// Add Player到Cell上
- (void)updateScrollViewPlayerToCell
{
    if (self.player.currentPlayerManager.view &&
        self.player.scrollView.zf_playingIndexPath &&
        self.player.containerViewTag) {
        UIView *cell = [self.player.scrollView zf_getCellForIndexPath:self.player.scrollView.zf_playingIndexPath];
        UIView *containerView = [cell viewWithTag:self.player.containerViewTag];
        [self updateNoramlPlayerWithContainerView:containerView];
    }
}

/// 更新Playerc的容器
- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView
{
    [self.player addPlayerViewToContainerView:containerView];
}

// MARK: - Preload
/// 根据传入的模型，预加载上几个，下几个的视频
- (void)preload: (id<XSTPlayable>)resource
{
    if (self.playableArray.count <= 1)
        return;
    if (_nextLoadNum == 0 && _preLoadNum == 0)
        return;
    NSInteger start = [self.playableArray indexOfObject:resource];
    if (start == NSNotFound)
        return;
    [self cancelAllPreload];
    NSInteger index = 0;
    for (NSInteger i = start + 1; i < self.playableArray.count && index < _nextLoadNum; i++)
    {
        index += 1;
        id<XSTPlayable> model = self.playableArray[i];
        XSTPreLoaderModel *preModel = [self getPreloadModel: model.video_url];
        if (preModel) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject: preModel];
            }
        }
    }
    index = 0;
    for (NSInteger i = start - 1; i >= 0 && index < _preLoadNum; i--)
    {
        index += 1;
        id<XSTPlayable> model = self.playableArray[i];
        XSTPreLoaderModel *preModel = [self getPreloadModel: model.video_url];
        if (preModel) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject:preModel];
            }
        }
    }
    [self processLoader];
}

/// 取消所有的预加载
- (void)cancelAllPreload
{
    @synchronized (self.preloadArr) {
        if (self.preloadArr.count == 0)
        {
            return;
        }
        [self.preloadArr enumerateObjectsUsingBlock:^(XSTPreLoaderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.loader close];
        }];
        [self.preloadArr removeAllObjects];
    }
}

- (XSTPreLoaderModel *)getPreloadModel: (NSString *)urlStr
{
    if (!urlStr)
        return nil;
    // 判断是否已在队列中
    __block Boolean res = NO;
    @synchronized (self.preloadArr) {
        [self.preloadArr enumerateObjectsUsingBlock:^(XSTPreLoaderModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.url isEqualToString:urlStr])
            {
                res = YES;
                *stop = YES;
            }
        }];
    }
    if (res)
        return nil;
    NSURL *proxyUrl = [KTVHTTPCache proxyURLWithOriginalURL: [NSURL URLWithString:urlStr]];
    KTVHCDataCacheItem *item = [KTVHTTPCache cacheCacheItemWithURL:proxyUrl];
    double cachePrecent = 1.0 * item.cacheLength / item.totalLength;
    // 判断缓存已经超过10%了
    if (cachePrecent >= self.preloadPrecent)
        return nil;
    KTVHCDataRequest *req = [[KTVHCDataRequest alloc] initWithURL:proxyUrl headers:[NSDictionary dictionary]];
    KTVHCDataLoader *loader = [KTVHTTPCache cacheLoaderWithRequest:req];
    XSTPreLoaderModel *preModel = [[XSTPreLoaderModel alloc] initWithURL:urlStr loader:loader];
    return preModel;
}

- (void)processLoader
{
    @synchronized (self.preloadArr) {
        if (self.preloadArr.count == 0)
            return;
        XSTPreLoaderModel *model = self.preloadArr.firstObject;
        model.loader.delegate = self;
        [model.loader prepare];
    }
}

/// 根据loader，移除预加载任务
- (void)removePreloadTask: (KTVHCDataLoader *)loader
{
    @synchronized (self.preloadArr) {
        XSTPreLoaderModel *target = nil;
        for (XSTPreLoaderModel *model in self.preloadArr) {
            if ([model.loader isEqual:loader])
            {
                target = model;
                break;
            }
        }
        if (target)
            [self.preloadArr removeObject:target];
    }
}

// MARK: - KTVHCDataLoaderDelegate
- (void)ktv_loaderDidFinish:(KTVHCDataLoader *)loader
{
}
- (void)ktv_loader:(KTVHCDataLoader *)loader didFailWithError:(NSError *)error
{
    // 若预加载失败的话，就直接移除任务，开始下一个预加载任务
    [self removePreloadTask:loader];
    [self processLoader];
}
- (void)ktv_loader:(KTVHCDataLoader *)loader didChangeProgress:(double)progress
{
    if (progress >= self.preloadPrecent)
    {
        [loader close];
        [self removePreloadTask:loader];
        [self processLoader];
    }
}

// MARK: - Getter
- (BOOL)isViewControllerDisappear
{
    return self.player.isViewControllerDisappear;
}

- (NSIndexPath *)playingIndexPath
{
    return self.player.playingIndexPath;
}

- (NSMutableArray<XSTPreLoaderModel *> *)preloadArr
{
    if (_preloadArr == nil)
    {
        _preloadArr = [NSMutableArray array];
    }
    return _preloadArr;
}

- (id<ZFPlayerMediaPlayback>)currentPlayerManager
{
    return self.player.currentPlayerManager;
}

- (BOOL)isPlaying
{
    return self.player.currentPlayerManager.isPlaying;
}

- (UIView *)containerView
{
    return self.player.containerView;
}

- (BOOL)isWWANAutoPlay
{
    return self.player.isWWANAutoPlay;
}

- (void (^)(id<ZFPlayerMediaPlayback> _Nonnull, NSTimeInterval, NSTimeInterval))playerPlayTimeChanged
{
    return _player.playerPlayTimeChanged;
}


// MARK: - Setter
- (void)setPlayableArray:(NSArray<id<XSTPlayable>> *)playableArray
{
    _playableArray = playableArray;
    [self cancelAllPreload];
    // 默认预加载前几条数据
    NSRange range = NSMakeRange(0, _initPreloadNum);
    if (range.length > playableArray.count) {
        range.length = playableArray.count;
    }
    NSArray *subArr = [playableArray subarrayWithRange: range];
    for (id<XSTPlayable> model in subArr)
    {
        XSTPreLoaderModel *preload = [self getPreloadModel:model.video_url];
        if (preload) {
            @synchronized (self.preloadArr) {
                [self.preloadArr addObject: preload];
            }
        }
    }
    [self processLoader];
}

- (void)setWWANAutoPlay:(BOOL)WWANAutoPlay
{
    self.player.WWANAutoPlay = WWANAutoPlay;
}

- (void)setControlView:(UIView<ZFPlayerMediaControl> *)controlView
{
    _controlView = controlView;
    self.player.controlView = controlView;
}

- (void)setViewControllerDisappear:(BOOL)viewControllerDisappear
{
    self.player.viewControllerDisappear = viewControllerDisappear;
}

- (void)setPlayingIndexPath:(NSIndexPath * _Nullable)playingIndexPath
{
    self.playingIndexPath = playingIndexPath;
}

- (void)setPlayerDidToEnd:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull))playerDidToEnd {
    _player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        playerDidToEnd(asset);
    };
}

- (void)setPlayerPlayFailed:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, id _Nonnull))playerPlayFailed {
    _player.playerPlayFailed = playerPlayFailed;
}

- (void)setPlayerReadyToPlay:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerReadyToPlay {
    _player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        playerReadyToPlay(asset, assetURL);
    };
}

- (void)setPlayerPlayTimeChanged:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, NSTimeInterval, NSTimeInterval))playerPlayTimeChanged {
    _player.playerPlayTimeChanged = playerPlayTimeChanged;
}

- (void)setPlayerBufferTimeChanged:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, NSTimeInterval))playerBufferTimeChanged {
    _player.playerBufferTimeChanged = playerBufferTimeChanged;
}

- (void)setPresentationSizeChanged:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, CGSize))presentationSizeChanged {
    _player.presentationSizeChanged = presentationSizeChanged;
}

- (void)setPlayerPlayStateChanged:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, ZFPlayerPlaybackState))playerPlayStateChanged
{
    _player.playerPlayStateChanged = playerPlayStateChanged;
}

- (void)setPlayerLoadStateChanged:(void (^)(id<ZFPlayerMediaPlayback> _Nonnull, ZFPlayerLoadState))playerLoadStateChanged
{
    _player.playerLoadStateChanged = playerLoadStateChanged;
}

- (void)setZf_playerDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))zf_playerDisappearingInScrollView
{
    _player.zf_playerDisappearingInScrollView = zf_playerDisappearingInScrollView;
}

@end
