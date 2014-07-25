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

- (void) getMatchingRoutes:(NSString *)start dest:(NSString *)dest callback:(void (^)(NSArray *objects, NSError *error)) callback {
    NSMutableArray *validRoutes = [[NSMutableArray alloc] init];
    PFQuery *startPointQuery = [PFQuery queryWithClassName:@"geoPoints"];
    [startPointQuery orderByDescending:@"createdAt"];
    
    PFGeoPoint *userStartGeoPoint = [PFGeoPoint geoPointWithLatitude:37.35 longitude:-121.96];
    
    [startPointQuery whereKey:@"geoPoint" nearGeoPoint:userStartGeoPoint withinMiles:20.0];
    [startPointQuery whereKey:@"startPoint" equalTo:@(YES)];
    [startPointQuery includeKey:@"routeId"];
    
    [startPointQuery findObjectsInBackgroundWithBlock:^(NSArray *startPointObjects, NSError *startError) {
        if (!startError) {
            //NSLog(@"start point objects results: %@", startPointObjects);
            
            
            NSMutableDictionary *routeDict = [[NSMutableDictionary alloc] init];
            
            for(id startPointObject in startPointObjects) {
                PFObject *route = startPointObject[@"routeId"];
                // NSLog(@"start point object id %@", route.objectId);
                [routeDict setObject:route forKey:route.objectId];
            }
            
            PFGeoPoint *userEndGeoPoint = [PFGeoPoint geoPointWithLatitude:37.35 longitude:-121.96];
            PFQuery *endPointQuery = [PFQuery queryWithClassName:@"geoPoints"];
            
            [endPointQuery whereKey:@"geoPoint" nearGeoPoint:userEndGeoPoint withinMiles:20.0];
            [endPointQuery whereKey:@"endPoint" equalTo:@(YES)];
            [endPointQuery includeKey:@"routeId"];
            
            [endPointQuery findObjectsInBackgroundWithBlock:^(NSArray *endPointObjects, NSError *endError) {
                if(!endError) {
                    //NSLog(@"end point objects results: %@", endPointObjects);
                    
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
}


@end
