//
//  XTCollectionViewController.h
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTCoreData.h"

@interface XTCollectionViewController : UICollectionViewController

@property (nonatomic, readonly) NSFetchedResultsController * fetchedResultsController;

@end
