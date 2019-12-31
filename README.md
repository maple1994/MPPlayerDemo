# MPPlayerDemo
ZFPlayer进行播放，KTVHTTPCache负责预加载的一个播放器Demo

#Demo演示的功能
* ZFPlayer的列表播放
* 使用KTVHTTPCache实现缓存（播放过的视频无需再下载）
* 使用KTVHTTPCache实现预加载（可以实现秒播）
* 自定义转场动画（实现无缝衔接的播放效果）

gif演示：
![playerDemo.gif](playerDemo.gif)


# 一、缓存+预加载功能
## 1、播放器mgr核心代码
mgr实现ZFPlayerMediaPlayback协议，然后在初始化时，开启本地服务器
```
+ (void)initialize
{
    [KTVHTTPCache logSetConsoleLogEnable:NO];
    NSError *error = nil;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        NSLog(@"Proxy Start Failure, %@", error);
    }
    [KTVHTTPCache encodeSetURLConverter:^NSURL *(NSURL *URL) {
//        NSLog(@"URL Filter reviced URL : %@", URL);
        return URL;
    }];
    [KTVHTTPCache downloadSetUnacceptableContentTypeDisposer:^BOOL(NSURL *URL, NSString *contentType) {
        return NO;
    }];
    // 设置缓存最大容量
    [KTVHTTPCache cacheSetMaxCacheLength:1024 * 1024 * 1024];
}
```
设置assetURL时，设置KTVHTTpCache为中间服务器，若该资源已缓存完毕，就无需代理，这个判断可以使已缓存的视频播放的更快
```
- (void)setAssetURL:(NSURL *)assetURL {
    if (self.player) [self stop];
    // 如果有缓存，直接取本地缓存
    NSURL *url = [KTVHTTPCache cacheCompleteFileURLWithURL:assetURL];
    if (url) {
        _assetURL = url;
    }else {
        // 设置代理
        _assetURL = [KTVHTTPCache proxyURLWithOriginalURL:assetURL];
    }
    [self prepareToPlay];
}
```

##2、播放器Player核心代码
创建playableProtocol，方便数据管理
```
/// 只有实现该协议的模型才能预加载
@protocol XSTPlayable <NSObject>
/// string 视频链接
@property (nonatomic, copy) NSString *video_url;
@end
```

核心播放器为ZFPlayerController，为了方便管理，我们创建一个中间类包裹ZFPlayerController，且增加可以设置的预加载属性
```
@interface MPPlayerController : NSObject

// 预加载上几条
@property (nonatomic, assign) NSUInteger preLoadNum;
/// 预加载下几条
@property (nonatomic, assign) NSUInteger nextLoadNum;
/// 预加载的的百分比，默认10%
@property (nonatomic, assign) double preloadPrecent;
/// 设置playableAssets后，马上预加载的条数
@property (nonatomic, assign) NSUInteger initPreloadNum;
/// set之后，先预加载几个
@property (nonatomic, copy) NSArray<id<XSTPlayable>> *playableArray;
....
```

##3、预加载核心代码
预加载的时机是当前视频可以播放了，才进行预加载
```
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
```
预加载的规则是预加载当前视频的上2个，和下2个视频，逐个开启预加载，视频预加载（`核心类KTVHCDataLoader`）到10%就停止，然后开始下一个视频的预加载。这里要注意异步线程的操作，要加锁处理
```
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
```

# 二、无缝衔接转场动画
这里我直接拿ZFPlayerDemo中的一个列表播放，一个抖音列表播放的例子进行演示，不熟悉转场动画的，建议自行先看看唐巧的https://blog.devtang.com/2016/03/13/iOS-transition-guide/了解，这里不多说，直接上核心代码。

1、首先必须实现代理`UINavigationControllerDelegate`
```
@interface MPDetailViewController : UIViewController<UINavigationControllerDelegate>
```

2、传递player，startView，startImage等，并实现popback回调
```
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
```

