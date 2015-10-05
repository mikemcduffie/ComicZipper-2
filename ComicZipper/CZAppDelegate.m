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
    kApplicationSettingsPath = [NSString stringWithFormat:@"%@/settings.plist", kApplicationSupportPath];
}

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
}

- (void)saveApplicationSettings {
    [[self applicationSettings] writeToFile:kApplicationSettingsPath
                                 atomically:YES];
}

- (IBAction)openSettings:(id)sender {
    if ([self settingsController] == nil) {
        // The application settings dictionary that is passed along will be manipulated by the settings controller. Maybe find a better way to do this, no self? FU, self.
        CZSettingsController *settingsController = [[CZSettingsController alloc] initWithWindowNibName:@"Settings"
                                                                                    settingsDictionary:[self applicationSettings]];
        [self setSettingsController:settingsController];
    }

    [[self settingsController] showWindow:nil];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self loadApplicationSettings];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CZComicZipper *comicZipper = [[CZComicZipper alloc] init];
    CZMainController *mainController = [[CZMainController alloc] initWithWindowNibName:@"Main"
                                                                             ComicZipper:comicZipper
                                                                     andApplicationState:kAppStateNoItemDropped];
    [mainController showWindow:nil];
    [[mainController window] makeKeyAndOrderFront:nil];
    [self setMainController:mainController];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self saveApplicationSettings];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
