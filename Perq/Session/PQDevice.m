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




@end
