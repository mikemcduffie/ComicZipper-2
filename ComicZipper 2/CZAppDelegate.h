//
//  CZAppDelegate.h
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZDropView.h"

@interface CZAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet CZDropView *view;
@property (weak) IBOutlet NSView *superView;

@property (weak) IBOutlet NSDrawer *drawer;
@property (weak) IBOutlet NSButton *checkBoxDeleteFolders;
@property (weak) IBOutlet NSButton *checkBoxCompressedCount;
@property (weak) IBOutlet NSButton *checkBoxNotify;

- (IBAction)buttonPreferences:(id)sender;
- (IBAction)checkBoxClicked:(id)sender;

- (void)loadPreferences:(NSDictionary *)preferences;


@end
