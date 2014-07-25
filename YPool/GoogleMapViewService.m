//
//  GoogleMapViewService.m
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "GoogleMapViewService.h"
#import "MDDirectionService.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"

@interface GoogleMapViewService()

@property (nonatomic, strong) GMSMapView *mapView_;
@property (nonatomic, strong) NSMutableArray *waypoints_;
@property (nonatomic, strong) NSMutableArray *waypointStrings_;
@property (nonatomic, strong) NSMutableArray *paths;
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, assign) NSInteger selectedIndex;

@end


@implementation GoogleMapViewService

@synthesize gs;

-(id)init {
    self = [super init];
    
    if (self) {
        [self initializeObjects];
    }
    
    return self;
}

-(void) initializeObjects {
    self.paths = [[NSMutableArray alloc]init];
    self.routes = [[NSMutableArray alloc] init];
    self.waypoints_ = [[NSMutableArray alloc]init];
    self.waypointStrings_ = [[NSMutableArray alloc]init];
    
    gs = [[GCGeocodingService alloc] init];
}

-(GMSMapView *) getInitialViewWithFrame: (UIView *)frame {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.3533409
                                                            longitude:-122.010979
                                                                 zoom:13];
    self.mapView_ = [GMSMapView mapWithFrame:frame.bounds camera:camera];
    self.mapView_.delegate = self;
    return self.mapView_;
}

- (void) addWaypoint:(CLLocationCoordinate2D) position {
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.map = self.mapView_;
    [self.waypoints_ addObject:marker];
    NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",
                                position.latitude,position.longitude];
    [self.waypointStrings_ addObject:positionString];
}

- (void) addDirections:(NSDictionary *)json {
    
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
        polyline.strokeWidth = 3.;
        
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

-(void) getDirections {
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

- (void) addPoint {
    
    double lat = [[gs.geocode objectForKey:@"lat"] doubleValue];
    double lng = [[gs.geocode objectForKey:@"lng"] doubleValue];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    CLLocationCoordinate2D geolocation = CLLocationCoordinate2DMake(lat,lng);
    [self addWaypoint:geolocation];
    marker.position = geolocation;
    marker.title = [gs.geocode objectForKey:@"address"];
    
    marker.map = self.mapView_;
    
    [self getDirections];
}

- (void) drawPathFrom:(NSString *)fromAddress to:(NSString *)toAddress {
    [gs geocodeAddress:fromAddress withCallback:@selector(addPoint) withDelegate:self];
    [gs geocodeAddress:toAddress withCallback:@selector(addPoint) withDelegate:self];
}

-(void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSPolyline *)polyline {
    for (GMSPolyline *line in self.paths) {
        line.strokeWidth = 3.;
    }
    self.selectedIndex = [polyline.title integerValue];
    polyline.strokeWidth = 6.;
    
    [self.delegate handleTapOverlay:polyline];
}

-(NSDictionary *) getSelectedRoute {
    return self.routes[self.selectedIndex];
}

@end
