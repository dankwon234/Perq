//
//  PQDevice.h
//  Perq
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQDevice : NSObject

@property (copy, nonatomic) NSString *deviceHash;
@property (copy, nonatomic) NSString *deviceToken;
@property (copy, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSMutableArray *contactList;
+ (PQDevice *)sharedDevice;
- (void)updateDevice;
- (NSDictionary *)parametersDictionary;
- (NSString *)jsonRepresentation;
- (void)populate:(NSDictionary *)info;

@end
