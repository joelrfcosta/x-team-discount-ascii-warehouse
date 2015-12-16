//
//  XTCollectionViewCell.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 09/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCollectionViewCell.h"

@implementation XTCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.buyNowButton.titleLabel.textAlignment = NSTextAlignmentCenter;    
}

- (void)configureCellWithItem:(XTItem *)item {
    if (item) {
        self.faceLabel.text = item.face;
        self.priceLabel.text = [NSString stringWithFormat:@"%d", item.stockValue];// [_priceFormatter stringFromNumber:item.price];
        
        if (item.stockValue == 0) {
            [self.buyNowButton setTitle:NSLocalizedString(@"Out of stock!", @"Buy button text when without items on stock") forState:UIControlStateNormal];
            self.buyNowButton.enabled = NO;
        } else if (item.stockValue == 1) {
            [self.buyNowButton setTitle:NSLocalizedString(@"BUY NOW!\n(Only 1 more on stock!)", @"Buy button text when only 1 item on stock") forState:UIControlStateNormal];
            self.buyNowButton.enabled = YES;
        } else {
            [self.buyNowButton setTitle:NSLocalizedString(@"BUY NOW!", @"Buy button text when more than 1 item on stock") forState:UIControlStateNormal];
            self.buyNowButton.enabled = YES;
        }
    } else {
        self.faceLabel.text = @"";
        self.priceLabel.text = @"";
        [self.buyNowButton setTitle:@"" forState:UIControlStateNormal];
        self.buyNowButton.enabled = NO;
    }
}

@end
