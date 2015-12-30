//
//  XTCollectionViewController.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCollectionViewController.h"
#import "XTItem.h"
#import "XTTag.h"
#import "XTCommunication.h"
#import "XTCollectionViewCell.h"
#import "XTCollectionViewLayout.h"
#import "XTLoadMoreCollectionReusableView.h"

@interface XTCollectionViewController () <NSFetchedResultsControllerDelegate, XTCollectionViewLayoutDelegate, UIScrollViewDelegate, UISearchBarDelegate> {
    NSNumberFormatter *_priceFormatter;
    NSMutableDictionary *_inserted;
    NSMutableArray *_updated;
    NSMutableArray *_deleted;
    XTLoadMoreCollectionReusableView *_footerview;
    BOOL _loadMore;
    BOOL _dragging;
    UISearchBar *_searchBar;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *stockOnlyToolbarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButton;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL onStockOnly;
@property (nonatomic) NSArray *searchParams;

@end

@implementation XTCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSUInteger const fetchQuantity = 10;

@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark Setters

- (void)setOnStockOnly:(BOOL)onStockOnly {
    _onStockOnly = onStockOnly;
    if (_onStockOnly) {
        self.stockOnlyToolbarButton.title = NSLocalizedString(@"View all items", @"On stock filter button title");
    } else {
        self.stockOnlyToolbarButton.title = NSLocalizedString(@"View stock only", @"On stock filter button title");
    }
}

- (void)setSearchParams:(NSArray *)searchParams {
    _searchParams = searchParams;
    [self performFetch];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    
    UIEdgeInsets inset = self.collectionView.contentInset;
    
    if (_loading) {
        _footerview.loadingMoreStatus = XTLoadMoreCollectionReusableViewLoadingStatusAfterTrigger;
        self.resetBarButton.enabled = NO;
        self.refreshBarButton.enabled = NO;
        
        inset.right += 100;
    } else {
        _loading = NO;
        _loadMore = NO;
        _footerview.loadingMoreStatus = XTLoadMoreCollectionReusableViewLoadingStatusIddle;
        self.resetBarButton.enabled = YES;
        self.refreshBarButton.enabled = YES;
        inset.right -= 100;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.collectionView.contentInset = inset;
    }];
}

#pragma mark Actions

- (IBAction)didTouchRefreshButton:(id)sender {
    [_searchBar resignFirstResponder];
    [self fetchRemoteDataSkip:0 onStockOnly:_onStockOnly quantity:self.fetchedResultsController.fetchedObjects.count];
}

