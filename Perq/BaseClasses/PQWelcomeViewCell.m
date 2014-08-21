//
//  PQWelcomeViewCell.m
//  Perq
//
//  Created by Dan Kwon on 8/10/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQWelcomeViewCell.h"
#import "Config.h"

@interface PQWelcomeViewCell ()
@property (strong, nonatomic) UIView *background;
@end

@implementation PQWelcomeViewCell
@synthesize contentImage;
@synthesize btnSignup;
@synthesize lblCaption;
@synthesize lblDescription;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        NSLog(@"INIT WELCOME VIEW CELL");
        self.contentView.backgroundColor = [UIColor clearColor];
        
        static CGFloat padding = 12.0f;
        self.background = [[UIView alloc] initWithFrame:CGRectMake(padding, padding, frame.size.width-2*padding, frame.size.height-2*padding)];
        self.background.backgroundColor = [UIColor whiteColor];
        self.background.alpha = 0.75f;
        self.background.layer.cornerRadius = 4.0f;
        self.background.layer.masksToBounds = YES;
        [self.contentView addSubview:self.background];
        
        CGFloat dimen = 0.40f*frame.size.width;
        self.contentImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2*dimen, dimen)];
        self.contentImage.center = CGPointMake(self.contentView.center.x, 0.65f*self.contentView.center.y);
        self.contentImage.image = [UIImage imageNamed:@"tutorial-1.png"];
        [self.contentView addSubview:self.contentImage];
        
        CGFloat height = 30.0f;
        self.lblCaption = [[UILabel alloc] initWithFrame:CGRectMake(0.5f*frame.size.width+5.0f, 40.0f, 120.0f, height)];
        self.lblCaption.backgroundColor = [UIColor clearColor];
        self.lblCaption.numberOfLines = 0;
        self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblCaption.textColor = [UIColor darkGrayColor];
        self.lblCaption.textAlignment = NSTextAlignmentCenter;
        self.lblCaption.font = [UIFont fontWithName:@"Verdana" size:16.0f];
        [self.lblCaption addObserver:self forKeyPath:@"text" options:0 context:NULL];
        [self.contentView addSubview:self.lblCaption];
        
        CGFloat width = frame.size.width-4*padding;
        self.lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(2*padding, 160.0f, width, height)];
        self.lblDescription.numberOfLines = 0;
        self.lblDescription.textAlignment = NSTextAlignmentCenter;
        self.lblDescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblDescription.backgroundColor = [UIColor clearColor];
        self.lblDescription.font = [UIFont fontWithName:@"Verdana" size:14.0f];
        self.lblDescription.textColor = [UIColor darkGrayColor];
        [self.lblDescription addObserver:self forKeyPath:@"text" options:0 context:NULL];
        [self.contentView addSubview:self.lblDescription];
        
        self.btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSignup.frame = CGRectMake(2*padding, frame.size.height-30.0f-2*padding, width, height);
        self.btnSignup.backgroundColor = kRed;
        [self.btnSignup setTitle:@"Go" forState:UIControlStateNormal];
        [self.btnSignup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.btnSignup];

        
    }
    return self;
}

- (void)dealloc
{
    [self.lblDescription removeObserver:self forKeyPath:@"text"];
    [self.lblCaption removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.lblDescription]){
        if ([keyPath isEqualToString:@"text"]==NO)
            return;
        
        CGRect frame = self.lblDescription.frame;
        CGRect boudingRect = [self.lblDescription.text boundingRectWithSize:CGSizeMake(frame.size.width, 250.0f)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:self.lblDescription.font}
                                                                    context:NULL];
        
        frame.size.height = boudingRect.size.height+10.0f;
        self.lblDescription.frame = frame;
    }
    
    if ([object isEqual:self.lblCaption]){
        if ([keyPath isEqualToString:@"text"]==NO)
            return;
        
        CGRect frame = self.lblCaption.frame;
        CGRect boudingRect = [self.lblCaption.text boundingRectWithSize:CGSizeMake(frame.size.width, 250.0f)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:self.lblCaption.font}
                                                                    context:NULL];
        
        frame.size.height = boudingRect.size.height+10.0f;
        self.lblCaption.frame = frame;
    }

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
