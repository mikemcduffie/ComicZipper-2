//
//  ComicZipper.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "ComicZipper.h"
#import "CZDropItem.h"
#import "CZStatusButton.h"
#import "CZCompressRequest.h"

@interface ComicZipper () <NOZCompressDelegate>

@property (nonatomic) NSMutableArray *foldersToDelete;
@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) NSOperationQueue *operations;
@property (nonatomic) NSArray *filesToFilter;
@property (nonatomic) BOOL shouldFilterEmpty;
@property (nonatomic) BOOL shouldDeleteFolder;

@end

@implementation ComicZipper

#pragma mark PUBLIC METHODS

- (BOOL)isItemInList:(NSString *)folderPath {
    NSUInteger index = [self.archiveItems indexOfObjectPassingTest:
                        ^BOOL(CZDropItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([item.folderPath isEqualToString:folderPath]) {
                                // User should be able to add already archived items as the processed item in the list after the archive operation does not represent the folder anymore.
                                if(item.isArchived == YES) {
                                    return NO;
                                } else {
                                    return YES;
                                }
                            } else {
                                return NO;
                            }
                        }];
    if (index == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (void)addItem:(CZDropItem *)item {
    [self.archiveItems addObject:item];
}

- (void)addItems:(NSArray *)items {
    [self.archiveItems addObjectsFromArray:[items copy]];
}

- (void)removeItemAtIndex:(NSInteger)index {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self removeItemsAtIndexes:indexSet];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [[self archiveItems] removeObjectsAtIndexes:indexes];
}

- (CZDropItem *)itemAtIndex:(NSInteger)index {
    return [self.archiveItems objectAtIndex:index];
}

- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes {
    return [self.archiveItems objectsAtIndexes:indexes];
}

- (NSInteger)count {
    return self.archiveItems.count;
}

- (NSInteger)countActive {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCancelled == NO && isArchived == NO"];
    return [[self.archiveItems filteredArrayUsingPredicate:predicate] count];
}

- (NSInteger)countArchived {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == YES"];
    return [[self.archiveItems filteredArrayUsingPredicate:predicate] count];
}

- (NSInteger)countCancelled {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCancelled == YES && isArchived == NO"];
    return [[self.archiveItems filteredArrayUsingPredicate:predicate] count];
}

#pragma mark ITEMS METHODS

- (NSArray *)itemsActive {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCancelled == NO && isArchived == NO && isArchived == NO"];
    return [self.archiveItems filteredArrayUsingPredicate:predicate];
}

- (void)cancelItemAtIndex:(NSInteger)index {
    [[self.archiveItems objectAtIndex:index] setCancelled:YES];
}

- (BOOL)isItemRunning:(NSInteger)index {
    return [[self.archiveItems objectAtIndex:index] isRunning];
}

- (void)clearItems {
    self.archiveItems = nil;
}

#pragma mark COMPRESSION METHODS

- (void)compressionStart {
    // Store the settings temporarily so they don't get changed during compression
    self.shouldDeleteFolder = [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsDeleteFolders];
    self.shouldFilterEmpty = [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsFilterEmptyData];
    self.filesToFilter = [self setFilters];
    for (CZDropItem *item in self.archiveItems) {
        // Do not compress already archived, cancelled or running items.
        if (item.running == NO && item.cancelled == NO && item.archived == NO) {
            [self.operations addOperation:[self createOperationForItem:item]];
        }
    }
}

- (void)compressionStop:(CZStatusButton *)sender {
    NSInteger index = sender.rowIndex;
    [self cancelItemAtIndex:index];
    if ([self isItemRunning:index] == NO) {
        [self.delegate ComicZipper:self
            didCancelItemAtIndex:index];
    }
}

- (void)compressionStopAll {
    if (_operations) {
        [[self operations] cancelAllOperations];
        
        for (CZDropItem *item in [self archiveItems]) {
            [item setCancelled:YES];
        }
    }
}

- (void)compressOperation:(NOZCompressOperation *)operation didUpdateProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger index = [operation.name integerValue];
        CZDropItem *item = [self.archiveItems objectAtIndex:index];
        if (item.isRunning == NO) {
            item.running = YES;
        }
        // Cancelled items should abort operation
        if (item.isCancelled && operation.isCancelled == NO) {
            [operation cancel];
        } else {
            if (item.isRunning) {
                [self.delegate ComicZipper:self
                         didUpdateProgress:progress
                             ofItemAtIndex:index];
            }
        }
    });
}