- (IBAction)didTouchResetButton:(id)sender {
    [_searchBar resignFirstResponder];
    
    UIAlertController *controller =
    [UIAlertController alertControllerWithTitle:nil
                                        message:NSLocalizedString(@"Are you sure you want to reset all data?", @"Reset all data message")
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Confirmation option while resetting data") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        _searchBar.text = nil;
        _searchParams = nil;
        self.onStockOnly = NO;
        
        NSManagedObjectContext *context = [[XTCoreData sharedInstance] privateManagedObjectContext];
        [XTItem deleteAll:context];
        [XTTag deleteAll:context];
        
        NSError *error;
        [context save:&error];
        if (error) {
            DDLogDebug(@"%@", error);
        }
        
        [self fetchRemoteDataSkip:0 onStockOnly:_onStockOnly quantity:fetchQuantity];
        
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Cancel option while resetting data") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)didTouchStockOnlyButton:(id)sender {
    self.onStockOnly = !_onStockOnly;
    [self performFetch];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

#pragma mark <UIViewController>

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dragging = NO;
    self.loading = NO;
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    _priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    _priceFormatter.maximumFractionDigits = 0;
    
    ((XTCollectionViewLayout *)self.collectionViewLayout).delegate = self;
    self.collectionView.delegate = self;
    
    self.onStockOnly = NO;
    [self performFetch];
    
    self.navigationController.toolbarHidden = NO;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0)];
    _searchBar.showsCancelButton = YES;
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(_searchBar.frame.size.height + 5, 5, 5, 5);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentInset"])
    {
        UIEdgeInsets new = ((NSValue *)[change valueForKey:@"new"]).UIEdgeInsetsValue;
        UIEdgeInsets old = ((NSValue *)[change valueForKey:@"old"]).UIEdgeInsetsValue;
        
        if (new.bottom != old.bottom) {
            [self.collectionView performBatchUpdates:^{
                [self.collectionViewLayout invalidateLayout];
            } completion:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.collectionView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    [self fetchRemoteDataSkip:self.fetchedResultsController.fetchedObjects.count onStockOnly:_onStockOnly quantity:fetchQuantity];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.collectionView removeObserver:self forKeyPath:@"contentInset"];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [_searchBar resignFirstResponder];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.collectionViewLayout invalidateLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
    
    //[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark Communication

- (void)fetchRemoteDataSkip:(NSUInteger)skip onStockOnly:(BOOL)onStockOnly quantity:(NSUInteger)quantity {
    if (!_loading) {
        self.loading = YES;
        
        if (quantity <= 0) {
            quantity = fetchQuantity;
        }
        
        AFHTTPRequestOperation *operation =
        [[XTCommunication sharedInstance] fetchWithParameters:XTMakeCommunicationSearchParameters(_searchParams, quantity, skip, onStockOnly) succeed:^(NSArray *items) {
            NSManagedObjectContext *context = [[XTCoreData sharedInstance] privateManagedObjectContext];
            [XTItem addItems:items managedObjectContext:context];
            [context save:nil];
            self.loading = NO;
        } failed:^(NSError *error) {
            DDLogError(@"%@", error);
            self.loading = NO;
        }];
        if (!operation) {
            NSArray *items =
            @[
              @"{\"type\":\"face\",\"id\":\"0-4itmqrfkz6e9izfr\",\"size\":24,\"price\":379,\"face\":\"( .-. )\",\"stock\":7,\"tags\":[\"flat\",\"bored\"]}",
              @"{\"type\":\"face\",\"id\":\"1-vw21ngfdtn50o1or\",\"size\":19,\"price\":487,\"face\":\"( .o.)\",\"stock\":0,\"tags\":[\"suprised\",\"consectetur\"]}",
              @"{\"type\":\"face\",\"id\":\"2-243b4x4c3o6flxr\",\"size\":34,\"price\":501,\"face\":\"( `·´ )\",\"stock\":7,\"tags\":[\"angry\",\"cross\",\"elit\"]}",
              @"{\"type\":\"face\",\"id\":\"3-4xmmi1l37ukjfw29\",\"size\":15,\"price\":282,\"face\":\"( ° ͜ ʖ °)\",\"stock\":2,\"tags\":[\"happy\",\"nose\"]}",
              @"{\"type\":\"face\",\"id\":\"4-dv5v1dfy2ljcq5mi\",\"size\":32,\"price\":50,\"face\":\"( ͡° ͜ʖ ͡°)\",\"stock\":5,\"tags\":[\"happy\",\"nose\",\"sit\",\"consectetur\",\"sit\"]}",
              @"{\"type\":\"face\",\"id\":\"5-v2efv45eyeklnmi\",\"size\":22,\"price\":959,\"face\":\"( ⚆ _ ⚆ )\",\"stock\":6,\"tags\":[]}",
              @"{\"type\":\"face\",\"id\":\"6-si4bj477ntye3ik9\",\"size\":25,\"price\":931,\"face\":\"( ︶︿︶)\",\"stock\":6,\"tags\":[]}",
              @"{\"type\":\"face\",\"id\":\"7-alepfznr5p7j5rk9\",\"size\":28,\"price\":90,\"face\":\"( ﾟヮﾟ)\",\"stock\":1,\"tags\":[\"amet\"]}",
              @"{\"type\":\"face\",\"id\":\"8-wcayxmh1zf2sm7vi\",\"size\":35,\"price\":702,\"face\":\"(\\/)(°,,,°)(\\/)\",\"stock\":5,\"tags\":[\"zoidberg\",\"amet\"]}",
              @"{\"type\":\"face\",\"id\":\"9-8so9m5z5fai9hpvi\",\"size\":21,\"price\":868,\"face\":\"(¬_¬)\",\"stock\":2,\"tags\":[\"consectetur\",\"sit\",\"lorem\"]}"
              ];
            
            NSManagedObjectContext *context = [[XTCoreData sharedInstance] privateManagedObjectContext];
            [XTItem addItems:items managedObjectContext:context];
            [context save:nil];
            
            self.loading = NO;
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (void)performFetch {
    _fetchedResultsController = nil;
    
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
        DDLogError(@"%@", error);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    [NSFetchedResultsController deleteCacheWithName:@"Cache"];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[XTItem entityName]];
    
    NSMutableArray *predicates = [NSMutableArray new];
    if (_onStockOnly) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"stock > 0"]];
    }
    
    if (_searchParams.count) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"any tags.name in %@", _searchParams]];
    }
    
    if (predicates.count > 0) {
        fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
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
    cell.item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.buyNowButton.tag = indexPath.row;
    [cell.buyNowButton addTarget:self action:@selector(didTouchBuyButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        _footerview = (XTLoadMoreCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = _footerview;
    }
    return reusableview;
}

- (NSUInteger)itemsQuantityPerColumnForCollectionViewLayout:(XTCollectionViewLayout *)layout {
    CGFloat minHeight = 130;
    NSUInteger quantity = floorf((self.collectionView.frame.size.height - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom) / minHeight);
    if (quantity <= 0) {
        return 1;
    }
    return quantity;

}

- (CGFloat)collectionViewLayout:(XTCollectionViewLayout *)layout widthForItemAtIndexPath:(NSIndexPath *)indexPath {
    XTItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGSize size = [item.face sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:48.0f]}];
    return size.width + 40.0;
}

