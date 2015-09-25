//
//  CZArchiverItem.h
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

@class CZArchiverItem, CZArchiverItemDelegate, FinderFolder;

@protocol CZArchiverItemDelegate

@required
- (void)compressionDidStart:(CZArchiverItem *)archiver;
- (void)compressionDidEnd:(CZArchiverItem *)archiver;
- (void)compressionCouldNotFinish:(CZArchiverItem *)archiver errorCode:(NSString *)string;

@optional
- (void)archiverDidRemoveDirectory:(CZArchiverItem *)archiver;

@end

@interface CZArchiverItem : NSObject  <NSPasteboardReading>

@property (nonatomic) id delegate;
@property (nonatomic) long double fileSizeInBytes;
@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic, setter = shouldSkipRemoval:) BOOL shouldSkipRemoval;

- (instancetype)initWithSelection:(FinderFolder *)folder;
- (void)startCompression;
- (void)removeDirectory;
- (NSString *)path;

@end
