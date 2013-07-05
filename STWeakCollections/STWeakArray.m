//
//  STWeakArray.m
//  STWeakCollections
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STWeakArray.h"

#import <objc/runtime.h>


typedef BOOL(^STCollectionElementValidator)(id obj);


@interface STMutableWeakArray ()
- (void)checkIndex:(NSUInteger)index count:(NSUInteger)count;
- (void)checkIndex:(NSUInteger)index count:(NSUInteger)count forInsertion:(BOOL)forInsertion;
- (void)checkObject:(id)obj;
- (void)compact;
- (void)resizeToSize:(NSUInteger)size;
@end

@implementation STMutableWeakArray {
@private
	unsigned long _mutationsCount;
	id *_weakObjects;
	NSUInteger _weakObjectsCapacity;
	NSUInteger _weakObjectsCount;
	STCollectionElementValidator _validator;
}

- (id)init {
    return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity {
	if ((self = [super init])) {
		if (capacity) {
			_weakObjects = calloc(capacity, sizeof(void *));
			_weakObjectsCapacity = capacity;
		}
    }
    return self;
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt {
    if ((self = [self initWithCapacity:cnt])) {
		for (NSUInteger i = 0; i < cnt; ++i) {
			[self addObject:objects[i]];
		}
	}
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity options:(NSDictionary *)options {
	if ((self = [self initWithCapacity:capacity])) {
		_validator = [^(id obj) {
			for (Protocol *protocol in options[STCollectionOptionRequiredProtocols]) {
				if (![obj conformsToProtocol:protocol]) {
					return NO;
				}
			}
			return YES;
		} copy];
	}
	return self;
}


- (void)dealloc {
	free(_weakObjects), _weakObjects = NULL;
	[super dealloc];
}


- (NSUInteger)count {
	[self compact];
	return _weakObjectsCount;
}

- (void)addObject:(id)anObject {
	[self insertObject:anObject atIndex:_weakObjectsCount];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
	[self checkIndex:index count:_weakObjectsCount forInsertion:YES];
	[self checkObject:anObject];
	if (_weakObjectsCount + 1 > _weakObjectsCapacity) {
		[self resizeToSize:(_weakObjectsCapacity * 2) ?: 16];
	}
	++_mutationsCount;
	for (NSUInteger i = _weakObjectsCount; i > index; --i) {
		id *objectPriorAddress = (id *)&_weakObjects[i-1];
		id *objectAddress = (id *)&_weakObjects[i];
		id object = objc_loadWeak(objectPriorAddress);
		objc_storeWeak(objectAddress, object);
	}
	id *objectAddress = (id *)&_weakObjects[index];
	objc_storeWeak(objectAddress, anObject);
	++_weakObjectsCount;
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	[self checkIndex:index count:_weakObjectsCount];
	[self checkObject:anObject];
	++_mutationsCount;
	id *objectAddress = (id *)&_weakObjects[index];
	objc_storeWeak(objectAddress, anObject);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	[self checkIndex:index count:_weakObjectsCount];
	++_mutationsCount;
	NSUInteger weakObjectsCount = _weakObjectsCount;
	for (NSUInteger i = index; i < weakObjectsCount; ++i) {
		id *objectAddress = (id *)&_weakObjects[i];
		id *objectAfterAddress = (id *)&_weakObjects[i+1];
		id object = objc_loadWeak(objectAfterAddress);
		objc_storeWeak(objectAddress, object);
	}
	id *objectAddress = (id *)&_weakObjects[weakObjectsCount];
	objc_storeWeak(objectAddress, nil);
	--_weakObjectsCount;
}

- (id)objectAtIndex:(NSUInteger)index {
	[self checkIndex:index count:_weakObjectsCount];
	id *objectAddress = (id *)&_weakObjects[index];
	id object = objc_loadWeak(objectAddress);
	return object;
}


- (void)compact {
	NSUInteger weakObjectsCount = _weakObjectsCount;
	NSUInteger elidedWeakObjectsCount = 0;
	for (NSUInteger i = 0; i < weakObjectsCount; ++i) {
		id *objectAddress = &_weakObjects[i];
		id object = objc_loadWeak(objectAddress);
		if (!object) {
			id *objectAfterAddress = (id *)&_weakObjects[i+1];
			id objectAfter = objc_loadWeak(objectAfterAddress);
			objc_storeWeak(objectAddress, objectAfter);
			objc_storeWeak(objectAfterAddress, nil);
			++elidedWeakObjectsCount;
		}
	}
	_weakObjectsCount -= elidedWeakObjectsCount;
}


- (void)checkIndex:(NSUInteger)index count:(NSUInteger)count {
	[self checkIndex:index count:count forInsertion:NO];
}

- (void)checkIndex:(NSUInteger)index count:(NSUInteger)count forInsertion:(BOOL)forInsertion {
	NSUInteger upperBound = forInsertion ? count + 1 : count;
	if (index >= upperBound) {
		if (count) {
			@throw [NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"index %lu beyond bounds [0 .. %lu]", (unsigned long)index, (unsigned long)count-1] userInfo:nil];
		} else {
			@throw [NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"index %lu beyond bounds for empty array", (unsigned long)index] userInfo:nil];
		}
	}
}


- (void)checkObject:(id)obj {
	if (_validator && !_validator(obj)) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Object failed validation" userInfo:nil];
	}
}


- (void)resizeToSize:(NSUInteger)size {
	void *weakObjects = calloc(size, sizeof(void *));
	if (!weakObjects) {
		@throw [NSException exceptionWithName:NSMallocException reason:nil userInfo:nil];
	}

	for (NSUInteger i = 0; i < _weakObjectsCount; ++i) {
		id *objectAddress = &_weakObjects[i];
		id object = objc_loadWeak(objectAddress);
		if (object) {
			if (i < size) {
				id *objectNewAddress = &weakObjects[i];
				objc_storeWeak(objectNewAddress, object);
			}
			objc_storeWeak(objectAddress, nil);
		}
	}
	free(_weakObjects);
	_weakObjects = weakObjects;
	_weakObjectsCapacity = size;
}


#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	state->mutationsPtr = &_mutationsCount;
	state->itemsPtr = (id *)_weakObjects;
	return _weakObjectsCount;
}

@end
