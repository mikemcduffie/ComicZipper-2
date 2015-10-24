//
//  CZDropView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZDropView.h"
#import "CZDropItem.h"

@interface CZDropView () <NSDraggingDestination>

@property (nonatomic, getter = isHighlighted) BOOL highlight;
@property (nonatomic) NSInteger numberOfValidItemsForDrop;
@property (nonatomic) NSMutableArray *droppedItems;
@property (strong) IBOutlet NSImageView *imageView;

@end

@implementation CZDropView

- (void)awakeFromNib {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
}

- (void)setHighlight:(BOOL)highlight {
    _highlight = highlight;
    [self.delegate dropView:self
        viewShouldHighlight:highlight];
}

#pragma mark DRAG METHODS
/*!
 *  @brief Invoked when the dragged image enters destination bounds or frame; delegate returns dragging operation to perform.
 *  @param sender The object sending the message; use it to get details about the dragging operation.
 *  @return One (and only one) of the dragging operation constants described in NSDragOperation in the NSDraggingInfo reference.
 *
 */
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    // Abort drag operation if the view should not be in drop mode (in compression mode no objects should be added).
    if (self.isInDragMode == YES) {
        return NSDragOperationNone;
    }
    // Turn on the highlight
    if (self.isHighlighted == NO) {
        self.highlight = YES;
    }
    // Reset the count before enumeration, so the badge displays the correct number of valid items.
    self.numberOfValidItemsForDrop = 0;
    NSArray *classArray = [NSArray arrayWithObjects:[CZDropItem class], nil];
    // Enumerate through the dragged items, checking against the CZDropItem class that will make sure that the dragged items are, in fact, a valid folder.
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages
                                      forView:self
                                      classes:classArray
                                searchOptions:@{}
                                   usingBlock:
     ^(NSDraggingItem * _Nonnull draggingItem, NSInteger idx, BOOL * _Nonnull stop) {
         // Files already in the list should not be included in drag operation
         BOOL isFileInList = [self.delegate dropView:self isItemInList:[draggingItem.item folderPath]];
         if (isFileInList == NO) {
             [self.droppedItems addObject:draggingItem.item];
             self.numberOfValidItemsForDrop++;
         } else {
             draggingItem.imageComponentsProvider = nil;
         }
    }];
    // Inform the sender of the number of valid items to drop, so that the drop manager can update the badge count.
    [sender setNumberOfValidItemsForDrop:self.numberOfValidItemsForDrop];
    if (self.numberOfValidItemsForDrop > 0) {
        return NSDragOperationCopy;
    } else {
        self.highlight = NO;
        return NSDragOperationNone;
    }
}
/*!
 *  @description Invoked when the dragged image exits the destination’s bounds rectangle (in the case of a view object) or its frame rectangle (in the case of a window object). 
 *  @param sender The object sending the message; use it to get details about the dragging operation.
 */
- (void)draggingExited:(id<NSDraggingInfo>)sender {
    if (self.isHighlighted) {
        self.highlight = NO;
    }
    // Cleanup must be done on draggingExited: so as to empty the array. Otherwise the objects will pile up and in the array and all will be added later on.
    [self cleanUpAfterDragOperation];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    [sender setAnimatesToDestination:NO];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    if (self.isHighlighted) {
        self.highlight = NO;
    }
    // The drop view delegate will take over the items, making it safe for resetting the droppedItems array in the cleanUpAfterDragOperation method.
    if ([self hasDroppedItems]) {
        [self.delegate dropView:self
                didReceiveFiles:self.droppedItems];
    }
    
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    [self cleanUpAfterDragOperation];
}

#pragma mark GETTERS AND SETTERS METHODS

- (NSMutableArray *)droppedItems {
    if (!_droppedItems) {
        _droppedItems = [NSMutableArray array];
    }
    
    return _droppedItems;
}

#pragma mark PRIVATE METHODS

- (BOOL)hasDroppedItems {
    if (_droppedItems.count > 0) {
        return YES;
    } else {
        return NO;
    }
}
/*!
 *  @brief Cleans up after the drag operation.
 *  @discussion Invoked once drag operation has finished, releasing any unecessary objects.
 */
- (void)cleanUpAfterDragOperation {
    if (_droppedItems) {
        _droppedItems = nil;
    }
}

@end
