package bingo.supercharger.checkin

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.hardware.GeomagneticField
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs

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
        // The new engine starts the compass again if its settings want it.
        stopHeading()
        engine?.destroy()
        val loader = FlutterInjector.instance().flutterLoader()
        engine = FlutterEngine(applicationContext).also {
            channel = MethodChannel(it.dartExecutor.binaryMessenger, "supercharger_bingo/live_update").apply {
                setMethodCallHandler { call, result ->
                    when (call.method) {
                        "show" -> show(Update.from(call))
                        "watchHeading" -> watchHeading(
                            call.argument<Double>("latitude")!!,
                            call.argument<Double>("longitude")!!,
                        )
                        else -> return@setMethodCallHandler result.notImplemented()
                    }
                    result.success(null)
                }
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

    /** Starts the compass on the first call. Each call updates the magnetic
     *  declination for the user's position, so headings are from true north
     *  like GPS bearings. */
    private fun watchHeading(latitude: Double, longitude: Double) {
        declination = GeomagneticField(
            latitude.toFloat(), longitude.toFloat(), 0f, System.currentTimeMillis(),
        ).declination
        if (watchingHeading) return
        val sensors = getSystemService(SensorManager::class.java)
        val sensor = sensors.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) ?: return
        watchingHeading = sensors.registerListener(compass, sensor, SensorManager.SENSOR_DELAY_UI)
    }

    private var channel: MethodChannel? = null
    private var watchingHeading = false
    private var declination = 0f
    private var sentHeading: Float? = null

    /** Sends the heading of the phone's top edge while it lies within 35
     *  degrees of flat, and null when tilted. Small turns are skipped, since
     *  the arrow only has eight directions. */
    private val compass = object : SensorEventListener {
        private val rotation = FloatArray(9)
        private val orientation = FloatArray(3)

        override fun onSensorChanged(event: SensorEvent) {
            SensorManager.getRotationMatrixFromVector(rotation, event.values)
            SensorManager.getOrientation(rotation, orientation)
            val pitch = Math.toDegrees(orientation[1].toDouble())
            val roll = Math.toDegrees(orientation[2].toDouble())
            val flat = abs(pitch) < FLAT_DEGREES && abs(roll) < FLAT_DEGREES
            val heading = if (flat) {
                ((Math.toDegrees(orientation[0].toDouble()) + declination + 360) % 360).toFloat()
            } else {
                null
            }
            val last = sentHeading
            if (heading == null && last == null) return
            if (heading != null && last != null) {
                val turn = abs(((heading - last + 540) % 360) - 180)
                if (turn < MIN_TURN_DEGREES) return
            }
            sentHeading = heading
            channel?.invokeMethod("heading", heading?.toDouble())
        }

        override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}
    }

    private fun stopHeading() {
        if (watchingHeading) getSystemService(SensorManager::class.java).unregisterListener(compass)
        watchingHeading = false
        sentHeading = null
    }

    override fun onDestroy() {
        stopHeading()
        channel = null
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
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_bolt)
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
        // Same order as the site sheet: Navigate, then Check In.
        if (update.siteId != null && update.latitude != null && update.longitude != null) {
            builder.addAction(0, "Navigate", navigate(update))
        }
        if (update.siteId != null && update.checkIn) {
            builder.addAction(0, "Check In", openApp(update.siteId, checkIn = true))
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
        private const val FLAT_DEGREES = 35.0
        private const val MIN_TURN_DEGREES = 5f

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
