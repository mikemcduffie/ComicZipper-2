//
//  ComicZipper.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@class CZDropItem;

@interface ComicZipper : NSObject <NSTableViewDataSource>

- (void)addItem:(CZDropItem *)item;
- (void)addItems:(NSArray *)items;
- (CZDropItem *)itemAtIndex:(NSInteger)index;
- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes;

@end
