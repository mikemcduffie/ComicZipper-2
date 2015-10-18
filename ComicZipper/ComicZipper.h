//
//  ComicZipper.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@class ComicZipper, CZDropItem, CZStatusButton;

@protocol ComicZipperDelegate <NSObject>

@required
- (void)ComicZipper:(ComicZipper *)comicZipper didStartItemAtIndex:(NSUInteger)index;
- (void)ComicZipper:(ComicZipper *)comicZipper didFinishItemAtIndex:(NSUInteger)index;
- (void)ComicZipper:(ComicZipper *)comicZipper didCancelItemAtIndex:(NSUInteger)index;
- (void)ComicZipper:(ComicZipper *)comicZipper didUpdateProgress:(float)progress ofItemAtIndex:(NSUInteger)index;

@end

@interface ComicZipper : NSObject <NSTableViewDataSource>

@property (weak) id delegate;
@property (nonatomic) BOOL shouldDeleteFolder;
/*!
 *  @brief State of compression.
 *  @description This variable is set to TRUE when an item is compressing.
 */
@property (nonatomic, readonly, getter = isRunning) BOOL running;
/*!
 *  @brief Check if an item is already in the list.
 */
- (BOOL)isItemInList:(NSString *)folderPath;
/*!
 *  @brief Add an item to the ComicZipper item list.
 *  @param item A CZDropItem object.
 */
- (void)addItem:(CZDropItem *)item;
/*!
 *  @brief Add several items to the ComicZipper item list.
 *  @param items An array containing multiple CZDropItem objects.
 */
- (void)addItems:(NSArray *)items;
/*!
 *  @brief Remove an item from the array.
 *  @discussion Remove CZDropItem objects from the archive items array, specified by their index.
 *  @param index The position of the object in the array.
 */
- (void)removeItemAtIndex:(NSInteger)index;
/*!
 *  @brief Remove items from the array.
 *  @discussion Remove CZDropItem objects from the archive items array, specified by their indexes.
 *  @param indexes The position of the objects in the array.
 */
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
/*!
 *  @brief Retrieve an item at a specific position in the list.
 *  @param index Index of object in list.
 *  @return An instance of CZDropItem.
 */
- (CZDropItem *)itemAtIndex:(NSInteger)index;
/*!
 *  @brief Retrieve several items at a specific position in the list.
 *  @param indexes The indexes of objects in list.
 *  @return An array containing the CZDropItem objects
 */
- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes;
/*!
 *  @brief Number of items in the ComicZipper list.
 */
- (NSInteger)count;
/*!
 *  @brief Number of unprocessed items in the ComicZipper list
 */
- (NSInteger)countActive;
/*!
 *  @brief Number of archived items in the ComicZipper list.
 */
- (NSInteger)countArchived;
/*!
 *  @brief Number of cancelled items in the ComicZipper list.
 */
- (NSInteger)countCancelled;
/*!
 *  @brief Notify ComicZipper to start compression.
 */
- (void)compressionStart;
/*!
 *  @brief Notify ComicZipper to cancel compression.
 */
- (void)compressionStop:(CZStatusButton *)sender;
/*!
 *  @brief Notify ComicZipper to cancel all items compressing.
 */
- (void)compressionStopAll;
/*!
 *  @brief Clear the ComicZipper list.
 */
- (void)clearItems;

- (NSMutableArray *)foldersToDelete;

- (void)setFilter:(NSArray *)filter;

@end
