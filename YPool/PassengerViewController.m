//
//  PassengerViewController.m
//  YPool
//
//  Created by Carl Baltrunas on 7/24/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "PassengerViewController.h"
#import "PoolCellTableViewCell.h"
#import "PoolSelectionViewController.h"
#import <Parse/Parse.h>
#import "RoutesClient.h"

@interface PassengerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *poolTableView;
@property (weak, nonatomic) IBOutlet UIImageView *poolMapImageView;

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
    self.poolSelected = nil;
    
//    PFQuery *query = [PFQuery queryWithClassName:@"publishedRoute"];
//    [query orderByDescending:@"createdAt"];
//    
//    //    [query whereKey:@"startPoint" equalTo:@(YES)];
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            NSLog(@"results: %@", objects);
//            for (int i=0; i<objects.count; i++) {
//                PFObject *str = objects[i];
//                NSString *endP = str[@"endPlace"];
//                NSString *routeD = str[@"routeDetail"];
//                
//                NSDictionary *info = [NSJSONSerialization
//                                      JSONObjectWithData:[routeD dataUsingEncoding:NSUTF8StringEncoding]
//                                      options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves)
//                                      error:&error];
//
//                NSLog(@"results: %@", info);
//            }
//            
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];

    RoutesClient *routesClient = [RoutesClient instance];
    
    [routesClient getMatchingRoutes:@"" dest:@"" callback:^(NSArray *objects, NSError *error) {
        NSLog(@"matched routes %@", objects);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any last initialization...
    
    // (re)load data table of routes
    // *** need to add read data here
    self.poolData = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poolData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoolCellTableViewCell *cell;
    NSDictionary *pool;
    NSDictionary *passengers;
    cell = [tableView dequeueReusableCellWithIdentifier:@"poolCell" forIndexPath:indexPath];
    
    // use custom cell, display name of pool, starting time
    // note -- name will include location info
    cell.poolDestination.text = pool[@"destination"];
    cell.poolTime.text = pool[@"time"];
    passengers = pool[@"passengers"];
    cell.poolPassengers.text = [NSString stringWithFormat:@"%d of %@",
                                (int)passengers.count,
                                pool[@"seats"]];
    
    // use one or the other of these - label needs to be bigger?
    // cell.poolStatus.text = @"N";
    cell.poolStatusImageView.image = [UIImage imageNamed:@{@"N": @"statusNewPool.png",
                                                           @"R": @"statusRequestPool.png",
                                                           @"D": @"statusDeclinePool.png",
                                                           @"A": @"statusAcceptPool.png",
                                                           @"C": @"statusConfirmPool.png"}[@"N"]] ;
    return cell;
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
    
    // now update map using self.poolMapImageView
    
}

- (IBAction)poolSelectedAction:(id)sender {
    if (self.poolSelected) {
        // allow more interaction of selected route
        PoolSelectionViewController *poolSelectionViewController = [[PoolSelectionViewController alloc] initWithNibName:@"TLDPoolSelectionViewController"  bundle:nil];
        poolSelectionViewController.selectedPool = self.poolSelected;
        
        [self presentViewController:poolSelectionViewController animated:YES completion:nil];
    }
    
}


@end
