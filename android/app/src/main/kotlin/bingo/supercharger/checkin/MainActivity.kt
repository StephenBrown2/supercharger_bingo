package bingo.supercharger.checkin

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingBackground: MethodChannel.Result? = null
    private var nearestSite: MethodChannel? = null

    // Android 11+ ignores a background location request sent together with
    // the foreground ones, which is what geolocator does. Ask for it alone.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "supercharger_bingo/location")
            .setMethodCallHandler { call, result ->
                if (call.method != "requestBackgroundLocation") {
                    result.notImplemented()
                } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    result.success(true)
                } else {
                    pendingBackground?.success(false)
                    pendingBackground = result
                    requestPermissions(
                        arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                        BACKGROUND_REQUEST,
                    )
                }
            }
        nearestSite = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "supercharger_bingo/nearest_site").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> NearestSiteEngineService.start(
                        this@MainActivity,
                        call.argument<Int>("id")!!,
                        call.argument<String>("key")!!,
                    )
                    "stop" -> NearestSiteEngineService.stop(this@MainActivity)
                    // A Live Update tap that launched the app, read once.
                    "takeLaunchSite" -> return@setMethodCallHandler result.success(takeSite(intent))
                    else -> return@setMethodCallHandler result.notImplemented()
                }
                result.success(null)
            }
        }
        // Hands a site to whichever navigation app the user picks: Google
        // Maps, Waze, ABRP and the Tesla app all open geo: links. Android's
        // own picker offers "Always", so it is one tap after the first time.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "supercharger_bingo/navigate")
            .setMethodCallHandler { call, result ->
                if (call.method != "navigate") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val lat = call.argument<Double>("latitude")
                val lon = call.argument<Double>("longitude")
                val label = Uri.encode(call.argument<String>("label") ?: "")
                val uri = Uri.parse("geo:$lat,$lon?q=$lat,$lon($label)")
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, uri))
                    result.success(true)
                } catch (_: ActivityNotFoundException) {
                    result.success(false)
                }
            }
    }

    // A Live Update tap while the app is open.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        takeSite(intent)?.let { nearestSite?.invokeMethod("openSite", it) }
    }

    private fun takeSite(intent: Intent?): Int? {
        if (intent?.hasExtra(EXTRA_SITE_ID) != true) return null
        val siteId = intent.getIntExtra(EXTRA_SITE_ID, 0)
        intent.removeExtra(EXTRA_SITE_ID)
        return siteId
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != BACKGROUND_REQUEST) return
        pendingBackground?.success(
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED,
        )
        pendingBackground = null
    }

    companion object {
        private const val BACKGROUND_REQUEST = 7301
        const val EXTRA_SITE_ID = "nearest_site_id"
    }
}
