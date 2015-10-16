/*
 *  CZArchiveItem.h
 *  ComicZipper
 *
 *  Created by Ardalan Samimi on 15/10/15.
 *  Copyright © 2015 Saturn Five. All rights reserved.
 *
 *  @class CZArchiveItem
 *  @brief A CZArchiveItem object represents the comic book archive.
 *  @discussion The object represents either the folder that will become the archive, or the end product itself.
 */
@interface CZArchiveItem : NSObject

@property (nonatomic, getter = isRunning) BOOL running;
@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic, getter = isCancelled) BOOL cancelled;
@property (nonatomic, readonly) NSString *temporaryPath;

+ (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

- (NSURL *)fileURL;
- (NSString *)filePath;
- (NSString *)folderPath;
- (NSString *)archivePath;
- (NSString *)fileSize;

@end
