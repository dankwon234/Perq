//
//  PQPostViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/4/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQPostViewController.h"
#import "PQAppDelegate.h"
#import "PQCollectionViewFlowLayout.h"
#import "PQCommentViewCell.h"
#import "PQComment.h"

@interface PQPostViewController ()
@property (strong, nonatomic) UIImageView *postImage;
@property (strong, nonatomic) UIView *border;
@property (strong, nonatomic) UIButton *btnBack;
@property (strong, nonatomic) UICollectionView *commentsCollectionView;
@property (strong, nonatomic) UIView *infoBox;
@property (strong, nonatomic) UILabel *lblCaption;
@property (strong, nonatomic) UILabel *lblLocation;
@property (strong, nonatomic) UIView *fullImageView;
@property (strong, nonatomic) UIImageView *fullImage;
@property (strong, nonatomic) UIView *commentsFieldView;
@property (strong, nonatomic) UITextView *commentsField;
@property (strong, nonatomic) UIButton *btnLike;
@property (strong, nonatomic) UIButton *btnShare;
@property (strong, nonatomic) UILabel *lblDate;
@property (nonatomic) BOOL textFieldCanDismiss;
@end

static NSString *cellIdentifier = @"commentCellIdentifier";
#define kTopInset 200.0f
#define kCommentViewHeight 44.0f

@implementation PQPostViewController
@synthesize post;
@synthesize offset;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.textFieldCanDismiss = NO;

    }
    return self;
}

- (void)dealloc
{
    [self.commentsCollectionView removeObserver:self forKeyPath:@"contentOffset"];
//    [self.lblCaption removeObserver:self forKeyPath:@"text"];
}

