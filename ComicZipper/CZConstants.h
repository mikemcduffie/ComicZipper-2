//
//  Constants.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZConstants : NSObject

typedef enum {
    /*!
     *  @brief Application has no items to process.
     *  @discussion
     */
    CZApplicationStateNoItemDropped,
    /*!
     *  @brief Application receives items for the first time.
     *  @discussion This key represents the transition between a no-item-state and a populated list-state.
     */
    CZApplicationStateFirstItemDrop,
    /*!
     *  @brief Application already has loaded items to process.
     */
    CZApplicationStatePopulatedList
} ApplicationStates;

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
 *  @brief The default row height.
 */
extern float const kTableRowHeight;
/*!
 *  @brief The default width of the table column.
 */
extern float const kTableColumnWidth;
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
extern NSString *const CZDropViewNoHighlightImage;
/*!
 *  @brief Name of the image representing highlighted state of drop view.
 */
extern NSString *const CZDropViewHighlightImage;
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
 *  @brief Notification name for toggling drag mode.
 */
extern NSString *const CZToggleDragModeNotification;
/*!
 *  @brief Notify window controller of view change.
 */
extern NSString *const CZChangeViewNotification;
/*!
 *  @brief The application's Application support directory.
 */
+ (NSString *)applicationSupportPath;
/*!
 *  @brief The application's cache directory.
 */
+ (NSString *)cacheDirectoryPath;
/*!
 *  @brief The application's settings file.
 */
+ (NSString *)settingsDirectoryPath;
/*!
 *  @brief The valid file extensions.
 */
+ (NSArray *)validFileExtensions;
/*!
 *  @brief The regular expression patterns for hidden files.
 */
+ (NSArray *)filterForHiddenFiles;
/*!
 *  @brief The regular expression patterns for meta files and folders.
 */
+ (NSArray *)filterForMetaFiles;
@end
