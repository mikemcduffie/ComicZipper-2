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

@interface CZAppDelegate ()

@property (strong) CZMainController *mainController;

@end

@implementation CZAppDelegate


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
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
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
