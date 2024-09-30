#import "AlphaPlayerPlugin.h"
#import "AlphaPlayerViewFactory.h"

@implementation AlphaPlayerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // 生成视图工厂
    AlphaPlayerViewFactory *viewFactory = [[AlphaPlayerViewFactory alloc] initWithMessenger:registrar.messenger];
    // 注册视图工厂
    [registrar registerViewFactory:viewFactory withId:@"alpha_player_view_factory"];
}

@end
