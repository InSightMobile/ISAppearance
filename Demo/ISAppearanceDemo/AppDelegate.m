//
//  AppDelegate.m
//  ISAppearanceDemo
//
//

#import "AppDelegate.h"
#import "ISAppearance.h"

@implementation AppDelegate

+ (void)initialize {
    [ISAppearance prepareAppearance];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[ISAppearance sharedInstance] loadAppearanceNamed:@"appearance.yaml" withMonitoringForDirectory:@"~/prj/ISAppearance/ISAppearanceDemo/"];
    [[ISAppearance sharedInstance] processAppearance];
    return YES;
}

@end
