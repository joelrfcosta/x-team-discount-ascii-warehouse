//
//  XTCollectionViewCell.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 09/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCollectionViewCell.h"


@implementation XTCollectionViewCell {
    NSNumberFormatter *_priceFormatter;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.buyNowButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.buyNowButton setBackgroundImage:[self imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];    
    
    _priceFormatter = [NSNumberFormatter new];
    _priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    _priceFormatter.maximumFractionDigits = 0;
    
    self.background.layer.cornerRadius = 5.0;
}

- (void)setItem:(XTItem *)item {
    _item = item;
    if (_item) {
        self.faceLabel.text = _item.face;
        self.priceLabel.text = [_priceFormatter stringFromNumber:item.price];
        
        if (_item.stockValue == 0) {
            [self.buyNowButton setTitle:NSLocalizedString(@"Out of stock!", @"Buy button text when without items on stock") forState:UIControlStateNormal];
            self.buyNowButton.enabled = NO;
        } else if (_item.stockValue == 1) {
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
