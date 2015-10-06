//
//  AppDelegate.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZAppDelegate.h"
#import "CZComicZipper.h"
#import "CZMainController.h"
#import "CZSettingsController.h"

@interface CZAppDelegate ()

@property (strong) CZMainController *mainController;
@property (strong) CZSettingsController *settingsController;
@property (nonatomic) NSMutableDictionary *applicationSettings;

@end

@implementation CZAppDelegate

#pragma mark PREFERENCES SETTINGS

/*!
 *  @brief Sets up the necessary path strings.
 *  @discussion The Application Support folder and the path to the application settings file in that folder will be set up. If there is no application specific folder in the Application Support directory, one will be created.
 */
- (void)setUpPaths {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    kApplicationSupportPath = [NSString stringWithFormat:@"%@/%@", applicationSupportPath, kApplicationName];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:kApplicationSupportPath isDirectory:&isDirectory] && !isDirectory) {
        // Create the Application Support directory if it does not exist.
        [[NSFileManager defaultManager] createDirectoryAtPath:kApplicationSupportPath
                                  withIntermediateDirectories:YES
                                                   attributes:NULL
                                                        error:NULL];
    }
    kApplicationSettingsPath = [NSString stringWithFormat:@"%@/%@", kApplicationSupportPath, kApplicationSettingsFileName];
}
/*!
 *  @brief Load application settings.
 *  @discussion Settings from the DefaultPreferences.plist file will be used if a settings file cannot be found in the Application Support directory.
 */
- (void)loadApplicationSettings {
    [self setUpPaths];
    if ([[NSFileManager defaultManager] fileExistsAtPath:kApplicationSettingsPath isDirectory:nil]) {
        _applicationSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:kApplicationSettingsPath];
    } else {
        NSString *defaultSettingsPath = [[NSBundle mainBundle] pathForResource:@"DefaultPreferences"
                                                                        ofType:@"plist"];
        _applicationSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultSettingsPath];
        [self saveApplicationSettings];
    }

    for (NSString *keyPath in [self applicationSettings]) {
        [[self applicationSettings] addObserver:self
                                     forKeyPath:keyPath
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
    }
}
/*!
 *  @brief Save the application settings.
 */
- (void)saveApplicationSettings {
    [[self applicationSettings] writeToFile:kApplicationSettingsPath
                                 atomically:YES];
}

- (void)updateSettingsAcrossApplication {
    [[self mainController] updateApplicationSettings:[self applicationSettings]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    [[self mainController] updateApplicationSettings:[self applicationSettings]];
}

#pragma mark USER INTERFACE METHODS

/*!
 *  @brief Opens the settings window.
 */
- (IBAction)openSettings:(id)sender {
    if ([self settingsController] == nil) {
        // The application settings dictionary that is passed along will be manipulated by the settings controller. Maybe find a better way to do this, no, self? FU, self!
        CZSettingsController *settingsController = [[CZSettingsController alloc] initWithWindowNibName:@"Settings"
                                                                                    settingsDictionary:[self applicationSettings]];
        [self setSettingsController:settingsController];
    }

    [[self settingsController] showWindow:nil];
}

- (void)launchMainController {
    if ([self mainController] == nil) {
        CZComicZipper *comicZipper = [[CZComicZipper alloc] init];
        CZMainController *mainController = [[CZMainController alloc] initWithWindowNibName:@"Main"
                                                                               ComicZipper:comicZipper
                                                                          applicationState:kAppStateNoItemDropped
                                                                       applicationSettings:[[self applicationSettings] copy]];
        [mainController showWindow:nil];
        [[mainController window] makeKeyAndOrderFront:nil];
        [self setMainController:mainController];
    }
}

#pragma mark DELEGATE METHODS

- (void)application:(NSApplication *)sender openFiles:(nonnull NSArray *)filenames {
    [self launchMainController];
    [[self mainController] addItemsDraggedToDock:filenames];
}

/*!
 *  @brief Sent by the default notification center immediately before the application object is initialized.
 */
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self loadApplicationSettings];
}
/*!
 *  @brief Sent by the default notification center after the application has been launched and initialized but before it has received its first event.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self launchMainController];

}
/*!
 *  @brief Sent by the default notification center immediately before the application terminates.
 */
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self saveApplicationSettings];
}
/*!
 *  @brief Sent to notify the delegate that the application is about to terminate.
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return YES;
}
/*!
 *  @brief Invoked when the user closes the last window the application has open.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
