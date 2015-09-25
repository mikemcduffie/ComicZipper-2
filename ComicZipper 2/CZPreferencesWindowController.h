//
//  CZPreferencesWindowController.h
//  ComicZipper 2
//
//  Created 18/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZPreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSButton *checkBoxDeleteFolders;
@property (weak) IBOutlet NSButton *checkBoxCompressedCount;
@property (weak) IBOutlet NSButton *checkBoxNotify;

- (IBAction)checkBoxClicked:(id)sender;

@end
