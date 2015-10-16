//
//  CZArchiveItem.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZArchiveItem.h"

@interface CZArchiveItem ()

@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic, copy) NSString *parentFolder;
@property (nonatomic, copy) NSString *folderName;
@property (nonatomic, copy) NSString *folderPath;
@property (nonatomic, copy) NSString *archivePath;
@property (nonatomic, copy) NSArray *validExtensions;
@property (nonatomic, readonly) unsigned long long fileSizeInBytes;

@end

@implementation CZArchiveItem

+ (instancetype)initWithURL:(NSURL *)url {
    return [[super alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        _fileURL = url;
        _folderPath = [url path];
        _folderName = [self folderNameFromURL:url];
        _parentFolder = [self parentFolderFromURL:url];
        _archivePath = [self archivePathFromURL:url];
        _validExtensions = nil;
        _fileSizeInBytes = [self calculateFileSize];
        if (_fileSizeInBytes == 0) {
            return nil;
        }
        _running = NO;
        _archived = NO;
        _cancelled = NO;
    }
    
    return self;
}

#pragma mark PATH SETUP METHODS

- (NSString *)folderNameFromURL:(NSURL *)url {
    NSString *folderName;
    return folderName;
}

- (NSString *)parentFolderFromURL:(NSURL *)url {
    NSString *folderName;
    return folderName;
}

- (NSString *)archivePathFromURL:(NSURL *)url {
    NSString *archivePath;
    return archivePath;
}

- (NSInteger)calculateFileSize {
    return 0;
}


@end
