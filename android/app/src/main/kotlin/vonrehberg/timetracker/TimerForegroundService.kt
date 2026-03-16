package vonrehberg.timetracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class TimerForegroundService : Service() {
    private val channelId = "timer_foreground_channel"
    private val notificationId = 1001
    
    private var startTimestampSeconds: Long = 0
    private var title: String = ""
    private var subtitle: String = ""
    private var tag: String = ""
    
    companion object {
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_UPDATE = "ACTION_UPDATE"
        
        const val EXTRA_START_TIMESTAMP = "EXTRA_START_TIMESTAMP"
        const val EXTRA_TITLE = "EXTRA_TITLE"
        const val EXTRA_SUBTITLE = "EXTRA_SUBTITLE"
        const val EXTRA_TAG = "EXTRA_TAG"
    }
    
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startTimestampSeconds = intent.getLongExtra(EXTRA_START_TIMESTAMP, 0)
                title = intent.getStringExtra(EXTRA_TITLE) ?: ""
                subtitle = intent.getStringExtra(EXTRA_SUBTITLE) ?: ""
                tag = intent.getStringExtra(EXTRA_TAG) ?: ""
                
                val notification = buildNotification()
                startForeground(notificationId, notification)
            }
            ACTION_UPDATE -> {
                startTimestampSeconds = intent.getLongExtra(EXTRA_START_TIMESTAMP, 0)
                
                val notification = buildNotification()
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(notificationId, notification)
            }
            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Active Timer",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Shows active timer with elapsed time"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)

        }
    }
    
    private fun buildNotification(): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // For chronometer: setWhen() should be the wall clock time when the timer started
        // startTimestampSeconds is Unix time in seconds
        val startTimeMillis = startTimestampSeconds * 1000L
        
        val builder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setContentTitle(title)
            .setContentText("$subtitle • $tag")
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setWhen(startTimeMillis)
            .setShowWhen(true)
            .setUsesChronometer(true)
        
        // Set chronometer to count up (not down)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder.setChronometerCountDown(false)
        }
        
        return builder.build()
    }
}
