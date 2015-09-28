//
//  CZTableView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZTableView.h"

@interface CZTableView ()

@property (nonatomic) BOOL commandKeyState;
@property (nonatomic) NSInteger *row;

@end

@implementation CZTableView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setMenu:[[NSMenu alloc] initWithTitle:@"Contextual Menu"]];
        [[self menu] insertItemWithTitle:@"Show in Finder"
                                  action:@selector(menuItemOpenFinder)
                           keyEquivalent:@""
                                 atIndex:0];
        [[self menu] insertItemWithTitle:@"Remove from list"
                                  action:@selector(menuItemRemove)
                            keyEquivalent:@""
                                 atIndex:1];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)menuItemOpenFinder {
//    [[self delegate] openItemFinder:[self selectedRowIndexes]];
}



@end
