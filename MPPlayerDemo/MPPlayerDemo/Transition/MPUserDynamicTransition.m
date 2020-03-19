//
//  MPUserDynamicTransition.m
//
//  Created by Maple on 2019/12/5.
//

#import "MPUserDynamicTransition.h"
#import <ZFPlayer/ZFUtilities.h>

@interface MPUserDynamicTransition ()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) UIView *startView;
@property (nonatomic, strong) UIImage *startImage;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat endX;
@property (nonatomic, assign) UINavigationControllerOperation operation;

@end

@implementation MPUserDynamicTransition

+ (instancetype)animationWithDuration:(NSTimeInterval)duration
 startView:(UIView *)startView
startImage:(UIImage *)startImage
endX: (CGFloat)endX
 operation:(UINavigationControllerOperation)operation
{
    MPUserDynamicTransition *transition = [[self alloc] init];
    transition.duration = duration;
    transition.startView = startView;
    transition.startImage = startImage;
    transition.endX = endX;
    transition.operation = operation;
    return transition;
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.operation == UINavigationControllerOperationPush) {
        [self startPushAnimation: transitionContext];
    }else {
        [self startPopAnimation: transitionContext];
    }
}

- (void)startPushAnimation: (nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *contentView = [transitionContext containerView];
    // 获取 fromView 和 toView
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [contentView addSubview:fromView];
    [contentView addSubview:toView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = self.startView.bounds.size.width * 0.5;
    imageView.layer.masksToBounds = YES;
    imageView.image = self.startImage;
    CGRect winFrame = CGRectZero;
    if (self.startView) {
        winFrame = [self.startView convertRect:self.startView.bounds toView:nil];
    }
    imageView.frame = winFrame;
    toView.center = imageView.center;
    CGFloat scale = 56.0 / ZFPlayer_ScreenWidth;
    toView.transform = CGAffineTransformMakeScale(scale, scale);
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toView.transform = CGAffineTransformIdentity;
        toView.center = CGPointMake(ZFPlayer_ScreenWidth * 0.5, ZFPlayer_ScreenHeight * 0.5);
    } completion:^(BOOL finished) {
        // 结束动画
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)startPopAnimation: (nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *contentView = [transitionContext containerView];
    // 获取 fromView 和 toView
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *whiteCoverView = [[UIView alloc] init];
    whiteCoverView.backgroundColor = [UIColor blackColor];
    whiteCoverView.frame = CGRectMake(0, 0, ZFPlayer_ScreenWidth, ZFPlayer_ScreenHeight);
    whiteCoverView.alpha = 0;
    [contentView addSubview:toView];
    [contentView addSubview:whiteCoverView];
    [contentView addSubview:fromView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = self.startImage;
    imageView.layer.cornerRadius = ZFPlayer_ScreenWidth * 0.5;
    CGFloat top = (ZFPlayer_ScreenHeight - ZFPlayer_ScreenWidth) * 0.5;
    CGRect winFrame = CGRectMake(0, top, ZFPlayer_ScreenWidth, ZFPlayer_ScreenWidth);
    imageView.frame = winFrame;
    imageView.hidden = YES;
    [contentView addSubview:imageView];
    
    CGFloat targetCorner = 0;
    CGRect targetFrame = CGRectZero;
    if (self.startView) {
        targetFrame = [self.startView convertRect:self.startView.bounds toView:nil];
        targetFrame = CGRectMake(self.endX, targetFrame.origin.y, targetFrame.size.width, targetFrame.size.height);
        targetCorner = self.startView.bounds.size.width * 0.5;
    }
    dispatch_block_t block = dispatch_block_create(0, ^{
        imageView.hidden = NO;
        toView.alpha = 1.0f;
        fromView.transform = CGAffineTransformIdentity;
        fromView.alpha = 0.0f;
        whiteCoverView.alpha = 0.4;
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            whiteCoverView.alpha = 0;
            imageView.frame = targetFrame;
            imageView.layer.cornerRadius = targetCorner;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [whiteCoverView removeFromSuperview];
            // 结束动画
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    });
    if (self.isInteracting) {
        whiteCoverView.alpha = 1;
        [UIView animateWithDuration:self.duration animations:^{
            whiteCoverView.alpha = 0.4;
            fromView.transform = CGAffineTransformScale(fromView.transform, 0.9, 0.9);
            fromView.transform = CGAffineTransformTranslate(fromView.transform, 0, ZFPlayer_ScreenHeight * 0.5);
        } completion:^(BOOL finished) {
            if (self.isComplete) {
                block();
            }else {
                [imageView removeFromSuperview];
                [whiteCoverView removeFromSuperview];
                // 结束动画
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }
        }];
    }else {
        block();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    // 标记转场结束
    id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
    // 结束动画
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
}

@end
