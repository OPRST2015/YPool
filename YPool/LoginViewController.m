//
//  LoginViewController.m
//  chatclient
//
//  Created by Natarajan Kannan on 7/15/14.
//  Copyright (c) 2014 Y.CORP.YAHOO.COM\natarajk. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/PFUser.h>
#import "SignupViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)onSignup:(id)sender;

- (IBAction)onLogin:(id)sender;

@end

@implementation LoginViewController

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

    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onSignup:(id)sender {
    
    SignupViewController * svc = [[SignupViewController alloc]init];
    
    [self presentViewController:svc animated:YES completion:nil];
    
//    PFUser *user = [PFUser user];
//    user.username = self.usernameTextField.text;
//    user.password = self.passwordTextField.text;
//    
//
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//
//            NSLog(@"succeeded sign-up");
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginStateChanged" object:nil];
//
//        } else {
//            // NSString *errorString = [error userInfo][@"error"];
//            // Show the errorString somewhere and let the user try again.
//            NSLog(@"failed sign-up., %@", error);
//        }
//    }];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)onLogin:(id)sender {
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    
    
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            NSLog(@"logged in");
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginStateChanged" object:nil];
                                        } else {
                                            NSLog(@"failed");
                                        }
                                    }];}
@end
