//
//  AppDelegate.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 27/09/15.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZAppDelegate.h"
#import "CZTableView.h"
#import "CZDropView.h"
#import "CZDropItem.h"

#pragma mark CONSTANTS

#define CZ_APP_STATE_START 1
#define CZ_APP_STATE_FILEDROP_FIRST 2
#define CZ_APP_STATE_FILEDROP 3
#define CZ_APP_STATE_BADGE_INCREMENT 99
#define CZ_APP_STATE_BADGE_RESET 100
#define CZ_COLUMN_RATIO 1.1
#define CZ_ROW_HEIGHT 40

@interface CZAppDelegate () <CZDropViewDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (weak) CZDropView *dropView;
@property (weak) NSScrollView *scrollView;
@property (weak) NSTableView *tableView;
@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) int applicationState;

@end

@implementation CZAppDelegate

- (void)initialSetup {
    _archiveItems = [[NSMutableArray alloc] init];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self initialSetup];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self drawDropView];
    [self drawUIElements:CZ_APP_STATE_FILEDROP_FIRST];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    return YES;
}

#pragma mark USER INTERFACE METHODS

- (void)drawUIElements:(int)applicationState {
    [self setApplicationState:applicationState];
    if (applicationState == CZ_APP_STATE_START) {
        [self drawLabelForDropView];
    } else if (applicationState == CZ_APP_STATE_FILEDROP_FIRST) {
        // Remove the DropView label before proceeding to create the table view
        [[[self dropView] viewWithTag:101] removeFromSuperview];
        NSTableView *tableView = [self drawTableView];
        NSScrollView *scrollView = [self drawScrollView];
//        [scrollView setDocumentView:tableView];
//        [[self superView] addSubview:scrollView];
//        [self setScrollView:scrollView];
//        [self setTableView:tableView];
        NSRect textFieldBounds = NSMakeRect(18, self.superView.frame.size.height-40, self.superView.frame.size.width, self.superView.frame.size.height);
        NSTextField *textField = [self createTextFieldWithFrame:textFieldBounds];
        [textField setFont:[NSFont fontWithName:@"Lucida Grande" size:22.0]];
        [textField setTextColor:[NSColor whiteColor]];
        [textField setTag:101];
        [textField setStringValue:@"1 of 8 items compressed"];
        [textField setAlignment:NSCenterTextAlignment];
        [[self superView] addSubview:textField];




    }
}

/*!
 *  @brief Create an NSTextField object with a given frame.
 *
 */
- (NSTextField *)createTextFieldWithFrame:(NSRect)frame {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setBordered:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField setDrawsBackground:NO];
    [textField setAllowsEditingTextAttributes:NO];
    return textField;
}

/*!
 *  @brief  Create constraints for the UI elements.
 *  @param  firstItem ...
 *  @param  secondItem ...
 *  @param  attribute ...
 *
 */
- (void)constraintItem:(id)firstItem toItem:(id)secondItem withAttribute:(NSLayoutAttribute)attribute {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:secondItem
                                                                  attribute:attribute
                                                                 multiplier:1.0f
                                                                   constant:0];
    [firstItem addConstraint:constraint];
}


#pragma mark USER INTERFACE METHODS – APP STATE: START

- (void)drawDropView {
    // Create the view that will act as the drop zone and define the view delegate to enable inter-communication.
    CZDropView *dropView = [[CZDropView alloc] initWithFrame:[[self superView] bounds]];
    [self setDropView:dropView];
    [[self dropView] setDragMode:YES];
    [[self dropView] setDelegate:self];
    [[self superView] addSubview:[self dropView]];
    [[self dropView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self constraintItem:[self superView] toItem:[self dropView] withAttribute:NSLayoutAttributeWidth];
    [self constraintItem:[self superView] toItem:[self dropView] withAttribute:NSLayoutAttributeHeight];
}

- (void)drawLabelForDropView {
    // Draw up a label to be displayed in the middle of the drop view.
    CGSize viewSize = self.dropView.frame.size;
    NSTextField *textField = [self createTextFieldWithFrame:NSMakeRect(0, viewSize.height/2-16, viewSize.width, 32)];
    [textField setFont:[NSFont fontWithName:@"Lucida Grande" size:22.0]];
    [textField setTextColor:[NSColor whiteColor]];
    [textField setTag:101];
    [textField setAlignment:NSCenterTextAlignment];
    [textField setStringValue:@"Drop Folders Here"];
    [[self dropView] addSubview:textField];
    // Add constraints to the newly created label for auto layout purposes, constraining it to drop view.
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self constraintItem:[self dropView] toItem:textField withAttribute:NSLayoutAttributeCenterX];
    [self constraintItem:[self dropView] toItem:textField withAttribute:NSLayoutAttributeCenterY];
}

#pragma mark USER INTERFACE METHODS – APP STATE: FIRST DROP

- (NSTableView *)drawTableView {
    NSRect frame = [[self superView] frame];
    NSTableView *tableView = [[NSTableView alloc] initWithFrame:frame];
    [tableView setHeaderView:nil];
    return tableView;
}

- (NSScrollView *)drawScrollView {
    NSRect bounds = [[self superView] bounds];
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:bounds];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setDrawsBackground:NO];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setHasVerticalScroller:NO];
    [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    return scrollView;
}

#pragma mark CZDropView Delegate Methods

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items {
    [[self archiveItems] addObjectsFromArray:items];
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    NSUInteger indexOfObject = [[self archiveItems] indexOfObjectPassingTest:
                                ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                    // As per request, archived objects can be added again to the list (without removing the already processed item from the list).
                                    if ([obj isArchived]) {
                                        return NO;
                                    }
                                    // TODO: Match by path, instead of description of the object. Two objects with same name (from different folders) can be problematic.
                                    BOOL found = [[obj description] isEqualToString:description];
                                    return found;
                                }];
    if (indexOfObject == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isDropViewFront {
    return YES;
}

@end