- (void)loadView
{
    
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor greenColor];
    CGRect frame = view.frame;
    
    CGFloat y = frame.size.height;
    PQCollectionViewFlowLayout *layout = [[PQCollectionViewFlowLayout alloc] init];
    self.commentsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(30.0f, y, frame.size.width-30, frame.size.height-20.0f) collectionViewLayout:layout];
    
    [self.commentsCollectionView registerClass:[PQCommentViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    self.commentsCollectionView.backgroundColor = [UIColor clearColor];
    self.commentsCollectionView.showsVerticalScrollIndicator = NO;
    self.commentsCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.commentsCollectionView.dataSource = self;
    self.commentsCollectionView.delegate = self;
    self.commentsCollectionView.contentInset = UIEdgeInsetsMake(kTopInset, 0.0f, 54.0f, 0.0f);
    
    self.infoBox = [[UIView alloc]initWithFrame:CGRectMake(0, -kTopInset, frame.size.width, kTopInset)];
    self.infoBox.backgroundColor = [UIColor clearColor];
    [self.commentsCollectionView addSubview:self.infoBox];
    [self.commentsCollectionView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];

    [view addSubview:self.commentsCollectionView];


    CGFloat dimen = 0.70f*kPostCellDimension;
    self.border = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen+4, dimen+4)];
    self.border.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.border.center = CGPointMake(67.5f, 47.5f);
    self.border.backgroundColor = [UIColor whiteColor];
    self.border.layer.cornerRadius = 0.5f*(dimen+2);
    [view addSubview:self.border];
    
    self.postImage = [[UIImageView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, dimen, dimen)];
    self.postImage.tag = 1001;
    self.postImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.postImage.backgroundColor = [UIColor yellowColor];
    self.postImage.image = self.post.imageData;
    self.postImage.layer.cornerRadius = 0.5*dimen;
    self.postImage.layer.masksToBounds = YES;
    self.postImage.center = self.border.center;
    self.postImage.userInteractionEnabled = YES;
    [self.postImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage:)]];
    [view addSubview:self.postImage];
    

    CGFloat x = self.border.frame.origin.x+dimen+16.0f;
    y = 0;
    CGFloat width = frame.size.width-x;
    
    self.lblLocation = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 22.0f)];
    self.lblLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblLocation.backgroundColor = [UIColor clearColor];
    self.lblLocation.textColor = [UIColor lightGrayColor];
    self.lblLocation.text = [NSString stringWithFormat:@"%@, %@", self.post.city, [self.post.state uppercaseString]];
    self.lblLocation.alpha = 0.0f;
    self.lblLocation.font = [UIFont systemFontOfSize:14.0f];
    [view addSubview:self.lblLocation];
    y += self.lblLocation.frame.size.height;

    
    UIFont *verdana = [UIFont fontWithName:@"Verdana" size:16.0f];
    CGRect boudingRect = [self.post.caption boundingRectWithSize:CGSizeMake(width, 250.0f)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:verdana}
                                                         context:NULL];

    
    self.lblCaption = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, boudingRect.size.height+4.0f)];
    self.lblCaption.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor whiteColor];
    self.lblCaption.text = self.post.caption;
    self.lblCaption.alpha = 0.0f;
    self.lblCaption.font = verdana;
    [view addSubview:self.lblCaption];
    y += self.lblCaption.frame.size.height+20.0f;
    
    UIImage *imgHeart = nil;
    UIColor *btnColor = nil;
    if ([self.post.likes containsObject:self.session.deviceHash]){
        imgHeart = [UIImage imageNamed:@"iconHeartRed.png"];
        btnColor = [UIColor whiteColor];
    }
    else{
        imgHeart = [UIImage imageNamed:@"iconHeart.png"];
        btnColor = [UIColor darkGrayColor];
    }
    
    self.btnLike = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnLike.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnLike.frame = CGRectMake(x, y, imgHeart.size.width, imgHeart.size.height);
    [self.btnLike setBackgroundImage:imgHeart forState:UIControlStateNormal];
    [self.btnLike setTitleColor:btnColor forState:UIControlStateNormal];
    [self.btnLike setTitle:[NSString stringWithFormat:@"%d", self.post.likes.count] forState:UIControlStateNormal];
    self.btnLike.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.btnLike addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.btnLike];
    x += self.btnLike.frame.size.width;
    
    UIImage *imgShare = [UIImage imageNamed:@"iconShare.png"];
    self.btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnShare.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.btnShare setBackgroundImage:imgShare forState:UIControlStateNormal];
    self.btnShare.frame = CGRectMake(x, y, imgShare.size.width, imgShare.size.height);
    [view addSubview:self.btnShare];
    x += self.btnShare.frame.size.width;
    
    self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(x, y+8.5f, frame.size.width-x-10.0f, 22.0f)];
    self.lblDate.textColor = [UIColor darkGrayColor];
    self.lblDate.textAlignment = NSTextAlignmentCenter;
    self.lblDate.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.lblDate.backgroundColor = [UIColor whiteColor];
    self.lblDate.layer.cornerRadius = 4.0f;
    self.lblDate.text = self.post.formattedDate;
    self.lblDate.font = [UIFont systemFontOfSize:12.0f];
    if (self.post.formattedDate==nil)
        [self.post formatTimestamp];
    
    self.lblDate.text = self.post.formattedDate;
    [view addSubview:self.lblDate];

    
    UIImage *backArrow = [UIImage imageNamed:@"backarrow.png"];
    self.btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBack addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBack setBackgroundImage:backArrow forState:UIControlStateNormal];
    self.btnBack.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.btnBack.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.btnBack.frame = CGRectMake(12.0f, 10.0f, backArrow.size.width, backArrow.size.height);
    self.btnBack.center = CGPointMake(self.btnBack.center.x, 0.4f*frame.size.height);
    self.btnBack.alpha = 0.0f;
    [view addSubview:self.btnBack];

    // off screen bottom:
    self.commentsFieldView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, view.frame.size.height, frame.size.width, kCommentViewHeight)];
    self.commentsFieldView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.commentsFieldView.backgroundColor = [UIColor whiteColor];
    self.commentsFieldView.alpha = 0.90f;
    
    self.commentsField = [[UITextView alloc] initWithFrame:CGRectMake(5.0f, 5.0f, frame.size.width-90.0f, kCommentViewHeight-10.0f)];
    self.commentsField.delegate = self;
    self.commentsField.layer.cornerRadius = 3.0f;
    self.commentsField.layer.masksToBounds = YES;
    self.commentsField.returnKeyType = UIReturnKeyDone;
    self.commentsField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.commentsField.backgroundColor = [UIColor darkGrayColor];
    self.commentsField.textColor = [UIColor whiteColor];
    self.commentsField.font = [UIFont fontWithName:@"Verdana" size:14.0f];
    [self.commentsFieldView addSubview:self.commentsField];
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat w = 75.0f;
    btnSend.frame = CGRectMake(frame.size.width-w-5.0f, 5.0f, w, kCommentViewHeight-10.0f);
    [btnSend setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    btnSend.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    btnSend.backgroundColor = [UIColor clearColor];
    [btnSend addTarget:self action:@selector(submitComment) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsFieldView addSubview:btnSend];
    [view addSubview:self.commentsFieldView];
    

    self.fullImageView = [[UIView alloc] initWithFrame:view.frame];
    self.fullImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.fullImageView.backgroundColor = [UIColor blackColor];
    self.fullImageView.alpha = 0.0f;
    
    self.fullImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.width)];
    self.fullImage.center = self.fullImageView.center;
    [self.fullImageView addSubview:self.fullImage];
    
    width = 0.5f*view.frame.size.width;
    UIButton *btnExitFullImage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExitFullImage.frame = CGRectMake(0.5*(view.frame.size.width-width), view.frame.size.height-50.0f, width, 36.0f);
    btnExitFullImage.titleLabel.font = verdana;
    [btnExitFullImage setTitle:@"Close" forState:UIControlStateNormal];
    [btnExitFullImage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnExitFullImage addTarget:self action:@selector(exitFullImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullImageView addSubview:btnExitFullImage];

    
    [view addSubview:self.fullImageView];


    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PQAppDelegate *appDelegate = (PQAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.showStatusBar = NO;
    
    [UIView animateWithDuration:0.33f animations:^{
        self.btnBack.alpha = 1.0f;
        self.lblCaption.alpha = 1.0f;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    
    [UIView animateWithDuration:1.0f
                          delay:0
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.commentsCollectionView.frame;
                         frame.origin.y = 0.0f;
                         self.commentsCollectionView.frame = frame;
                     }
                     completion:^(BOOL finished){ // animate text view
                         [UIView animateWithDuration:0.30f
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              CGRect frame = self.commentsFieldView.frame;
                                              frame.origin.y = self.view.frame.size.height-kCommentViewHeight-20.0f;
                                              self.commentsFieldView.frame = frame;
                                          }
                                          completion:NULL];
                         
                     }];

    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.commentsCollectionView.collectionViewLayout invalidateLayout];
    [self refreshCommentsCollectionView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]){
        CGFloat verticalOffset = self.commentsCollectionView.contentOffset.y;
        if (verticalOffset < -kTopInset){
//            NSLog(@"%.2f", verticalOffset);
            
            verticalOffset *= -1;
            double diff = verticalOffset-kTopInset;
            double factor = diff/250.0f;
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0f+factor, 1.0f+factor);
            self.postImage.transform = transform;
            self.border.transform = transform;
            
            self.lblCaption.alpha = 1.0f;
            self.lblLocation.alpha = 1.0f;
            self.btnLike.alpha = 1.0f;
            self.btnShare.alpha = 1.0f;
            self.lblDate.alpha = 1.0f;
            return;
        }
        
        verticalOffset += kTopInset; // callibrate to 0
