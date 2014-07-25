//
//  RideTableViewCell.h
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RoutesClient.h"

@interface RideTableViewCell : UITableViewCell

@property (nonatomic, strong) PFObject *data;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIView *pendingView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
- (IBAction)onAccept:(id)sender;
- (IBAction)onDecline:(id)sender;
@property (strong, nonatomic) RoutesClient *rc;

@end
