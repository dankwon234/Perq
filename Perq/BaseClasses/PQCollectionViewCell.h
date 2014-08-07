//
//  PQCollectionViewCell.h
//  Perq
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@interface PQCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UIButton *btnComment;
@property (strong, nonatomic) UIButton *btnHeart;
- (void)slideOut:(double)delay;
- (void)restoreSubviews:(double)delay;
- (void)selected;
- (void)animateIcon;
@end
