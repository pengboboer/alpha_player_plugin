#import "AlphaPlayerPlugin.h"
#import "AlphaPlayerViewFactory.h"

@implementation AlphaPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"alpha_player_plugin"
            binaryMessenger:[registrar messenger]];
  AlphaPlayerPlugin* instance = [[AlphaPlayerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];

  // 生成视图工厂
  AlphaPlayerViewFactory *viewFactory = [[AlphaPlayerViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:viewFactory withId:@"alpha_player_view_factory"];// 注册视图工厂
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
