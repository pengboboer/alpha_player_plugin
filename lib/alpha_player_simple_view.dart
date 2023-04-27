import 'package:alpha_player_plugin/alpha_player_view.dart';
import 'package:flutter/material.dart';

/// @author: pengboboer
/// @createDate: 2023/3/29
typedef AlphaPlayerSimpleViewStartedCallback = void Function(AlphaPlayerController controller);

class AlphaPlayerSimpleView extends StatefulWidget {
  final String path;
  final double? width;
  final double? height;
  final AlphaPlayerScaleType? align;
  final bool isLooping;
  final AlphaPlayerSimpleViewStartedCallback? onStarted;
  final ValueChanged<String?>? onCompleted;

  //针对iOS平台,宽高必须得传

  const AlphaPlayerSimpleView({
    Key? key,
    required this.path,
    required this.width,
    required this.height,
    this.align,
    this.isLooping = true,
    this.onStarted,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<AlphaPlayerSimpleView> createState() => _AlphaPlayerSimpleViewState();
}

class _AlphaPlayerSimpleViewState extends State<AlphaPlayerSimpleView> {
  final AlphaPlayerController controller = AlphaPlayerController();

  @override
  void didUpdateWidget(covariant AlphaPlayerSimpleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      controller.start(widget.path, align: widget.align, isLooping: widget.isLooping);
      widget.onStarted?.call(controller);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlphaPlayerView(
      controller: controller,
      onCreated: (id) {
        controller.start(widget.path, align: widget.align, isLooping: widget.isLooping);
        widget.onStarted?.call(controller);
      },
      width: widget.width,
      height: widget.height,
      onCompleted: widget.onCompleted,
    );
  }
}
