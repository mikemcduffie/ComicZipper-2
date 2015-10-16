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
@property (nonatomic, getter = isInDragMode) BOOL dragMode;
@property (nonatomic) NSInteger numberOfValidItemsForDrop;

@end

@implementation CZDropView

- (void)awakeFromNib {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
}
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
    self.numberOfValidItemsForDrop = 0;
    NSArray *classArray = [NSArray arrayWithObjects:[CZDropItem class], nil];
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages
                                      forView:self
                                      classes:classArray
                                searchOptions:@{}
                                   usingBlock:
     ^(NSDraggingItem * _Nonnull draggingItem, NSInteger idx, BOOL * _Nonnull stop) {
         // Files already in the list should not be included in drag operation
//         BOOL isFileInList = [self. delegate dropView:self isItemInList:[draggingItem]];
    }];
    
    return NSDragOperationCopy;
}

#pragma mark GETTERS AND SETTERS METHODS

- (void)setDragMode:(BOOL)dragMode {
    _dragMode = dragMode;
}

@end
