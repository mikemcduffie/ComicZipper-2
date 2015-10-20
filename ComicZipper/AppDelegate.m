//
//  AppDelegate.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "AppDelegate.h"
#import "CZWindowController.h"
#import "CZSettingsController.h"
#import "CZAboutController.h"

@interface AppDelegate ()

@property (strong) CZWindowController *mainWindow;
@property (strong) CZSettingsController *settingsWindow;
@property (strong) CZAboutController *aboutWindow;

@end

@implementation AppDelegate

#pragma mark WINDOW CONTROLLER METHODS

- (void)launchMainWindow {
    self.mainWindow = [CZWindowController initWithApplicationState:CZApplicationStateNoItemDropped];
    [self.mainWindow showWindow:self];
    [self.mainWindow.window makeKeyAndOrderFront:self];
}

- (IBAction)openAboutWindow:(id)sender {
    self.aboutWindow = [[CZAboutController alloc] init];
    [self.aboutWindow showWindow:self];
}

- (IBAction)openPreferences:(id)sender {
    self.settingsWindow = [[CZSettingsController alloc] init];
    [self.settingsWindow showWindow:self];
}

#pragma mark DELEGATE METHODS

/*!
 *  @brief Tells the delegate to open multiple files.
 */
- (void)application:(NSApplication *)sender openFiles:(nonnull NSArray *)filenames {
    [self launchMainWindow];
//    [[self mainController] addItemsDraggedToDock:filenames];
}
/*!
 *  @brief Sent by the default notification center immediately before the application object is initialized.
 */
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self setUserDefaults];
}
/*!
 *  @brief Sent by the default notification center after the application has been launched and initialized but before it has received its first event.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self launchMainWindow];
}
/*!
 *  @brief Sent by the default notification center immediately before the application terminates.
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    if ([NSUserDefaults.standardUserDefaults boolForKey:CZSettingsResetSettings]) {
        [self resetUserDefaults];
    }
    
    [self clearCacheDirectory];
}
/*!
 *  @brief Sent to notify the delegate that the application is about to terminate.
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if ([self.mainWindow isRunning]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:CZApplicationName];
        [alert setInformativeText:@"The compression has not finished. Do you want to quit?"];
        [alert setIcon:[NSImage imageNamed:@"ComicZipper"]];
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Cancel"];
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}
/*!
 *  @brief Invoked when the user closes the last window the application has open.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    if ([self.mainWindow isRunning]) {
        return NO;
    }
    
    return YES;
}
/*!
 *  @brief Sent by the application to the delegate prior to default behavior to reopen (rapp) AppleEvents.
 */
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.mainWindow.window makeKeyAndOrderFront:nil];
    return NO;
}

#pragma mark LAUNCH AND SHUTDOWN METHODS

- (void)resetUserDefaults {
    NSString *domainName = [NSBundle.mainBundle bundleIdentifier];
    [NSUserDefaults.standardUserDefaults removePersistentDomainForName:domainName];
}

- (void)setUserDefaults {
    NSString *defaultsPath = [NSBundle.mainBundle pathForResource:@"UserDefaults"
                                                           ofType:@"plist"];
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    [NSUserDefaults.standardUserDefaults registerDefaults:defaults];
}

- (void)clearCacheDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [CZConstants cacheDirectoryPath];
    NSError *error = nil;
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:path
                                                            error:nil]) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, file]
                                error:&error];
    }
}

@end
