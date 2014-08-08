//
//  PQDateFormatter.h
//  Perq
//
//  Created by Dan Kwon on 8/8/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQDateFormatter : NSDateFormatter

@property (strong, nonatomic) NSArray *monthsArray;
+ (PQDateFormatter *)sharedDateFormatter;
@end
