//
//  PQViewController.h
//  Pique
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "PQLoadingIndicator.h"
#import "UIImage+PQImageEffects.h"
#import "UIView+PQViewAdditions.h"
#import "PQWebServices.h"
#import "PQSession.h"
#import "PQSocialAccountsManager.h"


@interface PQViewController : UIViewController

@property (strong, nonatomic) PQLoadingIndicator *loadingIndicator;
@property (strong, nonatomic) PQSession *session;
@property (strong, nonatomic) PQSocialAccountsManager *socialAccountsMgr;
- (UIView *)baseView:(BOOL)navCtr;
- (void)showAlertWithtTitle:(NSString *)title message:(NSString *)msg;
- (void)showAlertWithOptions:(NSString *)title message:(NSString *)msg;
@end
