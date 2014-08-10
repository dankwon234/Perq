//
//  PQDevice.m
//  Perq
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQDevice.h"

@implementation PQDevice
@synthesize deviceHash;
@synthesize deviceToken;
@synthesize phoneNumber;
@synthesize contactList;

- (id)init
{
    self = [super init];
    if (self){
        self.contactList = [NSMutableArray array];
        self.deviceToken = @"none";
        self.deviceHash = @"none";
        self.phoneNumber = @"none";
    }
    return self;
}


+ (PQDevice *)sharedDevice
{
    static PQDevice *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[PQDevice alloc] init];
        
    });
    
    return shared;
}

- (void)populate:(NSDictionary *)info
{
    for (NSString *key in info.allKeys) {
        if ([key isEqualToString:@"deviceHash"])
            self.deviceHash = [info objectForKey:key];

        if ([key isEqualToString:@"deviceToken"])
            self.deviceToken = [info objectForKey:key];

        if ([key isEqualToString:@"phoneNumber"])
            self.phoneNumber = [info objectForKey:key];

        if ([key isEqualToString:@"contactList"])
            self.contactList = [NSMutableArray arrayWithArray:[info objectForKey:key]];
    }
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"deviceHash":self.deviceHash, @"deviceToken":self.deviceToken, @"phoneNumber":self.phoneNumber, @"contactList":self.contactList}];
    
    return params;
}

- (NSString *)jsonRepresentation
{
    NSDictionary *info = [self parametersDictionary];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        return nil;
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



- (void)updateDevice
{
    
}


@end
