//
//  ShowRidesController.m
//  YPool
//
//  Created by Harsha Badami Nagaraj on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "ShowRidesController.h"
#import "RoutesClient.h"
#import "RideHeaderCell.h"
#import "RideTableViewCell.h"
#import "RideEmptyTableViewCell.h"

@interface ShowRidesController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *rides;

@end

@implementation ShowRidesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"carpool-title.png"]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = nil;

    RoutesClient *rc = [RoutesClient instance];
    [rc getMyPublishedRoutes:^(NSArray *objects, NSError *error) {
        self.rides = objects;
        NSLog(@"%@", self.rides);
        [self.tableView reloadData];
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RideHeaderCell" bundle:nil] forCellReuseIdentifier:@"RideHeaderCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RideTableViewCell" bundle:nil] forCellReuseIdentifier:@"RideTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"RideEmptyTableViewCell" bundle:nil] forCellReuseIdentifier:@"RideEmptyTableViewCell"];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.rides.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count= [self.rides[section][@"requestInfo"] count];
    if (count == 0) {
        return 1;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.rides[indexPath.section][@"requestInfo"] count] > 0) {
        RideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideTableViewCell"];
        PFObject *requestInfo = self.rides[indexPath.section][@"requestInfo"][indexPath.row];
        cell.data = requestInfo;
        PFUser *user = requestInfo[@"passengerUser"];
        cell.userName.text = user[@"name"];
        
        if (![requestInfo[@"requestStatus"] isEqualToString:@"PENDING"]) {
            cell.pendingView.hidden = YES;
            cell.statusLabel.hidden = NO;
            if ([requestInfo[@"requestStatus"] isEqualToString:@"ACCEPTED"]) {
                cell.statusLabel.text = @"Accepted";
                cell.statusLabel.textColor = [UIColor colorWithRed:14./255. green:107./255. blue:39./255. alpha:1.0];
            } else {
                cell.statusLabel.text = @"Declined";
                cell.statusLabel.textColor = [UIColor redColor];
            }
        } else {
            cell.pendingView.hidden = NO;
            cell.statusLabel.hidden = YES;
        }
        return cell;
    } else {
        RideEmptyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideEmptyTableViewCell"];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 63;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RideHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideHeaderCell"];
    PFObject *routeInfo = self.rides[section][@"routeInfo"];
    cell.destinationLabel.text = routeInfo[@"endPlace"];
    
    NSString *dateString = [NSDateFormatter localizedStringFromDate:routeInfo[@"startTime"] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    
    cell.timeLabel.text = dateString;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}


@end
