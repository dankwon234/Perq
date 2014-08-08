//
//  PQComment.h
//  Perq
//
//  Created by Dan Kwon on 8/6/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PQDateFormatter.h"

@interface PQComment : NSObject


@property (copy, nonatomic) NSString *uniqueId;
@property (strong, nonatomic) NSDate *timestamp;
@property (copy, nonatomic) NSString *deviceHash;
@property (copy, nonatomic) NSString *post;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *handle; //optional
@property (copy, nonatomic) NSString *formattedDate;
@property (strong, nonatomic) PQDateFormatter *dateFormatter;
+ (PQComment *)commentWithInfo:(NSDictionary *)info;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;
@end
