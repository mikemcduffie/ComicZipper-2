//
//  CZSettingsController.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 04/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZSettingsController : NSWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName settingsDictionary:(NSMutableDictionary *)settings;

@end
