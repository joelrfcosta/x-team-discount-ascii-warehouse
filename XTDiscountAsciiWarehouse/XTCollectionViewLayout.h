//
//  XTCollectionViewLayout.h
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 10/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTCollectionViewLayout;

@protocol XTCollectionViewLayoutDelegate <NSObject>

- (CGFloat) collectionViewLayout:(XTCollectionViewLayout *)layout widthForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat) itemsHeightForCollectionViewLayout:(XTCollectionViewLayout *)layout;
- (NSUInteger) itemsQuantityPerColumnForCollectionViewLayout:(XTCollectionViewLayout *)layout;

@optional
- (void)didFinishPrepareLayout:(XTCollectionViewLayout *)layout;

@end

@interface XTCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) id<XTCollectionViewLayoutDelegate> delegate;
@property (nonatomic) UIEdgeInsets *cellInset;
@property (nonatomic) CGFloat maxLineWidth;
@property (nonatomic) CGFloat minLineWidth;

@end
