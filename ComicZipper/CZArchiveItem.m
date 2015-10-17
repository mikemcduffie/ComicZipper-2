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
@property (nonatomic) unsigned long long fileSizeInBytes;

@end

@implementation CZArchiveItem

@synthesize temporaryPath = _temporaryPath;
//@synthesize previewItemURL = _previewItemURL;

#pragma mark CONSTANTS

/*!
 *  @description Regular expression pattern for issue numbering.
 */
static NSString *const kRegExpPattern = @"\\s([0-9]+$)";
/*!
 *  @description Regular expression pattern for issue numbering.
 */
static NSString *const kRegExpTemplate = @" #$1";

#pragma mark INIT METHODS

+ (instancetype)initWithURL:(NSURL *)url {
    return [[super alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        _fileURL = url;
        _folderPath = [url path];
        if (self.fileSizeInBytes == 0) {
            return nil;
        }
        _running = NO;
        _archived = NO;
        _cancelled = NO;
    }
    
    return self;
}

#pragma mark PUBLIC METHODS

- (NSString *)name {
    return self.folderName;
}

- (NSURL *)fileURL {
    return _fileURL;
}

- (NSString *)filePath {
    if (self.isArchived == YES) {
        return self.archivePath;
    } else {
        return self.folderPath;
    }
}

- (NSString *)folderPath {
    return _folderPath;
}

- (NSString *)fileSize {
    return [self stringFromBytes:self.fileSizeInBytes];
}

- (NSString *)temporaryPath {
    if (!_temporaryPath) {
        NSString *uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
        _temporaryPath = [NSString stringWithFormat:@"%@/%@.tmp", [CZConstants cacheDirectoryPath], uniqueID];
    }
    
    return _temporaryPath;
}

- (NSString *)description {
    return self.folderPath;
}

#pragma mark PATH SETUP METHODS

- (NSArray *)validExtensions {
    if (!_validExtensions) {
        _validExtensions = [CZConstants validFileExtensions];
    }
    
    return _validExtensions;
}

- (unsigned long long)fileSizeInBytes {
    if (!_fileSizeInBytes) {
        NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.folderPath];
        for (NSURL *file in directoryEnumerator) {
            // Only add files with valid extensions to the filesize count.
            if ([self.validExtensions containsObject:[file.pathExtension lowercaseString]]) {
                _fileSizeInBytes += [[directoryEnumerator.fileAttributes objectForKey:NSFileSize] longLongValue];
            }
        }
    }
    
    return _fileSizeInBytes;
}

- (NSString *)parentFolder {
    if (!_parentFolder) {
        // Retrieve the parent folder of the item. The parent folder
        // path is required for creating the archive path.
        NSRange range = NSMakeRange(self.folderPath.length - self.folderName.length, self.folderName.length);
        return [self.folderPath stringByReplacingCharactersInRange:range withString:@""];
    }
    
    return _parentFolder;
}

- (NSString *)folderName {
    if (!_folderName) {
        NSString *folderName = [self.fileURL lastPathComponent];
        // Make sure a folder name has been set, for safety issues.
        if (folderName == nil) {
            // Substring full path to get folder name
            NSRange lastSlashCaracter = [self.folderPath rangeOfString:@"/"
                                                               options:NSBackwardsSearch];
            NSRange rangeOfFolderPath = NSMakeRange(0, lastSlashCaracter.location+1);
            folderName = [self.folderPath stringByReplacingCharactersInRange:rangeOfFolderPath
                                                                  withString:@""];
        }
        _folderName = folderName;
    }
    
    return _folderName;
}

- (NSString *)archivePath {
    if (!_archivePath) {
        // Create the path for the archive to be created. Adds # sign before
        // the issue (001) number in the filename with regular expressions.
        NSError *error = nil;
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:kRegExpPattern
                                                                               options:0
                                                                                 error:&error];
        NSRange rangeForRegEx = NSMakeRange(0, self.folderName.length);
        NSString *fileName = [regEx stringByReplacingMatchesInString:self.folderName
                                                             options:0
                                                               range:rangeForRegEx
                                                        withTemplate:kRegExpTemplate];
        NSString *filePath = [NSString stringWithFormat:@"%@%@.%@", self.parentFolder, fileName, CZFileExtension];
        // Make sure the file name is not already taken.
        int i = 1;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        while ([fileManager fileExistsAtPath:filePath]) {
            filePath = [NSString stringWithFormat:@"%@%@-%d.%@", self.parentFolder, fileName, i++, CZFileExtension];
        }
        
        _archivePath = filePath;
    }
    
    return _archivePath;
}

#pragma mark PRIVATE METHODS

/*!
 *  @brief Translate filesize in string to a humanreadable string.
 *  @param fileSize The filesize in bytes.
 */
- (NSString *)stringFromBytes:(double)fileSize {
    NSString *size = [NSByteCountFormatter stringFromByteCount:fileSize
                                                    countStyle:NSByteCountFormatterCountStyleFile];
    return size;
}

@end
