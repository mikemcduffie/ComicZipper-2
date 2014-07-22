//
//  CZPreferencesWindowController.m
//  ComicZipper 2
//
//  Created 18/07/14.
//  Copyright (c) 2014 Pock Co. All rights reserved.
//

#import "CZPreferencesWindowController.h"
#import "CZAppDelegate.h"

#define CZ_PLIST_PATH [[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"]

@interface CZPreferencesWindowController () <NSWindowDelegate>

@property (nonatomic) NSMutableDictionary *preferences;
@property (nonatomic) BOOL shouldDeleteFolders;
@property (nonatomic) BOOL shouldBadgeDockIcon;

@end

@implementation CZPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        self.preferences = [NSMutableDictionary dictionaryWithContentsOfFile:CZ_PLIST_PATH];
    }

    return self;
}

- (void)windowWillLoad {
    BOOL badgeState = (BOOL)[[self preferences] valueForKey:@"CZBadgeApp"];
    BOOL deleteState = (BOOL)[[self preferences] valueForKey:@"CZDeleteFolderAfterCompress"];
    [self setShouldBadgeDockIcon:badgeState];
    [self setShouldDeleteFolders:deleteState];
}

- (void)windowDidLoad {
    [super windowDidLoad];    
    [[self checkBoxCompressedCount] setState:[self shouldBadgeDockIcon]];
    [[self checkBoxDeleteFolders] setState:[self shouldDeleteFolders]];
}

- (void)windowWillClose:(NSNotification *)notification {
    CZAppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [delegate setPreferences:[self.preferences copy]];
    [[self preferences] writeToFile:CZ_PLIST_PATH atomically:YES];
    
}

-  (BOOL)windowShouldClose:(id)sender {
    return YES;
}

- (IBAction)checkBoxClicked:(id)sender {
    NSNumber *checkValue = [NSNumber numberWithBool:YES];
    if ([sender state] != NSOnState) {
        checkValue = @NO;
    }

    [[self preferences] setValue:checkValue forKey:[sender identifier]];
}

@end
