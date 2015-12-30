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

typedef struct XTRowData {
    int numElements;
    double totalSize;
} XTRowData;

@implementation XTCollectionViewLayout {
    NSMutableArray *_itemsAttributes;
    NSMutableArray *_suplementaryItemsAttributes;
}

- (void)prepareLayout {
    if (!self.delegate) {
        return;
    }
    
    XTCollectionViewController *viewController = (XTCollectionViewController *)self.collectionView.dataSource;
    
    NSArray *fetchedObjects = viewController.fetchedResultsController.fetchedObjects;
    
    _itemsAttributes = [NSMutableArray new];
    _suplementaryItemsAttributes = [NSMutableArray new];
    
    CGFloat contentHeight = self.collectionView.frame.size.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom;
    NSUInteger quantity = [self.delegate itemsQuantityPerColumnForCollectionViewLayout:self];
    if (quantity <= 0) {
        return;
    }
    CGFloat height = contentHeight / (CGFloat)quantity;
    
    __block CGFloat y = 0;
    __block int index = 0;
    __block NSUInteger row = 0;
    __block NSUInteger column = 0;
    NSMutableArray *rowsData = [NSMutableArray new];
    
    [fetchedObjects enumerateObjectsUsingBlock:^(XTItem *  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSIndexPath *indexPath = [viewController.fetchedResultsController indexPathForObject:item];
        CGFloat width = [self.delegate collectionViewLayout:self widthForItemAtIndexPath:indexPath];

        CGRect frame;
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        if (index >= quantity) {
            UICollectionViewLayoutAttributes *prevAttributes = [_itemsAttributes objectAtIndex:index-quantity];
            CGFloat x = prevAttributes.frame.origin.x + prevAttributes.frame.size.width;
            frame = CGRectMake(x, y, width, height);
        } else {
            frame = CGRectMake(0, y, width, height);
        }
        attributes.frame = frame;
        [_itemsAttributes addObject:attributes];
        
        y += height;
        
        if (y >= contentHeight) {
            y = 0;
        }
        
        XTRowData data;
        data.numElements = 0;
        data.totalSize = 0;
        
        if (rowsData.count == quantity) {
            [rowsData[row] getValue:&data];
        }
        
        data.numElements += 1;
        data.totalSize += width;
        
        if (rowsData.count < quantity) {
            [rowsData addObject:[NSValue valueWithBytes:&data objCType:@encode(XTRowData)]];
        } else {
            [rowsData replaceObjectAtIndex:row withObject:[NSValue valueWithBytes:&data objCType:@encode(XTRowData)]];
        }
        
        if (row == quantity - 1) {
            row = 0;
        } else {
            row++;
        }
        
        index += 1;
    }];
    
    __block XTRowData maxRowData;
    maxRowData.totalSize = 0;
    [rowsData enumerateObjectsUsingBlock:^(NSValue *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XTRowData data;
        [obj getValue:&data];
        if (maxRowData.totalSize < data.totalSize) {
            maxRowData = data;
        }
    }];
    
    row = 0;
    
    [_itemsAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XTRowData data;
        [rowsData[row] getValue:&data];
        
        if (data.totalSize != maxRowData.totalSize) {
            double offset = (maxRowData.totalSize - data.totalSize) / (double)data.numElements;
            CGRect frame = obj.frame;
            
            frame.size.width += offset;
            frame.origin.x += (double)column * offset;
            
            obj.frame = frame;
        }
        
        if (row == quantity - 1) {
            row = 0;
            column++;
        } else {
            row++;
        }
    }];
    
    
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
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    attributes.frame = CGRectMake(  MAX(_maxLineWidth , self.collectionView.bounds.size.width - 1) , 0.0, 100.0, contentHeight);
    [_suplementaryItemsAttributes addObject:attributes];
    
    if ([self.delegate respondsToSelector:@selector(didFinishPrepareLayout:)]) {
        [self.delegate didFinishPrepareLayout:self];
    }
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake( MAX(_maxLineWidth + 1, self.collectionView.frame.size.width), self.collectionView.bounds.size.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    
    for (UICollectionViewLayoutAttributes *attributes in _itemsAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    for (UICollectionViewLayoutAttributes *attributes in _suplementaryItemsAttributes) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [layoutAttributes addObject:attributes];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _itemsAttributes.count) {
        return nil;
    }
    return [_itemsAttributes objectAtIndex:indexPath.row];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _suplementaryItemsAttributes.count) {
        return nil;
    }
    return [_suplementaryItemsAttributes objectAtIndex:indexPath.row];
}

@end