- (void)compressOperation:(NOZCompressOperation *)operation didCompleteWithResult:(NOZCompressResult *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger index = [operation.name integerValue];
        CZDropItem *item = [self.archiveItems objectAtIndex:index];
        item.running = NO;
        if (operation.isCancelled) {
            [self.delegate ComicZipper:self
                  didCancelItemAtIndex:index];
        } else {
            item.archived = YES;
            [self moveItemAtPath:item.temporaryPath
                          toPath:item.archivePath];
            if (self.shouldDeleteFolder) {
                [self.foldersToDelete addObject:[NSURL fileURLWithPath:item.folderPath]];
            }
            
            [self.delegate ComicZipper:self
                  didFinishItemAtIndex:index];
        }
        // Remove the folders (if setting is on) after compression
        if (self.operations.operationCount == 0) {
            [self deleteFolders];
        }
    });
    result = nil;
    operation = nil;
}

#pragma mark OPERATIONS

- (NOZCompressOperation *)createOperationForItem:(CZDropItem *)item {
    NSString *targetPath = [item temporaryPath];
    NSString *sourcePath = [item folderPath];
    NSString *processTag = [NSString stringWithFormat:@"%lu", [self.archiveItems indexOfObject:item]];
    // Create the request and add the folder to it.
    // Solved the issue with excluding files by extending the NOZCompressRequest class.
    CZCompressRequest *request = [[CZCompressRequest alloc] initWithDestinationPath:targetPath];
    request.filesToFilter = self.filesToFilter;
    request.shouldFilterEmpty = self.shouldFilterEmpty;
    [request addEntriesInDirectory:sourcePath
         compressionSelectionBlock:NULL];
    // Create the operation that will perform the request.
    NOZCompressOperation *operation = [[NOZCompressOperation alloc] initWithRequest:request
                                                                           delegate:self];
    [operation setName:processTag];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate ComicZipper:self
                 didStartItemAtIndex:[processTag integerValue]];
    });

    return operation;
}

#pragma mark TABLE VIEW DATA SOURCE METHODS

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.archiveItems.count;
}

#pragma mark PRIVATE METHODS

- (void)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath {
    [NSFileManager.defaultManager moveItemAtPath:fromPath
                                          toPath:toPath
                                           error:nil];
}

- (void)deleteFolders {
    if (_foldersToDelete != nil) {
        [NSWorkspace.sharedWorkspace recycleURLs:self.foldersToDelete
                               completionHandler:nil];
        [self setFoldersToDelete:nil];
    }
}

- (NSArray *)setFilters {
    NSMutableArray *filter = [[NSUserDefaults.standardUserDefaults valueForKey:CZSettingsCustomFilter] mutableCopy];

    if ([NSUserDefaults.standardUserDefaults boolForKey:CZSettingsFilterHidden]) {
        [filter addObjectsFromArray:[CZConstants filterForHiddenFiles]];
    }
    
    if ([NSUserDefaults.standardUserDefaults boolForKey:CZSettingsFilterMeta]) {
        [filter addObjectsFromArray:[CZConstants filterForMetaFiles]];
    }
    
    return [filter copy];
}

#pragma mark SETTERS AND GETTERS

- (BOOL)isRunning {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isRunning == YES"];
    return ([[self.archiveItems filteredArrayUsingPredicate:predicate] count] > 0);
}

- (NSMutableArray *)archiveItems {
    if (!_archiveItems) {
        _archiveItems = [NSMutableArray array];
    }
    
    return _archiveItems;
}

- (NSOperationQueue *)operations {
    if (!_operations) {
        _operations = [[NSOperationQueue alloc] init];
        [self.operations setMaxConcurrentOperationCount:1];
    }
    
    return _operations;
}

- (NSMutableArray *)foldersToDelete {
    if (!_foldersToDelete) {
        _foldersToDelete = [NSMutableArray array];
    }
    return _foldersToDelete;
}

@end
