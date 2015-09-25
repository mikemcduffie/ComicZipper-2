//
//  CZAppDelegate.m
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//
//  2.1.1 CHANGES: √ Ability to auto add folders on start from Finder selection.
//  2.1.2 CHANGES: √ Window is now resizeable.
//                 √ Added support for highlighting multple items in queue list with mouse/shift.
//                 √ Added support for highlighting all items in queue list with CMD+A.
//                 √ Changes made in preferences does not require app reboot. Reflects instantly.
//                 √ Added: Notifications, contextual menu with options to remove or open items in Finder.
//                 √ Bug fixes: The count is now correct. And hopefully the Zero KB bug is solved.
//  2.1.4 CHANGES: √ Support for OS X 10.10.
//  2.1.5 CHANGES: √ Changed file format from CBR to CBZ.
//                 √ Fixed the alert sound invoked upon keystroke.
//                 √ Fixed the bug where the app remains in a "compressing" state.
// TODO: Add help

#import "CZAppDelegate.h"
#import "CZDropView.h"
#import "CZArchiverItem.h"
#import "CZPreferencesWindowController.h"
#import "Finder.h"
#import "CZTableView.h"
#import "CZScrollView.h"
#import "CZCell.h"

#pragma mark CONSTANTS
#define CZ_APP_STATE_START 1
#define CZ_APP_STATE_FILEDROP_FIRST 2
#define CZ_APP_STATE_FILEDROP 3
#define CZ_APP_STATE_BADGE_INCREMENT 99
#define CZ_APP_STATE_BADGE_RESET 100
#define CZ_COLUMN_RATIO 1.1
#define CZ_ROW_HEIGHT 40
#define CZ_KEY_SPACE 49
#define CZ_KEY_DELETE 51
#define CZ_PLIST_PATH [[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"]

@interface CZAppDelegate () <CZDropViewDelegate, CZArchiverItemDelegate, CZTableViewDelegate, NSTableViewDataSource, NSUserNotificationCenterDelegate>

@property (weak) CZScrollView *scrollView;
@property (weak) CZTableView *tableView;
@property (weak) NSButton *buttonCompress;
@property (weak) NSProgressIndicator *progressIndicator;
@property (weak) NSTextField *label;

@property (strong) CZPreferencesWindowController *preferencesWindowController;

@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) NSMutableDictionary *preferences;
@property (nonatomic) long double totalSizeInBytes;
@property (nonatomic) int numberOfItemsCompressed, numberOfItemsToCompress, badgeCount, applicationState;
@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic, getter = applicationIsResigned) BOOL applicationResigned;
@property (nonatomic, readonly) BOOL shouldDisplayBadgeCount, shouldDeleteFoldersAfterCompress, shouldNotify;

@property (nonatomic) FinderApplication *finder;
@property (nonatomic) SBElementArray *selection;

- (void)initialSetup;

- (void)applicationWillFinishLaunching:(NSNotification *)notification;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)applicationDidResignActive:(NSNotification *)notification;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;
- (void)applicationWillTerminate:(NSNotification *)notification;
- (void)setApplicationBadgeLabel:(NSString *)label;

- (void)buttonCompress:(id)sender;

- (void)drawUIElements:(int)applicationState;
- (NSLayoutConstraint *)constraintWithItem:(id)firstItem toItem:(id)secondItem withAttribute:(NSLayoutAttribute)attribute andConstant:(float)constant;
- (void)showProgressIndicator:(BOOL)state;
- (void)updateTopLabel:(NSString *)label andShowProgressIndicator:(BOOL)progress;

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
- (NSTextField *)createTextFieldWithFrame:(NSRect)frame;
- (NSCell *)createCell;

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)archiveItems;
- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description;
- (BOOL)isDropViewFront;
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode;
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode withCommand:(BOOL)commandState;
- (void)openItemInFinder:(NSIndexSet *)indexSet;
- (void)compressionDidStart:(CZArchiverItem *)archiver;
- (void)compressionDidEnd:(CZArchiverItem *)archiver;
- (void)compressionCouldNotFinish:(CZArchiverItem *)archiver errorCode:(NSString *)string;
- (void)archiverDidRemoveDirectory:item;

