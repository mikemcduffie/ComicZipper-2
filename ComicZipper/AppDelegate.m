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

- (IBAction)openAboutWindow:(id)sender {
    self.aboutWindow = [[CZAboutController alloc] init];
    [self.aboutWindow showWindow:self];
}

- (IBAction)openPreferences:(id)sender {
    self.settingsWindow = [[CZSettingsController alloc] init];
    [self.settingsWindow showWindow:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.mainWindow = [CZWindowController initWithApplicationState:CZApplicationStateNoItemDropped];
    [self.mainWindow showWindow:self];
    [self.mainWindow.window makeKeyAndOrderFront:self];
    [self setUserDefaults];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return TRUE;
}

@end