//        NSLog(@"%.2f", verticalOffset);
        
        if (verticalOffset > 100.0f){
            self.lblCaption.alpha = 0.0f;
            self.lblLocation.alpha = 0.0f;
            self.btnLike.alpha = 0.0f;
            self.btnShare.alpha = 0.0f;
            self.lblDate.alpha = 0.0f;
            return;
        }
        
        double d = 1-(verticalOffset/100.0f);
        self.lblCaption.alpha = d;
        self.lblLocation.alpha = d;
        self.btnLike.alpha = d;
        self.btnShare.alpha = d;
        self.lblDate.alpha = d;
    }
}


- (void)exit:(UIButton *)btn
{
    self.commentsField.delegate = nil;
    
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.commentsCollectionView.frame;
                         frame.origin.y = self.view.frame.size.height;
                         self.commentsCollectionView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [self.navigationController popViewControllerAnimated:NO];
                     }];
    

    
}

- (void)refreshCommentsCollectionView
{
    // IMPORTANT: Have to call this on main thread! Otherwise, data models in array might not be synced, and reload acts funky
    dispatch_async(dispatch_get_main_queue(), ^{
        [self. commentsCollectionView reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i=0; i<self.post.comments.count; i++)
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [self.commentsCollectionView reloadItemsAtIndexPaths:indexPaths];
    });
}

- (void)viewImage:(UITapGestureRecognizer *)tap
{
    NSLog(@"viewImage:");
    
    self.fullImage.image = self.post.imageData;
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 1.0f;
                         self.fullImageView.alpha = 1.0f;

                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void)exitFullImage:(UIButton *)btn
{
    [UIView animateWithDuration:0.25f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.fullImage.alpha = 0.0f;
                         self.fullImageView.alpha = 0.0f;
                         
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)shiftMessageComposeView:(CGFloat)y withDelay:(double)delay
{
    self.commentsCollectionView.delegate = nil;
    [UIView animateWithDuration:0.26f-delay
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.commentsFieldView.frame;
                         frame.origin.y = y;
                         self.commentsFieldView.frame = frame;
                         
                         if (delay > 0){
                             // shifting up - make room for the keyboard:
//                             CGFloat d = self.threadTable.contentSize.height-self.threadTable.frame.size.height;
//                             self.threadTable.contentOffset = CGPointMake(0, d+190.0f);
                         }
                     }
                     completion:^(BOOL finished){
                         self.commentsCollectionView.delegate = self;
                     }];
}

