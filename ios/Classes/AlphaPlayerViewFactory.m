

#import "AlphaPlayerViewFactory.h"
#import "AlphaPlayerView.h"

@implementation AlphaPlayerViewFactory
{
  NSObject<FlutterBinaryMessenger>*_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
  self = [super init];
  if (self) {
    _messenger = messager;
  }
  return self;
}

//设置参数的编码方式
-(NSObject<FlutterMessageCodec> *)createArgsCodec{
  return [FlutterStandardMessageCodec sharedInstance];
}

//用来创建 ios 原生view
-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    CGRect viewFrame = frame;
    NSDictionary *arguments = args;
    if (![arguments isKindOfClass:[NSNull class]]){
        viewFrame.size.width = [arguments[@"width"] doubleValue];
        viewFrame.size.height = [arguments[@"height"] doubleValue];
    }
    AlphaPlayerView *activity = [[AlphaPlayerView alloc] initWithWithFrame:viewFrame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    return activity;
}

@end
