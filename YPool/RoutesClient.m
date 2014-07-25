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
                                    // we have a PFObject with one RouteID
                                    
                                    [validRoutes addObject:[self convertPFObjectToDisctionary:route]];
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

- (NSDictionary *)convertPFObjectToDisctionary:(PFObject *)route {

    NSString *routeD = route[@"routeDetail"];
    
    NSDictionary *info = [NSJSONSerialization
                          JSONObjectWithData:[routeD dataUsingEncoding:NSUTF8StringEncoding]
                          options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)
                          error:nil];
    
    NSDate *date = route[@"startTime"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    PFUser * user = route[@"driverUser"];
    NSString *name = user[@"name"];
    NSString *phone = user[@"phone"];
    NSDictionary * d = @{@"routeDetail" : info,
                                @"source" : route[@"startPlace"],
                                @"destination" : route[@"endPlace"],
                                @"time" :  stringFromDate,
                                @"seats" : [NSString stringWithFormat:@"%@ Seats",route[@"numberOfSeats"]],
                         @"name" : name,
                         @"phone" : phone
                                };
    //NSLog(@"New Dictionary: %@", d);
    return [d copy];
}

- (void) getMyPublishedRoutes: (void (^)(NSArray *objects, NSError *error)) callback {
    PFQuery *publishedRoutes = [PFQuery queryWithClassName:@"publishedRoute"];
    [publishedRoutes orderByDescending:@"startTime"];
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
            [liftRequestQuery includeKey:@"passengerUser"];
            NSArray *requests = [liftRequestQuery findObjects];
            // NSLog(@"requests for route:  %@, %@", route.objectId, requests);
            
            [response setObject:route forKey:@"routeInfo"];
            [response setObject:requests forKey:@"requestInfo"];
            [responseArray addObject:response];
        }
        callback(responseArray, nil);
    }];
}

- (void) getPendingInviteCount: (void (^)(NSInteger count, NSError *error)) callback {
    PFQuery *publishedRoutes = [PFQuery queryWithClassName:@"publishedRoute"];
    [publishedRoutes orderByDescending:@"startTime"];
    [publishedRoutes includeKey:@"driverUser"];
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];
    
    [publishedRoutes whereKey:@"driverUser" equalTo:currentUser];
    
    [publishedRoutes findObjectsInBackgroundWithBlock:^(NSArray *routes, NSError *error) {
        // NSLog(@"routes are %@", routes);
        NSInteger count = 0;
        PFQuery *liftRequestQuery = [PFQuery queryWithClassName:@"liftRequest"];
        for(PFObject *route in routes) {
            NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
            
            // NSLog(@"route is %@", route.objectId);
            [liftRequestQuery whereKey:@"routeId" equalTo:route];
            [liftRequestQuery includeKey:@"passengerUser"];
            NSArray *requests = [liftRequestQuery findObjects];
            // NSLog(@"requests for route:  %@, %@", route.objectId, requests);
            
            for(id request in requests) {
                if([request[@"requestStatus"] isEqualToString:@"PENDING"]) {
                    count++;
                }
            }
            
        }
        callback(count, nil);
    }];
}




- (void) getMyRequestedRoutes: (void (^)(NSArray *objects, NSError *error)) callback {
    PFQuery *liftRequests = [PFQuery queryWithClassName:@"liftRequest"];
    [liftRequests includeKey:@"passengerUser"];
    [liftRequests orderByDescending:@"createdAt"];

    PFUser *currentUser = [PFUser currentUser];
    
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];
    
    [liftRequests whereKey:@"passengerUser" equalTo:currentUser];
    [liftRequests includeKey:@"routeId"];
    
    [liftRequests findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        for(PFObject *request in requests) {
            NSMutableDictionary *response = [[NSMutableDictionary alloc]init];
            
            NSArray *requests = @[request];
            
            [response setObject:request[@"routeId"] forKey:@"routeInfo"];
            [response setObject:requests forKey:@"requestInfo"];
            [responseArray addObject:response];
        }
        callback(responseArray, nil);
    }];

}

- (void) postNewRequest: (PFObject *) route callback:(void (^)(BOOL succeeded, NSError *error)) callback {
    PFObject *liftRequest = [PFObject objectWithClassName:@"liftRequest"];
    
    liftRequest[@"routeId"] = route;
    liftRequest[@"passengerUser"] = [PFUser currentUser];
    liftRequest[@"requestStatus"] = @"PENDING";
    
    [liftRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        callback(succeeded, error);
    }];

}

- (void) updateRequest: (NSString *) requestId status:(NSString *)status callback:(void (^)(BOOL succeeded, NSError *error)) callback {
    PFQuery *query = [PFQuery queryWithClassName:@"liftRequest"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:requestId block:^(PFObject *liftRequest, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        liftRequest[@"requestStatus"] = status;
        
        [liftRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            callback(succeeded, error);
        }];
        
    }];
}


@end
