//
//  AppDelegate.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 04/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "AppDelegate.h"
#import "XTCoreData.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    /**
     *  During development print to console
     */
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
#else
    /**
     *  Only print on Apple System Logs if on production
     */
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
#endif
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /**
     *  Save core data when app enter background mode
     */
    [[XTCoreData sharedInstance] saveContext];    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /**
     *  Save core data before terminate
     */
    [[XTCoreData sharedInstance] saveContext];
}


@end
