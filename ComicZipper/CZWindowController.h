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
- (BOOL)hasProcessFinished;
- (NSInteger)numberOfItemsCompressed;

@end

@interface CZWindowController : NSWindowController

@property (weak) id delegate;
@property (nonatomic, getter = isRunning, readonly) BOOL running;

+ (instancetype)initWithApplicationState:(NSInteger)applicationState;

@end
