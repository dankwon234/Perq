//
//  PQDateFormatter.m
//  Perq
//
//  Created by Dan Kwon on 8/8/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQDateFormatter.h"

@implementation PQDateFormatter

- (id)init
{
    self = [super init];
    if (self){
        
        [self setDateFormat:@"EEE MMM dd HH:mm:ss z yyyy"]; //Tue Jun 17 00:52:49 UTC 2014

    }
    
    return self;
}


+ (PQDateFormatter *)sharedDateFormatter
{
    
    static PQDateFormatter *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[PQDateFormatter alloc] init];
        
    });
    
    return shared;
}


@end
