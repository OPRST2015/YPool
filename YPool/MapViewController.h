//
//  MapViewController.h
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/22/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"

@interface MapViewController : UIViewController <GMSMapViewDelegate, UITextFieldDelegate>

@property (strong,nonatomic) GCGeocodingService *gs;

@end
