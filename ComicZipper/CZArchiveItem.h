
#import <Quartz/Quartz.h>
#import <QuickLook/QuickLook.h>

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
@interface CZArchiveItem : NSObject <QLPreviewItem>

@property (nonatomic, getter = isRunning) BOOL running;
@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic, getter = isCancelled) BOOL cancelled;
@property (nonatomic, readonly) NSString *temporaryPath;
@property (nonatomic) NSInteger rowIndex;

+ (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

- (NSString *)name;
- (NSURL *)fileURL;
- (NSImage *)image;
- (NSString *)filePath;
- (NSString *)folderPath;
- (NSString *)archivePath;
- (NSString *)fileSize;

@end
