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
    NSMutableDictionary *_inserted;
    NSMutableArray *_updated;
    NSMutableArray *_deleted;
    BOOL _onStockOnly;
    UIBarButtonItem *_stockOnlyBarButton;
}

@end

@implementation XTCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSUInteger const fetchQuantity = 10;

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    ((XTCollectionViewLayout *)self.collectionViewLayout).delegate = self;
    self.collectionView.delegate = self;
    
    _stockOnlyBarButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(didTouchStockOnlyButton)];
    _stockOnlyBarButton.tintColor = [UIColor darkTextColor];
    self.navigationItem.leftBarButtonItem = _stockOnlyBarButton;
    
    _onStockOnly = NO;
    [self updateStockOnlyButton];
    [self performFetch];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
}

- (void)updateStockOnlyButton
{
    if (_onStockOnly) {
        _stockOnlyBarButton.title = NSLocalizedString(@"View all items", @"On stock filter button title");
    } else {
        _stockOnlyBarButton.title = NSLocalizedString(@"View stock only", @"On stock filter button title");
    }
}

- (void)refresh {
    [self fetchRemoteDataSkip:0 onStockOnly:_onStockOnly];
}

- (void)didTouchStockOnlyButton {
    _onStockOnly = !_onStockOnly;
    [self updateStockOnlyButton];
    [self performFetch];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)performFetch {
    _fetchedResultsController = nil;
    
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
        DDLogError(@"%@", error);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchRemoteDataSkip:self.fetchedResultsController.fetchedObjects.count onStockOnly:_onStockOnly];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)fetchRemoteDataSkip:(NSUInteger)skip onStockOnly:(BOOL)onStockOnly {
    [[XTCommunication sharedInstance] fetchWithParameters:XTMakeCommunicationSearchParameters(nil, fetchQuantity, skip, onStockOnly) succeed:^(NSArray *items) {
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
    
    if (_onStockOnly) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"stock > 0"];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortIdentifier" ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:[[XTCoreData sharedInstance] managedObjectContext]
                                 sectionNameKeyPath:nil
                                 cacheName:@"Cache"];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerview;
    }
    return reusableview;
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
    [self fetchRemoteDataSkip:self.fetchedResultsController.fetchedObjects.count onStockOnly:_onStockOnly];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.collectionViewLayout invalidateLayout];
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _inserted = [NSMutableDictionary new];
    _deleted = [NSMutableArray new];
    _updated = [NSMutableArray new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [_deleted addObject:indexPath];
            break;
        case NSFetchedResultsChangeInsert:
            [_inserted setObject:anObject forKey:newIndexPath];
            break;
        case NSFetchedResultsChangeMove:
            [_updated addObject:indexPath];
            [_updated addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [_updated addObject:indexPath];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:_deleted];
            
            NSArray<NSIndexPath *>* keys = [_inserted.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *  _Nonnull obj1, NSIndexPath *  _Nonnull obj2) {
                if (obj1.row > obj2.row) {
                    return NSOrderedDescending;
                } else if (obj1.row < obj2.row) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }];
            
            [keys enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.collectionView insertItemsAtIndexPaths:@[obj]];
            }];
            
            [self.collectionView reloadItemsAtIndexPaths:_updated];
            
        } completion:nil];
}

#pragma mark <UIScrollViewDelegate>


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.x + bounds.size.width - inset.right;
    float h = size.width;
    
    float reload_distance = 100; //distance for which you want to load more
    if(y > h + reload_distance) {
        
        scrollView.bounces = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [scrollView setContentOffset:CGPointMake(size.width - scrollView.frame.size.width, 0) animated:NO];
        } completion:^(BOOL finished) {
            scrollView.bounces = YES;
            
            // To cancel the gesture
            scrollView.panGestureRecognizer.enabled = NO;
            scrollView.panGestureRecognizer.enabled = YES;
            
            [self fetchRemoteDataSkip:self.fetchedResultsController.fetchedObjects.count onStockOnly:_onStockOnly];
        }];
    }
}

@end
