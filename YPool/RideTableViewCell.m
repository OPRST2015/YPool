//
//  RideTableViewCell.m
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "RideTableViewCell.h"
#import "RoutesClient.h"

@implementation RideTableViewCell

@synthesize rc;

- (void)awakeFromNib
{
    // Initialization code
    rc = [RoutesClient instance];
    self.pendingView.backgroundColor = [UIColor colorWithRed:240./255. green:244./255. blue:246./255. alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onAccept:(id)sender {
    
    [rc updateRequest:self.data.objectId status:@"ACCEPTED" callback:^(BOOL succeeded, NSError *error) {
        self.pendingView.hidden = YES;
        self.statusLabel.hidden = NO;

        self.statusLabel.text = @"Accepted";
        self.statusLabel.textColor = [UIColor colorWithRed:14./255. green:107./255. blue:39./255. alpha:1.0];
    }];
}

- (IBAction)onDecline:(id)sender {
    [rc updateRequest:self.data.objectId status:@"DECLINED" callback:^(BOOL succeeded, NSError *error) {
        self.pendingView.hidden = YES;
        self.statusLabel.hidden = NO;
        
        self.statusLabel.text = @"Declined";
        self.statusLabel.textColor = [UIColor redColor];
    }];
}
@end
