import 'package:alpha_player_plugin/alpha_player_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// @author: pengboboer
/// @createDate: 2023/3/29
class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  String? videoPath;

  final ImagePicker _picker = ImagePicker();

  AlphaPlayerController controller = AlphaPlayerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                      videoPath = video?.path;
                      setState(() {});
                    },
                    child: const Text("选择")),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      controller.start(videoPath);
                    },
                    child: const Text("播放")),
                ElevatedButton(
                    onPressed: () {
                      controller.pause();
                    },
                    child: const Text("暂停")),
                ElevatedButton(
                    onPressed: () {
                      controller.resume();
                    },
                    child: const Text("恢复")),
              ],
            ),
            Container(
              height: screenWidth * 1.5,
              width: screenWidth,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: AssetImage(
                    'assets/test_bg.png',
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: _buildContentWidget()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    return AlphaPlayerView(
      controller: controller,
      width: screenWidth,
      height: screenWidth * 1.5,
    );
  }
}
