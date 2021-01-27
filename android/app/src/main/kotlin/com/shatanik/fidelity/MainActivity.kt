package com.shatanik.fidelity

import android.app.SearchManager
import android.content.ComponentName
import android.content.Intent
import android.provider.AlarmClock
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
                    } else if (call.method == "setAlarm") {
                        val ok: Boolean = startAlarmClockActivity(call)
                        if (ok) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } else {
                        result.notImplemented()
                    }
                }
    }

    private fun playMusic(songName: String?) {


        val intent = Intent(Intent.ACTION_MAIN)
        intent.action = MediaStore.INTENT_ACTION_MEDIA_PLAY_FROM_SEARCH
        intent.component = ComponentName("com.spotify.music", "com.spotify.music.MainActivity")
        intent.putExtra(MediaStore.EXTRA_MEDIA_TITLE, "$songName")
        intent.putExtra(SearchManager.QUERY, "$songName")
        context.startActivity(intent)
    }

    private fun startAlarmClockActivity(call: MethodCall): Boolean {
        try {

            val i = Intent(AlarmClock.ACTION_SET_ALARM)
            i.putExtra(AlarmClock.EXTRA_HOUR, call.argument<Int>("hour"))
            i.putExtra(AlarmClock.EXTRA_MINUTES, call.argument<Int>("minute"))
            context.startActivity(i)
        } catch (e: Exception) {
            return false
        }
        return true
    }

    companion object {
        private const val CHANNEL = "com.shatanik.fidelity"
    }
}