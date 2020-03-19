//
//  MPUserDynamicDetailViewController.m
//  MPPlayerDemo
//
//  Created by Maple on 2020/3/18.
//  Copyright © 2020 Maple. All rights reserved.
//

#import "MPUserDynamicDetailViewController.h"
#import "MPTransition.h"
#import "MPUserDynamicViewController.h"
#import "MPUserDynamicTransition.h"
#import <ZFUtilities.h>

@interface MPUserDynamicDetailViewController ()

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveGes;
@property (nonatomic, assign) BOOL isInteracting;
@property (nonatomic, strong) MPUserDynamicTransition *transition;
@property (nonatomic, assign) CGFloat startOffsetY;
@property (nonatomic, assign) CGFloat lastOffsetY;

@end

@implementation MPUserDynamicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.interactiveGes = [[UIPercentDrivenInteractiveTransition alloc] init];
    self.isInteracting = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:pan];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (void)backAction
{
    self.isInteracting = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)percentForGesture:(UIPanGestureRecognizer *)gesture{
    // 最多只能移动SL_SCREEN_HEIGHT * 0.5
    CGFloat maxOffset = ZFPlayer_ScreenHeight * 0.5;
    CGFloat y = [gesture locationInView:[UIApplication sharedApplication].keyWindow].y;
    // 移动的距离
    CGFloat distance = y - self.startOffsetY;
    distance = MIN(maxOffset, distance);
    double degree = (distance / maxOffset) * M_PI_2;
    double x = 1 - (sin(degree));
    // 计算增量
    CGFloat delta = distance - self.lastOffsetY;
    self.lastOffsetY = self.lastOffsetY + x * delta;
    self.lastOffsetY = MAX(self.lastOffsetY, 0);
    CGFloat percent = self.lastOffsetY / maxOffset;
    return percent;
}


- (void)panAction: (UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state){
        case UIGestureRecognizerStateBegan:
        {
            self.startOffsetY = [gestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow].y;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case UIGestureRecognizerStateChanged:
            // 调用updateInteractiveTransition来更新动画进度
            // 里面嵌套定义 percentForGesture 方法计算动画进度
            [self.interactiveGes updateInteractiveTransition:[self percentForGesture:gestureRecognizer]];
            break;
        case UIGestureRecognizerStateEnded:
            //判断手势位置，要大于一般,就完成这个转场，要小于一半就取消
            if ([self percentForGesture:gestureRecognizer] >= 0.4) {
                self.transition.isComplete = YES;
                // 完成交互转场
                [self.interactiveGes finishInteractiveTransition];
            }else {
                // 取消交互转场
                [self.interactiveGes cancelInteractiveTransition];
            }
            break;
        default:
            [self.interactiveGes cancelInteractiveTransition];
            break;
    }
}

// MARK: - Transition
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    UIView *startView = self.startCell;
    UIImage *startImage = self.iconImage;
    CGFloat endX = 0;
    if (operation == UINavigationControllerOperationPop) {
        endX = [self getPopTransitionEndX];
    }
    if (startView == nil)
        return nil;
    NSTimeInterval duration = 0.2;
    MPUserDynamicTransition *transition = [MPUserDynamicTransition animationWithDuration:duration startView:startView startImage:startImage endX:endX operation:operation];
    if (operation == UINavigationControllerOperationPop) {
        transition.isInteracting = self.isInteracting;
        transition.isComplete = YES;
    }
    self.transition = transition;
    return transition;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.isInteracting ? self.interactiveGes : nil;
}

- (CGFloat)getPopTransitionEndX
{
    CGRect winFrame = [self.startCell convertRect:self.startCell.frame toView:nil];
    return winFrame.origin.x;
}

@end
