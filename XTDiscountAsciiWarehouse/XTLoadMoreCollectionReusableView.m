//
//  XTLoadMoreCollectionReusableView.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 28/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTLoadMoreCollectionReusableView.h"

@interface XTLoadMoreCollectionReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation XTLoadMoreCollectionReusableView

- (void)setLoadingMoreStatus:(XTLoadMoreCollectionReusableViewLoadingStatus)loadingMoreStatus {
    _loadingMoreStatus = loadingMoreStatus;
    
    switch (_loadingMoreStatus) {
        case XTLoadMoreCollectionReusableViewLoadingStatusIddle:
            self.titleLabel.text = NSLocalizedString(@"Pull to load more", @"Load more text before trigger offset");
            [self.activityIndicator stopAnimating];
            break;
        case XTLoadMoreCollectionReusableViewLoadingStatusBeforeTrigger:
            self.titleLabel.text = NSLocalizedString(@"Release to load more", @"Load more text after trigger offset");
            [self.activityIndicator stopAnimating];
            break;
        case XTLoadMoreCollectionReusableViewLoadingStatusAfterTrigger:
            self.titleLabel.text = NSLocalizedString(@"Please wait...", @"Load more text after trigger offset");
            [self.activityIndicator startAnimating];
            break;
    }
}

@end
