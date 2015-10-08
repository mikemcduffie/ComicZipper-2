//
//  CZArchiveItem.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

@class CZArchiveItem;

@interface CZArchiveItem : NSObject

@property (weak) id delegate;
@property (nonatomic) double progress;
@property (nonatomic, getter = isRunning) BOOL running;
@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic, readonly) NSString *temporaryPath;

+ (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;
/*!
 *  @brief The file/folder URL.
 *  @discussion If the item is archived, the returned URL will be of the compressed item. Otherwise, it returns the folder's URL.
 *  @return An NSURL object initialized with the path.
 */
- (NSURL *)fileURL;
/*!
 *  @brief The path of the folder.
 *  @return An NSString object with the full path to the folder.
 */
- (NSString *)folderPath;
/*!
 *  @brief The path of the resulting archive item.
 */
- (NSString *)archivePath;
/*!
 *  @brief The path of the item, either the folder or, if compressed, the file.
 */
- (NSString *)path;
/*!
 *  @brief The total size of the resulting archive item in a human readable language.
 *  @discussion Counts only files not added to the ignore list.
 */
- (NSString *)fileSize;

@end
