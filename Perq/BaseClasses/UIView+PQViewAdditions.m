//
//  UIView+PQViewAdditions.m
//  Perq
//
//  Created by Dan Kwon on 8/4/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "UIView+PQViewAdditions.h"

@implementation UIView (PQViewAdditions)


- (UIImage *)screenshot
{
    CGRect bounds = self.bounds;
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"SCREENSHOT: %.2f", image.size.height);
    return image;
}


@end
