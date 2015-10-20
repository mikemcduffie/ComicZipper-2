//
//  CZWindowController.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@class CZWindowController;

@protocol CZWindowControllerDelegate <NSObject>

@required
- (void)viewShouldHighlight:(BOOL)highlight;

@optional
- (BOOL)isItemInList:(NSString *)item;
- (void)addItemsFromArray:(NSArray *)array;
- (void)reloadData;
- (NSInteger)numberOfItemsCompressed;

@end

@interface CZWindowController : NSWindowController

@property (weak) id delegate;

+ (instancetype)initWithApplicationState:(NSInteger)applicationState;

@end
