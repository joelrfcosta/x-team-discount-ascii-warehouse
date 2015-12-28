//
//  XTLoadMoreCollectionReusableView.h
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 28/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    XTLoadMoreCollectionReusableViewLoadingStatusIddle,
    XTLoadMoreCollectionReusableViewLoadingStatusBeforeTrigger,
    XTLoadMoreCollectionReusableViewLoadingStatusAfterTrigger,
} XTLoadMoreCollectionReusableViewLoadingStatus ;

@interface XTLoadMoreCollectionReusableView : UICollectionReusableView

@property (nonatomic) XTLoadMoreCollectionReusableViewLoadingStatus loadingMoreStatus;

@end
