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
    RideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideTableViewCell"];
    if ([self.rides[indexPath.section][@"requestInfo"] count] > 0) {
        PFUser *user = self.rides[indexPath.section][@"requestInfo"][indexPath.row][@"passengerUser"];
        cell.userName.text = @"Sudip Shah";
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    RideHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideHeaderCell"];
    cell.destinationLabel.text =self.rides[section][@"routeInfo"][@"endPlace"];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

@end
