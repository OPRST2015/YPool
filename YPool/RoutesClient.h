//
//  RoutesClient.h
//  YPool
//
//  Created by Natarajan Kannan on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCGeocodingService.h"

@interface RoutesClient : NSObject

+ (RoutesClient *) instance;

- (void) getMatchingRoutes:(NSString *)start dest:(NSString *)dest radius:(float)radius callback:(void (^)(NSArray *objects, NSError *error)) callback;
- (void) getMyPublishedRoutes: (void (^)(NSArray *objects, NSError *error)) callback;
- (void) getMyRequests: (void (^)(NSArray *objects, NSError *error)) callback;
- (void) postNewRequest: (PFObject *) route callback:(void (^)(BOOL succeeded, NSError *error)) callback;
- (void) updateRequest: (NSString *) requestId status:(NSString *)status callback:(void (^)(BOOL succeeded, NSError *error)) callback;

@end