- (NSString *)stringFromByte:(double)fileSize;
- (NSImage *)updateImageForItem:(CZArchiverItem *)archiver atRow:(NSInteger)row isCached:(BOOL)cached;
- (void)controlApplicationBadge:(int)state;
- (void)deleteFolders;
- (void)setCacheDirectory:(NSString *)cacheDirectory;
- (void)clearCacheDirectory;
- (BOOL)hasSelection;
- (SBElementArray *)removeNonFoldersFromSelection:(SBElementArray *)selection;
- (NSArray *)getSelectionAsArray;
- (void)cleanUpAfterLaunch;
- (void)handleKeyEvent:(int)keyCode commandPressed:(BOOL)commandState;
- (void)updateCount;
- (void)displayNotification:(NSString *)text;

@end

@implementation CZAppDelegate

#pragma mark INITIAL SETUP
// Setup method; Specify notification
// center delegate, get app preferences,
// initialize archive items array and the
// Finder object and set the cache directory.
- (void)initialSetup {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    self.archiveItems = [[NSMutableArray alloc] init];
    self.finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];
    self.cacheDirectory = [[NSBundle mainBundle] bundleIdentifier];
    self.preferences = [NSMutableDictionary dictionaryWithContentsOfFile:CZ_PLIST_PATH];
    [self loadPreferences:[self preferences]];
}

- (void)loadPreferences:(NSDictionary *)preferences {
    _shouldDisplayBadgeCount = [[preferences valueForKey:@"CZBadgeApp"] boolValue];
    _shouldDeleteFoldersAfterCompress = [[preferences valueForKey:@"CZDeleteFolderAfterCompress"] boolValue];
    _shouldNotify = [[preferences valueForKey:@"CZNotify"] boolValue];
}

#pragma mark APPLICATION DELEGATE METHODS
// Called during launch, will invoke
// setup methods.
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [self initialSetup];
}

// Invoked after launch; Method
// should check if the user has
// set a selection. If so, load
// the selected folders into the
// table view.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if ([self hasSelection]) {
        NSArray *folders = [NSArray arrayWithArray:[self getSelectionAsArray]];
        [self dropView:[self view] didReceiveFiles:folders];
        [[self view] setDelegate:self];
        [[self view] setDraggable:YES];
    } else {
        [self drawUIElements:CZ_APP_STATE_START];
    }
    
    [self cleanUpAfterLaunch];
}

// Invoked when application resigns (loses focus).
- (void)applicationDidResignActive:(NSNotification *)notification {
    [self setApplicationResigned:YES];
}

