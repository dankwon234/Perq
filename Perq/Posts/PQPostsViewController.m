//
//  PQPostsViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQPostsViewController.h"
#import "PQAppDelegate.h"
#import "PQCollectionViewFlowLayout.h"
#import "PQCollectionViewCell.h"
#import "PQPostViewController.h"
#import "PQCreatePostViewController.h"
#import "PQAboutViewController.h"
#import "PQContactListViewController.h"
#import "PQPost.h"



@interface PQPostsViewController ()
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) UICollectionView *postsCollectionView;
@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *blurryBackground;
@property (strong, nonatomic) UIView *screen;
@property (strong, nonatomic) UIButton *btnCamera;
@property (strong, nonatomic) UIView *selectedPostIcon;
@property (strong, nonatomic) UIView *verticalLine;
@property (strong, nonatomic) NSMutableArray *menuButtons;
@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isNaturalState;
@property (nonatomic) NSTimeInterval now;
@property (nonatomic) int selectedMenuIndex;
@property (nonatomic) BOOL showNearbyPosts;
@end

static NSString *cellIdentifier = @"cellIdentifier";
#define kTopInset 170.0f

@implementation PQPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectedMenuIndex = 0;
        self.selectedPostIcon = nil;
        self.isNaturalState = YES;
        self.showNearbyPosts = NO;
        self.posts = [NSMutableArray array];
        self.menuButtons = [NSMutableArray array];
        

    }
    
    return self;
}


- (void)loadView
{

    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor clearColor];
    CGRect frame = view.frame;

    UIImage *bgImage = [UIImage imageNamed:@"bgCircles.png"];
    
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
    
    self.verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0.76f*frame.size.width, 0.0f, 2.0f, frame.size.height)];
    self.verticalLine.backgroundColor = [UIColor whiteColor];
    self.verticalLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [view addSubview:self.verticalLine];



    // Gradient:
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    static CGFloat maxRGB = 255.0f;
    UIColor *clear = [UIColor clearColor];
    gradient.colors = @[(id)[[UIColor colorWithRed:0.0f/maxRGB green:0.0f/maxRGB blue:0.0f/maxRGB alpha:0.70f] CGColor], (id)[clear CGColor], (id)[clear CGColor], (id)[clear CGColor]];
    [view.layer addSublayer:gradient];
    
    
    UIImage *btnMenuButton = [UIImage imageNamed:@"bgMenuButton.png"];
    
    BOOL hasFriends = (self.session.device.contactList.count==0 || [self.session.device.contactList containsObject:@"none"]==YES);
    
    NSArray *menuOptions = (hasFriends) ? @[@"Featured", @"Nearby", @"My Percs", @"About", @"Friends"] : @[@"Featured", @"Nearby", @"My Percs", @"About"];
    for (int i=0; i<menuOptions.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 1000+i;
        [btn setTitle:menuOptions[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"Verdana" size:16.0f];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        btn.frame = CGRectMake(-btnMenuButton.size.width, 20.0f+i*(btnMenuButton.size.height+12.0f), btnMenuButton.size.width, btnMenuButton.size.height);
        [btn setBackgroundImage:btnMenuButton forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(menuOptionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuButtons addObject:btn];
        [view addSubview:btn];
    }

    
    UIImage *imgCamera = [UIImage imageNamed:@"btnCamera.png"];
    self.btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnCamera.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.btnCamera setBackgroundImage:imgCamera forState:UIControlStateNormal];
    self.btnCamera.frame = CGRectMake(60.0, frame.size.height-0.8f*imgCamera.size.height-100.0f, 0.8f*imgCamera.size.width, 0.8f*imgCamera.size.height);
    [self.btnCamera addTarget:self action:@selector(postPicture:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:self.btnCamera];
    
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.logo.center = CGPointMake(self.btnCamera.center.x, frame.size.height-0.6*self.logo.frame.size.height);
    [view addSubview:self.logo];
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchFeaturedPosts];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.postsCollectionView.scrollEnabled = YES;
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.postsCollectionView.collectionViewLayout invalidateLayout];
    
    [self showMenuButtons];


    
    PQAppDelegate *appDelegate = (PQAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.showStatusBar = YES;
    
    [UIView animateWithDuration:0.33 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];

    
    if (self.isNaturalState==NO)
        [self restoreViewHierarchy];
    
    
    if (self.selectedPostIcon)
        return;
    
    
    CGFloat dimen = 0.70f*kPostCellDimension;
    
    self.selectedPostIcon = [[UIView alloc] initWithFrame:CGRectMake(197.5f, 20.0f, dimen+4, dimen+4)];
    self.selectedPostIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.selectedPostIcon.alpha = 0;
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen+4, dimen+4)];
    border.backgroundColor = [UIColor whiteColor];
    border.layer.cornerRadius = 0.5f*(dimen+2);
    [self.selectedPostIcon addSubview:border];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, dimen, dimen)];
    image.backgroundColor = [UIColor yellowColor];
    image.tag = 2000;
    image.layer.cornerRadius = 0.5*dimen;
    image.layer.masksToBounds = YES;
    [self.selectedPostIcon addSubview:image];
    
    [self.view addSubview:self.selectedPostIcon];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"imageData"]){
        PQPost *post = (PQPost *)object;
        if (!post.imageData)
            return;
        
        [post removeObserver:self forKeyPath:@"imageData" context:nil];
        [self refreshPostsCollectionView];
    }
    
    
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat offset = self.postsCollectionView.contentOffset.y;
        if (offset < -kTopInset){
            offset *= -1;
            double diff = offset-kTopInset;
            double factor = diff/250.0f;
            
            self.background.transform = CGAffineTransformMakeScale(1.0f+factor, 1.0f+factor);
            return;
        }
        
        double distance = offset+kTopInset;
        if (distance < 500.0f){
            CGPoint ctr = self.blurryBackground.center;
            ctr.y = 0.5f*self.view.frame.size.height-0.12f*distance;
            self.blurryBackground.center = ctr;
            self.background.center = ctr;
        }
        
        
        // closer to zero, less blur applied
        double blurFactor = (offset + self.postsCollectionView.contentInset.top) / (2 * CGRectGetHeight(self.postsCollectionView.bounds) / 3.5f);
        
        self.blurryBackground.alpha = blurFactor;
        self.screen.alpha = MAX(0.0, MIN(self.blurryBackground.alpha - 0.2f, 0.2f));
    }
}

