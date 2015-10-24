//
//  CZAboutController.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 20/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZAboutController : NSWindowController

@property (copy, readonly) NSString *bundleVersionNumber;
@property (copy, readonly) NSString *bundleApplicationName;

@end