// Invoked when application becomes active
// again (is in front). Resets the badge
// if displayed.
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self setApplicationResigned:NO];
    if ([self shouldDisplayBadgeCount]) {
        [self controlApplicationBadge:CZ_APP_STATE_BADGE_RESET];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

// Called during termination;
// clear cache directory.
- (void)applicationWillTerminate:(NSNotification *)notification {
    [self clearCacheDirectory];
}

- (void)setApplicationBadgeLabel:(NSString *)label {
    [[NSApp dockTile] setBadgeLabel:label];
}

#pragma mark BUTTON METHODS

// Invoked when the compress button
// is pressed, starting the process.
- (void)buttonCompress:(id)sender {
    // Update label to let user know
    // compression is in progress.
    [self updateTopLabel:@"Compressing" andShowProgressIndicator:YES];
    // Create NSOperationQueue for the
    // compression process to run in.
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    myQueue.name = @"Archive queue";
    [myQueue addOperationWithBlock:^{
        for (CZArchiverItem *item in [self archiveItems]) {
            // Do not compress already
            // archived items.
            if (![item isArchived]) {
                [item setDelegate:self];
                [item startCompression];
            }
        }
    }];
    // Disable button while compressing.
    [sender setEnabled:NO];
}

- (IBAction)buttonPreferences:(id)sender {
//    self.preferencesWindowController = [[CZPreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
//    [[[self preferencesWindowController] window] makeKeyAndOrderFront:self];
    
    if ([[self drawer] state] == NSDrawerClosedState ||
        [[self drawer] state] == NSDrawerClosingState) {
        NSSize drawerSize = {270,300};
        [[self drawer] setMaxContentSize:drawerSize];
        [[self drawer] setContentSize:drawerSize];
        [[self drawer] open];
        [[self checkBoxDeleteFolders] setState:_shouldDeleteFoldersAfterCompress];
        [[self checkBoxCompressedCount] setState:_shouldDisplayBadgeCount];
        [[self checkBoxNotify] setState:_shouldNotify];
    } else {
        [[self drawer] close];
    }
}

- (IBAction)checkBoxClicked:(id)sender {
    NSNumber *checkValue = [NSNumber numberWithBool:YES];
    if ([sender state] != NSOnState) {
        checkValue = @NO;
    }
    
    [[self preferences] setValue:checkValue forKey:[sender identifier]];
    [self loadPreferences:[self.preferences copy]];
    [[self preferences] writeToFile:CZ_PLIST_PATH atomically:YES];
}

#pragma mark USER INTERFACE METHODS

- (void)drawUIElements:(int)applicationState {
    [self setApplicationState:applicationState];
    if (applicationState == CZ_APP_STATE_START) {
        // Runs when app starts; Draws up a label
        // in the middle ("Drop Folders Here") and
        // sets the views (DropView) delegate to
        // AppDelegate, which will enable the
        // view to communicate with AppDelegate.
        CGSize viewSize = self.view.frame.size;
        NSTextField *label = [self createTextFieldWithFrame:NSMakeRect(0, viewSize.height/2-16, viewSize.width, 32)];
        
        [label setFont:[NSFont fontWithName:@"Lucida Grande" size:22.0]];
        [label setTextColor:[NSColor whiteColor]];
        [label setEnabled:NO];
        [label setTag:101];
        [label setAlignment:NSCenterTextAlignment];
        [label setStringValue:@"Drop Folders Here"];

        [[self view] addSubview:label];

        // Add constraints to label
        // for autolayout.
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *labelConstraintX = [self constraintWithItem:[self superView]
                                                                 toItem:label
                                                          withAttribute:NSLayoutAttributeCenterX
                                                            andConstant:0];
        NSLayoutConstraint *labelConstraintY = [self constraintWithItem:[self superView]
                                                                 toItem:label
                                                          withAttribute:NSLayoutAttributeCenterY
                                                            andConstant:0];
        [[self superView] addConstraints:@[ labelConstraintX, labelConstraintY ]];
        
        [[self view] setDelegate:self];
        [[self view] setDraggable:YES];
        
        self.totalSizeInBytes = 0.0;
        self.numberOfItemsCompressed = 0;
    } else if (applicationState == CZ_APP_STATE_FILEDROP_FIRST) {
        // Runs when folders been dropped on the Drop View the
        // first time; Removes the label and adding a scrollview
        // to hold a tableview that will display the selected
        // items in two columns (name, size). A button ("Compress")
        // is also created, linked to the start compression
        // method (buttonCompress:).
        [[[self view] viewWithTag:101] removeFromSuperview];
        
        NSRect frame = [[self view] frame];
        NSRect tableFrame = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height); //frame.size.height-74

        // Create a scrollview and a tableview.
        CZScrollView *scrollView = [[CZScrollView alloc] initWithFrame:tableFrame];
        CZTableView *tableView = [[CZTableView alloc] initWithFrame:tableFrame];
        
        // Create, configure and add the two columns to
        // the tableview.
        NSTableColumn *rightTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"rightColumn"];
        NSTableColumn *leftTableColumn = [[NSTableColumn alloc] initWithIdentifier:@"leftColumn"];
        [leftTableColumn setWidth:frame.size.width/CZ_COLUMN_RATIO];
        [rightTableColumn setWidth:frame.size.width-(frame.size.width/CZ_COLUMN_RATIO)];
        [tableView addTableColumn:leftTableColumn];
        [tableView addTableColumn:rightTableColumn];
        
        // Configure the tableview and the scrollview
        [tableView setColumnAutoresizingStyle:NSTableViewReverseSequentialColumnAutoresizingStyle];
        [tableView setUsesAlternatingRowBackgroundColors:YES];
        [tableView setAllowsColumnResizing:NO];
        [tableView setAllowsColumnReordering:NO];
        [tableView setAllowsColumnSelection:NO];
        [tableView setAllowsMultipleSelection:YES];
        [tableView setHeaderView:nil];
        [tableView setDelegate:self];
        [tableView setCZDelegate:self];
        [tableView setDataSource:self];
        [tableView becomeFirstResponder];
        [tableView reloadData];
        [scrollView setBorderType:NSBezelBorder];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
        [scrollView setDocumentView:tableView];

        self.scrollView = scrollView;
        self.tableView = tableView;
        [[self view] addSubview:self.scrollView];

        // Add constraints to scroll view for
        // autolayout.
        [[self scrollView] setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *scrollViewConstraintBottom = [self constraintWithItem:[self superView]
                                                                           toItem:[self scrollView]
                                                                    withAttribute:NSLayoutAttributeBottom
                                                                      andConstant:38];
        NSLayoutConstraint *scrollViewConstraintTrailing = [self constraintWithItem:[self superView]
                                                                             toItem:[self scrollView]
                                                                      withAttribute:NSLayoutAttributeTrailing
                                                                        andConstant:0];
        NSLayoutConstraint *scrollViewConstraintLeading = [self constraintWithItem:[self scrollView]
                                                                            toItem:[self superView]
                                                                     withAttribute:NSLayoutAttributeLeading
                                                                       andConstant:0];
        NSLayoutConstraint *scrollViewConstraintTop = [self constraintWithItem:[self scrollView]
                                                                        toItem:[self superView]
                                                                 withAttribute:NSLayoutAttributeTop
                                                                   andConstant:60];
        [[self superView] addConstraints:@[ scrollViewConstraintBottom, scrollViewConstraintTrailing, scrollViewConstraintLeading, scrollViewConstraintTop]];

        // Create the button that will serve as a
        // start button for the compression process.
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(285, 2, 102, 32)];
        self.buttonCompress = button;
        [self.buttonCompress setTitle:@"Compress"];
        [self.buttonCompress setFont:[NSFont fontWithName:@"LucidaGrande" size:13.0]];
        [self.buttonCompress setBordered:YES];
        [self.buttonCompress setBezelStyle:NSRoundedBezelStyle];
        [self.buttonCompress setButtonType:NSMomentaryPushInButton];
        [self.buttonCompress setTarget:self];
        [self.buttonCompress setAction:@selector(buttonCompress:)];
        
        [[self view] addSubview:self.buttonCompress];

        // Add constraints to button
        // for autolayout.
        [[self buttonCompress] setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *buttonConstraintTrailing = [self constraintWithItem:[self superView]
                                                                         toItem:[self buttonCompress]
                                                                  withAttribute:NSLayoutAttributeTrailing
                                                                    andConstant:10];
        NSLayoutConstraint *buttonConstraintBottom = [self constraintWithItem:[self superView]
                                                                       toItem:[self buttonCompress]
                                                                withAttribute:NSLayoutAttributeBottom
                                                                  andConstant:10];
        [[self superView] addConstraints:@[ buttonConstraintTrailing, buttonConstraintBottom ]];

        // Create the label that will be displayed over
        // the tableview with information (count, size)
        // about the items in the queue.
        CGSize viewSize = self.view.frame.size;
        NSTextField *label = [self createTextFieldWithFrame:NSMakeRect(0, viewSize.height-40, viewSize.width, 30)];
        
        // Configure the label and set its tag to 101.
        [label setFont:[NSFont fontWithName:@"Lucida Grande" size:15.0]];
        [label setTextColor:[NSColor controlTextColor]];
        [label setEnabled:NO];
        [label setTag:101];
        [label setAlignment:NSCenterTextAlignment];
        
        [[self view] addSubview:label];
        // Add constraints to label
        // for autolayout.
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *labelConstraintTop = [self constraintWithItem:[self superView]
                                                                   toItem:label
                                                            withAttribute:NSLayoutAttributeTop
                                                              andConstant:-25];
        NSLayoutConstraint *labelConstraintX = [self constraintWithItem:[self superView]
                                                                 toItem:label
                                                          withAttribute:NSLayoutAttributeCenterX
                                                            andConstant:0];
        [[self superView] addConstraints:@[ labelConstraintTop, labelConstraintX ]];

        [self updateTopLabel:@"Calculating..." andShowProgressIndicator:YES];
    } else if (applicationState == CZ_APP_STATE_FILEDROP) {
        // Run when folders been dropped (after first time).
        [[self tableView] reloadData];
    }
}

