//
//  CZComicZipper.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZComicZipper.h"
#import "CZDropItem.h"
#import <ZipUtilities/ZipUtilities.h>

@interface CZComicZipper () <NOZCompressDelegate>

@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) NSOperationQueue *operations;

@end

@implementation CZComicZipper

#pragma mark ARCHIVE ITEMS COLLECTION METHODS

- (NSMutableArray *)archiveItems {
    if (!_archiveItems) {
        _archiveItems = [[NSMutableArray alloc] init];
    }

    return _archiveItems;
}

/*!
 *  @brief Check if an item is already present in the ComicZipper item list.
 *  @return A boolean value.
 */
- (BOOL)isItemInList:(NSString *)description {
    NSUInteger indexOfItem = [[self archiveItems] indexOfObjectPassingTest:
                              ^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                  // User should be able to add already archived items as the processed item in the list after the archive operation does not represent the folder anymore.
                                  if ([obj isArchived]) {
                                      *stop = YES;
                                      return NO;
                                  }
                                  BOOL found = [[obj description] isEqualToString:description];
                                  return found;
                              }];
    if (indexOfItem == NSNotFound) {
        return NO;
    }
    return YES;
}
/*!
 *  @brief Add an item to the ComicZipper item list.
 *  @param item A CZDropItem object.
 */
- (void)addItem:(CZDropItem *)item {
    [[self archiveItems] addObject:item];
}
/*!
 *  @brief Add several items to the ComicZipper item list.
 *  @param items An array containing multiple CZDropItem objects.
 */
- (void)addItems:(NSArray *)items {
    [[self archiveItems] addObjectsFromArray:[items copy]];
}
/*!
 *  @brief Returns the number of items in list.
 */
- (NSInteger)count {
    return [[self archiveItems] count];
}
/*!
 *  @brief Retrieve an item at a specific position in the list.
 *  @param index Index of object in list.
 *  @return An instance of CZDropItem.
 */
- (CZDropItem *)itemWithIndex:(NSInteger)index {
    return [[self archiveItems] objectAtIndex:index];
}

- (void)removeItemsWithIndexes:(NSIndexSet *)indexes {
    [[self archiveItems] removeObjectsAtIndexes:indexes];
}

#pragma mark COMPRESSION METHODS

- (NSOperation *)compressItem:(CZDropItem *)item {
    NSString *targetPath = [item archivePath];
    NSString *sourcePath = [item folderPath];
    NSString *processTag = [NSString stringWithFormat:@"%lu", [[self archiveItems] indexOfObject:item]];
    // Create the request and add the folder to it.
    NOZCompressRequest *compRequest = [[NOZCompressRequest alloc] initWithDestinationPath:targetPath];
    [compRequest addEntriesInDirectory:sourcePath
             compressionSelectionBlock:NULL];
    // Create the operation that will perform the request.
    NOZCompressOperation *operation = [[NOZCompressOperation alloc] initWithRequest:compRequest
                                                                           delegate:self];
    [operation setName:processTag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [item setRunning:YES];
        [[self delegate] ComicZipper:self
                 didStartItemAtIndex:[processTag integerValue]];
    });
    return operation;
}

- (void)startCompression {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        for (CZDropItem *item in [self archiveItems]) {
            // Do not compress already archived items.
            if (![item isArchived]) {
                [[self operations] addOperation:[self compressItem:item]];
            }
        }
    });
}

- (void)compressOperation:(NOZCompressOperation *)operation didCompleteWithResult:(NOZCompressResult *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger index = [[operation name] integerValue];
        CZDropItem *item = [[self archiveItems] objectAtIndex:index];
        [item setRunning:NO];
        [item setArchived:YES];
        [[self delegate] ComicZipper:self
                didFinishItemAtIndex:index];
    });
}

- (void)compressOperation:(NOZCompressOperation *)operation didUpdateProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger index = [[operation name] integerValue];
        if ([[[self archiveItems] objectAtIndex:index] isRunning]) {
            [[self delegate] ComicZipper:self
                       didUpdateProgress:progress
                           ofItemAtIndex:index];            
        }
    });
}

#pragma mark PRIVATE METHODS

- (NSOperationQueue *)operations {
    if (!_operations) {
        _operations = [[NSOperationQueue alloc] init];
        [[self operations] setMaxConcurrentOperationCount:1];
    }
    
    return _operations;
}

@end
