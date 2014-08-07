//
//  PQLoadingIndicator.h
//  Pique
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PQLoadingIndicator : UIView

@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblMessage;
- (void)stopLoading;
- (void)startLoading;
@end
