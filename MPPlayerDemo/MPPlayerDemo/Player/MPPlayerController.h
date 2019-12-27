//
//  XSTPlayerController.h
//  XStarSDK
//
//  Created by Beauty-ruanjian on 2019/7/4.
//

#import <Foundation/Foundation.h>
#import <ZFPlayer.h>
#import "MPPlayableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPPlayerController : NSObject

// 预加载上几条
@property (nonatomic, assign) NSUInteger preLoadNum;
/// 预加载下几条
@property (nonatomic, assign) NSUInteger nextLoadNum;
/// 预加载的的百分比，默认10%
@property (nonatomic, assign) double preloadPrecent;
/// 设置playableAssets后，马上预加载的条数
@property (nonatomic, assign) NSUInteger initPreloadNum;
/// The indexPath is playing.
@property (nonatomic, readonly, nullable) NSIndexPath *playingIndexPath;
/// The current player controller is disappear, not dealloc
@property (nonatomic, getter=isViewControllerDisappear) BOOL viewControllerDisappear;
@property (nonatomic, readonly) UIView *containerView;
/// 可播放的视频的模型数组，若是混合区域，模型需要实现XSTPlayable
/// set之后，先预加载几个
@property (nonatomic, copy) NSArray<id<XSTPlayable>> *playableArray;
/// 当前正在播放的 MPPlayable 资源
@property (nonatomic, strong, readonly) id<XSTPlayable> currentPlayable;
/// The currentPlayerManager must conform `ZFPlayerMediaPlayback` protocol.
@property (nonatomic, strong) id<ZFPlayerMediaPlayback> currentPlayerManager;
/// The custom controlView must conform `ZFPlayerMediaControl` protocol.
@property (nonatomic, strong) UIView<ZFPlayerMediaControl> *controlView;
/// 保存player在信息流时，应该显示的scalingMode
@property (nonatomic, assign) ZFPlayerScalingMode videoFlowScalingMode;
@property (nonatomic, getter=isWWANAutoPlay) BOOL WWANAutoPlay;
@property (nonatomic, assign) BOOL isPlaying;

// MARK: - Block
/// 准备播放的block
@property (nonatomic, copy, nullable) void(^playerReadyToPlay)(id<ZFPlayerMediaPlayback> asset, NSURL *assetURL);
/// 播放进度的block
@property (nonatomic, copy, nullable) void(^playerPlayTimeChanged)(id<ZFPlayerMediaPlayback> asset, NSTimeInterval currentTime, NSTimeInterval duration);
/// 播放缓存时间的block
@property (nonatomic, copy, nullable) void(^playerBufferTimeChanged)(id<ZFPlayerMediaPlayback> asset, NSTimeInterval bufferTime);
/// 播放失败回调
@property (nonatomic, copy, nullable) void(^playerPlayFailed)(id<ZFPlayerMediaPlayback> asset, id error);
/// 播放到结尾的回调
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id<ZFPlayerMediaPlayback> asset);
// 播放器size变化的回调
@property (nonatomic, copy, nullable) void(^presentationSizeChanged)(id<ZFPlayerMediaPlayback> asset, CGSize size);
/// The block invoked when the player playback state changed.
@property (nonatomic, copy, nullable) void(^playerPlayStateChanged)(id<ZFPlayerMediaPlayback> asset, ZFPlayerPlaybackState playState);
/// The block invoked when the player load state changed.
@property (nonatomic, copy, nullable) void(^playerLoadStateChanged)(id<ZFPlayerMediaPlayback> asset, ZFPlayerLoadState loadState);
@property (nonatomic, copy, nullable) void(^zf_playerDisappearingInScrollView)(NSIndexPath *indexPath, CGFloat playerDisapperaPercent);


// MARK: - Init
/**
 创建播放单个视频的PlayerController
 
 @param containerView 指定显示视频的容器
 @return MPPlayerController实例
 */
+ (instancetype)playrWithContainerView:(UIView *)containerView;

/**
 创建播放单个视频的PlayerController
 
 @param containerView 指定显示视频的容器
 @return MPPlayerController实例
 */
- (instancetype)initWithContainerView:(UIView *)containerView;

/**
 在UITableView或UICollectionView中使用的PlayerController
 
 @param scrollView UITableView或UICollectionView
 @param containerViewTag 指定显示视频的容器tag，cell的子视图的tag
 @return PlayerController实例
 */
+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView containerViewTag:(NSInteger)containerViewTag;

/**
 在UITableView或UICollectionView中使用的PlayerController
 
 @param scrollView UITableView或UICollectionView
 @param containerViewTag 指定显示视频的容器tag，cell的子视图的tag
 @return PlayerController实例
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView containerViewTag:(NSInteger)containerViewTag;

// MARK: - Method
/// 移除player，移除其他通知
- (void)stop;

/// 停止播放播放的Cell
- (void)stopCurrentPlayingCell;

/// 播放对应的indexPath，传入resouce
- (void)playTheIndexPath:(NSIndexPath *)indexPath playable: (id<XSTPlayable>)playable;

/// 播放指定的url
- (void)playWithPlayable: (id<XSTPlayable>)playable;

/// 设置player显示，消失的百分比，用于判断自动播放和暂停
- (void)setDisapperaPercent: (CGFloat)disappearPercent appearPercent: (CGFloat)appearPercent;

/// 横屏显示
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/// 退出全屏
- (void)exitFullScreen: (BOOL)isAnimated;

/// Add Player到Cell上
- (void)updateScrollViewPlayerToCell;

/// 更新Playerc的容器
- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView;



@end

NS_ASSUME_NONNULL_END
