#import "XTItem.h"
#import "XTTag.h"

@interface XTItem ()

@end

@implementation XTItem

+ (nonnull NSArray *)addItems:(nullable NSArray *)items managedObjectContext:(nullable NSManagedObjectContext *)context {
    NSMutableArray *itemsAdded = [NSMutableArray new];
    
    [items enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XTItem *item = [[XTItem alloc] initWithString:obj managedObjectContext:context];
        if (item) {
            [itemsAdded addObject:item];
        }
    }];
    
    return itemsAdded;
}

+ (nullable XTItem *)itemWithIdentifier:(nullable NSString *)identifier managedObjectContext:(nullable NSManagedObjectContext *)context {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [NSFetchRequest new];
    
    [fetch setEntity:[NSEntityDescription entityForName:@"XTItem" inManagedObjectContext:context]];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", identifier]];
    
    NSError *error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    if(fetchedObjects.count == 1) {
        return [fetchedObjects objectAtIndex:0];
    }
    
    return nil;
}

- (nullable XTItem *)initWithString:(nullable NSString *)string managedObjectContext:(nullable NSManagedObjectContext *)context {
    if (!string || !string.length) {
        return nil;
    }
    
    NSError *error;
    
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        DDLogError(@"%@", error);
        return nil;
    }
    
    @try {
        NSString *identifier = [data objectForKey:@"id"];
        
        self = [XTItem itemWithIdentifier:identifier managedObjectContext:context];
        if (!self) {
            self = [XTItem insertInManagedObjectContext:context];
        }
        
        self.face = [data objectForKey:@"face"];
        self.identifier = identifier;
        self.price = [data objectForKey:@"price"];
        self.size = [data objectForKey:@"size"];
        self.stock = [data objectForKey:@"stock"];
        self.type = [data objectForKey:@"type"];
        
        [[data objectForKey:@"tags"] enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
            XTTag *tag = [[XTTag alloc] initWithName:name managedObjectContext:context];
            if (tag) {
                [self addTagsObject:tag];
            }
        }];
        
    }
    @catch (NSException *exception) {
        DDLogError(@"%@\nData:\n%@", exception, data);
        return nil;
    }
    
    DDLogDebug(@"%@", self);
    
    return self;
}

@end
