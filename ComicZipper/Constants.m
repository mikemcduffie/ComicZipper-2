//
//  Constants.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "Constants.h"

@implementation Constants

int const kAppStateNoItemDropped = 1;
int const kAppStateFirstItemDrop = 2;
int const kAppStatePopulatedList = 3;
int const kDeleteKey = 51;
int const kArrowUpKey = 125;
int const kArrowDownKey = 126;
float const kTableColumnWidth = 50;
float const kTableColumnHeight = 40.0;
float const kSubviewNormalHeight = kTableColumnHeight/2;
float const kSubviewDetailheight = kTableColumnHeight/2-3;
NSString *const kApplicationName = @"ComicZipper";
NSString *const kCZFileExtension = @"cbz";
NSString *const kImageNameForNoHighlight = @"DropFolderWhite";
NSString *const kImageNameForHighlight = @"DropFolderBlue";
NSString *const kDefaultNotifySoundName = @"Glass";
NSString *const kStatusIconError = @"statusError";
NSString *const kStatusIconSuccess = @"statusSuccess";
NSString *const kStatusIconCloseNormal = @"statusCloseNormal";
NSString *const kStatusIconCloseHover = @"statusCloseHover";
NSString *const kIdentifierForSettingsDeleteFolders = @"CZDeleteFolders";
NSString *const kIdentifierForSettingsExcludeHidden = @"CZExcludeHidden";
NSString *const kIdentifierForSettingsExcludedFiles = @"CZExcludedFiles";
NSString *const kIdentifierForSettingsUserNotification = @"CZUserNotify";
NSString *const kIdentifierForSettingsDockBadge = @"CZBadgeDockIcon";
NSString *const kIdentifierForSettingsAlertSound = @"CZAlertSound";
NSString *const kIdentifierForSettingsAutoStart = @"CZAutoStart";
NSString *const kidentifierForSettingsWindowState = @"CZWindowState";
NSString *const kApplicationSettingsFileName = @"CZSettings.plist";
NSString *kApplicationSupportPath;
NSString *kApplicationCachePath;
NSString *kApplicationSettingsPath;
NSArray *kValidFileExtensions;

+ (NSArray *)kHiddenFiles {
    return @[@"^\\.\\w+", @"thumbs.db$", @"__MACOS"];
}

@end
