//
//  MPDetailViewController.h
//  MPPlayerDemo
//
//  Created by Maple on 2019/12/27.
//  Copyright © 2019 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPPlayerController.h"
NS_ASSUME_NONNULL_BEGIN

@interface MPDetailViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, strong) MPPlayerController *player;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIView *startView;
@property (nonatomic, strong) UIImage *startImage;
@property (nonatomic, copy) void(^popbackBlock)(void);

@end

NS_ASSUME_NONNULL_END
