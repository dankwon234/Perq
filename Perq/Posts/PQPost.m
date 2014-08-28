//
//  PQPost.m
//  Perq
//
//  Created by Dan Kwon on 8/2/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQPost.h"
#import "PQWebServices.h"
#import "PQComment.h"

@interface PQPost ()
@property (nonatomic) BOOL isFetchingImage;
@end

@implementation PQPost
@synthesize caption;
@synthesize image;
@synthesize imageData;
@synthesize comments;
@synthesize uniqueId;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize latitude;
@synthesize longitude;
@synthesize likes;
@synthesize deviceHash;
@synthesize commentCount;
@synthesize formattedDate;
@synthesize dateFormatter;
@synthesize from;

#define kOneDay 24*60*60 // one day in seconds

- (id)init
{
    self = [super init];
    if (self){
        self.dateFormatter = [PQDateFormatter sharedDateFormatter];
        self.comments = [NSMutableArray array];
        self.likes = [NSMutableArray array];
        self.imageData = nil;
        self.timestamp = nil;
        self.deviceHash = @"none";
        self.uniqueId = @"none";
        self.image = @"none";
        self.caption = @"none";
        self.city = @"none";
        self.state = @"none";
        self.zip = @"none";
        self.from = @"none";
        self.latitude = 0.0f;
        self.longitude = 0.0f;
        self.imageData = nil;
        self.isFetchingImage = NO;
    }
    return self;
}

+ (PQPost *)postWithInfo:(NSDictionary *)info
{
    PQPost *post = [[PQPost alloc] init];
    [post populate:info];
    return post;
}


- (void)populate:(NSDictionary *)info
{
    for (NSString *key in info.allKeys) {
        if ([key isEqualToString:@"id"])
            self.uniqueId = [info objectForKey:key];
        
        if ([key isEqualToString:@"deviceHash"])
            self.deviceHash = [info objectForKey:key];

        if ([key isEqualToString:@"from"])
            self.from = [info objectForKey:key];

        if ([key isEqualToString:@"image"])
            self.image = [info objectForKey:key];

        if ([key isEqualToString:@"caption"])
            self.caption = [info objectForKey:key];

        if ([key isEqualToString:@"city"])
            self.city = [info objectForKey:key];

        if ([key isEqualToString:@"state"])
            self.state = [info objectForKey:key];

        if ([key isEqualToString:@"zip"])
            self.zip = [info objectForKey:key];
        
        if ([key isEqualToString:@"latitude"])
            self.latitude = [[info objectForKey:key] doubleValue];

        if ([key isEqualToString:@"longitude"])
            self.longitude = [[info objectForKey:key] doubleValue];
        
        if ([key isEqualToString:@"likes"])
            self.likes = [NSMutableArray arrayWithArray:[info objectForKey:key]];

        if ([key isEqualToString:@"commentCount"])
            self.commentCount = [[info objectForKey:key] intValue];

        if ([key isEqualToString:@"comments"]){
            NSArray *c = [info objectForKey:key];
            for (int i=0; i<c.count; i++) {
                PQComment *comment = [PQComment commentWithInfo:c[i]];
                [self.comments addObject:comment];
            }
        }
        
        if ([key isEqualToString:@"timestamp"]){

            if (self.timestamp==nil){
                NSString *ts = info[@"timestamp"];
                self.timestamp = [self.dateFormatter dateFromString:ts];
                
                // NOTE: this is process intensive so we throw it in the background 
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self formatTimestamp];
                });
            }
        }
        
    }
}

- (void)formatTimestamp
{
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
    
    NSString *dateString = [self.timestamp description];
    NSLog(@"FORMATTED DATE: %@", dateString);
    
    NSArray *parts = [dateString componentsSeparatedByString:@" "]; // 2014-08-22
    parts = [parts[0] componentsSeparatedByString:@"-"];
    NSString *month = self.dateFormatter.monthsArray[[parts[1] intValue]-1];
    dateString = [NSString stringWithFormat:@"%@ %@, %@", month, parts[2], parts[0]];
    
    self.formattedDate = dateString;
}

- (void)fetchImage
{
    if (self.isFetchingImage)
        return;
    
    self.isFetchingImage = YES;
    [[PQWebServices sharedInstance] fetchImage:self.image completion:^(id result, NSError *error){
        self.isFetchingImage = NO;
        if (error){
            NSLog(@"FETCH IMAGE: FAIL");
            
        }
        else{
            UIImage *img = (UIImage *)result;
            
            if (img){
                self.imageData = img;
                NSLog(@"FETCH IMAGE: %@ - - -  SUCCESS", self.caption);
            }
            else{
                NSLog(@"FETCH IMAGE: %@ - - -  IMAGE IS NIL ! ! !", self.caption);
                self.imageData = [UIImage imageNamed:@"elephant.png"];
            }
            
        }
        
    }];
    
}

- (NSDictionary *)parametersDictionary
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.uniqueId, @"from":self.from, @"deviceHash":self.deviceHash, @"caption":self.caption, @"image":self.image, @"city":self.city, @"state":self.state, @"zip":self.zip, @"latitude":[NSString stringWithFormat:@"%.4f", self.latitude], @"longitude":[NSString stringWithFormat:@"%.4f", self.longitude]}];
    
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
