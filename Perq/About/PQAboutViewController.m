//
//  PQAboutViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/20/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQAboutViewController.h"

@interface PQAboutViewController ()

@end

@implementation PQAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addNavigationTitleView];
        
    }
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:YES];
    static CGFloat rgbMax = 255.0f;
    static CGFloat rgb = 240.0f;
    view.backgroundColor = [UIColor colorWithRed:rgb/rgbMax green:rgb/rgbMax blue:rgb/rgbMax alpha:1];
    CGRect frame = view.frame;
    

    CGFloat width = frame.size.width-20.0f;
    UIScrollView *theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0f, 0.0f, width, frame.size.height)];
    theScrollview.showsVerticalScrollIndicator = NO;
    theScrollview.backgroundColor = [UIColor clearColor];
    theScrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    CGFloat y = 10.0f;
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, width, 22.0f)];
    lblHeader.text = @"About Perc";
    lblHeader.textColor = kRed;
    lblHeader.font = [UIFont boldSystemFontOfSize:18.0f];
    [theScrollview addSubview:lblHeader];
    y += lblHeader.frame.size.height+5.0f;
    
    NSString *txtAbout = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"txt"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];
    
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    CGRect boudingRectsize = [txtAbout boundingRectWithSize:CGSizeMake(width, 1000.0f)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:font}
                                                    context:NULL];

    
    UILabel *lblAbout = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, width, boudingRectsize.size.height)];
    lblAbout.font = font;
    lblAbout.lineBreakMode = NSLineBreakByWordWrapping;
    lblAbout.numberOfLines = 0;
    lblAbout.text = txtAbout;
    lblAbout.textColor = [UIColor darkGrayColor];
    [theScrollview addSubview:lblAbout];
    
    
    theScrollview.contentSize = CGSizeMake(0, boudingRectsize.size.height+90.0f);

    [view addSubview:theScrollview];
    
    
    
    self.view = view;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