3、实现`UIViewControllerAnimatedTransitioning`协议
```
/// 用于视频信息流的转场动画
@interface MPTransition : NSObject<UIViewControllerAnimatedTransitioning>

/**
 初始化动画
 
 @param duration 动画时长
 @param startView 开始视图
 @param startImage 开始图片
 @param  player 播放器
 @param operation 动画形式
 @param completion 动画完成block
 @return 动画实例
 */
+ (instancetype)animationWithDuration:(NSTimeInterval)duration
                            startView:(UIView *)startView
                           startImage:(UIImage *)startImage
                               player: (MPPlayerController *)player
                            operation:(UINavigationControllerOperation)operation
                           completion:(void(^)(void))completion;

@end
```
4、分别实现push，pop的转场动画
```
@interface MPTransition()

@property (nonatomic, strong) UIView *startView;
@property (nonatomic, strong) UIImage *startImage;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) MPPlayerController *player;
@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, assign) void(^completion)(void);
@property (nonatomic, strong) UIView *effectView;

@end

@implementation MPTransition

+ (instancetype)animationWithDuration:(NSTimeInterval)duration
                              startView:(UIView *)startView
                             startImage:(UIImage *)startImage
                                 player: (MPPlayerController *)player
                              operation:(UINavigationControllerOperation)operation
                             completion:(void(^)(void))completion
{
    MPTransition *animation = [MPTransition new];
    animation.player = player;
    animation.duration = duration;
    animation.startView = startView;
    animation.startImage = startImage;
    animation.operation = operation;
    animation.completion = completion;
    
    return animation;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.operation == UINavigationControllerOperationPush) {
        [self startPushAnimation: transitionContext];
    }else {
        [self startPopAnimation: transitionContext];
    }
}

- (void)startPushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // 获取 fromView 和 toView
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    // 添加到动画容器视图中
    [[transitionContext containerView] addSubview:fromView];
    [[transitionContext containerView] addSubview:toView];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:fromView.bounds];
    bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    bgImgView.image = self.startImage;
    UIView *colorCover = [[UIView alloc] init];
    colorCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    colorCover.frame = fromView.bounds;
    [bgImgView addSubview:colorCover];
    [bgImgView addSubview:self.effectView];
    [[transitionContext containerView] addSubview:bgImgView];
    
    // 创建player容器
    CGRect winFrame = CGRectZero;
    if (self.startView) {
        winFrame = [self.startView convertRect:self.startView.bounds toView:nil];
    }
    
    UIImageView *playerContainer = [[UIImageView alloc] initWithFrame:winFrame];
    playerContainer.image = self.startImage;
    playerContainer.contentMode = UIViewContentModeScaleAspectFit;
    [[transitionContext containerView]  addSubview:playerContainer];
    if (self.player) {
        self.player.currentPlayerManager.scalingMode = self.player.videoFlowScalingMode;
        self.player.currentPlayerManager.view.backgroundColor = [UIColor clearColor];
        [self.player updateNoramlPlayerWithContainerView:playerContainer];
    }
    CGFloat bottomOffset = iPhoneX ? 83 : 0;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGRect targetFrame = CGRectMake(0, 0, ZFPlayer_ScreenWidth, ZFPlayer_ScreenHeight - bottomOffset);
    
    toView.alpha = 0.0f;
    bgImgView.alpha = 0;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // mask 渐变效果
        bgImgView.alpha = 1;
        playerContainer.frame = targetFrame;
    } completion:^(BOOL finished) {
        toView.alpha = 1.0f;
        // 移除临时视图
        [bgImgView removeFromSuperview];
        [playerContainer removeFromSuperview];
        // 结束动画
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if (self.completion) {
            self.completion();
        }
    }];
}

- (void)startPopAnimation: (id<UIViewControllerContextTransitioning>)transitionContext
{
    // 获取 fromView 和 toView
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    self.player.currentPlayerManager.view.backgroundColor = [UIColor blackColor];
    
    // 添加到动画容器视图中
    UIView *container = [transitionContext containerView];
    [container addSubview:toView];
    [container addSubview:fromView];
    container.backgroundColor = [UIColor clearColor];
    
    // 添加动画临时视图到 fromView
    CGFloat bottomOffset = iPhoneX ? 83 : 0;
    CGRect normalFrame = CGRectMake(0, 0, ZFPlayer_ScreenWidth, ZFPlayer_ScreenHeight - bottomOffset);
    CGRect winFrame = CGRectZero;
    if (self.startView) {
        winFrame = [self.startView convertRect:self.startView.bounds toView:nil];
    }
    
    // 显示图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:normalFrame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    imageView.image = self.startImage;
    if (self.player) {
        // pop回去的时候，设置回原来的scalingMode
        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        [self.player updateNoramlPlayerWithContainerView:imageView];
    }
    
    [container addSubview:imageView];
    
    toView.alpha = 1;
    fromView.alpha = 1;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        imageView.frame = winFrame;
        fromView.alpha = 0;
    } completion:^(BOOL finished) {
        // 移除临时视图
        [imageView removeFromSuperview];
        
        // 结束动画
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        if (self.completion) {
            self.completion();
        }
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (UIView *)effectView {
    if (!_effectView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        } else {
            UIToolbar *effectView = [[UIToolbar alloc] init];
            effectView.barStyle = UIBarStyleBlackTranslucent;
            _effectView = effectView;
        }
    }
    return _effectView;
}

@end

```

#三、相关链接
* ZFPlayer
  https://github.com/renzifeng/ZFPlayer
* KTVHttpCache
  https://github.com/ChangbaDevs/KTVHTTPCache
* 转场动画
  https://blog.devtang.com/2016/03/13/iOS-transition-guide/
