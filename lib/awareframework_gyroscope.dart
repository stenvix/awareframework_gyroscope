import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';


/// The Gyroscope measures the acceleration applied to the sensor
/// built-in into the device, including the force of gravity.
///
/// Your can initialize this class by the following code.
/// ```dart
/// var sensor = GyroscopeSensor();
/// ```
///
/// If you need to initialize the sensor with configurations,
/// you can use the following code instead of the above code.
/// ```dart
/// var config =  GyroscopeSensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
///
/// var sensor = GyroscopeSensor.init(config);
/// ```
///
/// Each sub class of AwareSensor provides the following method for controlling
/// the sensor:
/// - `start()`
/// - `stop()`
/// - `enable()`
/// - `disable()`
/// - `sync()`
/// - `setLabel(String label)`
///
/// `Stream<GyroscopeData>` allow us to monitor the sensor update
/// events as follows:
///
/// ```dart
/// sensor.onDataChanged.listen((data) {
///   print(data)
/// }
/// ```
///
/// In addition, this package support data visualization function on Cart Widget.
/// You can generate the Cart Widget by following code.
/// ```dart
/// var card = GyroscopeCard(sensor: sensor);
/// ```
class GyroscopeSensor extends AwareSensor {
  static const MethodChannel _gyroscopeMethod = const MethodChannel('awareframework_gyroscope/method');
  static const EventChannel  _gyroscopeStream  = const EventChannel('awareframework_gyroscope/event');

  static const EventChannel  _onDataChangedStream  = const EventChannel('awareframework_gyroscope/event_on_data_changed');

  static StreamController<GyroscopeData> onDataChangedStreamController = StreamController<GyroscopeData>();

  GyroscopeData data = GyroscopeData();

  /// Init Gyroscope Sensor without a configuration file
  ///
  /// ```dart
  /// var sensor = GyroscopeSensor.init(null);
  /// ```
  GyroscopeSensor():this.init(null);

  /// Init Gyroscope Sensor with GyroscopeSensorConfig
  ///
  /// ```dart
  /// var config =  GyroscopeSensorConfig();
  /// config
  ///   ..debug = true
  ///   ..frequency = 100;
  ///
  /// var sensor = GyroscopeSensor.init(config);
  /// ```
  GyroscopeSensor.init(GyroscopeSensorConfig config) : super(config){
    /// Set sensor method & event channels
    super.setMethodChannel(_gyroscopeMethod);
  }

  /// An event channel for monitoring sensor events.
  ///
  /// `Stream<GyroscopeData>` allow us to monitor the sensor update
  /// events as follows:
  ///
  /// ```dart
  /// sensor.onDataChanged.listen((data) {
  ///   print(data)
  /// }
  ///
  Stream<GyroscopeData> get onDataChanged {
    onDataChangedStreamController.close();
    onDataChangedStreamController = StreamController<GyroscopeData>();
    return onDataChangedStreamController.stream;
  }

  @override
  Future<Null> start() {
    super.getBroadcastStream(_onDataChangedStream,"on_data_changed").map(
            (dynamic event) => GyroscopeData.from(Map<String,dynamic>.from(event))
    ).listen((event){
      this.data = event;
      if (!onDataChangedStreamController.isClosed){
        onDataChangedStreamController.add(event);
      }
    });
    return super.start();
  }

  @override
  Future<Null> stop() {
    super.cancelBroadcastStream("on_data_changed");
    return super.stop();
  }

}


/// A configuration class of GyroscopeSensor
///
/// You can initialize the class by following code.
///
/// ```dart
/// var config =  GyroscopeSensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
/// ```
class GyroscopeSensorConfig extends AwareSensorConfig{
  GyroscopeSensorConfig();

  int frequency    = 5;
  double period    = 1.0;
  double threshold = 0.0;

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['frequency'] = frequency;
    map['period']    = period;
    map['threshold'] = threshold;
    return map;
  }
}


/// A data model of GyroscopeSensor
///
/// This class converts sensor data that is Map<String,dynamic> format, to a
/// sensor data object.
///
class GyroscopeData extends AwareData {
  Map<String,dynamic> source;
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  int eventTimestamp = 0;
  GyroscopeData():this.from(null);
  GyroscopeData.from(Map<String,dynamic> data):super.from(data){
    if (data != null) {
      x = data["x"];
      y = data["y"];
      z = data["z"];
      eventTimestamp = data["eventTimestamp"];
      source = data;
    }
  }

  @override
  String toString() {
    if(source != null){
      return source.toString();
    }
    return super.toString();
  }
}


///
/// A Card Widget of Gyroscope Sensor
///
/// You can generate a Cart Widget by following code.
/// ```dart
/// var card = GyroscopeCard(sensor: sensor);
/// ```
class GyroscopeCard extends StatefulWidget {
  GyroscopeCard({Key key, @required this.sensor, this.height = 250.0, this.bufferSize = 299} ) : super(key: key);

  final GyroscopeSensor sensor;
  final double height;
  final int bufferSize;

  final List<LineSeriesData> dataLine1 = List<LineSeriesData>();
  final List<LineSeriesData> dataLine2 = List<LineSeriesData>();
  final List<LineSeriesData> dataLine3 = List<LineSeriesData>();

  @override
  GyroscopeCardState createState() => new GyroscopeCardState();
}

///
/// A Card State of Gyroscope Sensor
///
class GyroscopeCardState extends State<GyroscopeCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      if(mounted) {
        setState((){
          if(event!=null){
            DateTime.fromMicrosecondsSinceEpoch(event.timestamp);
            StreamLineSeriesChart.add(data:event.x, into:widget.dataLine1, id:"x", buffer: widget.bufferSize);
            StreamLineSeriesChart.add(data:event.y, into:widget.dataLine2, id:"y", buffer: widget.bufferSize);
            StreamLineSeriesChart.add(data:event.z, into:widget.dataLine3, id:"z", buffer: widget.bufferSize);
          }
        });
      }
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }


  @override
  Widget build(BuildContext context) {
    var data = StreamLineSeriesChart.createTimeSeriesData(widget.dataLine1, widget.dataLine2, widget.dataLine3);
    return new AwareCard(
      contentWidget: SizedBox(
          height:widget.height,
          width: MediaQuery.of(context).size.width*0.8,
          child: new StreamLineSeriesChart(data),
        ),
      title: "Gyroscope",
      sensor: widget.sensor
    );
  }
}
