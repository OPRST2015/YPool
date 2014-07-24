//
//  SignupViewController.m
//  YPool
//
//  Created by Sudip Shah on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/PFUser.h>

@interface SignupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

- (IBAction)onSignUp:(id)sender;

@end

@implementation SignupViewController

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
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSignUp:(id)sender {

    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    user[@"name"] = self.nameTextField.text;
    user[@"phone"] = self.phoneTextField.text;
    
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            NSLog(@"succeeded sign-up");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoginStateChanged" object:nil];
            
        } else {
            // NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            NSLog(@"failed sign-up., %@", error);
        }
    }];
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}
@end
