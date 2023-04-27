import 'package:alpha_player_plugin/alpha_player_simple_view.dart';
import 'package:alpha_player_plugin/alpha_player_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// @author: pengboboer
/// @createDate: 2023/3/29
class DemoSimplePage extends StatefulWidget {
  const DemoSimplePage({Key? key}) : super(key: key);

  @override
  State<DemoSimplePage> createState() => _DemoSimplePageState();
}

class _DemoSimplePageState extends State<DemoSimplePage> {
  String? videoPath;

  final ImagePicker _picker = ImagePicker();

  AlphaPlayerController? controller;

  String? hint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "视频路径为：$videoPath",
                        style: const TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
                      setState(() {
                        videoPath = video?.path;
                      });
                    },
                    child: const Text("选择视频")),
              ],
            ),
            _buildSimpleWidget(),
            _buildContentWidget(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(hint ?? ""),
            )
          ],
        ),
      ),
    );
  }

  /// 最简单的用法
  /// 传 path
  /// ios 必须传宽高
  /// 默认为循环播放
  Widget _buildSimpleWidget() {
    if (videoPath == null) return const SizedBox();

    return AlphaPlayerSimpleView(
      path: videoPath!,
      width: 100,
      height: 150,
    );
  }

  /// 更全一点的用法
  Widget _buildContentWidget() {
    if (videoPath == null) return const SizedBox();
    return Container(
      color: Colors.black,
      child: AlphaPlayerSimpleView(
        path: videoPath!,
        width: 200,
        height: 300,
        isLooping: false,
        onStarted: (ct) {
          // 可以拿到controller,进行其他操作
          controller = ct;
        },
        onCompleted: (videoPath) {
          // isLooping为false 才能拿到播放结束的回调
          setState(() {
            hint = "拿到视频播放结束的回调, 仅限looping为false的时候\n\n单次播放完成的视频地址: $videoPath";
          });
        },
      ),
    );
  }
}
