//
//  PQSelectNetworkViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/21/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQSelectNetworkViewController.h"

@interface PQSelectNetworkViewController ()
@property (strong, nonatomic) UITableView *networksTable;
@property (strong, nonatomic) NSArray *networks;
@end

@implementation PQSelectNetworkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addNavigationTitleView];
        self.networks = @[@"Facebook", @"Instagram", @"Twitter", @"Contacts"];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    view.backgroundColor = [UIColor redColor];
    CGRect frame = view.frame;

    
    self.networksTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    self.networksTable.dataSource = self;
    self.networksTable.delegate = self;
    [view addSubview:self.networksTable];
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.networks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.networks[indexPath.row];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
