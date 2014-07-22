//
//  CZTableView.h
//  ComicZipper 2
//
//  Created 19/07/14.
//  Copyright (c) 2014 Pock Co. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CZTableView, CZTableViewDelegate;

@protocol CZTableViewDelegate <NSTableViewDelegate>

@optional
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode;
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode withCommand:(BOOL)commandState;
- (void)openItemInFinder:(NSIndexSet *)rows;
@end

@interface CZTableView : NSTableView

@property (nonatomic, assign) id CZDelegate;

@end
