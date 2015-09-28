//
//  CZDropView.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CZDropView;

@protocol CZDropViewDelegate <NSObject>

@required
- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items;
- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description;
- (BOOL)isDropViewFront;

@end

@interface CZDropView : NSView

@property (weak) id delegate;
@property (nonatomic, getter = inDragMode) BOOL dragMode;

@end