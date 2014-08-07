//
//  PQCollectionViewFlowLayout.m
//  Perq
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQCollectionViewFlowLayout.h"
#import "Config.h"

@interface PQCollectionViewFlowLayout ()
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@end


@implementation PQCollectionViewFlowLayout

- (id)init
{
    
    self = [super init];
    if (self){
        self.minimumInteritemSpacing = 10; // horizontal gap between columns
//        self.minimumInteritemSpacing = 0; // horizontal gap between columns
        
        self.minimumLineSpacing = 10; // vertical gap between rows
//        self.minimumLineSpacing = 0; // vertical gap between rows
        
//        self.itemSize = CGSizeMake(kPostCellDimension, kPostCellDimension);
        self.itemSize = CGSizeMake(kPostCellDimension, kPostCellDimension);
        
        self.sectionInset = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 12.0f);
//        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    
    
    return self;
}

//- (CGSize)collectionViewContentSize
//{
//    id<UICollectionViewDataSource> dataSource = self.collectionView.dataSource;
//    int numberOfItems = [dataSource collectionView:self.collectionView numberOfItemsInSection:0];
//    
//    CGSize size = CGSizeMake(self.collectionView.frame.size.width, numberOfItems*kPostCellDimension);
//    NSLog(@"collectionViewContentSize: %d ITEMS, %.2f, %.2f", numberOfItems, size.width, size.height);
//
//    return size;
//  
//}


- (void)prepareLayout
{
    [super prepareLayout];
    
    
    if (self.dynamicAnimator.behaviors.count > 0)
        return;
    
    CGSize contentSize = self.collectionView.contentSize;
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height)];
    [items enumerateObjectsUsingBlock:^(id<UIDynamicItem> obj, NSUInteger idx, BOOL *stop) {
        UIAttachmentBehavior *behaviour = [[UIAttachmentBehavior alloc] initWithItem:obj
                                                                    attachedToAnchor:[obj center]];
        
        behaviour.length = 0.0f;
        behaviour.damping = 0.9f;
        behaviour.frequency = 1.0f;
        
        [self.dynamicAnimator addBehavior:behaviour];
    }];
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}


-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    //    NSLog(@"shouldInvalidateLayoutForBoundsChange:");
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1300.0f;
        
        UICollectionViewLayoutAttributes *item = springBehaviour.items.firstObject;
        CGPoint center = item.center;
        center.y += (delta < 0) ? MAX(delta, delta*scrollResistance) : MIN(delta, delta*scrollResistance);
        item.center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
