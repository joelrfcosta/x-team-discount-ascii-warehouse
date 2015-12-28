#import "_XTTag.h"

@interface XTTag : _XTTag {}

+ (nullable XTTag *)itemWithName:(nullable NSString *)name managedObjectContext:(nullable NSManagedObjectContext *)context;
+ (void)deleteAll:(nonnull NSManagedObjectContext *)context;

- (nullable XTTag *)initWithName:(nullable NSString *)name managedObjectContext:(nullable NSManagedObjectContext *)context;

@end
