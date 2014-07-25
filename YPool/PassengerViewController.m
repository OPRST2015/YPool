//
//  PassengerViewController.m
//  YPool
//
//  Created by Carl Baltrunas on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "PassengerViewController.h"
#import "PoolTableViewCell.h"
#import "PoolSelectionViewController.h"
#import <Parse/Parse.h>
#import "RoutesClient.h"
#import "PoolTableViewCell1.h"

@interface PassengerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectionImageView;
@property (weak, nonatomic) IBOutlet UITextField *sourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UITableView *poolTableView;
@property (weak, nonatomic) IBOutlet UIImageView *poolMapImageView;
@property (nonatomic, assign) BOOL noRoutesFound;


@end

@implementation PassengerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"carpool-title.png"]];
    
    self.poolSelected = nil;
    self.poolTableView.delegate = self;
    self.poolTableView.dataSource = self;
    self.sourceTextField.delegate = self;
    self.destinationTextField.delegate = self;

    [self getMatchingRoutesData];

    
    [self.poolTableView registerNib:[UINib nibWithNibName:@"PoolTableViewCell" bundle:nil] forCellReuseIdentifier:@"PoolTableViewCell"];
    [self.poolTableView registerNib:[UINib nibWithNibName:@"PoolTableViewCell1" bundle:nil] forCellReuseIdentifier:@"PoolTableViewCell1"];
    [self.poolTableView reloadData];
}

- (void)getMatchingRoutesData {
    if (![self.sourceTextField.text isEqualToString:@""] && ![self.destinationTextField.text isEqualToString:@""]) {
        RoutesClient *routesClient = [RoutesClient instance];
        
        [routesClient getMatchingRoutes:self.sourceTextField.text dest:self.destinationTextField.text radius:20.0 callback:^(NSArray *objects, NSError *error) {
            
            if ([objects count]) {
                self.noRoutesFound = NO;
                self.poolData = objects;
                NSLog(@"matched routes %@", objects);
            } else {
                self.noRoutesFound = YES;
            }
            [self.poolTableView reloadData];
        }];

    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any last initialization...
    
    // (re)load data table of routes
    // *** need to add read data here
    self.poolData = nil;
    self.noRoutesFound = NO;
    [self getMatchingRoutesData];

//    self.backgroundImageView.image = [UIImage imageNamed:@"poolee-bkg.png"];
//    self.selectionImageView.image = [UIImage imageNamed:@"poolee-select-destination.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self getMatchingRoutesData];
    return YES;
}


#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Count of Pool Data: %d", self.poolData.count);
    if (self.noRoutesFound) {
        return 1;
    } else {
        return self.poolData.count;
    }

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.noRoutesFound) {
        PoolTableViewCell1 * ptvc1 = [tableView dequeueReusableCellWithIdentifier:@"PoolTableViewCell1" forIndexPath:indexPath];
        return ptvc1;
    } else {
        PoolTableViewCell *cell;
        NSDictionary *pool = self.poolData[indexPath.row];
        NSLog(@"Data for TableCell: %@", pool);
        //    NSDictionary *passengers;
        cell = [tableView dequeueReusableCellWithIdentifier:@"PoolTableViewCell" forIndexPath:indexPath];
        
        // use custom cell
        //    cell.poolCellBackgroundImage.image = [UIImage imageNamed:@"poolee-route-table-bkg.png"];
        cell.poolSource.text = pool[@"source"];
        cell.poolDestination.text = pool[@"destination"];
        cell.poolTime.text = pool[@"time"];
        //    passengers = pool[@"passengers"];
        //    cell.poolPassengers.text = [NSString stringWithFormat:@"%d of %@",
        //                                (int)passengers.count,
        //                                pool[@"seats"]];
        
        cell.poolPassengers.text = pool[@"seats"];
        // use one or the other of these - label needs to be bigger?
        //    cell.poolStatus.text = @"N";
        //    cell.poolStatusImageView.image = [UIImage imageNamed:@{@"N": @"statusNewPool.png",
        //                                                           @"R": @"statusRequestPool.png",
        //                                                           @"D": @"statusDeclinePool.png",
        //                                                           @"A": @"statusAcceptPool.png",
        //                                                           @"C": @"statusConfirmPool.png"}[pool[@"status"]]] ;
        return cell;

        
    }
}

/* If we decide to allow deleting of routes via table edit */

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath: (%d),(%d)", (int)indexPath.section, (int)indexPath.row);
    self.poolSelected = self.poolData[indexPath.row];

    // row is selected
    [self poolSelectedAction];
    
    // now update map using self.poolMapImageView
    
}

- (void)poolSelectedAction {
    if (self.poolSelected) {
        // allow more interaction of selected route
        PoolSelectionViewController *poolSelectionViewController = [[PoolSelectionViewController alloc] init];
        poolSelectionViewController.selectedPool = self.poolSelected;
        
        [self presentViewController:poolSelectionViewController animated:YES completion:nil];
    }
    
}


@end
