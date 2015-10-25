//
//  CZTableViewController.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@interface CZTableViewController : NSViewController

@property (weak) id delegate;
- (void)viewWillUnload;
- (void)cancelAllItems;

@end
