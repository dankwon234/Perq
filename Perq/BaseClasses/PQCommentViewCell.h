//
//  PQCommentViewCell.h
//  Perq
//
//  Created by Dan Kwon on 8/5/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PQCommentViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *lblText;
@property (strong, nonatomic) UILabel *lblDate;
+ (CGFloat)textLabelWidth;
+ (UIFont *)textLabelFont;
@end
