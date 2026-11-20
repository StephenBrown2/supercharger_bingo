package bingo.supercharger.checkin

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Location foreground service for the nearest site Live Update. It runs
 * nearestSiteMain in its own Flutter engine, so the update outlives the
 * activity's engine, which Back destroys. Dart works out the nearest site
 * and sends it here; this builds the notification, because Android 17's
 * MetricStyle (the large distance on the right) needs native code.
 */
class NearestSiteEngineService : Service() {
    private var engine: FlutterEngine? = null
    private var notificationId = 0

    override fun onBind(intent: Intent?) = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        notificationId = intent?.getIntExtra(EXTRA_ID, 0) ?: 0
        // The placeholder shows until the first fix.
        val notification = build(Update(title = "Nearest unvisited site", body = "Finding your location…"))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(notificationId, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(notificationId, notification)
        }
        runningKey = intent?.getStringExtra(EXTRA_KEY)
        engine?.destroy()
        val loader = FlutterInjector.instance().flutterLoader()
        engine = FlutterEngine(applicationContext).also {
            MethodChannel(it.dartExecutor.binaryMessenger, "supercharger_bingo/live_update")
                .setMethodCallHandler { call, result ->
                    if (call.method != "show") return@setMethodCallHandler result.notImplemented()
                    show(Update.from(call))
                    result.success(null)
                }
            it.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "package:supercharger_bingo/services/nearest_site_service.dart",
                    "nearestSiteMain",
                ),
            )
        }
        // Sticky would restart with no intent after a process kill.
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        runningKey = null
        engine?.destroy()
        engine = null
        super.onDestroy()
    }

    /** Replaces the foreground notification, which keeps its service flag. */
    private fun show(update: Update) {
        if (!NotificationManagerCompat.from(this).areNotificationsEnabled()) return
        @Suppress("MissingPermission")
        NotificationManagerCompat.from(this).notify(notificationId, build(update))
    }

    private fun build(update: Update): Notification {
        val icon = resources.getIdentifier(update.icon, "drawable", packageName)
            .takeIf { it != 0 } ?: R.drawable.ic_stat_bolt
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(icon)
            .setContentTitle(update.title)
            .setContentText(update.body)
            .setContentIntent(openApp(update.siteId, checkIn = false))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setShowWhen(false)
            .setCategory(NotificationCompat.CATEGORY_NAVIGATION)
            .setRequestPromotedOngoing(true)
        update.chip?.let { builder.setShortCriticalText(it) }
        if (update.metric != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.CINNAMON_BUN) {
            builder.setStyle(
                NotificationCompat.MetricStyle()
                    .addMetric(
                        NotificationCompat.Metric(
                            NotificationCompat.Metric.FixedText(update.metric),
                            update.metricLabel ?: "",
                        ),
                    )
                    .setCriticalMetric(0),
            )
        }
        if (update.siteId != null && update.checkIn) {
            builder.addAction(0, "Check In", openApp(update.siteId, checkIn = true))
        }
        if (update.siteId != null && update.latitude != null && update.longitude != null) {
            builder.addAction(0, "Navigate", navigate(update))
        }
        return builder.build()
    }

    /** Opens the app on the site, the way a tap on any site alert does, or
     *  straight into checking in there. */
    private fun openApp(siteId: Int?, checkIn: Boolean): PendingIntent {
        val intent = Intent(this, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            .putExtra(MainActivity.EXTRA_CHECK_IN, checkIn)
        siteId?.let { intent.putExtra(MainActivity.EXTRA_SITE_ID, it) }
        return PendingIntent.getActivity(
            this,
            // Separate request codes keep each intent's extras.
            if (checkIn) 2 else 0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    /** Same geo: link as the app's Navigate button, so Android's picker applies. */
    private fun navigate(update: Update): PendingIntent {
        val label = Uri.encode("Tesla Supercharger ${update.title}")
        val uri = Uri.parse("geo:${update.latitude},${update.longitude}?q=${update.latitude},${update.longitude}($label)")
        return PendingIntent.getActivity(
            this,
            1,
            Intent(Intent.ACTION_VIEW, uri),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private data class Update(
        val title: String,
        val body: String,
        val chip: String? = null,
        val icon: String = "ic_stat_bolt",
        val metric: String? = null,
        val metricLabel: String? = null,
        val siteId: Int? = null,
        val checkIn: Boolean = false,
        val latitude: Double? = null,
        val longitude: Double? = null,
    ) {
        companion object {
            fun from(call: MethodCall) = Update(
                title = call.argument<String>("title")!!,
                body = call.argument<String>("body")!!,
                chip = call.argument("chip"),
                icon = call.argument<String>("icon") ?: "ic_stat_bolt",
                metric = call.argument("metric"),
                metricLabel = call.argument("metricLabel"),
                siteId = call.argument("siteId"),
                checkIn = call.argument<Boolean>("checkIn") ?: false,
                latitude = call.argument("latitude"),
                longitude = call.argument("longitude"),
            )
        }
    }

    companion object {
        private const val CHANNEL_ID = "nearest_unvisited"
        private const val EXTRA_ID = "id"
        private const val EXTRA_KEY = "key"

        /** Settings the running engine started with, or null when stopped. */
        private var runningKey: String? = null

        /** Starts the update, or restarts it when [key] changed. Opening
         *  the app again with the same settings leaves it alone. */
        fun start(context: Context, id: Int, key: String) {
            if (key == runningKey) return
            val intent = Intent(context, NearestSiteEngineService::class.java)
                .putExtra(EXTRA_ID, id)
                .putExtra(EXTRA_KEY, key)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, NearestSiteEngineService::class.java))
        }
    }
}
