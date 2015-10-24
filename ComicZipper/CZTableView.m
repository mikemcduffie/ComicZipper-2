//
//  CZTableView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZTableView.h"

@interface CZTableView ()

@property (nonatomic) BOOL commandKeyState;
@property (nonatomic) NSInteger *row;

@end

@implementation CZTableView

#pragma mark SET UP METHODS

- (void)awakeFromNib {
    NSTableColumn *columnLft = [self tableColumnWithIdentifier:@"ColumnLeft"];
    NSTableColumn *columnMdl = [self tableColumnWithIdentifier:@"ColumnMiddle"];
    NSTableColumn *columnRgt = [self tableColumnWithIdentifier:@"ColumnRight"];
    [columnLft setWidth:kTableColumnWidth];
    [columnMdl setWidth:self.frame.size.width-(kTableColumnWidth*2)-10];
    [columnRgt setWidth:kTableColumnWidth];
    [columnLft setResizingMask:NSTableColumnNoResizing];
    [columnMdl setResizingMask:NSTableColumnAutoresizingMask];
    [columnRgt setResizingMask:NSTableColumnNoResizing];
    [self setAllowsColumnResizing:NO];
    [self setAllowsColumnSelection:NO];
    [self setAllowsColumnReordering:NO];
    [self setAllowsMultipleSelection:YES];
    [self setUsesAlternatingRowBackgroundColors:YES];
    [self setColumnAutoresizingStyle:NSTableViewReverseSequentialColumnAutoresizingStyle];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [self setMenu:menu];
    [self.menu insertItemWithTitle:@"Show in Finder"
                            action:@selector(menuItemOpenFinder)
                     keyEquivalent:@""
                           atIndex:0];
    [self.menu insertItemWithTitle:@"Remove from list"
                            action:@selector(menuItemRemove)
                     keyEquivalent:@""
                           atIndex:1];
}

#pragma mark MENU METHODS

- (void)menuItemOpenFinder {
    [self.delegate openItemInFinder:self.selectedRowIndexes];
}

- (void)menuItemRemove {
    [self.delegate tableView:self
            DidRegisterKeyUp:kDeleteKey
                atRowIndexes:self.selectedRowIndexes
                 withCommand:NO];
}

- (void)flagsChanged:(NSEvent *)theEvent {
    if (theEvent.modifierFlags & NSCommandKeyMask) {
        self.commandKeyState = !self.commandKeyState;
    }
}

- (void)keyUp:(NSEvent *)theEvent {
    // Filter out delete key, otherwise it will run twice ( as a key stroke event, and a menu item event)
    if (theEvent.keyCode != kDeleteKey) {
        [self.delegate tableView:self
                DidRegisterKeyUp:theEvent.keyCode
                    atRowIndexes:self.selectedRowIndexes
                     withCommand:self.commandKeyState];
    }
}

- (void)delete:(id)sender {
    // Needed to enable the delete menu item.
    [self menuItemRemove];
}

- (void)mouseDown:(NSEvent *)event {
    if ([event clickCount] > 1) {
        NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
        NSInteger row = [self rowAtPoint:point];
        NSIndexSet *i = [NSIndexSet indexSetWithIndex:row];
        [self.delegate openItemInFinder:i];
    }
    
    [super mouseDown:event];
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSPoint point = [self convertPoint:event.locationInWindow
                              fromView:nil];
    NSInteger row = [self rowAtPoint:point];
    if (row > -1 && row < self.numberOfRows) {
        if ([self.selectedRowIndexes containsIndex:row] == NO) {
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
              byExtendingSelection:NO];
        }

        return self.menu;
    }
    
    return nil;
}

- (void)scrollRowToVisible:(NSInteger)index
                   animate:(BOOL)animate {
    // Borrowed and slightly adjusted from https://gist.github.com/kgn/1558664
    if (animate) {
        NSRect rowRect = [self rectOfRow:index];
        NSPoint origin = rowRect.origin;
        NSClipView *clipView = (NSClipView *)[self superview];
        origin.y += MAX(0, round((NSHeight(rowRect) - NSHeight(clipView.frame)) * 0.5f));
        [[clipView animator] setBoundsOrigin:origin];
    } else {
        [self scrollRowToVisible:index];
    }
}

#pragma mark SETTERS AND GETTERS

- (void)setDelegate:(id<CZTableViewDelegate>)delegate {
    super.delegate = delegate;
}

- (id)delegate {
    return super.delegate;
}

@end
