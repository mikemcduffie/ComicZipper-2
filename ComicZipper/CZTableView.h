//
//  CZTableView.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CZTableView;

@protocol CZTableViewDelegate <NSTableViewDelegate>

- (void)tableView:(CZTableView *)tableView didRegisterKeyUp:(int)keyCode;
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode withCommand:(BOOL)commandState;
- (void)openItemInFinder:(NSIndexSet *)rows;

@end

@interface CZTableView : NSTableView

@property (assign) id czDelegate;

@end
