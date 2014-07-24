//
//  MainViewController.m
//  YPool
//
//  Created by Sudip Shah on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

@interface MainViewController ()
- (IBAction)onDriverButton:(id)sender;
- (IBAction)onYpoolerButton:(id)sender;
- (IBAction)onLogout:(id)sender;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDriverButton:(id)sender {
    
    NSLog(@"I am a driver!");
}

- (IBAction)onYpoolerButton:(id)sender {
    
    NSLog(@"I am looking for a Ypool");
}

- (IBAction)onLogout:(id)sender {

    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginStateChanged" object:nil];
}



@end
