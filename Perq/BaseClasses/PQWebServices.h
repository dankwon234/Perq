//
//  PQWebServices.h
//  Pique
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PQPost.h"
#import "PQComment.h"

typedef void (^PQWebServiceRequestCompletionBlock)(id result, NSError *error);



@interface PQWebServices : NSObject


+ (PQWebServices *)sharedInstance;

// Images:
- (void)fetchUploadString:(PQWebServiceRequestCompletionBlock)completionBlock;
- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(PQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchImage:(NSString *)imageId completion:(PQWebServiceRequestCompletionBlock)completionBlock;

// Post:
- (void)fetchPosts:(PQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchPostsFromDevice:(NSString *)deviceHash completion:(PQWebServiceRequestCompletionBlock)completionBlock;
- (void)fetchPostsFromLocation:(NSDictionary *)location completion:(PQWebServiceRequestCompletionBlock)completionBlock;
- (void)createPost:(PQPost *)post completion:(PQWebServiceRequestCompletionBlock)completionBlock;

// Comments:
- (void)postComment:(PQComment *)comment completion:(PQWebServiceRequestCompletionBlock)completionBlock;

@end
