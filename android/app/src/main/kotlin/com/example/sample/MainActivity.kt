package com.example.sample

import android.annotation.SuppressLint
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.SigningInfo
import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import org.json.simple.JSONObject

@Suppress("DEPRECATION")
class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        if (VERSION.SDK_INT >= VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val flutterChannel = "flutter.native.dev/info"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, flutterChannel).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            when (call.method) {
                "getBatteryLevel" -> senseBatteryLevel(result)
                "getDeviceInfo" -> senseDeviceStatus(result)
                "getPackageInfo" -> sensePackageInfo(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun sensePackageInfo(result: Result) {
        val packageManager = applicationContext!!.packageManager
        val info = packageManager.getPackageInfo(applicationContext!!.packageName, 0)
        val buildSignature = getBuildSignature(packageManager)
        val infoMap = HashMap<String, String>()
        infoMap.apply {
            put("appName", info.applicationInfo.loadLabel(packageManager).toString())
            put("packageName", applicationContext!!.packageName)
            put("version", info.versionName)
            put("buildNumber", getLongVersionCode(info).toString())
            if (buildSignature != null) put("buildSignature", buildSignature)
        }.also { resultingMap ->
            result.success(resultingMap)
        }
    }

    @SuppressLint("ObsoleteSdkInt")
    private fun senseBatteryLevel(result: Result) {
        val batteryLevel: Int = if (VERSION.SDK_INT < VERSION_CODES.LOLLIPOP) {
            val intent =
                ContextWrapper(applicationContext)
                    .registerReceiver(
                        null,
                        IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                    )
            intent!!.getIntExtra(
                BatteryManager.EXTRA_LEVEL,
                -1
            ) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        } else {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        }
        if (batteryLevel != -1) result.success(batteryLevel) else {
            result.error("UNAVAILABLE", "Battery level not available.", null)
        }
    }

    private fun senseDeviceStatus(result: Result) {
        val build: MutableMap<String, Any> = HashMap()
        build["board"] = Build.BOARD
        build["bootloader"] = Build.BOOTLOADER
        build["brand"] = Build.BRAND
        build["device"] = Build.DEVICE
        build["display"] = Build.DISPLAY
        build["fingerprint"] = Build.FINGERPRINT
        build["hardware"] = Build.HARDWARE
        build["host"] = Build.HOST
        build["id"] = Build.ID
        build["manufacturer"] = Build.MANUFACTURER
        build["model"] = Build.MODEL
        build["product"] = Build.PRODUCT
        build["tags"] = Build.TAGS
        build["type"] = Build.TYPE
        val version: MutableMap<String, Any> = HashMap()
        if (VERSION.SDK_INT >= VERSION_CODES.M) {
            version["baseOS"] = VERSION.BASE_OS
            version["previewSdkInt"] = VERSION.PREVIEW_SDK_INT
            version["securityPatch"] = VERSION.SECURITY_PATCH
        }
        version["codename"] = VERSION.CODENAME
        version["incremental"] = VERSION.INCREMENTAL
        version["release"] = VERSION.RELEASE
        version["sdkInt"] = VERSION.SDK_INT
        build["version"] = version
        println(build)
        result.success(build)
    }

    @SuppressLint("PackageManagerGetSignatures")
    private fun getBuildSignature(pm: PackageManager): String? {
        return try {
            if (VERSION.SDK_INT >= VERSION_CODES.P) {
                val packageInfo: PackageInfo = pm.getPackageInfo(
                    applicationContext!!.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
                val signingInfo: SigningInfo = packageInfo.signingInfo ?: return null

                if (signingInfo.hasMultipleSigners()) {
                    signatureToSha1(signingInfo.apkContentsSigners.first().toByteArray())
                } else {
                    signatureToSha1(signingInfo.signingCertificateHistory.first().toByteArray())
                }
            } else {
                val packageInfo = pm.getPackageInfo(
                    applicationContext!!.packageName,
                    PackageManager.GET_SIGNATURES
                )
                val signatures = packageInfo.signatures

                if (signatures.isNullOrEmpty() || packageInfo.signatures.first() == null) {
                    null
                } else {
                    signatureToSha1(signatures.first().toByteArray())
                }
            }
        } catch (e: PackageManager.NameNotFoundException) {
            null
        } catch (e: NoSuchAlgorithmException) {
            null
        }
    }

    private fun getLongVersionCode(info: PackageInfo): Long {
        return when {
            VERSION.SDK_INT >= VERSION_CODES.P -> info.longVersionCode
            else -> info.versionCode.toLong()
        }
    }
}
