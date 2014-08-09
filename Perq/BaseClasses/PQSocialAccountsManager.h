//
//  PQSocialAccountsManager.h
//  Perq
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Config.h"


typedef void (^PQSocialAccountsMgrCompletionBlock)(id result, NSError *error);

@interface PQSocialAccountsManager : NSObject

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) NSArray *twitterAccounts;
+ (PQSocialAccountsManager *)sharedAccountManager;

// Facebook
- (void)requestFacebookAccess:(NSArray *)permissions completionBlock:(PQSocialAccountsMgrCompletionBlock)completionBlock;
- (void)requestFacebookAccountInfo:(PQSocialAccountsMgrCompletionBlock)completionBlock;

// Twitter
- (void)requestTwitterAccess:(PQSocialAccountsMgrCompletionBlock)completionBlock;
- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completionBlock:(PQSocialAccountsMgrCompletionBlock)completionBlock;
- (void)fetchRecentTweets:(ACAccount *)twitterAccount completionBlock:(PQSocialAccountsMgrCompletionBlock)completionBlock;


@end
