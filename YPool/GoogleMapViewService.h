//
//  GoogleMapViewService.h
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"

@class GoogleMapViewService;

@protocol GoogleMapViewServiceDelegate <NSObject>

-(void) handleTapOverlay:(GMSPolyline *)polyline;

@end

@interface GoogleMapViewService : NSObject <GMSMapViewDelegate>

@property (strong,nonatomic) GCGeocodingService *gs;
-(GMSMapView *) getInitialViewWithFrame: (UIView *)frame;
- (void) drawPathFrom:(NSString *)fromAddress to:(NSString *)toAddress;
-(NSDictionary *) getSelectedRoute;

@property (nonatomic, weak) id <GoogleMapViewServiceDelegate> delegate;

@end

