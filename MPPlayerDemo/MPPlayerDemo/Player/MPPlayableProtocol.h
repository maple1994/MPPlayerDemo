//
//  XSTViedoFlowProtocol.h
//  Pods
//
//  Created by Beauty-ruanjian on 2019/4/24.
//

#ifndef XSTViedoFlowProtocol_h
#define XSTViedoFlowProtocol_h

/// XSTPlayerController播放的模型，必须实现这个协议
@protocol XSTPlayable <NSObject>
/// string 视频链接
@property (nonatomic, copy) NSString *video_url;
/// 作品id
@property (nonatomic,   copy) NSString *artID;
@end


#endif /* XSTViedoFlowProtocol_h */
