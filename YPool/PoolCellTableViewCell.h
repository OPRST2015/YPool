//
//  TDLPoolCellTableViewCell.h
//  YPool
//
//  Created by Carl Baltrunas on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDLPoolCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *poolDestination;
@property (weak, nonatomic) IBOutlet UILabel *poolTime;
@property (weak, nonatomic) IBOutlet UILabel *poolPassengers;
@property (weak, nonatomic) IBOutlet UIImageView *poolStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *poolStatus;

@end