// Create constraints for UI Elements
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

// Toggle progress indicator at the top.
- (void)showProgressIndicator:(BOOL)state {
    if (state) {
        // If YES, create indicator with
        // specified frame, and start
        // animate indicator.
        CGSize viewSize = self.view.frame.size;
        NSProgressIndicator *progressIndicatorSpinning = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(viewSize.width/3-5, viewSize.height-27, 16, 16)];
        self.progressIndicator = progressIndicatorSpinning;
        [[self progressIndicator] setStyle:NSProgressIndicatorSpinningStyle];
        [[self progressIndicator] setControlSize:NSSmallControlSize];
        [[self progressIndicator] startAnimation:self];
        [[self view] addSubview:[self progressIndicator]];
        
        // Add constraints to indicator
        // for autolayout.
        [[self progressIndicator] setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *progressIndicatorConstraintTop = [self constraintWithItem:[self superView]
                                                                               toItem:[self progressIndicator]
                                                                        withAttribute:NSLayoutAttributeTop
                                                                          andConstant:-27];
        NSLayoutConstraint *progressIndicatorConstraintX = [self constraintWithItem:[self superView]
                                                                             toItem:[self progressIndicator]
                                                                      withAttribute:NSLayoutAttributeCenterX
                                                                        andConstant:65];
        [[self superView] addConstraints:@[ progressIndicatorConstraintTop, progressIndicatorConstraintX ]];
    } else {
        // If NO, remove the indicator and set property to nil.
        [[self progressIndicator] removeFromSuperview];
        self.progressIndicator = nil;
    }
}

