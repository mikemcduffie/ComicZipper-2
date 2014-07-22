//
//  CZPreferencesWindowController.h
//  ComicZipper 2
//
//  Created 18/07/14.
//  Copyright (c) 2014 Pock Co. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZPreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSButton *checkBoxDeleteFolders;
@property (weak) IBOutlet NSButton *checkBoxCompressedCount;
@property (weak) IBOutlet NSPopUpButton *popUpFormat;

- (IBAction)checkBoxClicked:(id)sender;

@end
