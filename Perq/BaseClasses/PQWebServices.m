//
//  PQWebServices.m
//  Pique
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQWebServices.h"
#import "AFNetworking.h"
#include <sys/xattr.h>


#define kBaseUrl @"http://thegrid-perq.appspot.com/"
#define kSSLBaseUrl @"https://thegrid-perq.appspot.com/"
#define kPathUpload @"/api/upload/"
#define kPathImages @"/api/images/"
#define kPathSiteImages @"/site/images/"
#define kPathPosts @"/api/posts/"
#define kPathComments @"/api/comments/"


@implementation PQWebServices



+ (PQWebServices *)sharedInstance
{
    static PQWebServices *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[PQWebServices alloc] init];
        
    });
    
    return shared;
}

// - - - - - - - - - - - - - - - - - - - - - - - - IMAGES - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (void)fetchUploadString:(PQWebServiceRequestCompletionBlock)completionBlock
{
//    SignalCheck *signalCheck = [SignalCheck signalWithDelegate:self];
//    if (![signalCheck checkSignal]){
//        NSDictionary *results = @{@"confirmation":@"fail", @"message":@"No Connection. Please find an internet connection."};
//        if (completionBlock)
//            completionBlock(results, nil);
//        
//        return;
//    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [httpClient getPath:kPathUpload
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSError *error = nil;
                    NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                      options:NSJSONReadingMutableContainers
                                                                                                        error:&error];
                    
                    if (error){
//                        NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                        completionBlock(responseObject, error);
                    }
                    else{
                        //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                        NSDictionary *results = [responseDictionary objectForKey:@"results"];
                        NSString *confirmation = [results objectForKey:@"confirmation"];
                        
                        if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                            if (completionBlock)
                                completionBlock(results, error);
                        }
                        else{
                            if (completionBlock)
                                completionBlock(results, nil);
                        }
                    }
                }
     
                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                    if (completionBlock)
                        completionBlock(nil, error);
                }];
}


- (void)uploadImage:(NSDictionary *)image toUrl:(NSString *)uploadUrl completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
//    SignalCheck *signalCheck = [SignalCheck signalWithDelegate:self];
//    if (![signalCheck checkSignal]){
//        NSDictionary *results = @{@"confirmation":@"fail", @"message":@"No Connection. Please find an internet connection."};
//        if (completionBlock)
//            completionBlock(results, nil);
//        
//        return;
//    }
    
    NSData *imageData = image[@"data"];
    NSString *imageName = image[@"name"];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:uploadUrl parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        NSError *error = nil;
        NSDictionary *responseDictionary = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (error){
            completionBlock(responseObject, error);
        }
        else{
//            completionBlock(response, nil);
            
            NSDictionary *results = [responseDictionary objectForKey:@"results"];
            NSString *confirmation = [results objectForKey:@"confirmation"];
            
            if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                if (completionBlock)
                    completionBlock(results, error);
            }
            else{
                if (completionBlock)
                    completionBlock(results, nil);
            }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        //        NSLog(@"UPLOAD FAILED: %@", [error localizedDescription]);
        completionBlock(nil, error);
    }];
    
    
    [operation start];
}

- (void)fetchImage:(NSString *)imageId completion:(PQWebServiceRequestCompletionBlock)completionBlock;
{
    
    //check cache first:
    NSString *filePath = [self createFilePath:imageId];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data){
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"CACHED IMAGE: %@, %d bytes", imageId, data.length);
        if (!image)
            NSLog(@"CACHED IMAGE IS NIL:");

        if (completionBlock)
            completionBlock(image, nil);
        
        return;
    }
    

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [httpClient getPath:[kPathSiteImages stringByAppendingString:[NSString stringWithFormat:@"%@?crop=480", imageId]]
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    
                    NSData *imageData = (NSData *)responseObject; // convert response data into image
                    
                    //Save image to cache directory:
                    [imageData writeToFile:filePath atomically:YES];
                    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
                    
                    
                    UIImage *image = [UIImage imageWithData:imageData];
                    if (completionBlock)
                        completionBlock(image, nil);
                }
     
                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                    if (completionBlock)
                        completionBlock(nil, error);
                }];
}




// - - - - - - - - - - - - - - - - - - - - - - - - POSTS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //

- (void)fetchPosts:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [httpClient getPath:kPathPosts
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSError *error = nil;
                    NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                      options:NSJSONReadingMutableContainers
                                                                                                        error:&error];
                    
                    if (error){
                        //                        NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                        completionBlock(responseObject, error);
                    }
                    else{
                        //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                        NSDictionary *results = [responseDictionary objectForKey:@"results"];
                        NSString *confirmation = [results objectForKey:@"confirmation"];
                        
                        if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                            if (completionBlock)
                                completionBlock(results, error);
                        }
                        else{
                            if (completionBlock)
                                completionBlock(results, nil);
                        }
                    }
                }
     
                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                    if (completionBlock)
                        completionBlock(nil, error);
                }];

}