- (void)slidePostsView:(CGFloat)originY completion:(SEL)selector
{
    [UIView animateWithDuration:1.2f
                          delay:0
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.view.frame;
                         self.postsCollectionView.frame = CGRectMake(0.5f*frame.size.width, originY, 0.5f*frame.size.width, frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                         if (selector){
                             [self performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
//                             [self performSelector:selector withObject:nil afterDelay:0];
                         }
                     }];

}

- (void)findLocation
{
    [self.loadingIndicator startLoading];
    [self launchLocationManager];
    [self.locationManager startUpdatingLocation];
}

- (void)launchLocationManager
{
    if (self.locationManager)
        return;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
}



- (void)menuOptionSelected:(UIButton *)btn
{
    int oldIndex = self.selectedMenuIndex;
    int tag = (int)btn.tag-1000;
    if (tag==self.selectedMenuIndex)
        return;
    
    self.selectedMenuIndex = tag;
    
    
    
    if (self.selectedMenuIndex==0){ // Featured
        [self.loadingIndicator startLoading];
        [self slidePostsView:self.view.frame.size.height completion:@selector(fetchFeaturedPosts)];
    }
    
    if (self.selectedMenuIndex==1){ // Nearby
        
        if (self.session.latitude!=0.0 && self.session.longitude!=0.0){
            [self.loadingIndicator startLoading];
            [self slidePostsView:self.view.frame.size.height completion:@selector(fetchNearbyPosts)];
            [self showMenuButtons];
            return;
        }
        
        self.showNearbyPosts = YES;
        [self.loadingIndicator startLoading];
        [self slidePostsView:self.view.frame.size.height completion:@selector(findLocation)];
    }
    
    if (self.selectedMenuIndex==2){ // My Perqs
        [self.loadingIndicator startLoading];
        [self slidePostsView:self.view.frame.size.height completion:@selector(fetchDevicePosts)];
    }
    
    if (self.selectedMenuIndex==3){ // About
        self.selectedMenuIndex = oldIndex;
        PQAboutViewController *aboutVc = [[PQAboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVc animated:YES];
        return;
    }

    if (self.selectedMenuIndex==4){ // Friends
        self.selectedMenuIndex = oldIndex;
        PQContactListViewController *friendsVc = [[PQContactListViewController alloc] init];
        [self.navigationController pushViewController:friendsVc animated:YES];
        return;
    }
    
    
    [self showMenuButtons];
}


- (void)destroyPostsCollectionView
{
    if (self.postsCollectionView==nil){
        return;
    }
    
    self.postsCollectionView.dataSource = nil;
    self.postsCollectionView.delegate = nil;
    [self.postsCollectionView removeObserver:self forKeyPath:@"contentOffset"];
    [self.postsCollectionView removeFromSuperview];
    self.postsCollectionView = nil;
}

- (void)layoutPostsCollectionView
{
    CGRect frame = self.view.frame;
    PQCollectionViewFlowLayout *layout = [[PQCollectionViewFlowLayout alloc] init];
    self.postsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.5f*frame.size.width, frame.size.height, 0.5f*frame.size.width, frame.size.height) collectionViewLayout:layout];
    [self.postsCollectionView registerClass:[PQCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    self.postsCollectionView.backgroundColor = [UIColor clearColor];
    self.postsCollectionView.showsVerticalScrollIndicator = NO;
    self.postsCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.postsCollectionView.dataSource = self;
    self.postsCollectionView.delegate = self;
    self.postsCollectionView.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, 12.0f, 0.0f);
    
    UIView *topPadding = [[UIView alloc]initWithFrame:CGRectMake(0, -kTopInset, frame.size.width, kTopInset)];
    topPadding.backgroundColor = [UIColor clearColor];
    [self.postsCollectionView addSubview:topPadding];
    
    [self.postsCollectionView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    
    
    [self.view addSubview:self.postsCollectionView];
    [self refreshPostsCollectionView];
    
    [self slidePostsView:0.0f completion:nil];
}



- (void)fetchFeaturedPosts
{
    [self destroyPostsCollectionView];
    
    [self.loadingIndicator startLoading];
    [[PQWebServices sharedInstance] fetchPosts:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            
        }
        else {
            NSDictionary *results = (NSDictionary *)result;
            [self parseResults:results];
        }
        
    }];
    
}