// Update the top label and toggle progress indicator.
- (void)updateTopLabel:(NSString *)label andShowProgressIndicator:(BOOL)progress {
    [[[self view] viewWithTag:101] setStringValue:label];
    [self showProgressIndicator:progress];
}

#pragma mark USER INTERFACE METHODS: TABLEVIEW

// Populate the table view with
// items in array archiveItems.
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cellView = [[NSTableView alloc] makeViewWithIdentifier:@"cellView" owner:self];
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableView.frame.size.width, 35)];
        cellView.identifier = @"cellView";
    }
    
    CZArchiverItem *item = [[self archiveItems] objectAtIndex:row];
    
    if ([[tableColumn identifier] isEqualToString:@"leftColumn"]) {
        // Get the name of the item that will occupy the cell and
        // the size of the item in bytes and convert it to a readable
        // readable number to be displayed in the subtitle cell.
        NSString *leftCellText = [item description];
        double fileSize = [item fileSizeInBytes];
        
        // The cells that will display the name...
        NSCell *leftCell = [self createCell];
        [leftCell setStringValue:leftCellText];
        [leftCell setFont:[NSFont fontWithName:@"Lucida Grande Bold" size:13.0]];

        // ...and the file size + other information
        NSCell *detailCell = [self createCell];
        [detailCell setStringValue:[self stringFromByte:fileSize]];
        [detailCell setFont:[NSFont fontWithName:@"Lucida Grande" size:9.5]];
        
        // The textfield that will hold the main cell
        NSTextField *leftTextField = [self createTextFieldWithFrame:NSMakeRect(45, 15, [tableColumn width], CZ_ROW_HEIGHT/2)];
        [leftTextField setToolTip:leftCellText];
        [leftTextField setCell:leftCell];

        // The textfield that will hold the info cell
        NSTextField *leftDetailTextField = [self createTextFieldWithFrame:NSMakeRect(45, 0, [tableColumn width], CZ_ROW_HEIGHT/2-3)];
        [leftDetailTextField setCell:detailCell];

        // Add a folder-image to the far right,
        // if the item is not already compressed.
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, CZ_ROW_HEIGHT)];
        [imageView setTag:row+200];
        if (![item isArchived]) {
            [imageView setImage:[NSImage imageNamed:@"NSFolder"]];
        } else {
            [imageView setImage:[self updateImageForItem:item atRow:row isCached:YES]];
        }
        
        [cellView addSubview:leftDetailTextField];
        [cellView addSubview:leftTextField];
        [cellView addSubview:imageView];
    } else {
        // Add status indicator at far left for
        // displaying the compression status of
        // the current item.
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        if ([[[self archiveItems] objectAtIndex:row] isArchived]) {
            [imageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        } else {
            [imageView setImage:[NSImage imageNamed:@"NSStatusNone"]];
        }

        [imageView setTag:row+300];
        [cellView addSubview:imageView];
        [self updateCount];
    }

    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self archiveItems] count];
}

// Sets the height of the row;
// CZ_ROW_HEIGHT.
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return CZ_ROW_HEIGHT;
}

// Returns a textField with
// specified frame.
- (NSTextField *)createTextFieldWithFrame:(NSRect)frame {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setBordered:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setAllowsEditingTextAttributes:NO];
    [textField setSelectable:NO];

    return textField;
}

// Returns a simple cell for
// use in the table view.
- (CZCell *)createCell {
    CZCell *cell = [[CZCell alloc] init];
    [cell setSelectable:NO];
    [cell setEditable:NO];
    [cell setLineBreakMode:NSLineBreakByTruncatingMiddle];

    return cell;
}

