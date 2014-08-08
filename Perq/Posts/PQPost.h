//
//  PQPost.h
//  Perq
//
//  Created by Dan Kwon on 8/2/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PQDateFormatter.h"

@interface PQPost : NSObject

@property (copy, nonatomic) NSString *uniqueId;
@property (copy, nonatomic) NSString *caption;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *zip;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *deviceHash;
@property (copy, nonatomic) NSString *formattedDate;
@property (strong, nonatomic) PQDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) UIImage *imageData;
@property (strong, nonatomic) NSMutableArray *comments;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int commentCount;
+ (PQPost *)postWithInfo:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;
- (void)fetchImage;
- (void)formatTimestamp;
@end
