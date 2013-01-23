//
//  STWeakArrayTests.m
//  STWeakCollectionsTests
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STWeakArrayTests.h"

#import "STWeakArray.h"


@implementation STWeakArrayTests

- (void)testDegenerate {
	{
		STWeakMutableArray * const array = [STWeakMutableArray arrayWithCapacity:0];
		@autoreleasepool {
			id foo = [[NSObject alloc] init];
			[array addObject:foo];
			STAssertEquals([array count], (NSUInteger)1, @"", nil);
			STAssertNotNil(array[0], @"", nil);
			STAssertEquals(array[0], foo, @"", nil);
			STAssertTrue([array containsObject:foo], @"", nil);
		}

		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNil(array[0], @"", nil);
	}

	{
		STWeakMutableArray * const array = [STWeakMutableArray arrayWithCapacity:0];

		id foo = [[NSObject alloc] init];
		[array addObject:foo];
		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);

		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);
	}

	{
		STWeakMutableArray * const array = [STWeakMutableArray arrayWithCapacity:0];
		@autoreleasepool {
			id foo = [[NSObject alloc] init];
			[array addObject:foo];
			STAssertEquals([array count], (NSUInteger)1, @"", nil);
			STAssertNotNil(array[0], @"", nil);
			STAssertEquals(array[0], foo, @"", nil);
		}

		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNil(array[0], @"", nil);

		[array removeObjectAtIndex:0];

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}

	{
		STWeakMutableArray * const array = [STWeakMutableArray arrayWithCapacity:0];

		id foo = [[NSObject alloc] init];
		[array addObject:foo];
		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);

		[array removeObjectAtIndex:0];

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}

	{
		STWeakMutableArray * const array = [STWeakMutableArray arrayWithCapacity:0];

		id foo = [[NSObject alloc] init];
		[array addObject:foo];
		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);

		[array removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0]];

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}
}

@end
