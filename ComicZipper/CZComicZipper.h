//
//  CZComicZipper.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

@class CZDropItem, CZComicZipper;

@protocol CZComicZipperDelegate <NSObject>

@required
- (void)ComicZipper:(CZComicZipper *)comicZipper didStartItemAtIndex:(NSUInteger)index;
- (void)ComicZipper:(CZComicZipper *)comicZipper didFinishItemAtIndex:(NSUInteger)index;
- (void)ComicZipper:(CZComicZipper *)comicZipper didUpdateProgress:(float)progress ofItemAtIndex:(NSUInteger)index;

@end

@interface CZComicZipper : NSObject

@property (weak) id delegate;
@property (nonatomic) BOOL shouldDeleteFolder;

- (NSInteger)count;
- (NSInteger)countAll;
- (void)addItems:(NSArray *)items;
- (void)addItem:(CZDropItem *)item;
- (BOOL)isItemInList:(NSString *)description;
- (CZDropItem *)itemWithIndex:(NSInteger)index;
- (NSArray *)itemsWithIndex:(NSIndexSet *)indexes;
- (void)removeItemsWithIndexes:(NSIndexSet *)indexes;
- (void)readyToCompress;
- (void)ignoreFiles:(NSArray *)list;

@end
