//
//  PQContainerViewController.m
//  Pique
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQContainerViewController.h"
#import "PQPostsViewController.h"
#import "PQAppDelegate.h"

@interface PQContainerViewController ()
@property (strong, nonatomic) PQPostsViewController *postsVc;
@end

@implementation PQContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
//    NSLog(@"preferredStatusBarStyle");
    return UIStatusBarStyleLightContent; // your own style
    
}

- (BOOL)prefersStatusBarHidden
{
//    NSLog(@"prefersStatusBarHidden");
    
    PQAppDelegate *appDelegate = (PQAppDelegate *)[UIApplication sharedApplication].delegate;
    return !appDelegate.showStatusBar;

//    return NO; // your own visibility code
}


- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor redColor];
    
    self.postsVc = [[PQPostsViewController alloc] init];
    
    UINavigationController *navCtr = [[UINavigationController alloc] initWithRootViewController:self.postsVc];
    navCtr.navigationBar.barTintColor = kGreen;
    navCtr.navigationBar.tintColor = [UIColor whiteColor];
    [navCtr setNavigationBarHidden:YES animated:NO];
    
    [self addChildViewController:navCtr];
    [navCtr willMoveToParentViewController:self];
    [view addSubview:navCtr.view];

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
