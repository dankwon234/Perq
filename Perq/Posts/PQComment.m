//
//  PQComment.m
//  Perq
//
//  Created by Dan Kwon on 8/6/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQComment.h"

@implementation PQComment
@synthesize uniqueId;
@synthesize timestamp;
@synthesize post;
@synthesize text;
@synthesize handle;
@synthesize deviceHash;
@synthesize formattedDate;
@synthesize dateFormatter;


#define kOneDay 24*60*60 // one day in seconds

- (id)init
{
    self = [super init];
    if (self){
        self.dateFormatter = [PQDateFormatter sharedDateFormatter];
        self.post = @"none";
        self.handle = @"none";
        self.text = @"none";
        self.deviceHash = @"none";
    }
    return self;
    
}

+ (PQComment *)commentWithInfo:(NSDictionary *)info
{
    PQComment *comment = [[PQComment alloc] init];
    [comment populate:info];
    return comment;
}


- (void)populate:(NSDictionary *)info
{
    for (NSString *key in info.allKeys) {
        if ([key isEqualToString:@"id"])
            self.uniqueId = [info objectForKey:key];

        if ([key isEqualToString:@"post"])
            self.post = [info objectForKey:key];

        if ([key isEqualToString:@"text"])
            self.text = [info objectForKey:key];

        if ([key isEqualToString:@"handle"])
            self.handle = [info objectForKey:key];
        
        if ([key isEqualToString:@"deviceHash"])
            self.deviceHash = [info objectForKey:key];

        
        if ([key isEqualToString:@"timestamp"]){
            NSString *ts = info[@"timestamp"];
            self.timestamp = [self.dateFormatter dateFromString:ts];
            
            NSTimeInterval sinceNow = -1*[self.timestamp timeIntervalSinceNow];
            if (sinceNow < kOneDay){
                double mins = sinceNow/60.0f;
                if (mins < 60){
                    self.formattedDate = (mins < 2) ? [NSString stringWithFormat:@"%d minute ago", (int)mins] : [NSString stringWithFormat:@"%d minutes ago", (int)mins];
                    return;
                }
                
                double hours = mins/60.0f;
                self.formattedDate = [NSString stringWithFormat:@"%d hours ago", (int)hours];
                return;
            }
            
            
            NSArray *parts = [ts componentsSeparatedByString:@" "];
            if (parts.count > 5)
                self.formattedDate = [NSString stringWithFormat:@"%@ %@", parts[1], parts[2]];
            
        }

}
    
}


- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"text":self.text, @"post":self.post, @"handle":self.handle, @"deviceHash":self.deviceHash}];
    
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



@end
