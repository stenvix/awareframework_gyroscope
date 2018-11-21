import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';

/// init sensor
class GyroscopeSensor extends AwareSensorCore {
  static const MethodChannel _gyroscopeMethod = const MethodChannel('awareframework_gyroscope/method');
  static const EventChannel  _gyroscopeStream  = const EventChannel('awareframework_gyroscope/event');

  /// Init Gyroscope Sensor with GyroscopeSensorConfig
  GyroscopeSensor(GyroscopeSensorConfig config):this.convenience(config);
  GyroscopeSensor.convenience(config) : super(config){
    /// Set sensor method & event channels
    super.setSensorChannels(_gyroscopeMethod, _gyroscopeStream);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onDataChanged {
     return super.receiveBroadcastStream("on_data_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }
}

class GyroscopeSensorConfig extends AwareSensorConfig{
  GyroscopeSensorConfig();

  /// TODO

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// Make an AwareWidget
class GyroscopeCard extends StatefulWidget {
  GyroscopeCard({Key key, @required this.sensor}) : super(key: key);

  GyroscopeSensor sensor;

  @override
  GyroscopeCardState createState() => new GyroscopeCardState();
}


class GyroscopeCardState extends State<GyroscopeCard> {

  List<LineSeriesData> dataLine1 = List<LineSeriesData>();
  List<LineSeriesData> dataLine2 = List<LineSeriesData>();
  List<LineSeriesData> dataLine3 = List<LineSeriesData>();
  int bufferSize = 299;

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          StreamLineSeriesChart.add(data:event['x'], into:dataLine1, id:"x", buffer: bufferSize);
          StreamLineSeriesChart.add(data:event['y'], into:dataLine2, id:"y", buffer: bufferSize);
          StreamLineSeriesChart.add(data:event['z'], into:dataLine3, id:"z", buffer: bufferSize);
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }


  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          height:250.0,
          width: MediaQuery.of(context).size.width*0.8,
          child: new StreamLineSeriesChart(StreamLineSeriesChart.createTimeSeriesData(dataLine1, dataLine2, dataLine3)),
        ),
      title: "Gyroscope",
      sensor: widget.sensor
    );
  }

}
