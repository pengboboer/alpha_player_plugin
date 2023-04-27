package com.example.alpha_player_plugin

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger

/**
 * Created by pengboboer.
 * Date: 2023/3/28
 */
class AlphaPlayerPlugin : FlutterPlugin {

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger: BinaryMessenger = flutterPluginBinding.binaryMessenger
        flutterPluginBinding
                .platformViewRegistry
                .registerViewFactory(
                        "alpha_player_view_factory", AlphaPlayerViewFactory(messenger)
                )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
