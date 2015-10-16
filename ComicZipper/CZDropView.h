//
//  CZDropView.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@class CZDropView;

@protocol CZDropViewDelegate <NSObject>

@required
- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)item;
- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)files;
- (void)dropView:(CZDropView *)dropView viewShouldHighlight:(BOOL)highlight;

@end

@interface CZDropView : NSView

@property (weak) id delegate;
- (void)setDragMode:(BOOL)dragMode;

@end
