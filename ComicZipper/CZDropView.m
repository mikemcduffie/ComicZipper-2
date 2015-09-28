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

@property (nonatomic, getter=isHighlighted) BOOL highlight;
@property (nonatomic) NSInteger numberOfValidItemsForDrop;
@property (nonatomic) NSMutableArray *droppedItems;

/*!
 *  @brief Initial setup method
 *  @description Sets the needed configurations on init, for example registering the data types the view can accept in a drag operation.
 */
- (void)initialSetup;

@end

@implementation CZDropView

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
}

- (void)initialSetup {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self setDragMode:YES];
}

- (BOOL)isDirectory:(NSString *)path {
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory)
        return YES;
    return NO;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    // Abort drag operation if the view should not be in drop mode.
    if (![self inDragMode])
        return NSDragOperationNone;
    // Reset the count for the badge to display the right number of valid items that can be dropped.
    [self setNumberOfValidItemsForDrop:0];

    // Enumerate through the dragged items, checking against the CZDropItem class.
    NSArray *classArray = [NSArray arrayWithObjects:[CZDropItem class], nil];
    [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages
                                      forView:self
                                      classes:classArray
                                searchOptions:nil
                                   usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
                                       
                                       [self setNumberOfValidItemsForDrop:[self numberOfValidItemsForDrop]+1];
    }];
    
    
//    NSPasteboard *pasteBoard = [sender draggingPasteboard];
//    // Check if the dropped item is a directory and if they are already in the list.
//    if ([[pasteBoard types] containsObject:NSFilenamesPboardType]) {
//        NSArray *files = [pasteBoard propertyListForType:NSFilenamesPboardType];
//        for (NSString *file in files) {
//            if ([self isDirectory:file] && [[self delegate] dropView:self isItemInList:[file description]]) {
//                [self setNumberOfValidItemsForDrop:[self numberOfValidItemsForDrop] + 1];
//            }
//        }
//    }
    [sender setNumberOfValidItemsForDrop:[self numberOfValidItemsForDrop]];
    return NSDragOperationCopy;
}


@end
