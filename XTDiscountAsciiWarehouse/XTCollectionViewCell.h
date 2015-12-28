//
//  XTCollectionViewCell.h
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 09/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTItem.h"

@interface XTCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *faceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyNowButton;
@property (nonatomic) XTItem *item;

@end
