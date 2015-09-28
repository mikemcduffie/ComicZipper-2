//
//  AppDelegate.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZAppDelegate.h"
#import "CZDropView.h"

#pragma mark CONSTANTS

#define CZ_APP_STATE_START 1
#define CZ_APP_STATE_FILEDROP_FIRST 2
#define CZ_APP_STATE_FILEDROP 3
#define CZ_APP_STATE_BADGE_INCREMENT 99
#define CZ_APP_STATE_BADGE_RESET 100
#define CZ_COLUMN_RATIO 1.1
#define CZ_ROW_HEIGHT 40

@interface CZAppDelegate () <CZDropViewDelegate>

@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) int applicationState;

@end

@implementation CZAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self drawUIElements:CZ_APP_STATE_START];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

#pragma mark USER INTERFACE METHODS

- (void)drawUIElements:(int)applicationState {
    [self setApplicationState:applicationState];
    if (applicationState == CZ_APP_STATE_START) {
        [self drawDropView];
    }
}

- (void)drawDropView {
    // Draw up a label in the middle of the drop view and define the view delegate to enable inter-communication.
    CGSize viewSize = self.dropView.frame.size;
    NSTextField *textField = [self createTextFieldWithFrame:NSMakeRect(0, viewSize.height/2-16, viewSize.width, 32)];
    [textField setFont:[NSFont fontWithName:@"Lucida Grande" size:22.0]];
    [textField setTextColor:[NSColor whiteColor]];
    [textField setTag:101];
    [textField setAlignment:NSCenterTextAlignment];
    [textField setStringValue:@"Drop Folders Here"];
    [[self dropView] addSubview:textField];
    // Add constraints to the newly created label for auto layout purposes.
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *labelConstraintX = [self constraintWithItem:[self superView]
                                                             toItem:textField
                                                      withAttribute:NSLayoutAttributeCenterX
                                                        andConstant:0];
    NSLayoutConstraint *labelConstraintY = [self constraintWithItem:[self superView]
                                                             toItem:textField
                                                      withAttribute:NSLayoutAttributeCenterY
                                                        andConstant:0];
    [[self superView] addConstraints:@[ labelConstraintX, labelConstraintY ]];
    
    [[self dropView] setDelegate:self];
    [[self dropView] setDragMode:YES];

}

- (NSTextField *)createTextFieldWithFrame:(NSRect)frame {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setBordered:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField setDrawsBackground:NO];
    [textField setAllowsEditingTextAttributes:NO];
    return textField;
}

- (NSLayoutConstraint *)constraintWithItem:(id)firstItem toItem:(id)secondItem withAttribute:(NSLayoutAttribute)attribute andConstant:(float)constant {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:secondItem
                                                                  attribute:attribute
                                                                 multiplier:1.0f
                                                                   constant:constant];
    [constraint setPriority:1];
    return constraint;
}


#pragma mark CZDropView Delegate Methods

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items {
    
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    NSUInteger indexOfObject = [[self archiveItems] indexOfObjectPassingTest:
                                ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//                                    if ([obj isArchived]) {
//                                        *stop = YES;
//                                        return NO;
//                                    }
                                    
                                    return [[obj description] isEqualToString:description];
                                }];
    if (indexOfObject == NSNotFound)
        return NO;
    return YES;
}

- (BOOL)isDropViewFront {
    return YES;
}

@end
