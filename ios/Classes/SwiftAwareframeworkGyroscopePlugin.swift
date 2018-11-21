import Flutter
import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_gyroscope
import com_awareframework_ios_sensor_core
import awareframework_core

public class SwiftAwareframeworkGyroscopePlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler, GyroscopeObserver{

    var gyroscopeSensor:GyroscopeSensor?

    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        if self.sensor == nil {
            if let config = call.arguments as? Dictionary<String,Any>{
                let json = JSON.init(config)
                self.gyroscopeSensor = GyroscopeSensor.init(GyroscopeSensor.Config(json))
            }else{
                self.gyroscopeSensor = GyroscopeSensor.init(GyroscopeSensor.Config())
            }
            self.gyroscopeSensor?.CONFIG.sensorObserver = self
            return self.gyroscopeSensor
        }else{
            return nil
        }
    }

    public override init() {
        super.init()
        super.initializationCallEventHandler = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        // add own channel
        super.setChannels(with: registrar,
                          instance: SwiftAwareframeworkGyroscopePlugin(),
                          methodChannelName: "awareframework_gyroscope/method",
                          eventChannelName: "awareframework_gyroscope/event")

    }

    public func onDataChanged(data: GyroscopeData) {
        for handler in self.streamHandlers {
            if handler.eventName == "on_data_changed" {
                handler.eventSink(data.toDictionary())
            }
        }
    }
}
