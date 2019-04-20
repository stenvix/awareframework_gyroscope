package com.awareframework.gyroscope.awareframeworkgyroscope

import android.content.Context
import com.awareframework.android.core.db.Engine
import com.awareframework.android.sensor.gyroscope.GyroscopeSensor
import com.awareframework.android.sensor.gyroscope.model.GyroscopeData
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*
import kotlin.collections.HashMap

class AwareframeworkGyroscopePlugin(var context: Context) : MethodCallHandler, EventChannel.StreamHandler {
    var listeners: LinkedList<EventChannel.EventSink> = LinkedList()
    var observer: GyroscopeObserver = GyroscopeObserver(listeners)

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            var instance = AwareframeworkGyroscopePlugin(registrar.context())
            MethodChannel(registrar.messenger(), "awareframework_gyroscope/method").setMethodCallHandler(instance)
            EventChannel(registrar.messenger(), "awareframework_gyroscope/event_on_data_changed").setStreamHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "start" -> start(call, result)
            "stop" -> stop(result)
            else -> result.notImplemented()
        }
    }

    private fun start(call: MethodCall, result: Result) {
        GyroscopeSensor.start(context, getConfig(call))
        result.success(true)
    }

    private fun stop(result: Result) {
        GyroscopeSensor.stop(context)
        result.success(true);
    }

    override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
        listeners.add(sink)
    }

    override fun onCancel(p0: Any?) {}


    private fun getConfig(call: MethodCall): GyroscopeSensor.Config {
        var frequency = call.argument<Int>("frequency")
        var debug = call.argument<Boolean>("debug")
        var period = call.argument<Double>("period")
        var threshold = call.argument<Double>("threshold")
        var label = call.argument<String>("label")
        var enabled = call.argument<Boolean>("enabled")
        var dbPath = call.argument<String>("dbPath")

        return GyroscopeSensor.Config().apply {
            if (frequency != null) this.interval = frequency
            if (threshold != null) this.threshold = threshold
            if (period != null) this.period = period.toFloat()
            if (label != null) this.label = label
            if (dbPath != null) this.dbPath = dbPath
            if (debug != null) this.debug = debug
            if (enabled != null) this.enabled = enabled
            this.sensorObserver = observer
            this.dbType = Engine.DatabaseType.NONE
        }
    }
}

class GyroscopeObserver(var listeners: List<EventChannel.EventSink>) : GyroscopeSensor.Observer {
    override fun onDataChanged(data: GyroscopeData) {
        var map = HashMap<String, Any>()
        map["x"] = data.x
        map["y"] = data.y
        map["z"] = data.z
        for (sink in listeners) {
            sink.success(map);
        }
    }
}
