//
//  AppDelegate.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "AppDelegate.h"
#import "CZWindowController.h"

@interface AppDelegate ()

@property (strong) CZWindowController *mainWindow;

@end

@implementation AppDelegate

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
