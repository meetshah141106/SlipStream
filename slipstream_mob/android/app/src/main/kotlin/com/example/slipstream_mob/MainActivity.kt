package com.example.slipstream_mob

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "slipstream/bluetooth"
    private val BLUETOOTH_PERMISSION_REQUEST = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "requestBluetoothPermission" -> {
                    requestBluetoothPermission()
                    result.success(true)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun requestBluetoothPermission() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {

            val permissions = arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )

            val permissionsNeeded = permissions.filter {
                ContextCompat.checkSelfPermission(
                    this,
                    it
                ) != PackageManager.PERMISSION_GRANTED
            }

            if (permissionsNeeded.isNotEmpty()) {
                ActivityCompat.requestPermissions(
                    this,
                    permissionsNeeded.toTypedArray(),
                    BLUETOOTH_PERMISSION_REQUEST
                )
            }
        }
    }
}

