//
//  TDLAppDelegate.m
//  YPool
//
//  Created by Sudip Shah on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "TDLAppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>


@implementation TDLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    [Parse setApplicationId:@"ttpedmQfBzcXueernRefpYjuT1zsbkov8hTE1GZS"
                  clientKey:@"rLG4YXRDkZ3WUBZ2F1kfiok1pgY9ZziCh5xzdauY"];
    
    
    [self selectRootViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectRootViewController) name:@"UserLoginStateChanged" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectRootViewController) name:@"RoutePublished" object:nil];
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
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

- (void) selectRootViewController {
    PFUser *currentUser = [PFUser currentUser];
    
    
    if (currentUser) {
        self.window.rootViewController = [[MainViewController alloc] init];
        
    } else {
        self.window.rootViewController = [[LoginViewController alloc] init];
    }
}

@end
