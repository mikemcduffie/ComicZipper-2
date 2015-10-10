//
//  AppDelegate.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *drawer;
@property (weak) IBOutlet NSView *superView;
@property (copy, readonly) NSString *bundleVersionNumber;
@property (copy, readonly) NSString *bundleApplicationName;

@end

