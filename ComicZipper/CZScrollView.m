//
//  CZScrollView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZScrollView.h"

@interface CZScrollView ()

@property (nonatomic, getter = isHighlighted) BOOL highlight;

@end

@implementation CZScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    if ([self isHighlighted]) {
        [NSBezierPath setDefaultLineWidth:5.0];
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath fillRect:dirtyRect];
    }
}


- (void)toggleHighlight {
    [self setHighlight:![self isHighlighted]];
    [self setNeedsDisplay:YES];
}

@end
