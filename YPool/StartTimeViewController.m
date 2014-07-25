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
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"carpool-title.png"]];

    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    self.numberOfSeatsField.delegate = self;
    NSLog(@"%@", self.selectedRoute);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)saveRoute:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    NSString *jsonString;
    
    // save published route object
    PFObject *route = [PFObject objectWithClassName:@"publishedRoute"];
    route[@"driverUser"] = currentUser;
    route[@"startTime"] = [self.startTimePicker date];
    route[@"routeDetail"] = @"this is the route detail";
    route[@"numberOfSeats"] = @([self.numberOfSeatsField.text intValue]);
    route[@"startPlace"] = self.selectedRoute[@"legs"][0][@"start_address"];
    route[@"endPlace"] = self.selectedRoute[@"legs"][0][@"end_address"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.selectedRoute
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
       jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    route[@"routeDetail"] = jsonString;

    
    [route saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // success
        NSLog(@"saved route");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RoutePublished" object:nil];
    }];
    
    NSString *startLatString = self.selectedRoute[@"legs"][0][@"start_location"][@"lat"];
    float startLat = [startLatString floatValue];
    NSString *startLongString = self.selectedRoute[@"legs"][0][@"start_location"][@"lng"];
    float startLong = [startLongString floatValue];
    NSString *endLatString = self.selectedRoute[@"legs"][0][@"end_location"][@"lat"];
    float endLat = [endLatString floatValue];
    NSString *endLongString = self.selectedRoute[@"legs"][0][@"end_location"][@"lng"];
    float endLong = [endLongString floatValue];

    
    // save routeEndPoint object (to ease querying)
    PFObject *routeStartPoint = [PFObject objectWithClassName:@"geoPoints"];
    PFGeoPoint *startPoint = [PFGeoPoint geoPointWithLatitude:startLat longitude:startLong];
    routeStartPoint[@"routeId"] = route;
    routeStartPoint[@"geoPoint"] = startPoint;
    routeStartPoint[@"startPoint"] = @(YES);
    routeStartPoint[@"endPoint"] = @(NO);
    
    [routeStartPoint saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // save routeEndPoint object (to ease querying)
        PFObject *routeEndPoint = [PFObject objectWithClassName:@"geoPoints"];
        PFGeoPoint *endPoint = [PFGeoPoint geoPointWithLatitude:endLat longitude:endLong];
        
        routeEndPoint[@"routeId"] = route;
        routeEndPoint[@"geoPoint"] = endPoint;
        routeEndPoint[@"startPoint"] = @(NO);
        routeEndPoint[@"endPoint"] = @(YES);
        
        [routeEndPoint saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // success
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Route Saved Successfully"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];

    }];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


@end
