//
//  PQWelcomeViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/10/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQWelcomeViewController.h"
#import "PQCollectionViewFlowLayout.h"
#import "PQWelcomeViewCell.h"


@interface PQWelcomeViewController ()
@property (strong, nonatomic) UICollectionView *welcomeCollectionView;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *blurryBackground;
@property (strong, nonatomic) UIView *screen;
@property (strong, nonatomic) UITextField *phoneNumberField;
@property (strong, nonatomic) UIImageView *logo;
@end

static NSString *cellIdentifier = @"welcomeCellIdentifier";
#define kTopInset 120.0f

@implementation PQWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor greenColor];
    CGRect frame = view.frame;
    
    
    UIImage *bgImage = [UIImage imageNamed:@"bgBlurry.png"];
    
    self.background = [[UIImageView alloc] initWithImage:bgImage];
    self.background.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.background.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
    [view addSubview:self.background];

    self.blurryBackground = [[UIImageView alloc] initWithImage:[bgImage applyBlurOnImage:0.9f]];
    self.blurryBackground.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.blurryBackground.frame = CGRectMake(0, 0, bgImage.size.width, bgImage.size.height);
    self.blurryBackground.alpha = 1.0f;
    [view addSubview:self.blurryBackground];
    
    self.screen = [[UIView alloc] initWithFrame:self.blurryBackground.frame];
    self.screen.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight);
    self.screen.alpha = 0.0;
    self.screen.backgroundColor = [UIColor clearColor];
    [view addSubview:self.screen];
    
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.logo.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.logo.center = CGPointMake(0.5f*frame.size.width, 50.0f);
    [view addSubview:self.logo];
    
    
    
    PQCollectionViewFlowLayout *layout = [[PQCollectionViewFlowLayout alloc] init];
    self.welcomeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, frame.size.height+100.0f) collectionViewLayout:layout];
    
    [self.welcomeCollectionView registerClass:[PQWelcomeViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    self.welcomeCollectionView.backgroundColor = [UIColor clearColor];
    self.welcomeCollectionView.showsVerticalScrollIndicator = NO;
    self.welcomeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.welcomeCollectionView.dataSource = self;
    self.welcomeCollectionView.delegate = self;
    self.welcomeCollectionView.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, kTopInset, 0.0f);
    [self.welcomeCollectionView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    [view addSubview:self.welcomeCollectionView];


    self.view = view;
}

- (void)dealloc
{
    [self.welcomeCollectionView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.welcomeCollectionView.collectionViewLayout invalidateLayout];
    
    
    [UIView animateWithDuration:1.2f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect frame = self.welcomeCollectionView.frame;
                         frame.origin.y = 0.0f;
                         self.welcomeCollectionView.frame = frame;
                         
                     }
                     completion:^(BOOL finished){
                         CGRect frame = self.welcomeCollectionView.frame;
                         frame.size.height = self.view.frame.size.height;
                         self.welcomeCollectionView.frame = frame;
                     }];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.welcomeCollectionView.contentOffset.y;
        if (offset < -kTopInset){
            offset *= -1;
            double diff = offset-kTopInset;
            double factor = diff/250.0f;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f+factor, 1.0f+factor);
            self.background.transform = transform;
            self.logo.transform = transform;
            self.logo.alpha = 1.0f;
            return;
        }
        
        double distance = offset+kTopInset;
        if (distance < 500.0f){
            CGPoint ctr = self.blurryBackground.center;
            ctr.y = 0.5f*self.view.frame.size.height-0.12f*distance;
            self.blurryBackground.center = ctr;
            self.background.center = ctr;
        }
        
        self.logo.alpha = 1-(distance/100.0f);
        
        // closer to zero, less blur applied
        double blurFactor = (offset + self.welcomeCollectionView.contentInset.top) / (2 * CGRectGetHeight(self.welcomeCollectionView.bounds) / 3.5f);
        
        self.blurryBackground.alpha = blurFactor;
        self.screen.alpha = MAX(0.0, MIN(self.blurryBackground.alpha - 0.2f, 0.2f));
    }
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PQWelcomeViewCell *cell = (PQWelcomeViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    int row = indexPath.row;
    
    if (row==0){
        cell.btnSignup.alpha = 0.0f;
        cell.lblDescription.alpha = 1.0f;
        cell.contentImage.image = [UIImage imageNamed:@"tutorial-1.png"];
        cell.lblCaption.text = @"Local";
        cell.lblDescription.text = @"On Perc, see pictures posted by people nearby. All content is posted anonymously.";
    }
    
    if (row==1){
        cell.btnSignup.alpha = 0.0f;
        cell.lblDescription.alpha = 1.0f;
        cell.contentImage.image = [UIImage imageNamed:@"tutorial-2.png"];
        cell.lblCaption.text = @"Comments";
        cell.lblDescription.text = @"Comment, like and share posts on your social networks.";
    }

    if (row==2){
        cell.btnSignup.alpha = 0.0f;
        cell.lblDescription.alpha = 1.0f;
        cell.contentImage.image = [UIImage imageNamed:@"tutorial-3.png"];
        cell.lblCaption.text = @"Guess Who?";
        cell.lblDescription.text = @"Earn points by guessing which one of your friends posted certain pictures.";
    }

    if (row==3){
        cell.btnSignup.alpha = 1.0f;
        cell.lblDescription.alpha = 0.0f;
        
        [cell.btnSignup addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
        cell.contentImage.image = [UIImage imageNamed:@"tutorial-4.png"];
        cell.lblCaption.text = @"We promise to never share your info or reveal your identity.";
        cell.lblDescription.text = @"";
    }

    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(280.0f, 2*kPostCellDimension);
}

- (void)signUp:(UIButton *)btn
{
    NSLog(@"signUp: ");
    
    if (self.phoneNumberField.text.length < 10){
        
        [UIView animateWithDuration:0.2f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             CGRect frame = self.view.frame;
                             frame.origin.y = frame.size.height;
                             self.view.frame = frame;
                         }
                         completion:^(BOOL finished){
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self willMoveToParentViewController:nil];
                                 [self.view removeFromSuperview];
                                 [self removeFromParentViewController];
                                 [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kWelcomeViewDismissedNotification object:nil]];
                             });
                         }];
        
        return;
    }
    
    [self.loadingIndicator startLoading];
    [self.phoneNumberField resignFirstResponder];
    self.session.device.phoneNumber = [self.phoneNumberField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self.session.device updateDevice:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopLoading];
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kWelcomeViewDismissedNotification object:nil]];
        });
    }];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.phoneNumberField resignFirstResponder];
}


#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = -120.0f;
                         self.view.frame = frame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = 0.0f;
                         self.view.frame = frame;
                     }
                     completion:^(BOOL finished){
                         
                     }];

    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
