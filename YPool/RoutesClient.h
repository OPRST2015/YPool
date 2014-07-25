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
- (void) getMyRoutes: (void (^)(NSArray *objects, NSError *error)) callback;

@end
