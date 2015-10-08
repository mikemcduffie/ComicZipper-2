//
//  CZArchiveItem.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZArchiveItem.h"

@interface CZArchiveItem ()

@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic, copy) NSString *filesToIgnore;
@property (nonatomic, copy) NSString *parentFolder;
@property (nonatomic, copy) NSString *folderName;
@property (nonatomic, copy) NSString *folderPath;
@property (nonatomic, copy) NSString *archivePath;
@property (nonatomic, copy) NSArray *validExtensions;
@property (nonatomic, readonly) unsigned long long fileSizeInBytes;

@end

@implementation CZArchiveItem

@synthesize temporaryPath = _temporaryPath;

/*!
 *  @description Regular expression pattern for issue numbering.
 */
static NSString *const kCZRegExPattern = @"\\s([0-9]+$)";
/*!
 *  @description Regular expression pattern for issue numbering.
 */
static NSString *const kCZRegExTemplate = @" #$1";

#pragma mark PUBLIC METHODS

+ (instancetype)initWithURL:(NSURL *)url {
    return [[super alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        _fileURL    = url;
        _folderPath = [url path];
        _folderName = [self getFolderNameFromURL:url];
        _parentFolder = [self getParentFolderName];
        _archivePath = [self getArchivePath];
        _validExtensions = kValidFileExtensions;
        _fileSizeInBytes = [self calculateFileSize];
        // Empty folders should not be added
        if (_fileSizeInBytes == 0) {
            return nil;
        }
        _running = NO;
        _archived = NO;
    }
    
    return self;
}

- (NSURL *)fileURL {
    if ([self isArchived]) {
        return [NSURL fileURLWithPath:[self archivePath]];
    }
    return _fileURL;
}

- (NSString *)folderPath {
    return _folderPath;
}

- (NSString *)archivePath {
    return _archivePath;
}

- (NSString *)path {
    if ([self isArchived]) {
        return [self archivePath];
    } else {
        return [self folderPath];
    }
}

- (NSString *)fileSize {
    return [self stringFromByte:[self fileSizeInBytes]];
}

- (NSString *)temporaryPath {
    if (!_temporaryPath) {
        NSString *uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
        _temporaryPath = [NSString stringWithFormat:@"%@/%@.tmp", kApplicationCachePath, uniqueID];
    }
    
    return _temporaryPath;
}

- (NSString *)description {
    return [self folderName];
}

#pragma mark PATH SETUP METHODS

- (NSString *)getFolderNameFromURL:(NSURL *)url {
    NSString *folderName = [url lastPathComponent];
    // Make sure a folder name has been set, for safety issues.
    if (folderName == nil) {
        // Substring full path to get folder name
        NSRange lastSlashCaracter = [[url path] rangeOfString:@"/"
                                                      options:NSBackwardsSearch];
        NSRange rangeOfFolderPath = NSMakeRange(0, lastSlashCaracter.location+1);
        folderName = [[url path] stringByReplacingCharactersInRange:rangeOfFolderPath
                                                         withString:@""];
    }
    
    return folderName;
}

- (NSString *)getArchivePath {
    // Sets the new name for the archive to be created. Adds # sign before the issue (001) number in the filename with regular expressions
    NSError *error = nil;
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:kCZRegExPattern
                                                                            options:0
                                                                              error:&error];
    NSRange rangeForRegEx = NSMakeRange(0, [_folderName length]);
    NSString *fileName = [regEx stringByReplacingMatchesInString:_folderName
                                                         options:0
                                                           range:rangeForRegEx
                                                    withTemplate:kCZRegExTemplate];
    NSString *filePath = [NSString stringWithFormat:@"%@%@.%@", _parentFolder, fileName, kCZFileExtension];
    // Make sure the file name is not already taken.
    int i = 1;
    NSFileManager *fileManager = [NSFileManager alloc];
    while ([fileManager fileExistsAtPath:filePath]) {
        filePath = [NSString stringWithFormat:@"%@%@-%d.%@", _parentFolder, fileName, i++, kCZFileExtension];
    }
    
    return filePath;
}

- (NSString *)getParentFolderName {
    // Parent folder name is necessary for the zip command line tool.
    NSRange range = NSMakeRange([_folderPath length] - [_folderName length], [_folderName length]);
    return [_folderPath stringByReplacingCharactersInRange:range withString:@""];
}

- (unsigned long long)calculateFileSize {
    unsigned long long fileSizeInBytes = 0;
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:_folderPath];
    for (NSURL *file in directoryEnumerator) {
        // Only add files with valid extensions to the filesize count.
        if ([_validExtensions containsObject:[[file pathExtension] lowercaseString]]) {
            fileSizeInBytes += [[[directoryEnumerator fileAttributes] objectForKey:NSFileSize] longLongValue];
        }
    }

    return fileSizeInBytes;
}

/*!
 *  @brief Translate filesize in string to a humanreadable string.
 *  @param fileSize The filesize in bytes.
 */
- (NSString *)stringFromByte:(double)fileSize {
    NSString *size = [NSByteCountFormatter stringFromByteCount:fileSize
                                                    countStyle:NSByteCountFormatterCountStyleFile];
    return size;
}

@end
