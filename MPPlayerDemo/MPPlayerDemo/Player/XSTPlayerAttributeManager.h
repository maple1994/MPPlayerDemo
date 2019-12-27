//
//  XSTPlayerAssetManager.h
//  XStarSDK
//
//  Created by Beauty-ruanjian on 2019/7/4.
//

#import <Foundation/Foundation.h>
#import <ZFPlayer/ZFPlayerMediaPlayback.h>

NS_ASSUME_NONNULL_BEGIN

/// 视频属性，视频资源等管理
@interface XSTPlayerAttributeManager : NSObject<ZFPlayerMediaPlayback>

@property (nonatomic) BOOL shouldAutoPlay;

@end

NS_ASSUME_NONNULL_END
