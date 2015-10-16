//
//  Constants.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZConstants.h"

@implementation CZConstants

NSString *const CZApplicationName = @"ComicZipper";
NSString *const CZFileExtension = @"cbz";
NSString *const CZDropViewNoHighlightImage = @"DropFolderNormal";
NSString *const CZDropViewHighlightImage = @"DropFolderHighlighted";

+ (NSArray *)validFileExtensions {
    return @[@"jpg", @"jpeg", @"png", @"gif", @"tiff", @"tif", @"bmp"];
}

+ (NSString *)cacheDirectoryPath {
    NSString *cacheDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [cacheDirectoryPath stringByAppendingPathComponent:CZApplicationName];

}

@end
