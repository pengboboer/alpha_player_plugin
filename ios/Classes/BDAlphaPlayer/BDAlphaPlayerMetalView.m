//
//  BDAlphaPlayerMetalView.m
//  BDAlphaPlayer
//
//  Created by ByteDance on 2020/7/5.
//

#import "BDAlphaPlayerMetalView.h"

#import "BDAlphaPlayerAssetReaderOutput.h"
#import "BDAlphaPlayerMetalRenderer.h"
#import "BDAlphaPlayerMetalShaderType.h"

#import <MetalKit/MetalKit.h>
#import <pthread.h>

@interface BDAlphaPlayerMetalView ()

@property (nonatomic, strong, readwrite) BDAlphaPlayerResourceModel *model;
@property (nonatomic, assign, readwrite) BDAlphaPlayerPlayState state;

@property (nonatomic, weak, nullable) id<BDAlphaPlayerMetalViewDelegate> delegate;

@property (nonatomic, assign) CGRect renderSuperViewFrame;
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) BDAlphaPlayerMetalRenderer *metalRenderer;

@property (nonatomic, strong) BDAlphaPlayerAssetReaderOutput *output;

///为了重置时,拿到上次的播放参数
@property (nonatomic, strong) NSString *directory;
@property (nonatomic, assign) int contentMode;
@property (nonatomic, assign) BOOL repeat;

@end

@implementation BDAlphaPlayerMetalView

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(nullable id<BDAlphaPlayerMetalViewDelegate>)delegate
{
    if (self = [super initWithFrame:CGRectZero]) {
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        [self setupMetal];
    }
    return self;
}

#pragma mark - Public Method

- (void)playWithMetalConfiguration:(BDAlphaPlayerMetalConfiguration *)configuration
{
    NSAssert(!CGRectIsEmpty(configuration.renderSuperViewFrame), @"You need to initialize renderSuperViewFrame before playing");
    NSError *error = nil;
    self.renderSuperViewFrame = configuration.renderSuperViewFrame;
    self.model = [BDAlphaPlayerResourceModel resourceModelFromDirectory:configuration.directory orientation:configuration.orientation error:&error];
    if (error) {
        [self didFinishPlayingWithError:error];
        return;
    }
    [self configRenderViewContentModeFromModel];
    [self play];
}

- (void)playWithMetalConfigurationWithDirectory:(NSString *)directory renderSuperViewFrame:(CGRect)renderSuperViewFrame contentMode:(int)contentMode repeat:(BOOL)repeat{
    if (directory.length == 0){
        NSLog(@"directory为空");
        return;
    }
    ///为了重置时,拿到上次的播放参数
    self.directory = directory;
    self.contentMode = contentMode;
    self.repeat = repeat;
    
    //针对停止后,重新初始化mtkView
    [self setupMetal];
    //延迟了render的创建,原来在setupmodel中
    if (self.metalRenderer == nil){
        self.metalRenderer = [[BDAlphaPlayerMetalRenderer alloc] initWithMetalKitView:self.mtkView repeat:repeat];
        
        __weak __typeof(self) weakSelf = self;
        self.metalRenderer.framePlayDurationCallBack = ^(NSTimeInterval duration) {
            if (weakSelf && [weakSelf.delegate respondsToSelector:@selector(frameCallBack:)]) {
                [weakSelf.delegate frameCallBack:duration];
            }
        };
    }else{
        //针对第二次加载地址时,flutter端改变了,但是同一个render的repeat值,没有改变的问题
        self.metalRenderer.repeat = repeat;
        if (self.mtkView.hidden == YES){
            self.mtkView.hidden = NO;
        }
    }
    
    
    self.renderSuperViewFrame = renderSuperViewFrame;
    
    BDAlphaPlayerResourceModel *resourceModel = [BDAlphaPlayerResourceModel new];
    
    BDAlphaPlayerResourceInfo *portraitResourceInfo = [BDAlphaPlayerResourceInfo new];
    portraitResourceInfo.contentMode = contentMode;
    portraitResourceInfo.resourceName = [directory lastPathComponent];
    portraitResourceInfo.resourceFilePath = directory;
    portraitResourceInfo.resourceFileURL = [NSURL fileURLWithPath:directory];
    resourceModel.portraitResourceInfo = portraitResourceInfo;
    
    resourceModel.currentOrientationResourceInfo = portraitResourceInfo;
    
    self.model = resourceModel;
    
    if (!self.model) {
        return;
    }
    [self configRenderViewContentModeFromModel];
    [self play];
}

