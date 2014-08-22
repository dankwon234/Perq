//
//  PQSocialAccountsManager.m
//  Perq
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQSocialAccountsManager.h"


@implementation PQSocialAccountsManager
@synthesize accountStore;
@synthesize facebookAccount;
@synthesize twitterAccounts;

#define kErrorDomain @"com.perc.ios"

+ (PQSocialAccountsManager *)sharedAccountManager
{
    static PQSocialAccountsManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[PQSocialAccountsManager alloc] init];
        
    });
    
    return shared;
}


#pragma mark - Twitter
- (void)requestTwitterAccess:(PQSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *twitterAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
    [accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted==NO) {
            error = [NSError errorWithDomain:@"com.flashzone.app" code:14 userInfo:@{NSLocalizedDescriptionKey:@"Authorization not granted."}];
            completionBlock(nil, error);
            return ;
        }
        
        NSArray *accounts = [accountStore accountsWithAccountType:twitterAccountType];
        
        // Check if the users has setup at least one Twitter account
        if (accounts.count == 0) {
            NSLog(@"No Twitter Acccounts found.");
            return;
        }
        
        self.twitterAccounts = accounts;
        completionBlock(self.twitterAccounts, nil);
        
        
        
    }];
}


- (void)requestTwitterProfileInfo:(ACAccount *)twitterAccount completionBlock:(PQSocialAccountsMgrCompletionBlock)completionBlock
{
    NSString *url = [kTwitterAPI stringByAppendingString:@"users/show.json"];
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:url] parameters:@{@"screen_name":twitterAccount.username}];
    twitterInfoRequest.account = twitterAccount;
    
    
    // Making the request
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 429) { // Check if we reached the reate limit
            //            NSLog(@"Rate limit reached");
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Rate limit reached"}]);
            return;
        }
        
        
        if (error){
            completionBlock(nil, error);
            return;
        }
        
        if (!responseData) {
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Response Data"}]);
        }
        
        error = nil;
        NSDictionary *twitterAccountInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error){ // JSON parsing error
            completionBlock(nil, error);
            return;
        }
        
        //        NSLog(@"%@", [twitterAccountInfo description]);
        completionBlock(twitterAccountInfo, nil);
        
    }];
    
}

- (void)fetchRecentTweets:(ACAccount *)twitterAccount completionBlock:(PQSocialAccountsMgrCompletionBlock)completionBlock
{
    NSString *url = [kTwitterAPI stringByAppendingString:@"statuses/user_timeline.json"];
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:url] parameters:@{@"screen_name":twitterAccount.username}];
    twitterInfoRequest.account = twitterAccount;
    
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if ([urlResponse statusCode] == 429) { // Check if we reached the reate limit
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"Rate limit reached"}]);
            return;
        }
        
        
        if (error){
            completionBlock(nil, error);
            return;
        }
        
        if (!responseData) {
            completionBlock(nil, [NSError errorWithDomain:kErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Response Data"}]);
        }
        
        error = nil;
        NSArray *recentTweets = (NSArray *)[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        
        if (error){ // JSON parsing error
            completionBlock(nil, error);
            return;
        }
        
        completionBlock(recentTweets, nil);
    }];
    
}



#pragma mark - Facebook
- (void)requestFacebookAccess:(NSArray *)permissions completionBlock:(PQSocialAccountsMgrCompletionBlock)completionBlock
{
    
    if (!self.accountStore)
        self.accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *FBaccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *dictFB = @{ACFacebookAppIdKey:kFacebookAppID, ACFacebookPermissionsKey:permissions};
    [accountStore requestAccessToAccountsWithType:FBaccountType options:dictFB completion:^(BOOL granted, NSError *e) {
        if (granted){
            if (e){
                completionBlock(nil, e);
            }
            else{
                NSArray *accounts = [accountStore accountsWithAccountType:FBaccountType];
                ACAccount *fbAccount = [accounts lastObject]; //it will always be the last object with single sign on
                ACAccountCredential *facebookCredential = [fbAccount credential];
                NSString *accessToken = [facebookCredential oauthToken];
                NSLog(@"Facebook Access Token: %@", accessToken);
                
                self.facebookAccount = fbAccount;
                NSLog(@"facebook account = %@", fbAccount.username);
                completionBlock(self.facebookAccount, nil);
            }
        }
        else{
            e = [NSError errorWithDomain:@"com.flashzone.app" code:14 userInfo:@{NSLocalizedDescriptionKey:@"Authorization not granted."}];
            completionBlock(nil, e);
            
        }
    }];
}


- (void)requestFacebookAccountInfo:(PQSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.facebookAccount) { // no facebook acccount linked
        NSError *error = [NSError errorWithDomain:@"com.perq.app" code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Facebook account linked. Please allow Facebook access."}];
        completionBlock(nil, error);
        return;
    }
    
    NSString *url = [kFacebookAPI stringByAppendingString:@"me"]; // https://graph.facebook.com/me
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *facebookAccountInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"FACEBOOK INFO: %@", [facebookAccountInfo description]);
            
            if (error){ // JSON parsing error
                completionBlock(nil, error);
            }
            else {
                completionBlock(facebookAccountInfo, nil);
            }
        }
        else { // handle error:
            NSLog(@"error from get - - %@", [error localizedDescription]); //attempt to revalidate credentials
            completionBlock(nil, error);
        }
    }];
}

- (void)requestFacebookUserFriends:(PQSocialAccountsMgrCompletionBlock)completionBlock
{
    if (!self.facebookAccount) { // no facebook acccount linked
        NSError *error = [NSError errorWithDomain:@"com.perq.app" code:0 userInfo:@{NSLocalizedDescriptionKey:@"No Facebook account linked. Please allow Facebook access."}];
        completionBlock(nil, error);
        return;
    }
    
    NSString *url = [kFacebookAPI stringByAppendingString:@"me/friends"]; // https://graph.facebook.com/me/friends
    NSURL *requestURL = [NSURL URLWithString:url];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:requestURL parameters:nil];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *facebookAccountInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"FACEBOOK USER FRIENDS: %@", [facebookAccountInfo description]);
            
            if (error){ // JSON parsing error
                completionBlock(nil, error);
            }
            else {
                completionBlock(facebookAccountInfo, nil);
            }
        }
        else { // handle error:
            NSLog(@"error from get - - %@", [error localizedDescription]); //attempt to revalidate credentials
            completionBlock(nil, error);
        }
    }];
}



@end
