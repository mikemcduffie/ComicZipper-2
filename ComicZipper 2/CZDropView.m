//
//  CZDropView.m
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZDropView.h"
#import "CZArchiverItem.h"

@interface CZDropView () <NSDraggingDestination>

@property (nonatomic) BOOL highligted;
@property (nonatomic) NSInteger numberOfValidItemsForDrop;
@property (nonatomic) NSMutableArray *items;

@end

@implementation CZDropView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = [NSMutableArray array];
        // Registers the pasteboard types that the receiver
        // will accept as the destination of an image-dragging session.
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }

    return self;
}

// Fixes the keystroke "error beep"
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    // Allows only CMD+; and up and down arrows.
    if ([theEvent modifierFlags] & NSCommandKeyMask || [theEvent keyCode] == 126 || [theEvent keyCode] == 125) {
        return NO;
    }
    return YES;
}

#pragma mark HIGHLIGHTING METHODS

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Highlight the drop view area
    if ([self highligted]) {
        [NSBezierPath setDefaultLineWidth:5.0];
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath fillRect:dirtyRect];
//        [NSBezierPath strokeRect:dirtyRect];
    }
}
// Highlight the drop view area
- (void)setHighligted:(BOOL)highligted {
    _highligted = highligted;
    if ([[self delegate] isDropViewFront]) {
        [self setNeedsDisplay:YES];   
    }
}

#pragma mark DRAGGING OPERATIONS

// Method is called when an item is dragged unto
// the drop destination bounds. Method will run
// through each item to see if they are Finder
// folders (by calling CZArchiverItem).
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    // If view is not draggable that means
    // the compressor is at work and user
    // should not be able to add items to
    // the queue.
    if (![self isDraggable]) {
        return NSDragOperationNone;
    }
    // Reset the counter so that the badge will
    // display the proper number of items to drop.
    self.numberOfValidItemsForDrop = 0;
    // Check if the dragged items are valid, that is, folders with the NSDraggingInfo method
    // enumerateDraggingItemsWithOptions:forview:Classes:SearchOptions:usingBlock:.
    NSArray *classes = [NSArray arrayWithObjects:[CZArchiverItem class], nil];
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages
                                      forView:self
                                      classes:classes
                                searchOptions:nil
                                   usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                       // Check if the item is already in the queue by
                                       // calling delegate method dropView:isItemInList:.
                                       if (![[self delegate] dropView:self isItemInList:[[draggingItem item] description]]) {
                                           // Check so array is initialized
                                           if ([self items] == nil) {
                                               self.items = [NSMutableArray arrayWithObject:[draggingItem item]];
                                           } else {
                                               [[self items] addObject:[draggingItem item]];
                                           }
                                           // Increase vald items counter and inform the
                                           // sender (NSDraggingInfo object) of the number
                                           // of valid items to drop, so that the drop
                                           // manager can update the badge count.
                                           self.numberOfValidItemsForDrop++;
                                           [sender setNumberOfValidItemsForDrop:self.numberOfValidItemsForDrop];
                                       }
                                   }];
    // Highlight the drop view area
    if (![self highligted]) {
        [self setHighligted:YES];
    }
    // Check if there are valid items to drop
    if (self.numberOfValidItemsForDrop) {
        return NSDragOperationCopy;
    } else {
        return NSDragOperationNone;
    }
}

// If drag operation was aborted then
// the cleanUp method should be called
// and the highlight removed.
- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self cleanUp];
    
    if ([self highligted]) {
        [self setHighligted:NO];
    }
}

// Invoked when the image is released,
// allowing the receiver to agree to
// or refuse drag operation.
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    [sender setAnimatesToDestination:NO];
    return YES;
}

// Invoked after the released image has been
// removed from the screen, signaling the receiver
// to import the pasteboard data.
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    if ([self highligted]) {
        [self setHighligted:NO];
    }

    if ([self items]) {
        [[self delegate] dropView:self didReceiveFiles:[self items]];
    }
    
    return YES;
}

// Invoked when the dragging operation is complete,
// signaling the receiver to perform any necessary clean-up.
- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self cleanUp];
}

# pragma mark CLEAN UP

- (void)cleanUp {
    if ([self items]) {
        self.items = nil;
    }
}

@end
