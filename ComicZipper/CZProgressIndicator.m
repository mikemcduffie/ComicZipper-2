//
//  CZProgressIndicator.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 02/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZProgressIndicator.h"

@implementation CZProgressIndicator

@synthesize tag = _tag;

+ (instancetype)initWithFrame:(NSRect)frameRect
                  andProgress:(double)progress {
    return [[self alloc] initWithFrame:frameRect andProgress:progress];
}

- (instancetype)initWithFrame:(NSRect)frameRect
                  andProgress:(double)progress {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        [self setStyle:NSProgressIndicatorBarStyle];
        [self setMinValue:0.0];
        [self setMaxValue:100.0];
        [self setDoubleValue:progress];
        [self setIndeterminate:NO];
        [self setDisplayedWhenStopped:NO];
    }
    
    return self;
}

- (NSInteger)tag {
    return _tag;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
}

@end
