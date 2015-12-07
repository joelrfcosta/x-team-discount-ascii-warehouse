// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XTItem.m instead.

#import "_XTItem.h"

const struct XTItemAttributes XTItemAttributes = {
	.face = @"face",
	.identifier = @"identifier",
	.price = @"price",
	.size = @"size",
	.stock = @"stock",
	.type = @"type",
};

const struct XTItemRelationships XTItemRelationships = {
	.tags = @"tags",
};

@implementation XTItemID
@end

@implementation _XTItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"XTItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"XTItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"XTItem" inManagedObjectContext:moc_];
}

- (XTItemID*)objectID {
	return (XTItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"priceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"price"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"size"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stockValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stock"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic face;

@dynamic identifier;

@dynamic price;

- (int16_t)priceValue {
	NSNumber *result = [self price];
	return [result shortValue];
}

- (void)setPriceValue:(int16_t)value_ {
	[self setPrice:@(value_)];
}

- (int16_t)primitivePriceValue {
	NSNumber *result = [self primitivePrice];
	return [result shortValue];
}

- (void)setPrimitivePriceValue:(int16_t)value_ {
	[self setPrimitivePrice:@(value_)];
}

@dynamic size;

- (int16_t)sizeValue {
	NSNumber *result = [self size];
	return [result shortValue];
}

- (void)setSizeValue:(int16_t)value_ {
	[self setSize:@(value_)];
}

- (int16_t)primitiveSizeValue {
	NSNumber *result = [self primitiveSize];
	return [result shortValue];
}

- (void)setPrimitiveSizeValue:(int16_t)value_ {
	[self setPrimitiveSize:@(value_)];
}

@dynamic stock;

- (int16_t)stockValue {
	NSNumber *result = [self stock];
	return [result shortValue];
}

- (void)setStockValue:(int16_t)value_ {
	[self setStock:@(value_)];
}

- (int16_t)primitiveStockValue {
	NSNumber *result = [self primitiveStock];
	return [result shortValue];
}

- (void)setPrimitiveStockValue:(int16_t)value_ {
	[self setPrimitiveStock:@(value_)];
}

@dynamic type;

@dynamic tags;

- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];

	[self didAccessValueForKey:@"tags"];
	return result;
}

@end

