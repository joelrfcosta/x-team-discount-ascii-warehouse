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
    
    DDLogDebug(@"%@", self);
    
    return self;
}


@end
