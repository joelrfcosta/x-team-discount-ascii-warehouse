#import "_XTItem.h"

@interface XTItem : _XTItem {}

+ (nonnull NSArray *)addItems:(nullable NSArray *)items managedObjectContext:(nonnull NSManagedObjectContext *)context;
+ (nullable XTItem *)itemWithIdentifier:(nullable NSString *)identifier managedObjectContext:(nonnull NSManagedObjectContext *)context;
+ (void)deleteAll:(nonnull NSManagedObjectContext *)context;

- (nullable XTItem *)initWithString:(nullable NSString *)string managedObjectContext:(nonnull NSManagedObjectContext *)context;

@end
