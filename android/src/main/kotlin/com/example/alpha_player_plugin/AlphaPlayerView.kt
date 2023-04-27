package com.example.alpha_player_plugin

import android.content.Context
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.RelativeLayout
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.ss.ugc.android.alpha_player.IMonitor
import com.ss.ugc.android.alpha_player.IPlayerAction
import com.ss.ugc.android.alpha_player.controller.IPlayerController
import com.ss.ugc.android.alpha_player.controller.PlayerController
import com.ss.ugc.android.alpha_player.model.AlphaVideoViewType
import com.ss.ugc.android.alpha_player.model.Configuration
import com.ss.ugc.android.alpha_player.model.DataSource
import com.ss.ugc.android.alpha_player.model.ScaleType
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import java.io.File

/**
 * Created by pengboboer.
 * Date: 2023/3/28
 */
class AlphaPlayerView(context: Context, viewId: Int, private val messenger: BinaryMessenger) :
        PlatformView, RelativeLayout(context), LifecycleOwner, MethodCallHandler {
    private val TAG = "AlphaPlayerView"


    private var channel: MethodChannel? = null

    private var result: MethodChannel.Result? = null

    private var mRegistry = LifecycleRegistry(this)

    private var mPlayerController: IPlayerController? = null

    private var filePath: String? = null

    private val playerAction = object : IPlayerAction {
        override fun onVideoSizeChanged(videoWidth: Int, videoHeight: Int, scaleType: ScaleType) {
            Log.i(TAG,
                    "call onVideoSizeChanged(), videoWidth = $videoWidth, videoHeight = $videoHeight, scaleType = $scaleType"
            )
        }

        override fun startAction() {
            Log.i(TAG, "call startAction()")
        }

        override fun endAction() {
            Log.i(TAG, "call endAction")
            if (channel != null) {
                val params: HashMap<String, String?> = HashMap()
                params["filePath"] = filePath
                channel?.invokeMethod("playEnd", params)
            }
        }
    }

    private val monitor = object : IMonitor {
        override fun monitor(state: Boolean, playType: String, what: Int, extra: Int, errorInfo: String) {
            Log.i(TAG,
                    "call monitor(), state: $state, playType = $playType, what = $what, extra = $extra, errorInfo = $errorInfo"
            )
        }
    }

    init {
        val layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT
        )
        setLayoutParams(layoutParams)
        initPlayerController(context, this)
        channel = MethodChannel(this.messenger, "alpha_player_plugin_$viewId")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result

        when (call.method) {
            "start" -> {
                filePath = call.argument<String>("filePath")
                val align = call.argument<Int>("align")
                val isLooping = call.argument<Boolean>("isLooping")
                if (filePath?.isNotEmpty() == true) {
                    val file = File(filePath)
                    file.parent?.let { startVideo(it, file.name, align, isLooping) }
                }
            }
            "pause" -> mPlayerController?.pause()
            "resume" -> mPlayerController?.resume()
            else -> result.notImplemented()
        }
        result.success(true)
    }

    override fun getView(): View = this

    override fun dispose() {
        releasePlayerController()
        channel?.setMethodCallHandler(null)
        channel = null
        detachView()
    }

    override fun getLifecycle(): Lifecycle = mRegistry

    private fun initPlayerController(context: Context, owner: LifecycleOwner) {
        val configuration = Configuration(context, owner)
        //  GLTextureView supports custom display layer, but GLSurfaceView has better performance, and the GLSurfaceView is default.
        configuration.alphaVideoViewType = AlphaVideoViewType.GL_TEXTURE_VIEW
        //  You can implement your IMediaPlayer, here we use ExoPlayerImpl that implemented by ExoPlayer, and
        //  we support DefaultSystemPlayer as default player.
        mPlayerController = PlayerController.get(configuration, ExoPlayerImpl(context))
        mPlayerController?.let {
            it.setPlayerAction(playerAction)
            it.setMonitor(monitor)
        }

        attachView()
    }


    private fun startVideo(filePath: String, fileName: String, align: Int?, looping: Boolean?) {
        if (TextUtils.isEmpty(filePath)) {
            return
        }

        var scaleType = align ?: 2
        var isLooping = looping ?: true

        val dataSource = DataSource().setBaseDir(filePath).setPortraitPath(fileName, scaleType)
                .setLandscapePath(fileName, scaleType).setLooping(isLooping)
        if (dataSource.isValid()) {
            mPlayerController?.start(dataSource)
        }
    }

    private fun attachView() {
        mPlayerController?.attachAlphaView(this)
    }

    fun detachView() {
        mPlayerController?.detachAlphaView(this)
    }

    fun releasePlayerController() {
        mPlayerController?.let {
            it.detachAlphaView(this)
            it.release()
        }
    }


}