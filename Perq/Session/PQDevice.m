//
//  PQDevice.m
//  Perq
//
//  Created by Dan Kwon on 8/9/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQDevice.h"
#import "PQWebServices.h"

@implementation PQDevice
@synthesize deviceHash;
@synthesize deviceToken;
@synthesize phoneNumber;
@synthesize contactList;
@synthesize points;

- (id)init
{
    self = [super init];
    if (self){
        self.contactList = [NSMutableArray array];
        self.deviceToken = @"none";
        self.deviceHash = @"none";
        self.phoneNumber = @"none";
        self.points = 0;
        
        [self populateFromCache];
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

- (void)cacheDevice
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *jsonString = [self jsonRepresentation];
    [defaults setObject:jsonString forKey:@"device"];
    [defaults synchronize];
}

- (void)populateFromCache
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:@"device"];
    if (!json)
        return;
    
    NSError *error = nil;
    NSDictionary *deviceInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"CACHED DEVICE: %@", [deviceInfo description]);
    
    if (error)
        return;
    
    [self populate:deviceInfo];
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
        
        if ([key isEqualToString:@"points"])
            self.points = [[info objectForKey:key] intValue];

    }
    
    [self cacheDevice];

}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"deviceHash":self.deviceHash, @"deviceToken":self.deviceToken, @"phoneNumber":self.phoneNumber, @"contactList":self.contactList, @"points":[NSString stringWithFormat:@"%d", self.points]}];
    
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

- (void)registerDevice
{
    [[PQWebServices sharedInstance] registerDevice:self completion:^(id result, NSError *error){
        
    }];
    
}

- (void)updateDevice
{
    [[PQWebServices sharedInstance] updateDevice:self completion:^(id result, NSError *error){
        
    }];
}


- (void)storeDeviceToken
{
    [[PQWebServices sharedInstance] updateDevice:self completion:^(id result, NSError *error){
        
    }];
}


- (void)updateDevice:(void (^)(void))completion
{
    [[PQWebServices sharedInstance] updateDevice:self completion:^(id result, NSError *error){
        completion();
    }];
}


@end