#pragma mark DELEGATE METHODS

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)archiveItems {
    int state = CZ_APP_STATE_START;
    // Check if compressor already has a items
    // in the list, or if it is the first filedrop.
    if ([[self archiveItems] count] > 0) {
        // Set the label to "Loading..." and show
        // the progress indicator spinning.
        [self updateTopLabel:@"Loading..." andShowProgressIndicator:YES];
        // Remove progress indicator and reenable
        // the compression button.
        [self showProgressIndicator:NO];
        [[self buttonCompress] setEnabled:YES];
        state = CZ_APP_STATE_FILEDROP;
    } else {
        // The first filedrop
        state = CZ_APP_STATE_FILEDROP_FIRST;
    }
    
    [self addObjectsToArchiveItemsFromArray:archiveItems];
    // If there are items in the array then
    // call drawUIElements: to create and/or
    // populate the table view.
    if ([[self archiveItems] count] > 0) {
        [self drawUIElements:state];
    }
}
// Invoked when folder is dragged on to view,
// checks if the list already has that item.
- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    NSUInteger itemInArray = [[self archiveItems] indexOfObjectPassingTest:
                              ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                  BOOL found = [[obj description] isEqualToString:description];
                                  return found;
                              }];
    // Check if the dragged item is not
    // already in the array archiveItems.
    if (itemInArray == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isDropViewFront {
    if ([self applicationState] == CZ_APP_STATE_START) {
        return YES;
    } else {
        [[self scrollView] toggleHighlight];
    }
    
    return NO;
}

// Invoked when tableview
// registers keyup event.
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode {
    [self handleKeyEvent:keyCode commandPressed:NO];
}

- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode withCommand:(BOOL)commandState {
    [self handleKeyEvent:keyCode commandPressed:YES];
}

- (void)openItemInFinder:(NSIndexSet *)indexSet {
    NSArray *array = [[[self archiveItems] objectsAtIndexes:indexSet] valueForKey:@"fileURL"];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:array];

}

// Invoked when the compression has started
// by each of the items, setting the status
// image at right to yellow, indicating that
// the process has started.
- (void)compressionDidStart:(CZArchiverItem *)archiver {
    // It is not allowed to drag more items
    // to the queue when process is running,
    // so turn of that function.
    if ([[self view] isDraggable]) {
        [[self view] setDraggable:NO];
    }
    // Run the items compression methods
    // and let user know process is under way.
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        NSInteger row = [[self archiveItems] indexOfObject:archiver];
        NSImageView *imageView = [[self view] viewWithTag:row+300];
        [imageView setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
    });
}

// Invoked when process ended, setting status image
// to green, and the changing folder image to the
// cover image from the archive.
- (void)compressionDidEnd:(CZArchiverItem *)archiver {
    // Get the row where the item is and fetch the
    // image view to the right.
    NSInteger row = [[self archiveItems] indexOfObject:archiver];
    NSImageView *imageView = [[self view] viewWithTag:row+300];
    // Make sure it's status has not already changed;
    // Important because the archiver sometimes sends
    // this messages twice.
    if (![[imageView image] isEqualTo:[NSImage imageNamed:@"NSStatusAvailable"]]) {
        // Change the status to done (green light), and increment count of number of items compressed.
        [imageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        self.numberOfItemsCompressed++;
        // Increment badge count.
        if ([self shouldDisplayBadgeCount] && [self applicationIsResigned]) {
            [self controlApplicationBadge:CZ_APP_STATE_BADGE_INCREMENT];
        }
        // Fetch the image view to the left and set the image to cover from the archive.
        imageView = [[self view] viewWithTag:row+200];
        [imageView setImage:[self updateImageForItem:archiver atRow:row isCached:NO]];
    }
    // If all items in queue have been compressed,
    // then the process is finished. Notify user.
    // BUG FIX: Changed [[self archiveItems] count]) to self.numberOfItemsCompress
    if ([self numberOfItemsCompressed] == self.numberOfItemsToCompress) {
        // Should the folders be deleted after compression?
        if ([self shouldDeleteFoldersAfterCompress]) {
            [self deleteFolders];
        } else {
            [self skipDeletion];
        }
        // Remove progress indicator and reenable drag function again.
        [self updateTopLabel:[NSString stringWithFormat:@"%i files compressed!", self.numberOfItemsCompressed] andShowProgressIndicator:NO];
        [[self view] setDraggable:YES];
        
        // Reset count
        self.totalSizeInBytes = 0.0;
        self.numberOfItemsCompressed = 0;
        
        // Notify user if app is in background
        if ([self applicationIsResigned] && [self shouldNotify]) {
            [self displayNotification:@"Compression process completed!"];
        }
    }
}

// Invoked when the compressor encountered an error.
- (void)compressionCouldNotFinish:(CZArchiverItem *)archiver errorCode:(NSString *)string {
    NSInteger row = [[self archiveItems] indexOfObject:archiver]+1;
    NSImageView *imageView = [[self view] viewWithTag:row];
    [imageView setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
    // ERROR HANDLING?
}

// Invoked if archiver is set to delete folders
// after the compression process and has done so.
- (void)archiverDidRemoveDirectory:item {
}

#pragma mark FOLDER DELETION METHODS

// Invoked if the delete folders after
// compression option is set.
- (void)deleteFolders {
    for (int i=0; i<[[self archiveItems] count]; i++) {
        if ([[[self archiveItems] objectAtIndex:i] isArchived] &&
            ![[[self archiveItems] objectAtIndex:i] shouldSkipRemoval]) {
            [[[self archiveItems] objectAtIndex:i] removeDirectory];
        }
    }
}
// Invoked if the deleted folders after compression option is not set.
// This guarantees that folders of already compressed items do not get
// deleted when a new batch of folders are loaded, and the to delete-option
// then is changed.
- (void)skipDeletion {
    for (id item in [self archiveItems]) {
        if (![item shouldSkipRemoval]) {
            [item shouldSkipRemoval:YES];
        }
    }
}

#pragma mark CACHE DIRECTORY METHODS

// Sets the cache directory
// while app is loading.
- (void)setCacheDirectory:(NSString *)cacheDirectory {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    _cacheDirectory = [NSString stringWithFormat:@"%@/%@", directory, cacheDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self cacheDirectory]
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
}

// Deletes the cache directory
// before app terminates.
- (void)clearCacheDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self cacheDirectory] error:nil];
    }
}

