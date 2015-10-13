//
//  CZStatusButton.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 10/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZStatusButton.h"

@implementation CZStatusButton

- (void)mouseEntered:(NSEvent *)theEvent{
    [self setImage:[NSImage imageNamed:CZStatusIconAbortHover]];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self setImage:[NSImage imageNamed:CZStatusIconAbortNormal]];
}

@end