- (void)fetchPostsFromDevice:(NSString *)deviceHash completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [httpClient getPath:kPathPosts
             parameters:@{@"device":deviceHash}
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSError *error = nil;
                    NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                      options:NSJSONReadingMutableContainers
                                                                                                        error:&error];
                    
                    if (error){
                        //                        NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                        completionBlock(responseObject, error);
                    }
                    else{
                        //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                        NSDictionary *results = [responseDictionary objectForKey:@"results"];
                        NSString *confirmation = [results objectForKey:@"confirmation"];
                        
                        if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                            if (completionBlock)
                                completionBlock(results, error);
                        }
                        else{
                            if (completionBlock)
                                completionBlock(results, nil);
                        }
                    }
                }
     
                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                    if (completionBlock)
                        completionBlock(nil, error);
                }];
    
}

- (void)fetchPostsFromLocation:(NSDictionary *)location completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    
    [httpClient getPath:kPathPosts
             parameters:location
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSError *error = nil;
                    NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                      options:NSJSONReadingMutableContainers
                                                                                                        error:&error];
                    
                    if (error){
                        //                        NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                        completionBlock(responseObject, error);
                    }
                    else{
                        //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                        NSDictionary *results = [responseDictionary objectForKey:@"results"];
                        NSString *confirmation = [results objectForKey:@"confirmation"];
                        
                        if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                            if (completionBlock)
                                completionBlock(results, error);
                        }
                        else{
                            if (completionBlock)
                                completionBlock(results, nil);
                        }
                    }
                }
     
                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                    if (completionBlock)
                        completionBlock(nil, error);
                }];
    
}


- (void)createPost:(PQPost *)post completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [httpClient postPath:kPathPosts
              parameters:[post parametersDictionary]
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     NSError *error = nil;
                     NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                         error:&error];
                     
                     if (error){
                         NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                     }
                     else{
                         //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                         NSDictionary *results = [responseDictionary objectForKey:@"results"];
                         NSString *confirmation = [results objectForKey:@"confirmation"];
                         
                         if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                             if (completionBlock)
                                 completionBlock(results, error);
                         }
                         else{
                             if (completionBlock)
                                 completionBlock(results, nil);
                         }
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                     NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                     if (completionBlock)
                         completionBlock(nil, error);
                 }];

}


- (void)likePost:(PQPost *)post withDevice:(NSString *)deviceHash completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [httpClient putPath:[kPathPosts stringByAppendingString:post.uniqueId]
              parameters:@{@"device":deviceHash, @"action":@"like"}
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     NSError *error = nil;
                     NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                         error:&error];
                     
                     if (error){
                         NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                     }
                     else{
                         //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                         NSDictionary *results = [responseDictionary objectForKey:@"results"];
                         NSString *confirmation = [results objectForKey:@"confirmation"];
                         
                         if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                             if (completionBlock)
                                 completionBlock(results, error);
                         }
                         else{
                             if (completionBlock)
                                 completionBlock(results, nil);
                         }
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                     NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                     if (completionBlock)
                         completionBlock(nil, error);
                 }];
    
}

- (void)unlikePost:(PQPost *)post withDevice:(NSString *)deviceHash completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [httpClient putPath:[kPathPosts stringByAppendingString:post.uniqueId]
             parameters:@{@"device":deviceHash, @"action":@"unlike"}
                success:^(AFHTTPRequestOperation *operation, id responseObject){
                    NSError *error = nil;
                    NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                      options:NSJSONReadingMutableContainers
                                                                                                        error:&error];
                    
                    if (error){
                        NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                    }
                    else{
                        //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                        NSDictionary *results = [responseDictionary objectForKey:@"results"];
                        NSString *confirmation = [results objectForKey:@"confirmation"];
                        
                        if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                            if (completionBlock)
                                completionBlock(results, error);
                        }
                        else{
                            if (completionBlock)
                                completionBlock(results, nil);
                        }
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                    if (completionBlock)
                        completionBlock(nil, error);
                }];
}


// - - - - - - - - - - - - - - - - - - - - - - - - COMMENTS - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - //


- (void)postComment:(PQComment *)comment completion:(PQWebServiceRequestCompletionBlock)completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    [httpClient postPath:kPathComments
              parameters:[comment parametersDictionary]
                 success:^(AFHTTPRequestOperation *operation, id responseObject){
                     NSError *error = nil;
                     NSDictionary *responseDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                         error:&error];
                     
                     if (error){
                         NSLog(@"SUCCESS BLOCK: ERROR - %@", [error localizedDescription]);
                     }
                     else{
                         //NSLog(@"SUCCESS BLOCK: %@", [responseDictionary description]);
                         NSDictionary *results = [responseDictionary objectForKey:@"results"];
                         NSString *confirmation = [results objectForKey:@"confirmation"];
                         
                         if ([confirmation isEqualToString:@"success"]){ // profile successfully registered
                             if (completionBlock)
                                 completionBlock(results, error);
                         }
                         else{
                             if (completionBlock)
                                 completionBlock(results, nil);
                         }
                     }
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                     NSLog(@"FAILURE BLOCK: %@", [error localizedDescription]);
                     if (completionBlock)
                         completionBlock(nil, error);
                 }];
}



#pragma mark - FileSavingStuff:
- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	return filePath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}



@end
