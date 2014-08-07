//
//  PQPostViewController.h
//  Perq
//
//  Created by Dan Kwon on 8/4/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQViewController.h"
#import "PQPost.h"

@interface PQPostViewController : PQViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) PQPost *post;
@property (nonatomic) CGFloat offset;
@end
