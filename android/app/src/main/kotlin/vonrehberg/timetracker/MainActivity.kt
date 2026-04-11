package vonrehberg.timetracker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build

class MainActivity: FlutterActivity() {
    private val channelName = "vonrehberg.timetracker.live-activity"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLiveActivity" -> {
                    val startTimestamp = (call.argument<Number>("startTimestamp"))?.toLong() ?: 0L
                    val title = call.argument<String>("title") ?: ""
                    val subtitle = call.argument<String>("subtitle") ?: ""
                    val tag = call.argument<String>("tag") ?: ""
                    
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_START
                        putExtra(TimerForegroundService.EXTRA_START_TIMESTAMP, startTimestamp)
                        putExtra(TimerForegroundService.EXTRA_TITLE, title)
                        putExtra(TimerForegroundService.EXTRA_SUBTITLE, subtitle)
                        putExtra(TimerForegroundService.EXTRA_TAG, tag)
                    }
                    
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "updateLiveActivity" -> {
                    val startTimestamp = (call.argument<Number>("startTimestamp"))?.toLong() ?: 0L
                    
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_UPDATE
                        putExtra(TimerForegroundService.EXTRA_START_TIMESTAMP, startTimestamp)
                    }
                    startService(intent)
                    result.success(null)
                }
                "stopLiveActivity" -> {
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