#pragma mark FINDER METHODS
// Invoked after launch; check
// if there is a selection set.
- (BOOL)hasSelection {
    self.selection = [self removeNonFoldersFromSelection:[[[self finder] selection] get]];
    int selectionCount = (unsigned)(long)[[self selection] count];
    if (selectionCount) {
        return YES;
    }
    
    return NO;
}

// Check so that the selection only contains
// folders. Remove non-folders if necessary.
- (SBElementArray *)removeNonFoldersFromSelection:(SBElementArray *)selection {
    NSMutableArray *nonFolderArray = [NSMutableArray array];
    
    for (FinderFolder *folder in selection) {
        if (![[folder kind] isEqualToString:@"Folder"]) {
            [nonFolderArray addObject:folder];
        }
    }
    
    [selection removeObjectsInArray:nonFolderArray];
    
    return selection;
}

// Create CZArchiverItem objects
// from the selected folders, return
// as array.
- (NSArray *)getSelectionAsArray {
    NSMutableArray *folders = [NSMutableArray array];
    
    for (FinderFolder *folder in [self selection]) {
        CZArchiverItem *item = [[CZArchiverItem alloc] initWithSelection:folder];
        [folders addObject:item];
    }
    
    return [folders copy];
}

#pragma mark MISC METHODS
// Convert the file size from bytes to proper format.
- (NSString *)stringFromByte:(double)fileSize {
    NSString *size = [NSByteCountFormatter stringFromByteCount:fileSize
                                                    countStyle:NSByteCountFormatterCountStyleFile];
    return size;
}

// Invoked for compressed items in the list, fetching
// the cover image from the archive to be displayed.
- (NSImage *)updateImageForItem:(CZArchiverItem *)archiver atRow:(NSInteger)row isCached:(BOOL)cached {
    // Fetch the contents of the folder
    // and search for the first image (which
    // usually is the cover image).
    NSData *data;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [self cacheDirectory], [archiver description]];
    if (!cached) {
        NSArray *contentsArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[archiver path] error:nil];
        NSUInteger index = [contentsArray indexOfObjectPassingTest:
                            ^(id obj, NSUInteger idx, BOOL *stop) {
                                BOOL found = ([obj hasSuffix:@"jpg"] || [obj hasSuffix:@"jpeg"] || [obj hasSuffix:@"gif"] || [obj hasSuffix:@"png"]);
                                return found;
                            }];
        // Create an NSURL object from the path
        // and create the image to be sent back.
        NSString *path = [NSString stringWithFormat:@"%@/%@", [archiver path], [contentsArray objectAtIndex:index]];
        data = [NSData dataWithContentsOfFile:path];
        [data writeToFile:cachePath options:NSDataWritingAtomic error:nil];
    } else {
        data = [NSData dataWithContentsOfFile:cachePath];
    }
    
    return [[NSImage alloc] initWithData:data];
}

