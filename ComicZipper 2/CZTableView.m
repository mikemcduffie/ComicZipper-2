//
//  CZTableView.m
//  ComicZipper 2
//
//  Created 19/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZTableView.h"


@interface CZTableView ()

@property (nonatomic) BOOL commandKeyState;
//@property (nonatomic) NSMenu *menu;
@property (nonatomic) NSInteger *row;

@end

@implementation CZTableView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.menu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
        [[self menu] insertItemWithTitle:@"Show in Finder" action:@selector(menuItemOpenFinder) keyEquivalent:@"" atIndex:0];
        [[self menu] insertItemWithTitle:@"Remove from list" action:@selector(menuItemRemove) keyEquivalent:@"" atIndex:1];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


- (void)menuItemOpenFinder {
    [[self CZDelegate] openItemInFinder:[self selectedRowIndexes]];
}

- (void)menuItemRemove {
    [[self CZDelegate] tableView:self DidRegisterKeyUp:51 withCommand:NO];
}

- (void)flagsChanged:(NSEvent *)theEvent {
    if (theEvent.modifierFlags & NSCommandKeyMask) {
        [self setCommandKeyState:![self commandKeyState]];
    }
}

- (void)keyUp:(NSEvent *)theEvent {
    [[self CZDelegate] tableView:self DidRegisterKeyUp:[theEvent keyCode] withCommand:[self commandKeyState]];
}


- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:p];

    if (row == -1) {
        return nil;
    }
    
    if (row < [self numberOfRows]) {
        if ([[self selectedRowIndexes] containsIndex:row] == NO) {
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        }

            return [self menu];
    }

    return nil;
}

@end