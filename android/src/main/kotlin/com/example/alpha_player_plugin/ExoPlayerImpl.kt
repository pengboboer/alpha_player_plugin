package com.example.alpha_player_plugin

import android.content.Context
import android.net.Uri
import android.util.Log
import android.view.Surface
import androidx.annotation.Keep
import com.google.android.exoplayer2.*
import com.google.android.exoplayer2.Player.*
import com.google.android.exoplayer2.video.VideoSize
import com.ss.ugc.android.alpha_player.model.VideoInfo
import com.ss.ugc.android.alpha_player.player.AbsPlayer
import com.ss.ugc.android.alpha_player.player.IMediaPlayer

/**
 * Created by pengboboer.
 * Date: 2023/3/28
 */
class ExoPlayerImpl(private val context: Context) : AbsPlayer(context) {
    private lateinit var exoPlayer: ExoPlayer

    private var currVideoWidth: Int = 0
    private var currVideoHeight: Int = 0
    private var isLooping: Boolean = false

    private val exoPlayerListener: Player.Listener = object : Player.Listener {
        override fun onVideoSizeChanged(
                videoSize: VideoSize
        ) {
            currVideoWidth = videoSize.width
            currVideoHeight = videoSize.height
        }

        override fun onRenderedFirstFrame() {
            firstFrameListener?.onFirstFrame()
        }

        override fun onPlayerError(error: PlaybackException) {
            errorListener?.onError(0, 0, "ExoPlayer on error: " + Log.getStackTraceString(error))
        }

        @Deprecated("Deprecated in Java")
        override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
            when (playbackState) {
                Player.STATE_READY -> {
                    if (playWhenReady) {
                        preparedListener?.onPrepared()
                    }
                }
                Player.STATE_ENDED -> {
                    completionListener?.onCompletion()
                }
                else -> {}
            }
        }
    }

    override fun initMediaPlayer() {
        exoPlayer = ExoPlayer.Builder(context).build()
        exoPlayer.addListener(exoPlayerListener)
        exoPlayer.repeatMode = REPEAT_MODE_ONE
    }

    override fun setDataSource(dataPath: String) {
        reset()
        val mediaItem = MediaItem.fromUri(Uri.parse(dataPath))
        exoPlayer.setMediaItem(mediaItem)
    }

    override fun prepareAsync() {
        exoPlayer.prepare()
        exoPlayer.playWhenReady = true
    }

    override fun start() {
        exoPlayer.play()
    }

    override fun pause() {
        exoPlayer.playWhenReady = false
    }

    override fun stop() {
        exoPlayer.stop()
    }

    override fun reset() {
        exoPlayer.stop()
        exoPlayer.clearMediaItems()
    }

    override fun release() {
        exoPlayer.release()
    }

    override fun setLooping(looping: Boolean) {
        this.isLooping = looping
        exoPlayer.repeatMode = if (isLooping) REPEAT_MODE_ONE else REPEAT_MODE_OFF
    }

    override fun setScreenOnWhilePlaying(onWhilePlaying: Boolean) {
    }

    override fun setSurface(surface: Surface) {
        exoPlayer.setVideoSurface(surface)
    }

    override fun getVideoInfo(): VideoInfo {
        return VideoInfo(currVideoWidth, currVideoHeight)
    }

    override fun getPlayerType(): String {
        return "ExoPlayerImpl"
    }


}