// Controls the badge label
- (void)controlApplicationBadge:(int)state {
    NSString *badgeLabel = nil;
    if (state == CZ_APP_STATE_BADGE_INCREMENT) {
        // Increment the badge count
        self.badgeCount++;
        // If the application is not in front
        // badge the dock icon.
        if ([self applicationIsResigned]) {
            badgeLabel = [NSString stringWithFormat:@"%i", [self badgeCount]];
        }
        // Reset the badge count
    } else if ([self badgeCount]) {
        self.badgeCount = 0;
    }
    // Update the badge
    [self setApplicationBadgeLabel:badgeLabel];
}

// Do some clean up after
// launch.
- (void)cleanUpAfterLaunch {
    self.finder = nil;
    self.selection = nil;
}

- (void)handleKeyEvent:(int)keyCode commandPressed:(BOOL)commandState {
    // If key is backspace then
    // delete selected objects.
    if (keyCode == CZ_KEY_DELETE) {
        NSIndexSet *rows = [[self tableView] selectedRowIndexes];
        // Check so that there are
        // rows in selection.
        if ([rows count]) {
            // Remove the object(s) and
            // reload table view.
            NSArray *array = [[self archiveItems] objectsAtIndexes:rows];
            [self removeObjectsInArchiveItemsFromArray:array];
            [[self tableView] reloadData];
            // Should set the selection if there
            // are anymore objects in queue.
            if ([[self archiveItems] count]) {
                NSIndexSet *indexSet;
                NSUInteger firstSelectedRow = [rows firstIndex];
                // If the row is not the first one...
                if (firstSelectedRow > 0) {
                    // ... and not the last one.
                    if ([[self archiveItems] count]-1 >= firstSelectedRow) {
                        indexSet = [[NSIndexSet alloc] initWithIndex:firstSelectedRow];
                    } else {
                        // Otherwise, set selection to the row before.
                        indexSet = [[NSIndexSet alloc] initWithIndex:firstSelectedRow-1];
                    }
                } else {
                    indexSet = [[NSIndexSet alloc] initWithIndex:0];
                }
                // Sets selection
                [[self tableView] selectRowIndexes:indexSet byExtendingSelection:NO];
            } else {
                // If there are not any more objects
                // in queue, then redraw window.
                [[self buttonCompress] removeFromSuperview];
                [[self tableView] removeFromSuperview];
                [[self scrollView] removeFromSuperview];
                [[[self view] viewWithTag:101] removeFromSuperview];
                self.buttonCompress = nil;
                self.tableView = nil;
                self.scrollView = nil;
                [self drawUIElements:CZ_APP_STATE_START];
            }
        }
    } else if (keyCode == 0 && commandState) {
        NSRange range = NSMakeRange(0, [[self archiveItems] count]);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [[self tableView] selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

- (double)calculateSizeOfItemsInArray:(NSArray *)array {
    long double size = 0.0;
    
    for (CZArchiverItem *item in array) {
        if (![item isArchived]) {
            size += [item fileSizeInBytes];
        }
    }
    return size;
}

- (void)removeObjectsInArchiveItemsFromArray:(NSArray *)array {
    [[self archiveItems] removeObjectsInArray:array];
    self.totalSizeInBytes = self.totalSizeInBytes - [self calculateSizeOfItemsInArray:array];
}

- (void)addObjectsToArchiveItemsFromArray:(NSArray *)array {
    [[self archiveItems] addObjectsFromArray:array];
    long double X = [self calculateSizeOfItemsInArray:array];
    self.totalSizeInBytes = self.totalSizeInBytes + X;
}

- (void)updateCount {
    NSString *label = @"";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == NO"];
    self.numberOfItemsToCompress = (int)[[[self archiveItems] filteredArrayUsingPredicate:predicate] count];
    
    if ([self numberOfItemsToCompress]) {
        label = [NSString stringWithFormat:@"%i file(s) to compress (%@).", [self numberOfItemsToCompress], [self stringFromByte:self.totalSizeInBytes]];
    }
    
    [self updateTopLabel:label andShowProgressIndicator:NO];
}

- (void)displayNotification:(NSString *)text {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:self.window.title];
    [notification setInformativeText:text];
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end