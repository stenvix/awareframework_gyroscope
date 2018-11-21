#import "AwareframeworkGyroscopePlugin.h"
#import <awareframework_gyroscope/awareframework_gyroscope-Swift.h>

@implementation AwareframeworkGyroscopePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwareframeworkGyroscopePlugin registerWithRegistrar:registrar];
}
@end
