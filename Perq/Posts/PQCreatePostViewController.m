//
//  PQCreatePostViewController.m
//  Perq
//
//  Created by Dan Kwon on 8/4/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQCreatePostViewController.h"
#import "PQPost.h"

@interface PQCreatePostViewController ()
@property (strong, nonatomic) PQPost *post;
@property (strong, nonatomic) UITextView *captionTextView;
@end

@implementation PQCreatePostViewController
@synthesize selectedImage;

static NSString *placeholder = @"Enter a short caption here.";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.post = [[PQPost alloc] init];
        self.post.deviceHash = self.session.deviceHash;
        
    }
    
    return self;
}

- (void)loadView
{
    UIView *view = [self baseView:NO];
    view.backgroundColor = [UIColor redColor];
    CGRect frame = view.frame;
    
    CGFloat dimen = 0.70f*kPostCellDimension;
    
    static CGFloat padding = 12.0f;
    CGFloat x = padding;
    CGFloat y = padding;
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(x, y, dimen+4, dimen+4)];
    border.backgroundColor = [UIColor whiteColor];
    border.layer.cornerRadius = 0.5f*(dimen+2);
    [view addSubview:border];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dimen, dimen)];
    imageView.center = border.center;
    imageView.backgroundColor = [UIColor yellowColor];
    imageView.image = self.selectedImage;
    imageView.layer.cornerRadius = 0.5*dimen;
    imageView.layer.masksToBounds = YES;
    [view addSubview:imageView];
    
    x += dimen+8.0f;
    self.captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, frame.size.width-x-padding, dimen)];
    self.captionTextView.returnKeyType = UIReturnKeyDone;
    self.captionTextView.backgroundColor = [UIColor yellowColor];
    self.captionTextView.textColor = [UIColor lightGrayColor];
    self.captionTextView.text = placeholder;
    self.captionTextView.font = [UIFont fontWithName:@"Verdana" size:16.0f];
    self.captionTextView.delegate = self;
    [view addSubview:self.captionTextView];
    
    y += dimen+padding;
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0.0f, y, frame.size.width, frame.size.height)];
    bottom.backgroundColor = [UIColor greenColor];
    
    UIButton *btnUpload = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpload.frame = CGRectMake(padding, padding, frame.size.width-2*padding, 44.0f);
    [btnUpload setTitle:@"Upload Photo" forState:UIControlStateNormal];
    [btnUpload addTarget:self action:@selector(submitPost:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:btnUpload];
    
    
    [view addSubview:bottom];
    
    
    
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self.captionTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)updatePost
{
    NSString *text = self.captionTextView.text;
    if ([text isEqualToString:placeholder] || text.length==0)
        self.post.caption = @"none";
    else
        self.post.caption = self.captionTextView.text;
    
}

- (void)submitPost:(id)sender
{
    if ([self.post.caption isEqualToString:placeholder]){
        [self showAlertWithOptions:@"Missing Caption" message:@"Please enter a short caption for your picture."];
        return;
    }
    
    if ([self.post.caption isEqualToString:@"none"]){
        [self showAlertWithOptions:@"Missing Caption" message:@"Please enter a short caption for your picture."];
        return;
    }
    
    if (self.post.caption.length==0){
        [self showAlertWithOptions:@"Missing Caption" message:@"Please enter a short caption for your picture."];
        return;
    }
    
    
    NSLog(@"submitPost: %@", [self.post jsonRepresentation]);
    [self.loadingIndicator startLoading];
    
    [[PQWebServices sharedInstance] fetchUploadString:^(id result, NSError *error){
        if (error){
            
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            NSString *confirmation = results[@"confirmation"];
//            NSLog(@"%@", [results description]);
            if ([confirmation isEqualToString:@"success"]){
                [self uploadImage:results[@"upload"]];
            }
            else {
                [self.loadingIndicator stopLoading];
                [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            }
        }
        
    }];



}
            

- (void)uploadImage:(NSString *)uploadUrl
{
    NSData *imageData = UIImageJPEGRepresentation(self.selectedImage, 0.8f);
    [[PQWebServices sharedInstance] uploadImage:@{@"name":@"image.jpg", @"data":imageData}
                                          toUrl:uploadUrl
                                     completion:^(id result, NSError *error){
                                         
                                         if (error){
                                             
                                         }
                                         else{
                                             NSDictionary *results = (NSDictionary *)result;
                                             NSString *confirmation = results[@"confirmation"];
                                             NSLog(@"%@", [results description]);
                                             if ([confirmation isEqualToString:@"success"]){
                                                 NSDictionary *imageInfo = results[@"image"];
                                                 self.post.image = imageInfo[@"id"];
                                                 [self createPost]; // Post post to backend
                                             }
                                             else{
                                                 [self.loadingIndicator stopLoading];
                                                 [self showAlertWithtTitle:@"Error" message:results[@"message"]];
                                             }
                                         }
                                     }];
}

- (void)createPost
{
    [[PQWebServices sharedInstance] createPost:self.post completion:^(id result, NSError *error){
        [self.loadingIndicator stopLoading];
        if (error){
            
        }
        else{
            NSDictionary *results = (NSDictionary *)result;
            NSString *confirmation = results[@"confirmation"];
            NSLog(@"%@", [results description]);
            if ([confirmation isEqualToString:@"success"]){
                
                
            }
            else{
                [self showAlertWithtTitle:@"Error" message:results[@"message"]];
            }
        }
    }];
}



#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:placeholder])
        textView.text = @"";
    
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) { // Done button
        [self submitPost:textView];
        return NO;
    }
    
    [self performSelector:@selector(updatePost) withObject:nil afterDelay:0.1];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
