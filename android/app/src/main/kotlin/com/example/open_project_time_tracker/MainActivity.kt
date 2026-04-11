package vonrehberg.timetracker

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "vonrehberg.timetracker.live-activity"
    private lateinit var timerNotificationService: TimerNotificationService
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        timerNotificationService = TimerNotificationService(this)
        
        android.util.Log.d("MainActivity", "Setting up method channel: $channelName")
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            android.util.Log.d("MainActivity", "Method call received: ${call.method}")
            when (call.method) {
                "startLiveActivity" -> {
                    val startTimestamp = (call.argument<Number>("startTimestamp"))?.toLong() ?: 0L
                    val title = call.argument<String>("title") ?: ""
                    val subtitle = call.argument<String>("subtitle") ?: ""
                    val tag = call.argument<String>("tag") ?: ""
                    
                    android.util.Log.d("MainActivity", "Starting notification: title=$title, subtitle=$subtitle, tag=$tag, timestamp=$startTimestamp")
                    
                    timerNotificationService.startNotification(startTimestamp, title, subtitle, tag)
                    result.success(null)
                }
                "updateLiveActivity" -> {
                    val startTimestamp = (call.argument<Number>("startTimestamp"))?.toLong() ?: 0L
                    
                    android.util.Log.d("MainActivity", "Updating notification: timestamp=$startTimestamp")
                    
                    timerNotificationService.updateNotification(startTimestamp)
                    result.success(null)
                }
                "stopLiveActivity" -> {
                    android.util.Log.d("MainActivity", "Stopping notification")
                    
                    timerNotificationService.stopNotification()
                    result.success(null)
                }
                else -> {
                    android.util.Log.w("MainActivity", "Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
}
