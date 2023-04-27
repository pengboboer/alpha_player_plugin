#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint alpha_player_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'alpha_player_plugin'
  s.version          = '0.0.1'
  s.summary          = '用于播放mp4透明视频插件'
  s.description      = <<-DESC
用于播放mp4透明视频插件
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  # s.dependency 'BDAlphaPlayer','1.2.2' //改为本地引入源码,修改api
  s.platform = :ios, '11.0'
  s.libraries = 'c++'
  s.frameworks = 'UIKit','CoreVideo'
  s.resource_bundles = {
     'BDAlphaPlayer' => ['Classes/**/*.metal']
   }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
end
