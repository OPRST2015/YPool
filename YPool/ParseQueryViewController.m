//
//  ParseQueryViewController.m
//  YPool
//
//  Created by Natarajan Kannan on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "ParseQueryViewController.h"
#import <Parse/Parse.h>

@interface ParseQueryViewController ()

@end

@implementation ParseQueryViewController

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
    
    PFQuery *query = [PFQuery queryWithClassName:@"publishedRoute"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];

    PFGeoPoint *userStartGeoPoint = [PFGeoPoint geoPointWithLatitude:37.35 longitude:-121.96];
    PFGeoPoint *userEndGeoPoint = [PFGeoPoint geoPointWithLatitude:37.38 longitude:-122.08];
    [query whereKey:@"startPoint" nearGeoPoint:userStartGeoPoint withinMiles:5.0];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"results: %@", objects);
            PFQuery *endPointQuery = [PFQuery queryWithClassName:@"routeEndPoint"];
            [endPointQuery whereKey:@"endPoint" nearGeoPoint:userEndGeoPoint withinMiles:5.0];
            [endPointQuery whereKey:@"routeId" containedIn:objects];
            
            NSArray *allObjects = [endPointQuery findObjects];
            NSLog(@"all objects %@", allObjects);
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
