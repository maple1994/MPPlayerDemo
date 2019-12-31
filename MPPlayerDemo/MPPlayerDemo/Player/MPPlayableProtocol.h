
#ifndef XSTViedoFlowProtocol_h
#define XSTViedoFlowProtocol_h

/// XSTPlayerController播放的模型，必须实现这个协议
@protocol XSTPlayable <NSObject>
/// string 视频链接
@property (nonatomic, copy) NSString *video_url;
@end


#endif /* XSTViedoFlowProtocol_h */
