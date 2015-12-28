#import "XTTag.h"

@interface XTTag ()

// Private interface goes here.

@end

@implementation XTTag

+ (nullable XTTag *)itemWithName:(nullable NSString *)name managedObjectContext:(nullable NSManagedObjectContext *)context {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [NSFetchRequest new];
    
    [fetch setEntity:[NSEntityDescription entityForName:@"XTTag" inManagedObjectContext:context]];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"name = %@", name]];
    
    NSError *error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    if(fetchedObjects.count == 1) {
        return [fetchedObjects objectAtIndex:0];
    }
    
    return nil;
}

+ (void)deleteAll:(nonnull NSManagedObjectContext *)context {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [NSFetchRequest new];
    
    [fetch setEntity:[NSEntityDescription entityForName:@"XTItem" inManagedObjectContext:context]];
    
    NSError *error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    if (error) {
        DDLogDebug(@"%@", error);
    } else if (fetchedObjects.count > 0) {
        [fetchedObjects enumerateObjectsUsingBlock:^(XTTag *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [context deleteObject:obj];
        }];
    }
}


- (nullable XTTag *)initWithName:(nullable NSString *)name managedObjectContext:(nullable NSManagedObjectContext *)context {
    if (!name || !name.length) {
        return nil;
    }
    
    @try {
        self = [XTTag itemWithName:name managedObjectContext:context];
        if (!self) {
            self = [XTTag insertInManagedObjectContext:context];
        }
        
        self.name = name;
    }
    @catch (NSException *exception) {
        DDLogError(@"%@", exception);
    }
    
    return self;
}


@end
