//
//  ComicZipper.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "ComicZipper.h"
#import "CZDropItem.h"

@interface ComicZipper ()

@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) NSMutableArray *itemsProcessed;
@property (nonatomic) NSMutableArray *itemsToProcess;

@end

@implementation ComicZipper

- (void)addItem:(CZDropItem *)item {
    [self.archiveItems addObject:item];
}

- (void)addItems:(NSArray *)items {
    [self.archiveItems addObjectsFromArray:items];
}

#pragma mark TABLE VIEW DATA SOURCE METHODS

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.archiveItems.count;
}

#pragma mark SETTERS AND GETTERS

- (NSMutableArray *)archiveItems {
    if (!_archiveItems) {
        _archiveItems = [NSMutableArray array];
    }
    
    return _archiveItems;
}

@end
