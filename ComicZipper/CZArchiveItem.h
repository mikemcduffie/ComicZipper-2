//
//  CZArchiveItem.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CZArchiveItem;

@protocol CZArchiveItemDelegate

@required
- (void)compressionDidStart:(CZArchiveItem *)archiveItem;
- (void)compressionDidFinish:(CZArchiveItem *)archiveItem;
- (void)compressionFailed:(CZArchiveItem *)archiver errorCode:(int)errorCode errorMessage:(NSString *)errorMessage;

@end

@interface CZArchiveItem : NSObject

@property (weak) id delegate;
@property (nonatomic, readonly) unsigned long long fileSizeInBytes;
@property (nonatomic, readonly, getter = isArchived) BOOL archived;
@property (nonatomic, setter = shouldSkipRemoval:) BOOL shouldSkipRemoval;

+ (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;
- (void)startCompression;
- (void)removeDirectory;
- (NSString *)path;

@end
