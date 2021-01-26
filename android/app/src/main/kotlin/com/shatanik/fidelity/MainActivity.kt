package com.shatanik.fidelity

import android.app.SearchManager
import android.content.ComponentName
import android.content.Intent
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    if (call.method == "playMusic") {
                        playMusic(call.argument<String>("song"))
                    } else {
                        result.notImplemented()
                    }
                }
    }

    private fun playMusic(songName: String?) {

        val intent = Intent(Intent.ACTION_MAIN)
        intent.action = MediaStore.INTENT_ACTION_MEDIA_PLAY_FROM_SEARCH
        intent.component = ComponentName("com.spotify.music", "com.spotify.music.MainActivity")
        intent.putExtra(SearchManager.QUERY, songName)
        context.startActivity(intent)
    }

    companion object {
        private const val CHANNEL = "com.shatanik.fidelity/playMusic"
    }
}