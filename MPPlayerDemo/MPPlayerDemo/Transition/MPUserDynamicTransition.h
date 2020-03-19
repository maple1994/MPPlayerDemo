//
//  MPUserDynamicTransition.h
//
//  Created by Maple on 2019/12/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 关注的用户动态转场
@interface MPUserDynamicTransition : NSObject<UIViewControllerAnimatedTransitioning, CAAnimationDelegate>
/// 是否手势退出
@property (nonatomic, assign) BOOL isInteracting;
@property (nonatomic, assign) BOOL isComplete;
/**
 初始化动画

 @param duration 动画时长
 @param startView 开始视图
 @param startImage 开始图片
 @param endX pop动画时的endX
 @param operation 动画形式
 @return 动画实例
 */
+ (instancetype)animationWithDuration:(NSTimeInterval)duration
                            startView:(UIView *)startView
                           startImage:(UIImage *)startImage
                            endX: (CGFloat)endX
                            operation:(UINavigationControllerOperation)operation;


@end

NS_ASSUME_NONNULL_END
