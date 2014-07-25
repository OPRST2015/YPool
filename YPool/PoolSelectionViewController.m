//
//  PoolSelectionViewController.m
//  YPool
//
//  Created by Carl Baltrunas on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "PoolSelectionViewController.h"
#import "GoogleMapViewService.h"
#import "RoutesClient.h"

@interface PoolSelectionViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *seatText;
@property (weak, nonatomic) IBOutlet UILabel *phoneText;
@property (weak, nonatomic) IBOutlet UILabel *startTimeText;
- (IBAction)onNextButton:(id)sender;

@property (nonatomic, strong) GoogleMapViewService *gmv;

@end

@implementation PoolSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.gmv = [[GoogleMapViewService alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"carpool-title.png"]];
    
    self.nameText.text = self.selectedPool[@"name"];
    self.phoneText.text = self.selectedPool[@"phone"];
    self.startTimeText.text = self.selectedPool[@"time"];
    self.seatText.text = self.selectedPool[@"seats"];
    
    [self.mapView addSubview:[self.gmv getInitialViewWithFrame:self.mapView]];
    
    [self.gmv setRoute:self.selectedPool[@"rawRoute"]];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onNextButton:(id)sender {
    
    RoutesClient *routesClient = [RoutesClient instance];
    [routesClient postNewRequest:self.selectedPool[@"routeObject"] callback:^(BOOL succeeded, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Submitted!"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RoutePublished" object:nil];
    }];
    
    
}
@end
