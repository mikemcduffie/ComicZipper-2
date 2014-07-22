//
//  CZAppDelegate.h
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2014 Pock Co. All rights reserved.
//

#import "CZDropView.h"

@interface CZAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet CZDropView *view;
@property (weak) IBOutlet NSView *superView;

- (IBAction)buttonPreferences:(id)sender;
- (void)setPreferences:(NSDictionary *)preferences;


@end