- (void)submitComment
{
    self.textFieldCanDismiss = YES;

    
    if (self.commentsField.text.length==0){
        [self showAlertWithtTitle:@"Missing Comment" message:@"Please enter a comment."];
        return;
    }
    
    [self.commentsField resignFirstResponder];
    [self shiftMessageComposeView:self.view.frame.size.height-kCommentViewHeight-20.0f withDelay:0.0f];

    
    PQComment *comment = [[PQComment alloc] init];
    comment.deviceHash = self.session.deviceHash;
    comment.text = self.commentsField.text;
    comment.post = self.post.uniqueId;
    
    [self.loadingIndicator startLoading];
    [[PQWebServices sharedInstance] postComment:comment completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        
        if (error){
            
        }
        else {
            NSDictionary *results = (NSDictionary *)result;
            NSString *confirmation = results[@"confirmation"];
            if ([confirmation isEqualToString:@"success"]){
//                NSLog(@"%@", [results description]);
                self.commentsField.text = @"";
                [self.post.comments removeAllObjects];
                [self.post populate:results[@"post"]]; // update the post
                [self refreshCommentsCollectionView];
                
                
            }
            else{
                [self showAlertWithtTitle:@"Error" message:results[@"message"]];
                
            }
        }
        
    }];
}

- (void)likePost:(UIButton *)btn
{
    UIImage *btnImage = nil;
    UIColor *btnColor = nil;
    if ([self.post.likes containsObject:self.session.deviceHash]){ // remove like
        [self.post.likes removeObject:self.session.deviceHash];
        btnImage = [UIImage imageNamed:@"iconHeart@2x"];
        btnColor = [UIColor darkGrayColor];
        
    }
    else{
        [self.post.likes addObject:self.session.deviceHash];
        btnImage = [UIImage imageNamed:@"iconHeartRed@2x"];
        btnColor = [UIColor whiteColor];
    }
    
    [UIView transitionWithView:btn
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        btn.alpha = 1.0f;
                        [btn setBackgroundImage:btnImage forState:UIControlStateNormal];
                        [btn setTitleColor:btnColor forState:UIControlStateNormal];
                        [btn setTitle:[NSString stringWithFormat:@"%d", self.post.likes.count] forState:UIControlStateNormal];
                    }
                    completion:^(BOOL finished){ // send api call
                        if ([self.post.likes containsObject:self.session.deviceHash]){ // remove like
                            [[PQWebServices sharedInstance] likePost:self.post withDevice:self.session.deviceHash completion:^(id result, NSError *error){
                                
                            }];
                        }
                        else{
                            [[PQWebServices sharedInstance] unlikePost:self.post withDevice:self.session.deviceHash completion:^(id result, NSError *error){
                                
                            }];
                        }
                        
                    }];
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.textFieldCanDismiss = NO;

    [self shiftMessageComposeView:self.view.frame.size.height-236.0f-kCommentViewHeight withDelay:0.0f];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    NSLog(@"textView shouldChangeTextInRange: %d, %d, %@", range.length, range.location, text);
    
    if ([text isEqualToString:@"\n"]){ // done button
        [self submitComment];
        return NO;
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"textViewShouldEndEditing:");
    return self.textFieldCanDismiss;
}


#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewWillBeginDragging: %.2f", self.contentOffsetY);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"scrollViewDidScroll: %.2f", scrollView.contentOffset.y);
    
    
    if (self.commentsField.isFirstResponder==NO)
        return;
    
    self.textFieldCanDismiss = (self.commentsField.text.length==0);
    if (self.textFieldCanDismiss==NO)
        return;
    
    
    [self.commentsField resignFirstResponder];
    [self shiftMessageComposeView:self.view.frame.size.height-kCommentViewHeight-20.0f withDelay:0.0f];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"scrollViewDidEndDragging:");
    
    if (scrollView.contentOffset.y < -225.0f)
        [self viewImage:nil];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // NOTE: this is a workaround. adding extra rows here in order to guarantee scrollability. Increasing the contentSize property didn't work

    return (self.post.comments.count < 5) ? 5 : self.post.comments.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PQCommentViewCell *cell = (PQCommentViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row >= self.post.comments.count){
        cell.contentView.alpha = 0;
        return cell;
    }
    
    
    cell.contentView.alpha = 1.0f;
    PQComment *comment = (PQComment *)self.post.comments[indexPath.row];
    cell.lblText.text = comment.text;
    cell.lblDate.text = comment.formattedDate;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat defaultHeight = 0.6f*kPostCellDimension;
    CGFloat defaultWidth = self.view.frame.size.width-30-24.0f;
    
    if (indexPath.row >= self.post.comments.count)
        return CGSizeMake(defaultWidth, defaultHeight);
    
    
    PQComment *comment = (PQComment *)self.post.comments[indexPath.row];
    CGRect boudingRect = [comment.text boundingRectWithSize:CGSizeMake([PQCommentViewCell textLabelWidth], 250.0f)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[PQCommentViewCell textLabelFont]}
                                                    context:NULL];

    CGFloat h = (boudingRect.size.height+40.0f < defaultHeight) ? defaultHeight : boudingRect.size.height+60.0f;
    
    return CGSizeMake(defaultWidth, h);

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
