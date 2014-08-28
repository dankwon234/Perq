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
#import "PQWelcomeViewController.h"


@interface PQContainerViewController ()
@property (strong, nonatomic) PQPostsViewController *postsVc;
@property (strong, nonatomic) UINavigationController *navCtr;
@property (strong, nonatomic) PQWelcomeViewController *welcomeVc;
@end

@implementation PQContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeWelcomeViewController)
                                                     name:kWelcomeViewDismissedNotification
                                                   object:nil];

        
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
    view.backgroundColor = kGreen;
    
    self.postsVc = [[PQPostsViewController alloc] init];
    
    self.navCtr = [[UINavigationController alloc] initWithRootViewController:self.postsVc];
    self.navCtr.navigationBar.barTintColor = kGreen;
    self.navCtr.navigationBar.tintColor = [UIColor whiteColor];
    [self.navCtr setNavigationBarHidden:YES animated:NO];
    
    [self addChildViewController:self.navCtr];
    [self.navCtr willMoveToParentViewController:self];
    [view addSubview:self.navCtr.view];

    

    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.signalCheck checkSignal]==NO)
        [self showAlertWithtTitle:@"No Connection" message:@"Please find an internet connection."];

    if (!self.session.firstSession)
        return;
    
    self.welcomeVc = [[PQWelcomeViewController alloc] init];
    [self addChildViewController:self.welcomeVc];
    [self.welcomeVc willMoveToParentViewController:self];
    [self.view addSubview:self.welcomeVc.view];
    
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)removeWelcomeViewController
{
    self.welcomeVc = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
