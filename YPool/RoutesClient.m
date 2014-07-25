//
//  RoutesClient.m
//  YPool
//
//  Created by Natarajan Kannan on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "RoutesClient.h"
#import <Parse/Parse.h>

@implementation RoutesClient

+ (RoutesClient *) instance {
    
    static RoutesClient *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[RoutesClient alloc] init];
    });
    
    return instance;
}

- (void) getMatchingRoutes:(NSString *)fromAddress dest:(NSString *)toAddress radius:(float) radius callback:(void (^)(NSArray *objects, NSError *error)) callback {
    
    NSMutableArray *validRoutes = [[NSMutableArray alloc] init];
    PFQuery *startPointQuery = [PFQuery queryWithClassName:@"geoPoints"];
    [startPointQuery orderByDescending:@"createdAt"];
    
    
    GCGeocodingService *gs = [[GCGeocodingService alloc] init];
    
    [gs geocodeAddressSimple:fromAddress callback:^(PFGeoPoint *fromGeoPoint, NSError *fromError) {
        
        // NSLog(@"FROM ADDRESS: %@", fromGeoPoint);
        [gs geocodeAddressSimple:toAddress callback:^(PFGeoPoint *toGeoPoint, NSError *toError) {
            // NSLog(@"TO ADDRESS: %@", toGeoPoint);
            //NSLog(@"TO ADDRESS: %f, %f", toGeoPoint.latitude, toGeoPoint.longitude);
            
            
            [startPointQuery whereKey:@"geoPoint" nearGeoPoint:fromGeoPoint withinMiles:radius];
            [startPointQuery whereKey:@"startPoint" equalTo:@(YES)];
            [startPointQuery includeKey:@"routeId"];
            
            [startPointQuery findObjectsInBackgroundWithBlock:^(NSArray *startPointObjects, NSError *startError) {
                if (!startError) {
                    // NSLog(@"start point objects results: %@", startPointObjects);
                    
                    
                    NSMutableDictionary *routeDict = [[NSMutableDictionary alloc] init];
                    
                    for(id startPointObject in startPointObjects) {
                        PFObject *route = startPointObject[@"routeId"];
                        // NSLog(@"start point object id %@", route.objectId);
                        [routeDict setObject:route forKey:route.objectId];
                    }
                    PFQuery *endPointQuery = [PFQuery queryWithClassName:@"geoPoints"];
                    
                    [endPointQuery whereKey:@"geoPoint" nearGeoPoint:toGeoPoint withinMiles:radius];
                    [endPointQuery whereKey:@"endPoint" equalTo:@(YES)];
                    [endPointQuery includeKey:@"routeId.driverUser"];
                    
                    [endPointQuery includeKey:@"routeId.driverUser"];
                    
                    [endPointQuery findObjectsInBackgroundWithBlock:^(NSArray *endPointObjects, NSError *endError) {
                        if(!endError) {
                            // NSLog(@"end point objects results: %@", endPointObjects);
                            
                            NSMutableArray *selectedRoutes = [[NSMutableArray alloc] init];
                            for(id endPointObject in endPointObjects) {
                                PFObject *route = endPointObject[@"routeId"];
                                // NSLog(@"end point object id %@", route.objectId);
                                if([routeDict valueForKey:route.objectId] != nil) {
                                    [validRoutes addObject:route];
                                }
                            }
                            callback(validRoutes, nil);
                            
                        } else {
                            callback(nil, endError);
                            
                        }
                    }];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@", startError);
                    callback(nil, startError);
                }
            }];
            
        }];
    }];
}

- (void) getMyPublishedRoutes: (void (^)(NSArray *objects, NSError *error)) callback {
    PFQuery *publishedRoutes = [PFQuery queryWithClassName:@"publishedRoute"];
    [publishedRoutes includeKey:@"driverUser"];
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];
    
    [publishedRoutes whereKey:@"driverUser" equalTo:currentUser];
    
    [publishedRoutes findObjectsInBackgroundWithBlock:^(NSArray *routes, NSError *error) {
        // NSLog(@"routes are %@", routes);
        PFQuery *liftRequestQuery = [PFQuery queryWithClassName:@"liftRequest"];
        for(PFObject *route in routes) {
            NSMutableDictionary *response = [[NSMutableDictionary alloc]init];

            // NSLog(@"route is %@", route.objectId);
            [liftRequestQuery whereKey:@"routeId" equalTo:route];
            [liftRequestQuery includeKey:@"passengeUser"];
            NSArray *requests = [liftRequestQuery findObjects];
            // NSLog(@"requests for route:  %@, %@", route.objectId, requests);
            
            [response setObject:route forKey:@"routeInfo"];
            [response setObject:requests forKey:@"requestInfo"];
            [responseArray addObject:response];
        }
        callback(responseArray, nil);
    }];
}

- (void) getMyRequests: (void (^)(NSArray *objects, NSError *error)) callback {

}

- (void) postMyRequest {
    PFQuer
}



@end