- (void)didFinishPrepareLayout:(XTCollectionViewLayout *)layout {
    if (layout.minLineWidth < self.collectionView.frame.size.width) {
        [self fetchRemoteDataSkip:self.fetchedResultsController.fetchedObjects.count onStockOnly:_onStockOnly quantity:fetchQuantity];
    }
}

- (void)didTouchBuyButton:(UIButton *)sender {
    XTItem *item = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    if (!item) {
        return;
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.maximumFractionDigits = 0;
    
    UIAlertController *controller =
    [UIAlertController alertControllerWithTitle:nil
                                        message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to buy\n%@\nfor %@?", @"Buying confirmation"), item.face, [formatter stringFromNumber:item.price]]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", @"Confirmation option while buying") style:UIAlertActionStyleDestructive handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", @"Cancel option while buying") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
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


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _dragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_dragging && !_loading) {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.x + bounds.size.width - inset.right;
        float h = size.width;
        
        float reload_distance = 100; //distance to trigger load more action
        if(y > h + reload_distance) {
            _footerview.loadingMoreStatus = XTLoadMoreCollectionReusableViewLoadingStatusBeforeTrigger;
            _loadMore = YES;
        } else {
            _footerview.loadingMoreStatus = XTLoadMoreCollectionReusableViewLoadingStatusIddle;
            _loadMore = NO;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_loadMore && !_loading) {
        [self fetchRemoteDataSkip:self.fetchedResultsController.fetchedObjects.count onStockOnly:_onStockOnly quantity:fetchQuantity];
    }
    _dragging = NO;
}

#pragma mark <UISearchBarDelegate>

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchParams = nil;
    [_searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchParams = [[_searchBar.text.lowercaseString stringByReplacingOccurrencesOfString:@"," withString:@" "] componentsSeparatedByString:@" "];
    [_searchBar resignFirstResponder];
}

@end
