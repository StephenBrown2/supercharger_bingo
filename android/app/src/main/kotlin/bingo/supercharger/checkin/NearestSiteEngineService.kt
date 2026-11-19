package bingo.supercharger.checkin

import android.app.Notification
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Location foreground service for the nearest site Live Update. It runs
 * nearestSiteMain in its own Flutter engine, so the update outlives the
 * activity's engine, which Back destroys. The Dart side replaces the
 * placeholder notification by posting under the same id.
 */
class NearestSiteEngineService : Service() {
    private var engine: FlutterEngine? = null

    override fun onBind(intent: Intent?) = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val id = intent?.getIntExtra(EXTRA_ID, 0) ?: 0
        // The placeholder shows until the first fix.
        val notification = placeholder()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(id, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(id, notification)
        }
        runningKey = intent?.getStringExtra(EXTRA_KEY)
        engine?.destroy()
        val loader = FlutterInjector.instance().flutterLoader()
        engine = FlutterEngine(applicationContext).also {
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

    private fun placeholder(): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(R.drawable.ic_stat_bolt)
            .setContentTitle("Nearest unvisited site")
            .setContentText("Finding your location…")
            .setOngoing(true)
            .setShowWhen(false)
            .build()
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
