//
//  XTCollectionViewController.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCollectionViewController.h"
#import "XTItem.h"
#import "XTCommunication.h"
#import "XTCollectionViewCell.h"
#import "XTCollectionViewLayout.h"

@interface XTCollectionViewController () <NSFetchedResultsControllerDelegate, XTCollectionViewLayoutDelegate, UIScrollViewDelegate> {
    NSNumberFormatter *_priceFormatter;
}

@end

@implementation XTCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSUInteger const fetchQuantity = 10;

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    ((XTCollectionViewLayout *)self.collectionViewLayout).delegate = self;
    self.collectionView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchRemoteData];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)fetchRemoteData {
    [[XTCommunication sharedInstance] fetchWithParameters:XTMakeCommunicationSearchParameters(nil, fetchQuantity, self.fetchedResultsController.fetchedObjects.count, false) succeed:^(NSArray *items) {
        NSManagedObjectContext *context = [[XTCoreData sharedInstance] privateManagedObjectContext];
        [XTItem addItems:items managedObjectContext:context];
        [context save:nil];
    } failed:^(NSError *error) {
        DDLogError(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"Cache"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[XTItem entityName]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIdentifier" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:[[XTCoreData sharedInstance] managedObjectContext]
                                 sectionNameKeyPath:nil
                                 cacheName:@"Cache"];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if ([_fetchedResultsController performFetch:&error]) {
        DDLogError(@"%@", error);
    }
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configureCellWithItem:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat)itemsHeightForCollectionViewLayout:(XTCollectionViewLayout *)layout {
    CGFloat itemsQuantity = [self itemsQuantityPerColumnForCollectionViewLayout:layout];
    return (self.collectionView.frame.size.height / itemsQuantity);
}

- (NSUInteger)itemsQuantityPerColumnForCollectionViewLayout:(XTCollectionViewLayout *)layout {
    if (self.view.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return 4;
    } else {
        if (self.collectionView.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            return 2;
        } else {
            return 3;
        }
    }
    
    return 0;
}

- (CGFloat)collectionViewLayout:(XTCollectionViewLayout *)layout widthForItemAtIndexPath:(NSIndexPath *)indexPath {
    XTItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGSize size = [item.face sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:48.0f]}];
    return size.width + 40;
}

- (void)didFinishPrepareLayout:(XTCollectionViewLayout *)layout {
    if (layout.minLineWidth < self.collectionView.frame.size.width) {
        [self fetchRemoteData];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.collectionViewLayout invalidateLayout];
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
    if (endEdge >= scrollView.contentSize.width) {
        [self fetchRemoteData];
    }
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
