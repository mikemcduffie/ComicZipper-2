//
//  CZArchiveItem.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZArchiveItem.h"

/*!
 *  @description Regular expression pattern used for ...
 */
static NSString *const kCZRegExPattern = @"\\s([0-9]+$)";
static NSString *const kCZRegExTemplate = @" #$1";
static NSString *const kCZFileExtension = @"cbz";

@interface CZArchiveItem ()

@property (nonatomic) NSTask *task;
@property (nonatomic, copy) NSURL *fileURL;
@property (nonatomic, copy) NSString *filesToIgnore;
@property (nonatomic, copy) NSString *parentFolder;
@property (nonatomic, copy) NSString *folderName;
@property (nonatomic, copy) NSString *folderPath;
@property (nonatomic, copy) NSString *archivePath;
@property (nonatomic, copy) NSString *commandLine;
@property (nonatomic, copy) NSArray *validExtensions;
@property (nonatomic) int deleteCount;
@property (nonatomic, setter = setRunning:, getter = isRunning) BOOL running;

@end

@implementation CZArchiveItem

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
        _validExtensions = @[@"jpg", @"jpeg", @"png", @"gif"];
        _fileSizeInBytes = [self calculateFileSize];
        NSLog(@"%@", _archivePath);
    }
    
    return self;
}

- (NSString *)getFolderNameFromURL:(NSURL *)url {
    NSString *folderName = [url lastPathComponent];
    // Make sure a folder name has been set, for safety issues.
    if (folderName == nil) {
        // Substring full path to get folder name
        NSRange lastSlashCaracter = [[url path] rangeOfString:@"/" options:NSBackwardsSearch];
        NSRange rangeOfFolderPath = NSMakeRange(0, lastSlashCaracter.location+1);
        folderName = [[url path] stringByReplacingCharactersInRange:rangeOfFolderPath withString:@""];
    }
    
    return folderName;
}

- (NSString *)getParentFolderName {
    // Parent folder name is necessary for the zip command line tool.
    NSRange range = NSMakeRange([_folderPath length] - [_folderName length], [_folderName length]);
    return [_folderPath stringByReplacingCharactersInRange:range withString:@""];
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

- (unsigned long long)calculateFileSize {
    unsigned long long fileSizeInBytes = 0;
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:_folderPath];
    for (NSURL *file in directoryEnumerator) {
        if ([_validExtensions containsObject:[file pathExtension]]) {
            fileSizeInBytes += [[[directoryEnumerator fileAttributes] objectForKey:NSFileSize] longLongValue];
        }
    }
    return fileSizeInBytes;
}

- (void)removeDirectory {
    
}

- (void)startCompression {
    
}

- (NSURL *)fileURL {
    if ([self isArchived]) {
        return [NSURL fileURLWithPath:[self archivePath]];
    }
    return _fileURL;
}

- (NSString *)path {
    return [self folderPath];
}

- (NSString *)description {
    return [self folderName];
}

- (void)dealloc {
    NSLog(@"Dealloc: %@", self);
}

@end
