//
//  CZScrollView.m
//  ComicZipper 2
//
//  Created 21/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZScrollView.h"

@interface CZScrollView ()

@property (nonatomic) BOOL highlighted;

@end

@implementation CZScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Highlight
    if ([self highlighted]) {
        [NSBezierPath setDefaultLineWidth:5.0];
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath fillRect:dirtyRect];
    }
}


- (void)toggleHighlight {
    [self setHighlighted:![self highlighted]];
    [self setNeedsDisplay:YES];
}

@end
