//
//  CZTableView.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@class CZTableView, CZTableViewDelegate;

@protocol CZTableViewDelegate <NSTableViewDelegate>

@required
- (void)tableView:(CZTableView *)tableView
 DidRegisterKeyUp:(int)keyCode
     atRowIndexes:(NSIndexSet *)indexes
      withCommand:(BOOL)commandState;
- (void)openItemInFinder:(NSIndexSet *)rows;

@end

@interface CZTableView : NSTableView

@property (nonatomic, assign) id<CZTableViewDelegate> delegate;

- (void)setUpTable;

@end
