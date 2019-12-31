//
//  PreLoaderModel.h
//  ListDemo
//
//  Created by Beauty-ruanjian on 2019/4/17.
//  Copyright © 2019 Beauty-ruanjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KTVHTTPCache.h>
NS_ASSUME_NONNULL_BEGIN

/// 预加载模型
@interface MPPreLoaderModel : NSObject

/// 加载的URL
@property (nonatomic, copy, readonly) NSString *url;
/// 请求URL的Loader
@property (nonatomic, strong, readonly) KTVHCDataLoader *loader;

- (instancetype)initWithURL: (NSString *)url loader: (KTVHCDataLoader *)loader;

@end

NS_ASSUME_NONNULL_END
