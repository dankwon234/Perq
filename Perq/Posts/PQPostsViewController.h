//
//  PQPostsViewController.h
//  Perq
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface PQPostsViewController : PQViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate>

@end
