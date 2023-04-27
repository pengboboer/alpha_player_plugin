import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

const String _viewType = "alpha_player_view_factory";
const String _channelName = "alpha_player_plugin_";

class AlphaPlayerView extends StatefulWidget {
  final double? width;
  final double? height;
  final AlphaPlayerController controller;
  final PlatformViewCreatedCallback? onCreated;
  /// 只有在looping为false的时候才有播放完成的回调
  final ValueChanged<String?>? onCompleted;

  const AlphaPlayerView({
    Key? key,
    required this.width,
    required this.height,
    required this.controller,
    this.onCreated,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<AlphaPlayerView> createState() => _AlphaPlayerViewState();
}

class _AlphaPlayerViewState extends State<AlphaPlayerView> {
  MethodChannel? methodChannel;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    methodChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onController() {
    switch (widget.controller.event) {
      case AlphaPlayerEvent.start:
        methodChannel?.invokeMethod('start', {
          'filePath': widget.controller.videoPath,
          'align': widget.controller.videoAlign?.getValue(),
          'isLooping': widget.controller.isLooping ?? true,
        });
        break;
      case AlphaPlayerEvent.pause:
        methodChannel?.invokeMethod('pause');
        break;
      case AlphaPlayerEvent.resume:
        methodChannel?.invokeMethod('resume');
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget showWidget;
    if (Platform.isAndroid) {
      showWidget = AndroidView(
          viewType: _viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec(),
          hitTestBehavior: PlatformViewHitTestBehavior.transparent);
    } else if (Platform.isIOS) {
      showWidget = UiKitView(
        viewType: _viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        creationParams: {
          'width': widget.width,
          'height': widget.height,
        },
      );
    } else {
      showWidget = const Center(
        child: Text(
          "该平台暂不支持 platform View",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: showWidget,
    );
  }

  void _onPlatformViewCreated(int id) {
    methodChannel = MethodChannel('$_channelName$id');
    widget.onCreated?.call(id);
    methodChannel?.setMethodCallHandler((call) async {
      switch (call.method) {
        case "playEnd":
          widget.onCompleted?.call(call.arguments?["filePath"]);
          break;
        default:
          break;
      }
    });
  }
}

class AlphaPlayerController extends ChangeNotifier {
  String? videoPath;
  AlphaPlayerScaleType? videoAlign;
  bool? isLooping;

  AlphaPlayerEvent? event;

  void start(
    String? path, {
    AlphaPlayerScaleType? align,
    bool? isLooping,
  }) {
    videoPath = path;
    videoAlign = align;
    this.isLooping = isLooping;
    event = AlphaPlayerEvent.start;
    notifyListeners();
  }

  void pause() {
    event = AlphaPlayerEvent.pause;
    notifyListeners();
  }

  void resume() {
    event = AlphaPlayerEvent.resume;
    notifyListeners();
  }
}

enum AlphaPlayerEvent { start, pause, resume, stop, reset }

enum AlphaPlayerScaleType {
  ScaleToFill, //  拉伸铺满全屏
  ScaleAspectFitCenter, //  等比例缩放对齐全屏，居中，屏幕多余留空
  ScaleAspectFill, //  等比例缩放铺满全屏，裁剪视频多余部分
  TopFill, //  等比例缩放铺满全屏，顶部对齐
  BottomFill, //  等比例缩放铺满全屏，底部对齐
  LeftFill, //  等比例缩放铺满全屏，左边对齐
  RightFill, //  等比例缩放铺满全屏，右边对齐
  TopFit, //  等比例缩放至屏幕宽度，顶部对齐，底部留空
  BottomFit, //  等比例缩放至屏幕宽度，底部对齐，顶部留空
  LeftFit, //  等比例缩放至屏幕高度，左边对齐，右边留空
  RightFit //  等比例缩放至屏幕高度，右边对齐，左边留空
}

extension ScaleTypeExtension on AlphaPlayerScaleType {
  int getValue() {
    if (this == AlphaPlayerScaleType.ScaleToFill) return 0;
    if (this == AlphaPlayerScaleType.ScaleAspectFitCenter) return 1;
    if (this == AlphaPlayerScaleType.ScaleAspectFill) return 2;
    if (this == AlphaPlayerScaleType.TopFill) return 3;
    if (this == AlphaPlayerScaleType.BottomFill) return 4;
    if (this == AlphaPlayerScaleType.LeftFill) return 5;
    if (this == AlphaPlayerScaleType.RightFill) return 6;
    if (this == AlphaPlayerScaleType.TopFit) return 7;
    if (this == AlphaPlayerScaleType.BottomFit) return 8;
    if (this == AlphaPlayerScaleType.LeftFit) return 9;
    if (this == AlphaPlayerScaleType.RightFit) return 10;
    return 0;
  }
}
