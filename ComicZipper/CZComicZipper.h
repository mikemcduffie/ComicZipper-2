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

- (BOOL)isItemInList:(NSString *)description;

- (void)addItem:(CZDropItem *)item;
- (void)addItems:(NSArray *)items;

- (NSInteger)count;
//- (NSDictionary *)itemWithIndex:(NSInteger)index;
- (CZDropItem *)itemWithIndex:(NSInteger)index;
- (void)startCompression;

@end
