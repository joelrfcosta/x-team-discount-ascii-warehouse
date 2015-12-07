// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XTTag.m instead.

#import "_XTTag.h"

const struct XTTagAttributes XTTagAttributes = {
	.name = @"name",
};

const struct XTTagRelationships XTTagRelationships = {
	.items = @"items",
};

@implementation XTTagID
@end

@implementation _XTTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"XTTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"XTTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"XTTag" inManagedObjectContext:moc_];
}

- (XTTagID*)objectID {
	return (XTTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@dynamic items;

- (NSMutableSet*)itemsSet {
	[self willAccessValueForKey:@"items"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"items"];

	[self didAccessValueForKey:@"items"];
	return result;
}

@end

