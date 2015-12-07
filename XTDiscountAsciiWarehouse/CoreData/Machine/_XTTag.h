// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XTTag.h instead.

@import CoreData;

extern const struct XTTagAttributes {
	__unsafe_unretained NSString *name;
} XTTagAttributes;

extern const struct XTTagRelationships {
	__unsafe_unretained NSString *items;
} XTTagRelationships;

@class XTItem;

@interface XTTagID : NSManagedObjectID {}
@end

@interface _XTTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) XTTagID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *items;

- (NSMutableSet*)itemsSet;

@end

@interface _XTTag (ItemsCoreDataGeneratedAccessors)
- (void)addItems:(NSSet*)value_;
- (void)removeItems:(NSSet*)value_;
- (void)addItemsObject:(XTItem*)value_;
- (void)removeItemsObject:(XTItem*)value_;

@end

@interface _XTTag (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSMutableSet*)primitiveItems;
- (void)setPrimitiveItems:(NSMutableSet*)value;

@end
