//
//  P3DAppDelegate.m
//  Present3D-Control
//
//  Created by Stephan Huber on 14.10.13.
//  Copyright (c) 2013 Stephan Huber. All rights reserved.
//

#import "P3DAppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#include "P3DAppInterface.h"
#include "IOSUtils.h"

#import "P3DRootViewController.h"
#import "P3DMenuViewController.h"


@implementation P3DAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Crashlytics startWithAPIKey:@"c21a7f3b9b7155c2dc0ac29a3a93ddba01a41289"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    NSString* bundle_path = [[NSBundle mainBundle] bundlePath];
    P3DAppInterface::instance()->addLocalFilePath(IOSUtils::toString(bundle_path));
    P3DAppInterface::instance()->addLocalFilePath(IOSUtils::getDocumentsFolder());
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/*
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL* url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if ([[url scheme] isEqualToString:@"present3d"]) {
        return YES;
    }
    
    return NO;
}
*/


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] isEqualToString:@"present3d"]) {
        
        //NSLog(@"URL: %@", url);
        
        NSString* path = [url absoluteString];
        path = [path stringByReplacingOccurrencesOfString:@"present3d" withString:@"http"];
        
        P3DRootViewController* root = (P3DRootViewController*)self.window.rootViewController;
        P3DMenuViewController* menu = (P3DMenuViewController*)root.underLeftViewController;
        [menu startReadingSequence];
        
        P3DAppInterface::instance()->readFile(IOSUtils::toString(path));
        return YES;
        
    }
    return NO;
}


@end
