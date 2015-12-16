//
//  XTCollectionViewLayout.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 10/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCollectionViewLayout.h"
#import "XTCollectionViewController.h"
#import "XTItem.h"

@implementation XTCollectionViewLayout {
    NSMutableArray *_itemsAttributes;
}

- (void)prepareLayout {
    if (!self.delegate) {
        return;
    }
    
    XTCollectionViewController *viewController = (XTCollectionViewController *)self.collectionView.dataSource;
    
    NSArray *fetchedObjects = viewController.fetchedResultsController.fetchedObjects;
    
    _itemsAttributes = [NSMutableArray new];
    
    CGFloat y = 0;
    int index = 0;
    CGFloat height = [self.delegate itemsHeightForCollectionViewLayout:self];
    NSUInteger quantity = [self.delegate itemsQuantityPerColumnForCollectionViewLayout:self];
    
    for (XTItem *item in fetchedObjects) {
        
        NSIndexPath *indexPath = [viewController.fetchedResultsController indexPathForObject:item];
        CGFloat width = [self.delegate collectionViewLayout:self widthForItemAtIndexPath:indexPath];

        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        if (index >= quantity) {
            UICollectionViewLayoutAttributes *prevAttributes = [_itemsAttributes objectAtIndex:index-quantity];
            CGFloat x = prevAttributes.frame.origin.x + prevAttributes.frame.size.width;
            attributes.frame = CGRectMake(x, y, width, height);
        } else {
            attributes.frame = CGRectMake(0, y, width, height);
        }
        attributes.size = CGSizeMake(width - 20, height - 10);
        [_itemsAttributes addObject:attributes];
        
        y += height;
        
        if (y >= self.collectionView.frame.size.height) {
            y = 0;
        }
        
        index += 1;
    }
    
    CGFloat maxWidth = CGFLOAT_MIN;
    CGFloat minWidth = CGFLOAT_MAX;
    if (_itemsAttributes.count) {
        NSUInteger quantity = [self.delegate itemsQuantityPerColumnForCollectionViewLayout:self];
        for (NSInteger i = _itemsAttributes.count-1; i >= _itemsAttributes.count - quantity && i >= 0; i--) {
            UICollectionViewLayoutAttributes *attributes = [_itemsAttributes objectAtIndex:i];
            CGFloat width = attributes.frame.origin.x + attributes.frame.size.width;
            maxWidth = MAX(maxWidth, width);
            minWidth = MIN(minWidth, width);
        }
    }
    _maxLineWidth = maxWidth;
    _minLineWidth = minWidth;
    
    if ([self.delegate respondsToSelector:@selector(didFinishPrepareLayout:)]) {
        [self.delegate didFinishPrepareLayout:self];
    }
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake( MAX(_maxLineWidth, self.collectionView.bounds.size.width), self.collectionView.bounds.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    
    for (UICollectionViewLayoutAttributes *attributes in _itemsAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_itemsAttributes objectAtIndex:indexPath.row];
}


@end
