//
//  PreLoaderModel.m
//  ListDemo
//
//  Created by Beauty-ruanjian on 2019/4/17.
//  Copyright © 2019 Beauty-ruanjian. All rights reserved.
//

#import "XSTPreLoaderModel.h"

@implementation XSTPreLoaderModel

- (instancetype)initWithURL: (NSString *)url loader: (KTVHCDataLoader *)loader
{
    if (self = [super init])
    {
        _url = url;
        _loader = loader;
    }
    return self;
}


@end
