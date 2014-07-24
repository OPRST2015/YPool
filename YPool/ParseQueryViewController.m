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

    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:37.35 longitude:-121.96];
    [query whereKey:@"startPoint" nearGeoPoint:userGeoPoint withinMiles:10.0];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"results: %@", objects);
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
