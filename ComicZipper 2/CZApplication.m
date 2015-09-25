//
//  CZApplication.m
//  ComicZipper 2
//
//  Created 20/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZApplication.h"

@implementation CZApplication

// Overriding the sendEvent: method
// so that application can register
// CMD keyups. Method borrowed from
// Ryan Stevens.
// http://lists.apple.com/archives/cocoa-dev/2003/Oct/msg00442.html.
- (void)sendEvent:(NSEvent *)theEvent {
    if ([theEvent type] == NSKeyUp) {
        [[[self mainWindow] firstResponder] tryToPerform:@selector(keyUp:) with:theEvent];
        return;
    } else {

    }
    
    [super sendEvent:theEvent];
}

@end
