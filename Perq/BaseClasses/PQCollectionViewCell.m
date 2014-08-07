//
//  PQCollectionViewCell.m
//  Perq
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQCollectionViewCell.h"

@interface PQCollectionViewCell ()
@property (strong, nonatomic) UIView *border;
@end

#define kIconDimen 32.0f
#define kImageDimen 0.70f*kPostCellDimension
#define kBorderWidth 2.0f

@implementation PQCollectionViewCell
@synthesize image;
@synthesize btnHeart;
@synthesize btnComment;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat x = 24.0f;
        self.border = [[UIView alloc] initWithFrame:CGRectMake(x-kBorderWidth, 0.0f, kImageDimen+2*kBorderWidth, kImageDimen+2*kBorderWidth)];
        self.border.backgroundColor = [UIColor whiteColor];
        self.border.layer.cornerRadius = 0.5f*(kImageDimen+kBorderWidth);
        self.border.layer.masksToBounds = YES;
        [self.contentView addSubview:self.border];
        
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(x, kBorderWidth, kImageDimen, kImageDimen)];
        self.image.image = [UIImage imageNamed:@"placeholder.png"];
        self.image.backgroundColor = [UIColor yellowColor];
        self.image.layer.cornerRadius = 0.5*kImageDimen;
        self.image.layer.masksToBounds = YES;
        [self.contentView addSubview:self.image];
        
        
        x = 28.0f;
        CGFloat y = frame.size.height-58.0f;
        self.btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnComment.frame = CGRectMake(x, y, kIconDimen, kIconDimen);
        self.btnComment.titleLabel.font = [UIFont systemFontOfSize:10.0f];
//        [self.btnComment setTitle:@"11" forState:UIControlStateNormal];
        [self.btnComment setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnComment setBackgroundImage:[UIImage imageNamed:@"iconComment.png"] forState:UIControlStateNormal];
        self.btnComment.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 4.0f, 0.0f);
        [self.contentView addSubview:self.btnComment];

        self.btnHeart = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHeart.frame = CGRectMake(x+54, y, kIconDimen, kIconDimen);
        [self.btnHeart setBackgroundImage:[UIImage imageNamed:@"iconHeart.png"] forState:UIControlStateNormal];
        [self.btnHeart setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        self.btnHeart.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 4.0f, 0.0f);
        self.btnHeart.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        [self.contentView addSubview:self.btnHeart];
        
        
    }
    return self;
}

- (void)animateIcon
{
    self.image.alpha = 0.0f;
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.image.alpha = 1.0f;
                     }
                     completion:NULL];
}


- (void)slideOut:(double)delay
{
    self.btnComment.alpha = 0;
    self.btnHeart.alpha = 0;

    [UIView animateWithDuration:0.24f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ // slide to right
                         CGPoint ctr = self.image.center;
                         ctr.x += 2*self.frame.size.width;
                         self.image.center = ctr;
                         self.border.center = ctr;
                     }
                     completion:^(BOOL finished){
                         CGAffineTransform shrink = CGAffineTransformMakeScale(0, 0);
                         self.btnComment.transform = shrink;
                         self.btnHeart.transform = shrink;
                     }];
}

- (void)selected
{
    self.btnComment.alpha = 0;
    self.btnHeart.alpha = 0;
    self.image.alpha = 0;
    self.border.alpha = 0;
    
    CGAffineTransform shrink = CGAffineTransformMakeScale(0, 0);
    self.btnComment.transform = shrink;
    self.btnHeart.transform = shrink;
}

- (void)restoreSubviews:(double)delay
{
//    NSLog(@"restoreSubviews: %.2f", self.image.frame.origin.x);
    
    if (self.image.frame.origin.x > 100){
        self.image.alpha = 1.0f;
        self.border.alpha = 1.0f;
    }

    [UIView animateWithDuration:0.24f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat x = 24.0f;
                         self.border.frame = CGRectMake(x-kBorderWidth, 0.0f, kImageDimen+2*kBorderWidth, kImageDimen+2*kBorderWidth);
                         self.image.frame = CGRectMake(x, kBorderWidth, kImageDimen, kImageDimen);
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.3f
                                               delay:0.4f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.image.alpha = 1.0f;
                                              self.border.alpha = 1.0f;

                                              self.btnComment.alpha = 1.0f;
                                              self.btnHeart.alpha = 1.0f;
                                              
                                              CGAffineTransform tfIdentity = CGAffineTransformIdentity;
                                              self.btnComment.transform = tfIdentity;
                                              self.btnHeart.transform = tfIdentity;

                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];

                     }];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
