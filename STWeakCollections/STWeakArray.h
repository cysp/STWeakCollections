//
//  STWeakArray.h
//  STWeakCollections
//
//  Created by Scott Talbot on 23/01/13.
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STCollection.h"


@interface STMutableWeakArray : NSMutableArray

- (id)initWithCapacity:(NSUInteger)capacity options:(NSDictionary *)options;

@end
