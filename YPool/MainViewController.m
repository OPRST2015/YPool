//
//  MainViewController.m
//  YPool
//
//  Created by Sudip Shah on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "MainViewController.h"
#import "StartTimeViewController.h"
#import "ParseQueryViewController.h"
#import <Parse/Parse.h>
#import "PassengerViewController.h"
#import "MapViewController.h"
#import "ShowRidesController.h"
#import "RoutesClient.h"

@interface MainViewController ()
- (IBAction)onDriverButton:(id)sender;
- (IBAction)onYpoolerButton:(id)sender;
- (IBAction)onLogout:(id)sender;
- (IBAction)onShowRides:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *notificationCount;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
    self.notificationCount.hidden = YES;
    [self getNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [self getNotifications];
}

- (void) getNotifications {
    RoutesClient *rc = [RoutesClient instance];
    
    [rc getPendingInviteCount:^(NSInteger count, NSError *error) {
        if (count>0) {
            self.notificationCount.hidden = NO;
            self.notificationCount.text = [NSString stringWithFormat:@"%d", count];
        } else {
            self.notificationCount.hidden = YES;
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDriverButton:(id)sender {
    // NSLog(@"I am a driver!");
    MapViewController *mvc = [[MapViewController alloc] init];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (IBAction)onYpoolerButton:(id)sender {
    // NSLog(@"I am looking for a Ypool");
//    ParseQueryViewController *parseVC = [[ParseQueryViewController alloc] init];
//    [self presentViewController:parseVC animated:YES completion:nil];
    PassengerViewController *passengerViewController = [[PassengerViewController alloc] init];
//    [self presentViewController:passengerViewController animated:YES completion:nil];
    [self.navigationController pushViewController:passengerViewController animated:YES];

}

- (IBAction)onLogout:(id)sender {

    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginStateChanged" object:nil];
}

- (IBAction)onShowRides:(id)sender {
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    ShowRidesController *ridesrc = [[ShowRidesController alloc] init];
    ridesrc.type = @"Rides";
    UINavigationController *ridesController = [[UINavigationController alloc] initWithRootViewController:ridesrc];
    //[self.navigationController pushViewController:srvc animated:YES];
    ridesController.tabBarItem.title = @"Rides";
    [ridesController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -12)];
    [ridesController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor blackColor], UITextAttributeTextColor,
                                                          [NSValue valueWithUIOffset:UIOffsetMake(0,0)], UITextAttributeTextShadowOffset,
                                                          [UIFont fontWithName:@"Helvetica" size:18.0], UITextAttributeFont, nil]
                                                forState:UIControlStateNormal];

    
    ShowRidesController *reqsrc = [[ShowRidesController alloc] init];
    reqsrc.type = @"Requests";
    UINavigationController *requestController = [[UINavigationController alloc] initWithRootViewController:reqsrc];
    requestController.tabBarItem.title = @"Requests";
    [requestController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -12)];
    [requestController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIColor blackColor], UITextAttributeTextColor,
                                            [NSValue valueWithUIOffset:UIOffsetMake(0,0)], UITextAttributeTextShadowOffset,
                                            [UIFont fontWithName:@"Helvetica" size:18.0], UITextAttributeFont, nil]
                                  forState:UIControlStateNormal];
    
    NSArray *controllers = [NSArray arrayWithObjects:ridesController, requestController, nil];
    
    tbc.viewControllers = controllers;
    
    [self.navigationController pushViewController:tbc animated:YES];
}




@end
