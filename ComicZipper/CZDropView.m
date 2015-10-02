//
//  CZDropView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZDropView.h"
#import "CZDropItem.h"

@interface CZDropView () <NSDraggingDestination>

@property (nonatomic, getter=isViewHighlighted) BOOL viewHighlight;
@property (nonatomic) NSInteger numberOfValidItemsForDrop;
@property (nonatomic) NSMutableArray *droppedItems;

@end

@implementation CZDropView

/*!
 *  @brief Initial setup method.
 */
- (void)initialSetup {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    _dragMode = YES;
    _droppedItems = [[NSMutableArray alloc] init];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

- (void)awakeFromNib {
    [self initialSetup];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Highlight the drop view area
    if ([self isViewHighlighted]) {
        [NSBezierPath setDefaultLineWidth:5.0];
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath fillRect:dirtyRect];
    }
}

/*!
 *  @brief The setter method of highlight property will redraw the view.
 *  @discussion During the drawRect: method, the view will be redrawn with an overlay.
 *  @param highlight Boolean value of the property. Set YES to turn on highlight.
 */
- (void)setViewHighlight:(BOOL)highlight {
    _viewHighlight = highlight;
    [self setNeedsDisplay:YES];
}

/*!
 *  @brief Invoked when the dragged image enters destination bounds or frame; delegate returns dragging operation to perform.
 *  @param sender The object sending the message; use it to get details about the dragging operation.
 *  @return One (and only one) of the dragging operation constants described in NSDragOperation in the NSDraggingInfo reference.
 *
 */
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    // Abort drag operation if the view should not be in drop mode (in compression mode no objects should be added).
    if (![self inDragMode]) {
        return NSDragOperationNone;
    }
    if (![self isViewHighlighted]) {
        [self setViewHighlight:YES];
    }
    // Reset the count before enumeration, so the badge displays the correct number of valid items.
    [self setNumberOfValidItemsForDrop:0];
    // Enumerate through the dragged items, checking against the CZDropItem class that will make sure that the dragged items are, in fact, a folder.
    NSArray *classArray = [NSArray arrayWithObjects:[CZDropItem class], nil];
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages
                                      forView:self
                                      classes:classArray
                                searchOptions:@{} // nil gives a warning, so send an empty dictionary instead.
                                   usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                       // Folders already added to the list should not be added or reloaded.
                                       if (![[self delegate] dropView:self
                                                         isItemInList:[[draggingItem item] description]]) {
                                           if (![self droppedItems]) {
                                               NSMutableArray *droppedItems = [[NSMutableArray alloc] init];
                                               [self setDroppedItems:droppedItems];
                                           }
                                           [[self droppedItems] addObject:[draggingItem item]];
                                           [self setNumberOfValidItemsForDrop:[self numberOfValidItemsForDrop]+1];
                                       }
    }];
    // inform the sender of the number of valid items to drop, so that the drop manager can update the badge count.
    [sender setNumberOfValidItemsForDrop:[self numberOfValidItemsForDrop]];
    
    if ([self numberOfValidItemsForDrop]) {
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    [sender setAnimatesToDestination:NO];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    if ([self isViewHighlighted]) {
        [self setViewHighlight:NO];
    }
    // The drop view delegate will take over the items, making it safe for deallocating the droppedItems array later in the cleanUp: method.
    if ([self droppedItems]) {
        [[self delegate] dropView:self
                  didReceiveFiles:[self droppedItems]];
    }
    
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self cleanUp];
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    if ([self isViewHighlighted]) {
        [self setViewHighlight:NO];
    }
    // Cleanup must be done on draggingExited: so as to empty the array. Otherwise the objects will pile up and in the array and all will be added later on.
    [self cleanUp];
}

/*!
 *  @brief Cleans up after the drag operation.
 *  @discussion Invoked once drag operation has finished, releasing any unecessary objects.
 */
- (void)cleanUp {
    if ([self droppedItems]) {
        [self setDroppedItems:nil];
    }
}

@end
