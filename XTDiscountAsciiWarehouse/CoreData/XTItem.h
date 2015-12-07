#import "_XTItem.h"

@interface XTItem : _XTItem {}

+ (nonnull NSArray *)addItems:(nullable NSArray *)items managedObjectContext:(nullable NSManagedObjectContext *)context;
+ (nullable XTItem *)itemWithIdentifier:(nullable NSString *)identifier managedObjectContext:(nullable NSManagedObjectContext *)context;

- (nullable XTItem *)initWithString:(nullable NSString *)string managedObjectContext:(nullable NSManagedObjectContext *)context;

@end
