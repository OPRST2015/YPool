//
//  MapViewController.m
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/22/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

#import "MapViewController.h"
#import "MDDirectionService.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"
#import "StartTimeViewController.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (nonatomic, strong) GMSMapView *mapView_;
@property (nonatomic, strong) NSMutableArray *waypoints_;
@property (nonatomic, strong) NSMutableArray *waypointStrings_;
@property (weak, nonatomic) IBOutlet UITextField *destinationField;
- (IBAction)onMapit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *sourceField;
@property (nonatomic, strong) NSMutableArray *paths;
- (IBAction)onContinue:(id)sender;
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, assign) NSInteger selectedIndex;

@end


@implementation MapViewController

@synthesize gs;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.paths = [[NSMutableArray alloc]init];
        self.routes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    gs = [[GCGeocodingService alloc] init];
    
    self.waypoints_ = [[NSMutableArray alloc]init];
    self.waypointStrings_ = [[NSMutableArray alloc]init];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.3533409
                                                            longitude:-122.010979
                                                                 zoom:13];
    self.mapView_ = [GMSMapView mapWithFrame:self.mapView.bounds camera:camera];
    self.mapView_.delegate = self;
    //self.view = self.mapView_;
    [self.mapView addSubview:self.mapView_];
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

/*- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:
 (CLLocationCoordinate2D)coordinate {
 
 CLLocationCoordinate2D position = CLLocationCoordinate2DMake(
 coordinate.latitude,
 coordinate.longitude);
 GMSMarker *marker = [GMSMarker markerWithPosition:position];
 marker.map = self.mapView_;
 [self.waypoints_ addObject:marker];
 NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
 coordinate.latitude,coordinate.longitude];
 [self.waypointStrings_ addObject:positionString];
 if([self.waypoints_ count]>1){
 NSString *sensor = @"false";
 NSArray *parameters = [NSArray arrayWithObjects:sensor, self.waypointStrings_,
 nil];
 NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
 NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters
 forKeys:keys];
 MDDirectionService *mds=[[MDDirectionService alloc] init];
 SEL selector = @selector(addDirections:);
 [mds setDirectionsQuery:query
 withSelector:selector
 withDelegate:self];
 }
 }*/

- (void) addWaypoint:(CLLocationCoordinate2D) position {
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.map = self.mapView_;
    [self.waypoints_ addObject:marker];
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                position.latitude,position.longitude];
    [self.waypointStrings_ addObject:positionString];
}

- (void)addDirections:(NSDictionary *)json {
    
    NSDictionary *routes = [json objectForKey:@"routes"];
    [self.paths removeAllObjects];
    NSInteger index = 0;
    
    for (NSDictionary *route in routes) {
        NSDictionary *route_path = [route objectForKey:@"overview_polyline"];
        NSString *overview_route = [route_path objectForKey:@"points"];
        GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        
        CGFloat redLevel    = rand() / (float) RAND_MAX;
        CGFloat greenLevel  = rand() / (float) RAND_MAX;
        CGFloat blueLevel   = rand() / (float) RAND_MAX;
        
        polyline.strokeColor = [UIColor colorWithRed: redLevel
                                               green: greenLevel
                                                blue: blueLevel
                                               alpha: 1.0];
        polyline.strokeWidth = 4.;
        
        polyline.tappable = TRUE;
        polyline.title = [NSString stringWithFormat:@"%d", index];
        polyline.map = self.mapView_;
        [self.paths addObject:polyline];
        [self.routes addObject:route];
        index++;
    }
    
    
    CLLocationCoordinate2D startPoint = [self convertStringToPosition:self.waypointStrings_[0]];
    CLLocationCoordinate2D endPoint = [self convertStringToPosition:self.waypointStrings_[1]];
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:startPoint coordinate:endPoint];
    GMSCameraUpdate *geoLocateCam = [GMSCameraUpdate fitBounds:bounds];
    [self.mapView_ animateWithCameraUpdate:geoLocateCam];
}

-(CLLocationCoordinate2D)convertStringToPosition: (NSString *)wp {
    NSArray *waypoints = [wp componentsSeparatedByString:@","];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake((CGFloat)[waypoints[0] floatValue], (CGFloat)[waypoints[1] floatValue]);
    return position;
}

- (void)getDirections {
    if([self.waypoints_ count]>1){
        NSString *sensor = @"false";
        NSArray *parameters = [NSArray arrayWithObjects:sensor, self.waypointStrings_,
                               nil];
        NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
        NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters
                                                          forKeys:keys];
        MDDirectionService *mds=[[MDDirectionService alloc] init];
        SEL selector = @selector(addDirections:);
        [mds setDirectionsQuery:query
                   withSelector:selector
                   withDelegate:self];
    }
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
    
    [gs geocodeAddress:self.sourceField.text withCallback:@selector(addPoint) withDelegate:self];
    [gs geocodeAddress:self.destinationField.text withCallback:@selector(addPoint) withDelegate:self];
}

- (void)addPoint {
    
    double lat = [[gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey:@"lng"] doubleValue];
    NSLog(@"Adding Point");
    GMSMarker *marker = [[GMSMarker alloc] init];
    CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(lat,lng);
    [self addWaypoint:geolocation];
    marker.position = geolocation;
    marker.title = [gs.geocode objectForKey:@"address"];
    
    marker.map = self.mapView_;
    
    [self getDirections];
}

-(void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSPolyline *)polyline {
    NSLog(@"%@", self.paths);

    for (GMSPolyline *line in self.paths) {
        line.strokeWidth = 4.;
    }
    self.selectedIndex = [polyline.title integerValue];
    polyline.strokeWidth = 8.;
}

- (IBAction)onContinue:(id)sender {
    StartTimeViewController *svc = [[StartTimeViewController alloc] init];
    svc.selectedRoute = self.routes[self.selectedIndex];

    [self presentViewController:svc animated:YES completion:nil];
    NSLog(@"SELECTED INDEX %d", self.selectedIndex);
}
@end
