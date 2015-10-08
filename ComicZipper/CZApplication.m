//
//  CZApplication.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 08/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZApplication.h"

@implementation CZApplication

- (void)sendEvent:(NSEvent *)theEvent {
    // Overriding the sendEvent: method so that application can register CMD keyups. Method borrowed from Ryan Stevens. http://lists.apple.com/archives/cocoa-dev/2003/Oct/msg00442.html.
    if ([theEvent type] == NSKeyUp) {
        [[[self mainWindow] firstResponder] tryToPerform:@selector(keyUp:) with:theEvent];
        return;
    }
    
    [super sendEvent:theEvent];
}

@end
