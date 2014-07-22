//
//  CZDropView.h
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2014 Pock Co. All rights reserved.
//

@class CZDropView, CZDropViewDelegate;

@protocol CZDropViewDelegate

@required
- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items;

@optional
- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description;
- (BOOL)isDropViewFront;
@end

@interface CZDropView : NSView

@property (nonatomic, assign) id delegate;
@property (nonatomic, getter = isDraggable) BOOL draggable;

@end
