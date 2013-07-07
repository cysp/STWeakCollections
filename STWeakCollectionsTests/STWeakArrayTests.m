//
//  STWeakArrayTests.m
//  STWeakCollectionsTests
//
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "STWeakArrayTests.h"

#import "STWeakArray.h"


@protocol STWeakArrayTestProtocol <NSObject>
@end
@interface STWeakArrayTestObject : NSObject <STWeakArrayTestProtocol>
@end
@implementation STWeakArrayTestObject
@end


@implementation STWeakArrayTests

- (void)testDegenerate {
	{
		STMutableWeakArray * const array = [STMutableWeakArray arrayWithCapacity:0];
		@autoreleasepool {
			id foo = [[NSObject alloc] init];
			[array addObject:foo];
			STAssertEquals([array count], (NSUInteger)1, @"", nil);
			STAssertNotNil(array[0], @"", nil);
			STAssertEquals(array[0], foo, @"", nil);
			STAssertTrue([array containsObject:foo], @"", nil);
		}

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}

	{
		STMutableWeakArray * const array = [STMutableWeakArray arrayWithCapacity:0];

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
		STMutableWeakArray * const array = [STMutableWeakArray arrayWithCapacity:0];
		@autoreleasepool {
			id foo = [[NSObject alloc] init];
			[array addObject:foo];
			STAssertEquals([array count], (NSUInteger)1, @"", nil);
			STAssertNotNil(array[0], @"", nil);
			STAssertEquals(array[0], foo, @"", nil);
		}

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}

	{
		STMutableWeakArray * const array = [STMutableWeakArray arrayWithCapacity:0];

		id foo = [[NSObject alloc] init];
		[array addObject:foo];
		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);

		[array removeObjectAtIndex:0];

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}

	{
		STMutableWeakArray * const array = [STMutableWeakArray arrayWithCapacity:0];

		id foo = [[NSObject alloc] init];
		[array addObject:foo];
		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);

		[array removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:0]];

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}
}

- (void)testEnumeration {
	{
		STMutableWeakArray * const array = [STMutableWeakArray arrayWithCapacity:0];
		@autoreleasepool {
			id foo = [[NSObject alloc] init];
			[array addObject:foo];
			STAssertEquals([array count], (NSUInteger)1, @"", nil);

			{
				NSUInteger __block count = 0;
				[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					++count;
				}];
				STAssertEquals(count, 1UL, @"", nil);
			}
		}

		{
			NSUInteger __block count = 0;
			[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				++count;
			}];
			STAssertEquals(count, 0UL, @"", nil);
		}

		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}
}

- (void)testProtocolConformanceAssertion {
	{
		STMutableWeakArray * const array = [[STMutableWeakArray alloc] initWithCapacity:0 options:@{
			STCollectionOptionRequiredProtocols: @[ @protocol(STWeakArrayTestProtocol) ],
		}];

		id foo = [[STWeakArrayTestObject alloc] init];
		[array addObject:foo];
		STAssertEquals([array count], (NSUInteger)1, @"", nil);
		STAssertNotNil(array[0], @"", nil);
		STAssertEquals(array[0], foo, @"", nil);
	}

	{
		STMutableWeakArray * const array = [[STMutableWeakArray alloc] initWithCapacity:0 options:@{
			STCollectionOptionRequiredProtocols: @[ @protocol(STWeakArrayTestProtocol) ],
		}];

		id foo = [[NSObject alloc] init];
		STAssertThrows([array addObject:foo], @"", nil);
		STAssertEquals([array count], (NSUInteger)0, @"", nil);
	}
}

@end
