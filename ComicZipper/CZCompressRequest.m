//
//  CZCompress.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 07/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZCompressRequest.h"
#import <ZipUtilities/NOZCompress.h>
#import <ZipUtilities/NOZZipper.h>

static NSArray<NOZFileZipEntry *> * __nonnull NOZEntriesFromDirectory(NSString * __nonnull directoryPath);

@implementation CZCompressRequest

- (void)addEntriesInDirectory:(NSString *)directoryPath compressionSelectionBlock:(nullable NOZCompressionSelectionBlock)block
{
    for (NOZFileZipEntry *entry in NOZEntriesFromDirectory(directoryPath)) {
        // Quick fix to exclude files added to the ignore list or file with zero length.
        if (![self doesFileMatchIgnoreList:entry.name] && [self doesFileHaveLength:entry.name]) {
            if (block) {
                NOZCompressionMethod method = NOZCompressionMethodDeflate;
                NOZCompressionLevel level = NOZCompressionLevelDefault;
                block(entry.filePath, &method, &level);
                entry.compressionLevel = level;
                entry.compressionMethod = method;
            }
            
            [self addEntry:entry];
        }
    }
}

- (BOOL)doesFileMatchIgnoreList:(NSString *)filePath {
    // Check the file name against the items in the ignorelist array.
    NSRange filePathRange = NSMakeRange(0, [filePath length]);
    NSUInteger indexOfObj = [[self ignoreFiles] indexOfObjectPassingTest:
                            ^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:obj
                                                                                                        options:0
                                                                                                          error:0];
                                NSUInteger matches = [regExp numberOfMatchesInString:filePath
                                                                             options:0
                                                                               range:filePathRange];
                                if (matches > 0) {
                                    *stop = YES;
                                    return YES;
                                }
                                
                                return NO;
    }];
    if (indexOfObj == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)doesFileHaveLength:(NSString *)filePath {
    // Check if the file is not zero byte
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath
                                                                                    error:nil];
    if (fileAttributes && [fileAttributes fileSize] == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end

static NSArray<NOZFileZipEntry *> * NOZEntriesFromDirectory(NSString * directoryPath)
{
    NSMutableArray<NOZFileZipEntry *> *entries = [[NSMutableArray alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:directoryPath];
    NSString *filePath = nil;
    while (nil != (filePath = enumerator.nextObject)) {
        NSString *fullPath = [directoryPath stringByAppendingPathComponent:filePath];
        BOOL isDir = NO;
        if ([fm fileExistsAtPath:fullPath isDirectory:&isDir] && !isDir) {
            NOZFileZipEntry *entry = [[NOZFileZipEntry alloc] initWithFilePath:fullPath name:filePath];
            [entries addObject:entry];
        }
    }
    return entries;
}
