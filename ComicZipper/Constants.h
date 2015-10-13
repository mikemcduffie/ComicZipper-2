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
 *  @brief Application has no items to process.
 *  @discussion Represents either the initial state of the application or when the items have been removed.
 */
extern int const CZApplicationStateNoItemDropped;
/*!
 *  @brief Application receives items for the first time.
 *  @discussion Use this key when the application goes from the initial state to a dropped state.
 */
extern int const CZApplicationStateFirstItemDrop;
/*!
 *  @brief Application already has loaded items to process.
 */
extern int const CZApplicationStatePopulatedList;
/*!
 *  @brief Delete key.
 */
extern int const kDeleteKey;
/*!
 *  @brief Arrow up key.
 */
extern int const kArrowUpKey;
/*!
 *  @brief Arrow down key.
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
extern NSString *const CZApplicationName;
/*!
 *  @description The file extension of the archive.
 */
extern NSString *const CZFileExtension;
/*!
 *  @brief Name of the image representing normal state of drop view.
 */
extern NSString *const CZImageNameForNoHighlight;
/*!
 *  @brief Name of the image representing highlighted state of drop view.
 */
extern NSString *const CZImageNameForHighlight;
/*!
 *  @brief The default notification sound.
 */
extern NSString *const CZDefaultNotifySoundName;
/*!
 *  @brief Resource name for error status icon.
 */
extern NSString *const CZStatusIconError;
/*!
 *  @brief Resource name for success status icon
 */
extern NSString *const CZStatusIconSuccess;
/*!
 *  @brief Resource name for abort icon.
 */
extern NSString *const CZStatusIconAbortNormal;
/*!
 *  @brief Resource name for abort icon when hovered over.
 */
extern NSString *const CZStatusIconAbortHover;
/*!
 *  @brief Key for settings Delete folders after compression.
 */
extern NSString *const CZSettingsDeleteFolders;
/*!
 *  @brief Key for settings Exclude hidden files and folders.
 */
extern NSString *const CZSettingsFilterHidden;
/*!
 *  @brief Key for settings Exclude meta files.
 */
extern NSString *const CZSettingsFilterMeta;
/*!
 *  @brief Key for settings Exclude empty files and folders.
 */
extern NSString *const CZSettingsFilterEmptyData;
/*!
 *  @brief Key for settings custom exclusions.
 */
extern NSString *const CZSettingsCustomFilter;
/*!
 *  @brief Key for user notifications settings.
 */
extern NSString *const CZSettingsNotifications;
/*!
 *  @brief Key for badge dock icon settings.
 */
extern NSString *const CZSettingsBadgeDockIcon;
/*!
 *  @brief Key for alert sound settings.
 */
extern NSString *const CZSettingsAlertSound;
/*!
 *  @brief Key for auto start settings.
 */
extern NSString *const CZSettingsAutoStart;
/*!
 *  @brief Key for window state setting.
 */
extern NSString *const CZSettingsWindowState;
/*!
 *  @brief The name of the application settings file.
 */
extern NSString *const CZApplicationSettingsFileName;
/*!
 *  @brief The application's Application support directory.
 */
+ (NSString *)CZApplicationSupportPath;
/*!
 *  @brief The application's cache directory.
 */
+ (NSString *)CZApplicationCachePath;
/*!
 *  @brief The application's settings file.
 */
+ (NSString *)CZApplicationSettingsPath;
/*!
 *  @brief The valid file extensions.
 */
+ (NSArray *)CZValidFileExtensions;
/*!
 *  @brief The regular expression patterns for hidden files.
 */
+ (NSArray *)CZFilterHidden;
/*!
 *  @brief The regular expression patterns for meta files and folders.
 */
+ (NSArray *)CZFilterMeta;

@end