- (NSTimeInterval)totalDurationOfPlayingEffect{
    if (self.output) {
        return self.output.videoDuration;
    } else {
        return 0.0;
    }
}

/// 暂停
- (void)pause{
    self.mtkView.paused = YES;
}

/// 恢复
- (void)resume{
    self.mtkView.paused = NO;
}

/// 停止
- (void)stop{
//    [self destroyMTKView];
    [self pause];
    self.mtkView.hidden = YES;
}

// /// 重置
// - (void)reset{
//     [self stop];
//     [self playWithMetalConfigurationWithDirectory:self.directory renderSuperViewFrame:self.renderSuperViewFrame contentMode:self.contentMode repeat:self.repeat];
// }

- (void)stopWithFinishPlayingCallback{
    [self stop];
    [self renderCompletion];
}

#pragma mark - Private Method

- (void)configRenderViewContentModeFromModel
{
    BDAlphaPlayerContentMode mode = self.model.currentOrientationResourceInfo.contentMode;
    self.model.currentOrientationResourceInfo.contentMode = mode;
}

#pragma mark Callback

- (void)didFinishPlayingWithError:(NSError *)error
{
    self.state = BDAlphaPlayerPlayStateStop;
    if (self.delegate && [self.delegate respondsToSelector:@selector(metalView:didFinishPlayingWithError:)]) {
        [self.delegate metalView:self didFinishPlayingWithError:error];
    }
}

#pragma mark Player

- (void)play
{
    NSURL *url = [self.model.currentOrientationResourceInfo resourceFileURL];
    NSError *error = nil;
    BDAlphaPlayerAssetReaderOutput *output = [[BDAlphaPlayerAssetReaderOutput alloc] initWithURL:url error:&error];
    CGRect rederFrame = [BDAlphaPlayerUtility frameFromVideoSize:output.videoSize renderSuperViewFrame:self.renderSuperViewFrame resourceModel:self.model];
    self.frame = rederFrame;
    
    if (error) {
        NSError *finishError = nil;
        switch (error.code) {
            case BDAlphaPlayerAssetReaderOutputErrorFileNotExists:
            case BDAlphaPlayerAssetReaderOutputErrorCannotReadFile:
                finishError = [NSError errorWithDomain:BDAlphaPlayerErrorDomain code:BDAlphaPlayerErrorCodeFile userInfo:error.userInfo];
                break;
            case BDAlphaPlayerAssetReaderOutputErrorVideoTrackNotExists:
                finishError = [NSError errorWithDomain:BDAlphaPlayerErrorDomain code:BDAlphaPlayerErrorCodePlay userInfo:@{NSLocalizedDescriptionKey:@"does not have video track"}];
                break;
            default:
                finishError = error;
                break;
        }
        [self didFinishPlayingWithError:finishError];
        return;
    }
    self.state = BDAlphaPlayerPlayStatePlay;
    __weak __typeof(self) weakSelf = self;
    [self renderOutput:output resourceModel:self.model completion:^{
        [weakSelf renderCompletion];
    }];
}

- (void)renderCompletion
{
    [self didFinishPlayingWithError:nil];
}

- (void)renderOutput:(BDAlphaPlayerAssetReaderOutput *)output resourceModel:(BDAlphaPlayerResourceModel *)resourceModel completion:(BDAlphaPlayerRenderOutputCompletion)completion
{
    if (!self.mtkView) {
        [self setupMetal];
    }
    self.output = output;
    BDAlphaPlayerRenderOutputCompletion renderCompletion = [completion copy];
    
    __weak __typeof(self) wSelf = self;
    [self.metalRenderer renderOutput:output resourceModel:resourceModel completion:^{
        if (!wSelf) {
            return;
        }
        [wSelf destroyMTKView];
        if (renderCompletion) {
            renderCompletion();
        }
    }];
}

- (void)destroyMTKView
{
    self.mtkView.paused = YES;
    [self.mtkView removeFromSuperview];
    [self.mtkView releaseDrawables];
    [self.metalRenderer drainSampleBufferQueue];
    self.mtkView = nil;
}

#pragma mark SetupMetal

- (void)setupMetal{
    // Init MTKView
    if (self.mtkView == nil) {
        self.mtkView = [[MTKView alloc] initWithFrame:CGRectZero];
        self.mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mtkView.backgroundColor = UIColor.clearColor;
        self.mtkView.device = MTLCreateSystemDefaultDevice();
        [self addSubview:self.mtkView];
    
        self.mtkView.frame = self.bounds;
    }
}

@end
