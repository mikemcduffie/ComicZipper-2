//
//  AppDelegate.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//
#import "Constants.h"
#import "CZAppDelegate.h"
#import "CZComicZipper.h"

@interface CZAppDelegate ()

@property (weak) CZComicZipper *comicZipper;

@end

@implementation CZAppDelegate


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CZComicZipper *comicZipper = [[CZComicZipper alloc] initWithState:kAppStateFirstLaunched];
    [self setComicZipper:comicZipper];
    [[self comicZipper] drawUIElements];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return YES;
}

@end
