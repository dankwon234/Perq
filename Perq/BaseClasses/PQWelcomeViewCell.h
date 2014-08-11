//
//  PQWelcomeViewCell.h
//  Perq
//
//  Created by Dan Kwon on 8/10/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PQWelcomeViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *contentImage;
@property (strong, nonatomic) UITextField *phoneNumberField;
@property (strong, nonatomic) UIButton *btnSignup;
@property (strong, nonatomic) UILabel *lblCaption;
@property (strong, nonatomic) UILabel *lblDescription;
@end
