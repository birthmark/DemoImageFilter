//
//  RootTableViewController.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 15/8/30.
//  Copyright (c) 2015年 icetime17. All rights reserved.
//

#import "RootTableViewController.h"
#import "ItemViewController.h"

@interface RootTableViewController ()

@property (nonatomic) NSArray *demosImageFilter;
@property (nonatomic) NSString *selectedItem;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Image Filter Demos";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.demosImageFilter = @[
                              @"CPU Image Filter",
                              @"CoreImage Filter",
                              @"CoreImage Filter Multiple",
                              @"GLKView and CoreImage Filter",
                              @"GPUImage Sepia Filter",
                              @"GPUImage Custom Filter",
                              @"GPUImage Still Camera",
                              @"GPUImage Video Camera",
                              @"Simple Album",
                              @"Custom Album",
                              @"Simple Camera",
                              @"Custom Camera",
                              @"Simple Video",
                              @"Custom Video",
                              ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demosImageFilter.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellImageFilter";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.demosImageFilter[indexPath.row]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedItem = (NSString *)self.demosImageFilter[indexPath.row];
    [self performSegueWithIdentifier:@"segueFromTalbeToCell" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemViewController *itemVC = (ItemViewController *)segue.destinationViewController;
    itemVC.item = self.selectedItem;
}

@end
