//
//  CZWindowController.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 30/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

@class CZComicZipper;

@interface CZMainController : NSWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                          ComicZipper:(CZComicZipper *)comicZipper
                     applicationState:(int)applicationState
                  applicationSettings:(NSDictionary *)applicationSettings;
- (void)updateApplicationSettings:(NSDictionary *)applicationSettings;
- (void)addItemsDraggedToDock:(NSArray *)items;

@end
