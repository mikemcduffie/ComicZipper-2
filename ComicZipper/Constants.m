//
//  Constants.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "Constants.h"

@implementation Constants

int const CZApplicationStateNoItemDropped = 1;
int const CZApplicationStateFirstItemDrop = 2;
int const CZApplicationStatePopulatedList = 3;
int const kDeleteKey = 51;
int const kArrowUpKey = 125;
int const kArrowDownKey = 126;
float const kTableColumnWidth = 50;
float const kTableColumnHeight = 40.0;
float const kSubviewNormalHeight = kTableColumnHeight/2;
float const kSubviewDetailheight = kTableColumnHeight/2-3;
NSString *const CZApplicationName = @"ComicZipper";
NSString *const CZFileExtension = @"cbz";
NSString *const CZImageNameForNoHighlight = @"DropFolderNormal";
NSString *const CZImageNameForHighlight = @"DropFolderHighlighted";
NSString *const CZDefaultNotifySoundName = @"Glass";
NSString *const CZStatusIconError = @"statusError";
NSString *const CZStatusIconSuccess = @"statusSuccess";
NSString *const CZStatusIconAbortNormal = @"statusCloseNormal";
NSString *const CZStatusIconAbortHover = @"statusCloseHover";
NSString *const CZSettingsDeleteFolders = @"CZDeleteFolders";
NSString *const CZSettingsFilterHidden = @"CZExcludeHidden";
NSString *const CZSettingsFilterMeta = @"CZExcludeMeta";
NSString *const CZSettingsFilterEmptyData = @"CZExcludeEmpty";
NSString *const CZSettingsCustomFilter = @"CZExcludedFiles";
NSString *const CZSettingsNotifications = @"CZUserNotify";
NSString *const CZSettingsBadgeDockIcon = @"CZBadgeDockIcon";
NSString *const CZSettingsAlertSound = @"CZAlertSound";
NSString *const CZSettingsAutoStart = @"CZAutoStart";
NSString *const CZSettingsWindowState = @"CZWindowState";
NSString *const CZApplicationSettingsFileName = @"CZSettings.plist";

+ (NSString *)CZApplicationSupportPath {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    return [NSString stringWithFormat:@"%@/%@", applicationSupportPath, CZApplicationName];
}

+ (NSString *)CZApplicationCachePath {
    NSString *cacheDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [cacheDirectoryPath stringByAppendingPathComponent:CZApplicationName];
}

+ (NSString *)CZApplicationSettingsPath {
     return [NSString stringWithFormat:@"%@/%@", [Constants CZApplicationSupportPath], CZApplicationSettingsFileName];
}

+ (NSArray *)CZValidFileExtensions {
    return @[@"jpg", @"jpeg", @"png", @"gif", @"tiff", @"tif", @"bmp"];
}

+ (NSArray *)CZFilterHidden {
    return @[@"^\\.(?!DS_Store|_)\\w+"];
}

+ (NSArray *)CZFilterMeta {
    return @[@"Thumbs.db$", @"__MACOSX", @".DS_Store", @"^\\._\\w+"];
}

@end
