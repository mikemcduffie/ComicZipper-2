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

- (void)setDelegate:(id<CZTableViewDelegate>)delegate {
    [super setDelegate:delegate];
}

- (id)delegate {
    return [super delegate];
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    // Set up the contextual menu for the table view
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

- (void)menuItemOpenFinder {
    [[self delegate] openItemInFinder:[self selectedRowIndexes]];
}

- (void)menuItemRemove {
    [[self delegate] tableView:self
              DidRegisterKeyUp:kDeleteKey
                  atRowIndexes:[self selectedRowIndexes]
                   withCommand:NO];
}

- (void)flagsChanged:(NSEvent *)theEvent {
    if ([theEvent modifierFlags] & NSCommandKeyMask) {
        [self setCommandKeyState:![self commandKeyState]];
    }
}

- (void)keyUp:(NSEvent *)theEvent {
    [[self delegate] tableView:self
              DidRegisterKeyUp:[theEvent keyCode]
                  atRowIndexes:[self selectedRowIndexes]
                   withCommand:[self commandKeyState]];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:point];
    //
    if (row > -1 && row < [self numberOfRows]) {
        if ([[self selectedRowIndexes] containsIndex:row] == NO) {
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
              byExtendingSelection:NO];
        }
        
        return [self menu];
    }
    
    return nil;
}

@end