- (void)fetchDevicePosts
{
    [self destroyPostsCollectionView];

    [[PQWebServices sharedInstance] fetchPostsFromDevice:self.session.deviceHash completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            
        }
        else {
            NSDictionary *results = (NSDictionary *)result;
            [self parseResults:results];
        }
        
    }];

}

- (void)fetchNearbyPosts
{
    [self destroyPostsCollectionView];
    
    [[PQWebServices sharedInstance] fetchPostsFromLocation:[self.session locationDictionary] completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            
        }
        else {
            NSDictionary *results = (NSDictionary *)result;
            [self parseResults:results];
        }
        
    }];
}


- (void)parseResults:(NSDictionary *)results
{
    NSString *confirmation = results[@"confirmation"];
    if ([confirmation isEqualToString:@"success"]==NO){
        [self showAlertWithtTitle:@"Error" message:results[@"message"]];
        return;
    }
    
    
    NSLog(@"%@", [results description]);
    NSArray *p = results[@"posts"];
    [self.postsCollectionView.collectionViewLayout invalidateLayout];
    [self.posts removeAllObjects];
    for (int i=0; i<p.count; i++)
        [self.posts addObject:[PQPost postWithInfo:p[i]]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self layoutPostsCollectionView];
        if (self.posts.count==0)
            [self showAlertWithtTitle:@"No Percs!" message:@"To post the first Perc, tap the camera icon on the lower left!"];
        
    });
}

- (void)refreshPostsCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.postsCollectionView.collectionViewLayout invalidateLayout];
        [self.postsCollectionView reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.posts.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.postsCollectionView reloadItemsAtIndexPaths:indexPaths];
    });
}


- (void)postPicture:(UIButton *)btn
{
//    NSLog(@"postPicture: ");
    
    if (self.session.latitude==0.0f && self.session.longitude==0.0f){ // fetch location
        [self.loadingIndicator startLoading];
        [self launchLocationManager];
        
        self.showNearbyPosts = NO;
        [self.locationManager startUpdatingLocation];
        return;
    }
    
    [self showImageSourceOptions];
}


- (void)launchImageSelector:(UIImagePickerControllerSourceType)sourceType
{
    [self.loadingIndicator startLoading];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        [self.loadingIndicator stopLoading];
    }];
    
}

