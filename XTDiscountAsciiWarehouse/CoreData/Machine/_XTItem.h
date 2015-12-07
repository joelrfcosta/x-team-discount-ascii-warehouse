// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XTItem.h instead.

@import CoreData;

extern const struct XTItemAttributes {
	__unsafe_unretained NSString *face;
	__unsafe_unretained NSString *identifier;
	__unsafe_unretained NSString *price;
	__unsafe_unretained NSString *size;
	__unsafe_unretained NSString *stock;
	__unsafe_unretained NSString *type;
} XTItemAttributes;

extern const struct XTItemRelationships {
	__unsafe_unretained NSString *tags;
} XTItemRelationships;

@class XTTag;

@interface XTItemID : NSManagedObjectID {}
@end

@interface _XTItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) XTItemID* objectID;

@property (nonatomic, strong) NSString* face;

//- (BOOL)validateFace:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* identifier;

//- (BOOL)validateIdentifier:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* price;

@property (atomic) int16_t priceValue;
- (int16_t)priceValue;
- (void)setPriceValue:(int16_t)value_;

//- (BOOL)validatePrice:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* size;

@property (atomic) int16_t sizeValue;
- (int16_t)sizeValue;
- (void)setSizeValue:(int16_t)value_;

//- (BOOL)validateSize:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* stock;

@property (atomic) int16_t stockValue;
- (int16_t)stockValue;
- (void)setStockValue:(int16_t)value_;

//- (BOOL)validateStock:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;

@end

@interface _XTItem (TagsCoreDataGeneratedAccessors)
- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(XTTag*)value_;
- (void)removeTagsObject:(XTTag*)value_;

@end

@interface _XTItem (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveFace;
- (void)setPrimitiveFace:(NSString*)value;

- (NSString*)primitiveIdentifier;
- (void)setPrimitiveIdentifier:(NSString*)value;

- (NSNumber*)primitivePrice;
- (void)setPrimitivePrice:(NSNumber*)value;

- (int16_t)primitivePriceValue;
- (void)setPrimitivePriceValue:(int16_t)value_;

- (NSNumber*)primitiveSize;
- (void)setPrimitiveSize:(NSNumber*)value;

- (int16_t)primitiveSizeValue;
- (void)setPrimitiveSizeValue:(int16_t)value_;

- (NSNumber*)primitiveStock;
- (void)setPrimitiveStock:(NSNumber*)value;

- (int16_t)primitiveStockValue;
- (void)setPrimitiveStockValue:(int16_t)value_;

- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;

@end
