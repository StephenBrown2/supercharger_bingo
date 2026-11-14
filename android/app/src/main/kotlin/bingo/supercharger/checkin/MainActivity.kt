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

    private companion object {
        const val BACKGROUND_REQUEST = 7301
    }
}
