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

@interface AppDelegate ()

@property (strong) CZWindowController *mainWindow;
@property (strong) CZSettingsController *settingsWindow;

@end

@implementation AppDelegate

- (IBAction)openPreferences:(id)sender {
    self.settingsWindow = [[CZSettingsController alloc] init];
    [self.settingsWindow showWindow:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.mainWindow = [CZWindowController initWithApplicationState:CZApplicationStateNoItemDropped];
    [self.mainWindow showWindow:self];
    [self.mainWindow.window makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return TRUE;
}

@end
