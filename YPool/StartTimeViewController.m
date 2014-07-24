//
//  StartTimeViewController.m
//  YPool
//
//  Created by Sudip Shah on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "StartTimeViewController.h"
#import <Parse/Parse.h>

@interface StartTimeViewController ()
- (IBAction)saveRoute:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UITextField *numberOfSeatsField;

@end

@implementation StartTimeViewController

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
    self.numberOfSeatsField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (IBAction)saveRoute:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    // save published route object
    PFObject *route = [PFObject objectWithClassName:@"publishedRoute"];
    route[@"driverUser"] = currentUser;
    route[@"startTime"] = [self.startTimePicker date];
    route[@"routeDetail"] = @"this is the route detail";
    route[@"numberOfSeats"] = @([self.numberOfSeatsField.text intValue]);
    PFGeoPoint *startPoint = [PFGeoPoint geoPointWithLatitude:37.37 longitude:-122.03];
    route[@"startPoint"] = startPoint;
    route[@"startPlace"] = @"Sunnyvale, CA";
    route[@"endPlace"] = @"Mountain View, CA";
    
    [route saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // success
        NSLog(@"saved route");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RoutePublished" object:nil];
    }];
    
    // save routeEndPoint object (to ease querying)
    PFObject *routeEndPoint = [PFObject objectWithClassName:@"routeEndPoint"];
    
    routeEndPoint[@"routeId"] = route;
    PFGeoPoint *endPoint = [PFGeoPoint geoPointWithLatitude:37.38 longitude:-122.08];
    routeEndPoint[@"endPoint"] = endPoint;
    [routeEndPoint saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // success
        NSLog(@"saved end point");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EndPointPublished" object:nil];
    }];
    
}

@end
