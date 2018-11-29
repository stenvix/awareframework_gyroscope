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
    super.setMethodChannel(_gyroscopeMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onDataChanged {
     return super.getBroadcastStream(_gyroscopeStream,"on_data_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }

  @override
  void cancelAllEventChannels() {
    super.cancelBroadcastStream("on_data_changed");
  }

}

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

/// Make an AwareWidget
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


class GyroscopeCardState extends State<GyroscopeCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          StreamLineSeriesChart.add(data:event['x'], into:widget.dataLine1, id:"x", buffer: widget.bufferSize);
          StreamLineSeriesChart.add(data:event['y'], into:widget.dataLine2, id:"y", buffer: widget.bufferSize);
          StreamLineSeriesChart.add(data:event['z'], into:widget.dataLine3, id:"z", buffer: widget.bufferSize);
        }
      });
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
