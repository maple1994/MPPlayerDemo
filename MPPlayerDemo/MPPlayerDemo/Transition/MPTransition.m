//
//  MPTransition.m
//  MPPlayerDemo
//
//  Created by Maple on 2019/12/31.
//  Copyright © 2019 Maple. All rights reserved.
//

#import "MPTransition.h"
#import "MPPlayerController.h"
#import <ZFUtilities.h>

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

