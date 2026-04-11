package vonrehberg.timetracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import android.os.SystemClock

class TimerNotificationService(private val context: Context) {
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val channelId = "timer_notification_channel"
    private val notificationId = 1001
    
    private var startTimestamp: Long = 0
    private var title: String = ""
    private var subtitle: String = ""
    private var tag: String = ""
    
    init {
        createNotificationChannel()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Timer Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Shows ongoing timer for time tracking"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    fun startNotification(startTimestampSeconds: Long, title: String, subtitle: String, tag: String) {
        this.startTimestamp = startTimestampSeconds
        this.title = title
        this.subtitle = subtitle
        this.tag = tag
        
        val notification = buildNotification()
        notificationManager.notify(notificationId, notification)
    }
    
    fun updateNotification(startTimestampSeconds: Long) {
        this.startTimestamp = startTimestampSeconds
        
        val notification = buildNotification()
        notificationManager.notify(notificationId, notification)
    }
    
    fun stopNotification() {
        notificationManager.cancel(notificationId)
    }
    
    private fun buildNotification(): Notification {
        // Calculate elapsed time
        val currentTimeMillis = System.currentTimeMillis()
        val startTimeMillis = startTimestamp * 1000L
        val elapsedMillis = currentTimeMillis - startTimeMillis
        val elapsedSeconds = (elapsedMillis / 1000).toInt()
        
        // Format elapsed time as HH:MM:SS
        val hours = elapsedSeconds / 3600
        val minutes = (elapsedSeconds % 3600) / 60
        val seconds = elapsedSeconds % 60
        val timeString = String.format("%02d:%02d:%02d", hours, minutes, seconds)
        
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        return NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setContentTitle("$title • $timeString")
            .setContentText("$subtitle • $tag")
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }
}