- (void)showMenuButtons
{
    NSLog(@"SHOW MENU BUTTONS");
    for (int i=self.selectedMenuIndex; i<self.selectedMenuIndex+self.menuButtons.count; i++) {
        int index = i%self.menuButtons.count;
        UIButton *btn = self.menuButtons[index];
        
        [UIView animateWithDuration:1.1f
                              delay:(i-self.selectedMenuIndex)*0.1f
             usingSpringWithDamping:0.5f
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             if (i==self.selectedMenuIndex) {
                                 btn.center = CGPointMake(16.0f, btn.center.y);
                                 [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
                             }
                             else{
                                 btn.center = CGPointMake(0.0f, btn.center.y);
                                 [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                             }
                         }
                         completion:NULL];
    }
    
    
}


- (void)viewPost:(PQPost *)post
{
    NSLog(@"viewPost: %@", post.caption);
    PQPostViewController *postVc = [[PQPostViewController alloc] init];
    postVc.post = post;
    postVc.offset = 100.0f;
    
    postVc.view.backgroundColor = [UIColor colorWithPatternImage:[self.view screenshot]];
    [self.navigationController pushViewController:postVc animated:NO];
}

- (void)restoreViewHierarchy
{
    [UIView animateWithDuration:0.72f
                          delay:0
         usingSpringWithDamping:0.65f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.logo.alpha = 1.0f;
                         
                         CGRect frame = self.btnCamera.frame;
                         self.btnCamera.frame = CGRectMake(60.0, self.view.frame.size.height-frame.size.height-100.0f, frame.size.width, frame.size.height);

                         
                         frame = self.view.frame;
                         self.verticalLine.frame = CGRectMake(0.76f*frame.size.width, 0.0f, 2.0f, frame.size.height);
                         
                         self.selectedPostIcon.center = CGPointMake(self.verticalLine.center.x, self.selectedPostIcon.tag);
                     }
                     completion:^(BOOL finished){
                         self.selectedPostIcon.alpha = 0.0f;
                         self.isNaturalState = YES;
                         
                     }];
    
    NSArray *visibleCells = [self.postsCollectionView visibleCells];
    for (int i=0; i<visibleCells.count; i++) {
        PQCollectionViewCell *cell = visibleCells[i];
        [cell restoreSubviews:i*0.06f];
    }
    
    
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSLog(@"collectionView numberOfItemsInSection: %d", self.posts.count);
    return self.posts.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PQCollectionViewCell *cell = (PQCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PQPost *post = (PQPost *)self.posts[indexPath.row];
    cell.tag = indexPath.row+1000;
    
    cell.border.backgroundColor = ([self.session.device.contactList containsObject:post.from]) ? [UIColor orangeColor] : [UIColor whiteColor];
    
    [cell.btnComment setTitle:[NSString stringWithFormat:@"%d", post.commentCount] forState:UIControlStateNormal];
    [cell.btnHeart setTitle:[NSString stringWithFormat:@"%d", post.likes.count] forState:UIControlStateNormal];
    
    if (post.imageData){
        cell.image.image = post.imageData;
    }
    else{
        cell.image.image = [UIImage imageNamed:@"placeholder.png"];
        [post addObserver:self forKeyPath:@"imageData" options:0 context:nil];
        [post fetchImage];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kPostCellDimension, kPostCellDimension);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.postsCollectionView.scrollEnabled = NO;
    PQPost *selectedPost = self.posts[indexPath.row];
    
    UIImageView *icon = (UIImageView *)[self.selectedPostIcon viewWithTag:2000];
    icon.image = selectedPost.imageData;
    self.selectedPostIcon.alpha = 1.0f;
    CGPoint ctr = self.selectedPostIcon.center;
    
    CGPoint center;
    NSArray *visibleCells = [self.postsCollectionView visibleCells];
    for (int i=0; i<visibleCells.count; i++) {
        PQCollectionViewCell *cell = visibleCells[i];
        if (cell.tag == indexPath.row+1000){
            center = [cell.image convertPoint:cell.image.center fromView:self.view];
            center.y *= -1;
            [cell selected];
        }
        else
            [cell slideOut:i*0.06f];
    }
    
    center.y += 0.5f*self.selectedPostIcon.frame.size.height+45.5f;
    self.selectedPostIcon.tag = center.y;
    //    NSLog(@"OFFSET Y: %2f", center.y);
    
    self.selectedPostIcon.center = CGPointMake(ctr.x, center.y);
    
    
    // animate buttons individually to stagger
    for (int i=0; i<self.menuButtons.count; i++) {
        UIButton *btn = self.menuButtons[i];
        [UIView animateWithDuration:0.56f
                              delay:(self.menuButtons.count-i-1)*0.1f
             usingSpringWithDamping:0.65f
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             btn.center = CGPointMake(-180.0f, btn.center.y);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
    

    
    [UIView animateWithDuration:0.72f
                          delay:0
         usingSpringWithDamping:0.65f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.logo.alpha = 0.0f;
                         
                         CGRect frame = self.btnCamera.frame;
                         frame.origin.x = -frame.size.width-20.0f;
                         self.btnCamera.frame = frame;
                         
                         frame = self.selectedPostIcon.frame;
                         frame.origin.x = 20.0f;
                         frame.origin.y = 40.0f;
                         self.selectedPostIcon.frame = frame;
                         
                         CGPoint ctr = self.verticalLine.center;
                         self.verticalLine.center = CGPointMake(67.0f, ctr.y);
                     }
                     completion:^(BOOL finished){
                         self.isNaturalState = NO;
                         [self performSelector:@selector(viewPost:)
                                    withObject:self.posts[indexPath.row]
                                    afterDelay:0.5f];
                     }];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", buttonIndex);
    if (buttonIndex==0){
        [self launchImageSelector:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if (buttonIndex==1){
        [self launchImageSelector:UIImagePickerControllerSourceTypeCamera];
    }
    
}




#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: didFinishPickingMediaWithInfo: %@", [info description]);
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    if (w != h){
        CGFloat dimen = (w < h) ? w : h;
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0.5*(image.size.width-dimen), 0.5*(image.size.height-dimen), dimen, dimen));
        image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithCGImage:imageRef], 0.5f)];
        CGImageRelease(imageRef);
    }
    
    
    
    PQCreatePostViewController *createPostVc = [[PQCreatePostViewController alloc] init];
    createPostVc.selectedImage = image;
    [self.navigationController pushViewController:createPostVc animated:NO];

    [picker dismissViewControllerAnimated:YES completion:^{
//        PQCreatePostViewController *createPostVc = [[PQCreatePostViewController alloc] init];
//        [self.navigationController pushViewController:createPostVc animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //    NSLog(@"imagePickerControllerDidCancel:");
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewWillBeginDragging: ");
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSString *keepMoving = (decelerate) ? @"YES" : @"NO";
//    NSLog(@"scrollView willDecelerate: %@", keepMoving);
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidEndDecelerating:");
}





#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"manager didUpdateLocations:");
    
    static double minAccuracy = 75.0f;
    CLLocation *bestLocation = nil;
    for (CLLocation *location in locations) {
        if (([location.timestamp timeIntervalSince1970]-self.now) >= 0){
            
            NSLog(@"LOCATION: %@, %.4f, %4f, ACCURACY: %.2f,%.2f", [location.timestamp description], location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, location.verticalAccuracy);
            
            if (location.horizontalAccuracy <= minAccuracy && location.horizontalAccuracy <= minAccuracy){
                [self.locationManager stopUpdatingLocation];
                self.locationManager.delegate = nil;
                bestLocation = location;
                NSLog(@"FOUND BEST LOCATION!!");
                break;
            }
        }
    }
    
    if (bestLocation==nil) // couldn't find location to desired accuracy
        return;
    
    self.session.latitude = self.locationManager.location.coordinate.latitude;
    self.session.longitude = self.locationManager.location.coordinate.longitude;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) { //Getting Human readable Address from Lat long...
        
        if (placemarks.count > 0){
            CLPlacemark *placeMark = placemarks[0];
            NSDictionary *locationInfo = placeMark.addressDictionary;
            NSLog(@"LOCATION: %@", [locationInfo description]);
            
            
            self.session.city = locationInfo[@"City"];
            self.session.state = locationInfo[@"State"];
            self.session.zip = locationInfo[@"ZIP"];

            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *cityState = [NSString stringWithFormat:@"%@, %@", self.session.city, self.session.state];
                UIButton *btnLocation = (UIButton *)self.menuButtons[1];
                [btnLocation setTitle:cityState forState:UIControlStateNormal];
                
                if (self.showNearbyPosts){
                    [self fetchNearbyPosts];

                }
                else{
                    [self.loadingIndicator stopLoading];
                    [self showImageSourceOptions];
                }
                

            });

            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithtTitle:@"Error" message:@"Could not find your location."];
            });
        }
    }];
}

- (void)showImageSourceOptions
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"photo library", @"take photo", nil];
    actionsheet.frame = CGRectMake(0, 150, self.view.frame.size.width, 100);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    [self.loadingIndicator stopLoading];
    [self showAlertWithtTitle:@"Error" message:@"Failed to Get Your Location. Please check your settings to make sure location services is ativated (under 'Privacy' section)."];
    
    

}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
