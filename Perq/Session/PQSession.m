//
//  PQSession.m
//  Perq
//
//  Created by Dan Kwon on 8/6/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQSession.h"

@implementation PQSession
@synthesize deviceHash;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize latitude;
@synthesize longitude;


- (id)init
{
    self = [super init];
    if (self){
        self.deviceHash = @"none";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"deviceHash"]){
            self.deviceHash = [defaults objectForKey:@"deviceHash"];
            NSLog(@"STORED HASH: %@", self.deviceHash);
        }
        else{
            self.deviceHash = [self randomStringWithLength:16];
            [defaults setObject:self.deviceHash forKey:@"deviceHash"];
            [defaults synchronize];
            NSLog(@"CREATED NEW HASH: %@", self.deviceHash);
        }
    }
    
    return self;
}

+ (PQSession *)sharedSession
{
    static PQSession *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[PQSession alloc] init];
        
    });
    
    return shared;
}

- (NSDictionary *)locationDictionary
{
    NSDictionary *locationInfo = @{@"city":self.city.lowercaseString, @"state":self.state.lowercaseString, @"zip":self.zip, @"latitude":[NSString stringWithFormat:@"%.4f", self.latitude], @"longitude":[NSString stringWithFormat:@"%.4f", self.longitude]};
    
    return locationInfo;
}

-(NSString *)randomStringWithLength:(int)len
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
    }
    
    return randomString;
}

//- (void)cacheProfile
//{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *jsonString = [self jsonRepresentation];
//    [defaults setObject:jsonString forKey:@"user"];
//    [defaults synchronize];
//}




@end
