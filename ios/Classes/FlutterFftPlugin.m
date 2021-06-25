#import "FlutterFftPlugin.h"
#if __has_include(<flutter_fft/flutter_fft-Swift.h>)
#import <flutter_fft/flutter_fft-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_fft-Swift.h"
#endif

@implementation FlutterFftPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterFftPlugin registerWithRegistrar:registrar];
}
@end
