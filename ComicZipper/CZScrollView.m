//
//  CZScrollView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZScrollView.h"

@interface CZScrollView ()

@property (nonatomic, getter = isHighlighted) BOOL highlight;

@end

@implementation CZScrollView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.isHighlighted) {
        [NSBezierPath setDefaultLineWidth:5.0];
        [[NSColor keyboardFocusIndicatorColor] set];
        [NSBezierPath fillRect:dirtyRect];
    }
}

- (void)toggleHighlight:(BOOL)highlight {
    self.highlight = highlight;
    [self setNeedsDisplay:YES];
}

@end
