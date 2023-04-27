


#import "AlphaPlayerView.h"
#import "BDAlphaPlayer.h"
#import <UIKit/UIKit.h>
@interface AlphaPlayerView ()<BDAlphaPlayerMetalViewDelegate>

/** channel*/
@property (nonatomic, strong)  FlutterMethodChannel  *channel;
/** 原生的父视图*/
@property (nonatomic, strong)  UIView *nativeView;

//自定义属性
@property (nonatomic, strong) BDAlphaPlayerMetalView *metalView;
//视频地址
@property (nonatomic, copy) NSString *videoPath;
//对齐方式
@property (nonatomic, assign) int align;

@property (nonatomic, assign) bool repeat;

@end

@implementation AlphaPlayerView
{
    CGRect _frame;
    int64_t _viewId;
    id _args;
}
// 创建原生视图
- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {

        _frame = frame;
        _viewId = viewId;
        _args = args;
        
        ///建立通信通道 用来 监听Flutter 的调用和 调用Fluttter 方法 这里的名称要和Flutter 端保持一致
        _channel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"alpha_player_plugin_%lld",viewId] binaryMessenger:messenger];
        
        __weak __typeof__(self) weakSelf = self;
        
        [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf onMethodCall:call result:result];
        }];
    
    }
  return self;
}

-(UIView *)view{
    UIView *nativeView = [[UIView alloc] initWithFrame:_frame];
    nativeView.backgroundColor = [UIColor clearColor];
    self.nativeView = nativeView;

    self.metalView = [[BDAlphaPlayerMetalView alloc] initWithDelegate:self];
    [self.nativeView insertSubview:self.metalView atIndex:0];

    return nativeView;
}


- (void)startPlay{
    if (self.videoPath.length > 0) {
        [self.metalView playWithMetalConfigurationWithDirectory:self.videoPath renderSuperViewFrame:self.nativeView.bounds contentMode:self.align repeat:self.repeat];
    }else{
        NSLog(@"路径为空,不处理");
    }
}

- (void)metalView:(BDAlphaPlayerMetalView *)metalView didFinishPlayingWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    NSLog(@"单次播放结束了");
    [self.channel invokeMethod:@"playEnd" arguments:@{@"filePath":self.videoPath}];

}
-(void)frameCallBack:(NSTimeInterval)duration{
//    NSLog(@"duration %f",duration);
}

#pragma mark -- Flutter 交互监听
-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    //监听Fluter
    if ([[call method] isEqualToString:@"start"]) {
        NSLog(@"----start");
        NSDictionary *arguments = call.arguments;
        if (![arguments[@"filePath"] isKindOfClass:[NSNull class]]){
            NSString *filePath = arguments[@"filePath"];
            self.videoPath = filePath;
        }
        self.align = 2;
        if (![arguments[@"align"] isKindOfClass:[NSNull class]]){
            self.align = [arguments[@"align"] intValue];
        }
        if (![arguments[@"isLooping"] isKindOfClass:[NSNull class]]){
            self.repeat = [arguments[@"isLooping"] boolValue];
        }else{
            self.repeat = YES;
        }
        [self startPlay];
    }else if ([[call method] isEqualToString:@"pause"]) {
        NSLog(@"----pause");
        [self.metalView pause];
    }else if ([[call method] isEqualToString:@"resume"]) {
        NSLog(@"----resume");
        [self.metalView resume];
    }
}
//调用Flutter
// - (void)flutterMethod{
//     [self.channel invokeMethod:@"clickAciton" arguments:@"我是参数"];
// }


@end
