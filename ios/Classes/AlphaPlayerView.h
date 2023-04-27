
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN
// 平台视图封装类
@interface AlphaPlayerView : NSObject<FlutterPlatformView>

/// 固定写法
- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END
