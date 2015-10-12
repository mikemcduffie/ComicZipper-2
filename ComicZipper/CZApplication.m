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
    } else if ([theEvent type] == NSKeyDown) {
        // Quick fix for fixing keyboard shortcut in textfields from http://stackoverflow.com/questions/970707/cocoa-keyboard-shortcuts-in-dialog-without-an-edit-menu
        if (([theEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) {
            if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"x"]) {
                if ([self sendAction:@selector(cut:) to:nil from:self])
                    return;
            } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"c"]) {
                if ([self sendAction:@selector(copy:) to:nil from:self])
                    return;
            } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"v"]) {
                if ([self sendAction:@selector(paste:) to:nil from:self])
                    return;
            } else if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"a"]) {
                if ([self sendAction:@selector(selectAll:) to:nil from:self])
                    return;
            }
        }
    }
    
    [super sendEvent:theEvent];
}


@end
