//
//  MapViewController.m
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/22/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

#import "MapViewController.h"
#import "StartTimeViewController.h"
#import "GoogleMapViewService.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *destinationField;
- (IBAction)onMapit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *sourceField;
- (IBAction)onContinue:(id)sender;
@property (nonatomic, strong) GoogleMapViewService *gmv;

@end


@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.gmv = [[GoogleMapViewService alloc] init];
        self.gmv.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.mapView addSubview:[self.gmv getInitialViewWithFrame:self.mapView]];
    
    /*GMSPanoramaView *panoView_ = [[GMSPanoramaView alloc] initWithFrame:self.mapView.bounds];
    [self.mapView addSubview:panoView_];
    
    [panoView_ moveNearCoordinate:CLLocationCoordinate2DMake(-33.732, 150.312)];*/
    /*    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(
     37.3533409,-122.010979);
     
     [self addWaypoint:position]; */
    
    
    // Do any additional setup after loading the view from its nib.
    /*GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
     longitude:151.20
     zoom:6];
     self.mapView_ = [GMSMapView mapWithFrame:self.mapView.bounds camera:camera];
     self.mapView_.myLocationEnabled = YES;
     self.mapView_.settings.myLocationButton = YES;
     
     [self.mapView addSubview:self.mapView_];// self.mapView_;
     
     // Creates a marker in the center of the map.
     GMSMarker *marker = [[GMSMarker alloc] init];
     marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
     marker.title = @"Sydney";
     marker.snippet = @"Australia";
     marker.map = self.mapView_;*/
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)onMapit:(id)sender {
    [self.destinationField resignFirstResponder];
    
    [self.gmv drawPathFrom:self.sourceField.text to:self.destinationField.text];
}


- (IBAction)onContinue:(id)sender {
    StartTimeViewController *svc = [[StartTimeViewController alloc] init];
    svc.selectedRoute = [self.gmv getSelectedRoute];

    [self presentViewController:svc animated:YES completion:nil];
}
@end
