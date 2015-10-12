//
//  Constants.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Constants : NSObject
/*!
 *  @brief A constant representing an application state.
 */
extern int const kAppStateNoItemDropped;
/*!
 *  @brief A constant representing an application state.
 */
extern int const kAppStateFirstItemDrop;
/*!
 *  @brief A constant representing an application state.
 */
extern int const kAppStatePopulatedList;
/*!
 *  @brief Delete key keycode.
 */
extern int const kDeleteKey;
/*!
 *  @brief Arrow up keycode.
 */
extern int const kArrowUpKey;
/*!
 *  @brief Arrow down keycode.
 */
extern int const kArrowDownKey;
/*!
 *  @brief The default width of the table column.
 */
extern float const kTableColumnWidth;
/*!
 *  @brief The default height of the table column.
 */
extern float const kTableColumnHeight;
/*!
 *  @brief The default height of the sub views of the table view.
 */
extern float const kSubviewNormalHeight;
/*!
 *  @brief The default height of the sub views holding the detail label of the table view.
 */
extern float const kSubviewDetailheight;
/*!
 *  @brief Name of the application.
 */
extern NSString *const kApplicationName;
/*!
 *  @description The file extension of the archive.
 */
extern NSString *const kCZFileExtension;
/*!
 *  @brief Name of the image representing normal state of drop view.
 */
extern NSString *const kImageNameForNoHighlight;
/*!
 *  @brief Name of the image representing highlighted state of drop view.
 */
extern NSString *const kImageNameForHighlight;
/*!
 *  @brief The application's default notification sound name.
 */
extern NSString *const kDefaultNotifySoundName;
/*!
 *  @brief Icon for error statuses.
 */
extern NSString *const kStatusIconError;
/*!
 *  @brief Icon for success statuses.
 */
extern NSString *const kStatusIconSuccess;
/*!
 *  @brief Icon for normal state statuses and close/remove items.
 */
extern NSString *const kStatusIconCloseNormal;
/*!
 *  @brief Icon for when normal state status button is hovered.
 */
extern NSString *const kStatusIconCloseHover;
/*!
 *  @brief Delete folders after compression has finished.
 */
extern NSString *const kIdentifierForSettingsDeleteFolders;
/*!
 *  @brief Exclude hidden files and other meta data.
 */
extern NSString *const kIdentifierForSettingsExcludeHidden;

extern NSString *const kIdentifierForSettingsExcludeThumbs;
extern NSString *const kIdentifierForSettingsExcludeEmptyFolders;
extern NSString *const kIdentifierForSettingsExcludeEmptyFiles;
/*!
 *  @brief Identifier for the file exclusion settings option.
 */
extern NSString *const kIdentifierForSettingsExcludedFiles;
/*!
 *  @brief Identifier for the user notification settings option.
 */
extern NSString *const kIdentifierForSettingsUserNotification;
/*!
 *  @brief Identifier for the badge dock icon settings option.
 */
extern NSString *const kIdentifierForSettingsDockBadge;
/*!
 *  @brief Identifier for the alert sound settings option.
 */
extern NSString *const kIdentifierForSettingsAlertSound;
/*!
 *  @brief Identifier for the auto start settings option.
 */
extern NSString *const kIdentifierForSettingsAutoStart;
/*!
 *  @brief Identifier for the last window size.
 */
extern NSString *const kidentifierForSettingsWindowState;
/*!
 *  @brief The name of the application settings file.
 */
extern NSString *const kApplicationSettingsFileName;
/*!
 *  @brief Global variable pointing to the application's Application support directory.
 */
extern NSString *kApplicationSupportPath;
/*!
 *  @brief Global variable pointing to the application's cache directory.
 */
extern NSString *kApplicationCachePath;
/*!
 *  @brief Global variable pointing to the application's settings file.
 */
extern NSString *kApplicationSettingsPath;
/*!
 *  @brief Global variable containing the valid file extensions.
 */
extern NSArray *kValidFileExtensions;
/*!
 *  @brief Regular expression patterns for hidden files and meta files.
 */
+ (NSArray *)kHiddenRegEx;

+ (NSArray *)kThumbsRegEx;

@end