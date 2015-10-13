//
//  AppDelegate.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZAppDelegate : NSObject <NSApplicationDelegate>

@property (copy, readonly) NSString *bundleVersionNumber;
@property (copy, readonly) NSString *bundleApplicationName;

@end

