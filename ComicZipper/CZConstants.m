//
//  Constants.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZConstants.h"

@implementation CZConstants

float const kTableRowHeight = 40;
float const kTableColumnWidth = 50;
float const kSubviewNormalHeight = kTableRowHeight/2;
float const kSubviewDetailheight = kTableRowHeight/2-3;
int const kDeleteKey = 51;
int const kArrowUpKey = 125;
int const kArrowDownKey = 126;
NSString *const CZApplicationName = @"ComicZipper";
NSString *const CZFileExtension = @"cbz";
NSString *const CZDropViewNoHighlightImage = @"DropFolderNormal";
NSString *const CZDropViewHighlightImage = @"DropFolderHighlighted";
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

+ (NSArray *)validFileExtensions {
    return @[@"jpg", @"jpeg", @"png", @"gif", @"tiff", @"tif", @"bmp"];
}

+ (NSString *)applicationSupportPath {
    return @"";
}

+ (NSString *)cacheDirectoryPath {
    NSString *cacheDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [cacheDirectoryPath stringByAppendingPathComponent:CZApplicationName];

}

+ (NSString *)settingsDirectoryPath {
    return @"";
}

+ (NSArray *)filterForHiddenFiles {
    return @[];
}

+ (NSArray *)filterForMetaFiles {
    return @[];
}

@end
