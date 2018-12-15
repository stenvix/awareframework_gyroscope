import 'package:test/test.dart';

import 'package:awareframework_gyroscope/awareframework_gyroscope.dart';

void main(){
  test("test sensor config", (){
    var config = GyroscopeSensorConfig();
    expect(config.debug, false);
  });

}