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
@property (nonatomic, setter = shouldSkipRemoval:) BOOL shouldSkipRemoval;

+ (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url;

- (NSString *)folderPath;
- (NSString *)archivePath;
- (NSString *)fileSize;

@end
