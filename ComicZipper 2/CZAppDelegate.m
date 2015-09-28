//
//  CZAppDelegate.m
//  ComicZipper 2
//
//  Created 15/07/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//
//  2.1.1 CHANGES:  √ Ability to auto add folders on start from Finder selection.
//  2.1.2 CHANGES:  √ Window is now resizeable.
//                  √ Added support for highlighting multple items in queue list with mouse/shift.
//                  √ Added support for highlighting all items in queue list with CMD+A.
//                  √ Changes made in preferences does not require app reboot. Reflects instantly.
//                  √ Added: Notifications, contextual menu with options to remove or open items in Finder.
//                  √ Bug fixes: The count is now correct. And hopefully the Zero KB bug is solved.
//  2.1.4 CHANGES:  √ Support for OS X 10.10.
//  2.1.5 CHANGES:  √ Changed file format from CBR to CBZ.
//                  √ Fixed the alert sound invoked upon keystroke.
//                  √ Fixed the bug where the app remains in a "compressing" state.
//  2.2.0 CHANGES:  √ Files can now be added by drag and drop on app icon.
//                  √ Removed support for adding files by selection on launch.
//  2.3.0 CHANGES:  √ File cleaning support added.
//  2.3.1 CHANGES:  √ Fixed errors caused by references to old files.
//  2.3.2 CHANGES:  √ All compression processes are now run in the same thread, separate from the main thread, making it a little slower but more reliable and less prone to crash or app freezing.
//                  √ The compress button is disabled while app is calculating the file sizes, fixing the Zero KB bug. This also fixes the bug that made the app crash or behave unexpected if the compress process is started before all the files have been added, loaded and calculated.
//  2.3.3 CHANGES:  √ Removed generic annotation, that only XCode 7 supports.
//  2.3.4 CHANGES:  √ File exclusion is now more reliable.
//                  √ Added error handling when compression fails (should fix issues with infinite progress spinners).
//                  √ Folders already processed can now be re-added to the list.
//                  √ Added sound notification when process is done also for when the app is in focus (and the option is set).

#import "CZAppDelegate.h"
#import "CZDropView.h"
#import "CZArchiverItem.h"
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
@property (nonatomic) NSMutableArray *archiveItems;
@property (nonatomic) NSMutableDictionary *preferences;
@property (nonatomic) long double totalSizeInBytes;
@property (nonatomic) int numberOfItemsCompressed, numberOfItemsFailed, numberOfItemsToCompress, badgeCount, applicationState;
@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic, getter = applicationIsResigned) BOOL applicationResigned;
@property (nonatomic, readonly) BOOL shouldDisplayBadgeCount, shouldDeleteFoldersAfterCompress, shouldNotify;
@property (nonatomic, readonly) NSString *filesToIgnore;
@property (nonatomic) FinderApplication *finder;
@property (nonatomic) SBElementArray *selection;

/*!
 @brief Initial setup method.
 @discussion Specifies a delegate for NSUserNotificationCenter, loads application preferences, sets the cache directory, initializes the archive items array and the Finder object.
 */
- (void)initialSetup;

/*!
 @brief Loads user's preferences.
 @discussion Loads the user preferences from the .plist file.
 @param preferences An NSDictionary object containing contents of .plist file.
 */
- (void)loadPreferences:(NSDictionary *)preferences;

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames;

- (void)applicationWillFinishLaunching:(NSNotification *)notification;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)applicationDidBecomeActive:(NSNotification *)notification;

- (void)applicationDidResignActive:(NSNotification *)notification;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;

- (void)applicationWillTerminate:(NSNotification *)notification;

/*!
 @brief Adds badge to application icon.
 @discussion Adds a alphanumerical badge to the application dock icon.
 @param label The badge value.
 */
- (void)setApplicationBadgeLabel:(NSString *)label;

/*!
 @brief Invoked when compress button is pressed.
 @discussion This method is invoked when the compress button is pressed, starting the compression process.
 @param sender The invoking button.
 */
- (void)buttonCompress:(id)sender;

/*!
 @brief Generate the user interface
 @discussion Generate the UI elements, depending on which state the app is in.
 @param applicationState Takes three different constants: CZ_APP_STATE_START, CZ_APP_STATE_FILEDROP_FIRST, CZ_APP_STATE_FILEDROP.
 */
- (void)drawUIElements:(int)applicationState;

/*!
 @brief Create constraints for the UI elements.
 @param firstItem The view for the left side of the constraint.
 @param secondItem The view for the right side of the constraint
 @param attribute The attribute of the view for the right and left side of the constraint.
 @param constant The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
 @return A constraint object relating the two provided views with the specified relation, attributes, multiplier, and constant.
 */
- (NSLayoutConstraint *)constraintWithItem:(id)firstItem toItem:(id)secondItem withAttribute:(NSLayoutAttribute)attribute andConstant:(float)constant;

/*!
 @brief Toggle progress indicator.
 @discussion Toggle the progress indicator (spinner) displayed at the top of the application.
 @param state A @a YES value will create the spinner and start the animation. @a NO will remove the indicator.
 */
- (void)showProgressIndicator:(BOOL)state;

/*!
 @brief Update status label.
 @discussion Update the status label at top of the application, and toggle the progress indicator.
 @param label Status label value.
 @param progress @a YES will start the spinner.
 */
- (void)updateTopLabel:(NSString *)label andShowProgressIndicator:(BOOL)progress;

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;

/*!
 @brief Create an NSTextField.
 @discussion Returns an NSTextField object with specified frame.
 @param frame The frame of the object.
 @return A new instance of NSTextField.
 */
- (NSTextField *)createTextFieldWithFrame:(NSRect)frame;

/*!
 @brief Create a table cell.
 @discussion Create a simple cell for the table view.
 @return A simple CZCell (NSCell).
 */
- (CZCell *)createCell;

/*!
 @brief Add dragged files to the table view.
 @discussion Delegate method for @b CZDropView when file(s) are dropped.
 @param CZDropView The view that sent the message.
 @param archiveItems An array containing the items dropped.
 */
- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)archiveItems;

/*!
 @brief Check if a item is already added to the list.
 @discussion Asks the delegate if the dragged item already is added to the list.
 @param CZDropView The view that sent the message.
 @param description Name of the item.
 @return @a YES, if the item is added.
 */
- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description;

/*!
 @brief Check if view is in focus.
 */
- (BOOL)isDropViewFront;

/*!
 @brief Informs the receiver that the user has released a key.
 @discussion Delegate method for CZTableView (NSTableView).
 @param CZTableView The table view sending the message.
 @param keyCode The key code for the keyboard key released.
 */
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode;

/*!
 @brief Informs the receiver that the user has released a key.
 @discussion Delegate method for CZTableView (NSTableView).
 @param CZTableView The table view sending the message.
 @param keyCode The key code for the keyboard key released.
 @param commandState If the Command key is pressed.
 */
- (void)tableView:(CZTableView *)tableView DidRegisterKeyUp:(int)keyCode withCommand:(BOOL)commandState;

/*!
 @brief Show item in Finder.
 @discussion Delegate method for CZTableView (NSTableView).
 @param indexSet The row index of the selected item(s).
 */
- (void)openItemInFinder:(NSIndexSet *)indexSet;

/*!
 @brief Informs the receiver the compression process has started.
 @discussion Invoked when a CZArchiverItem has begun compression process.
 @param archiver The CZArchiverItem that sent the message.
 */
- (void)compressionDidStart:(CZArchiverItem *)archiver;

/*!
 @brief Informs the receiver the compression has stopped.
 @discussion Invoked when compression of CZArchiverItem is finished.
 @param archiver The CZArchiverItem that sent the message.
 */
- (void)compressionDidEnd:(CZArchiverItem *)archiver;

/*!
 @brief Informs the receiver an error occured while compressing.
 @discussion Invoked when compression of CZArchiverItem has failed.
 @param archiver The CZArchiverItem that sent the message.
 @param string The error code.
 */
- (void)compressionCouldNotFinish:(CZArchiverItem *)archiver errorMessage:(NSString *)string;

/*!
 @brief Informs the receiver a directory has been deleted.
 @discussion Invoked when a CZArchiverItem has removed it's original directory.
 @param archiver The CZArchiverItem that sent the message.
 */
- (void)archiverDidRemoveDirectory:(CZArchiverItem *)archiver;

/*!
 @brief Delete folders.
 @discussion Invoked after compression process has finished, if the delete folders option is set.
 */
- (void)deleteFolders;

/*!
 @brief Invoked if the deleted folders after compression option is not set.
 @discussion Guarantees that folders of already compressed items do not get deleted when a new batch of folders are loaded, and the to delete-option then is changed.
 */
- (void)skipDeletion;

/*!
 @brief Set the cache directory.
 @discussion Runs upon app launch.
 @see initialSetup
 @param cacheDirectory The path to the cache directory.
 */
- (void)setCacheDirectory:(NSString *)cacheDirectory;

/*!
 @brief Empties the cache directory.
 @discussion Invoked before application terminates.
 @see initialSetup, setCacheDirectory
 */
- (void)clearCacheDirectory;

/*!
 @brief The selection in the frontmost Finder window.
 @discussion Get the selected folders in the frontmost Finder window.
 @return @a YES, if a selection is set.
 */
- (BOOL)hasSelection;

/*!
 @brief Removes all non-folders from selection.
 @param selection The selection in the frontmost Finder window.
 @return An SBElementArray object containing the selected folders.
 */
- (SBElementArray *)removeNonFoldersFromSelection:(SBElementArray *)selection;

/*!
 @brief Converts the selection to an array.
 @discussion Create CZArchiverItem objects from the selected folders and adds to an array to be returned.
 @return Array containing CZArchiverItems.
 */
- (NSArray *)getSelectionAsArray;

/*!
 @brief Checks if all items have been processed.
 @return @a YES if the process is finished.
 */
- (BOOL)hasProcessFinished;

/*!
 @brief Post compression operation.
 @discussion Invoked after all the items have been processed.
 */
- (void)processFinished;

/*!
 @brief Converts file size from bytes.
 @param fileSize The size of a file in bytes.
 @return The size of a file converted to a human-readable value.
 */
- (NSString *)stringFromByte:(double)fileSize;

/*!
 @brief Fetch cover image for compressed items.
 @discussion Fetches the folder image for the first image in the compressed folder.
 @param archiver The compressed item.
 @param row Row index of the item.
 @param cached If image has already been cached.
 @return The cover image.
 */
- (NSImage *)updateImageForItem:(CZArchiverItem *)archiver atRow:(NSInteger)row isCached:(BOOL)cached;

/*!
 @brief Control badge label.
 @param state State of the application.
 */
- (void)controlApplicationBadge:(int)state;

/*!
 @brief Clean up after launch.
 */
- (void)cleanUpAfterLaunch;

/*!
 @brief Handles the key events.
 @discussion Deletes items.
 @param keyCode The key code.
 @param commandState If the command key is pressed.
 */
- (void)handleKeyEvent:(int)keyCode commandPressed:(BOOL)commandState;

/*!
 @brief Calculates the total size of the items in the list.
 @param array The items.
 @return Size of the files in bytes.
 */
- (double)calculateSizeOfItemsInArray:(NSArray *)array;

/*!
 @brief Remove objects from the archiveItems array.
 @discussion Recalculates the size of the remaining objects.
 @see calculateSizeOfItemsInArray:.
 @param array The items to remove.
 */
- (void)removeObjectsInArchiveItemsFromArray:(NSArray *)array;

/*!
 @brief Adds objects from the archiveItems array.
 @discussion Recalculates the size of the objects.
 @see calculateSizeOfItemsInArray:.
 @param array The items to add.
 */
- (void)addObjectsToArchiveItemsFromArray:(NSArray *)array;

/*!
 @brief Update the number of items to compress.
 */
- (void)updateCount;

/*!
 @brief Update the status label after calculations.
 @see updateTopLabel:andShowProgressIndicator:
 */
- (void)countReady;

/*!
 @brief Display a notification.
 @discussion Displays a notification, if the user has enabled it and the app is out of focus.
 @param text The label to display in the notification.
 */
- (void)displayNotification:(NSString *)text;

@end

@implementation CZAppDelegate

#pragma mark INITIAL SETUP

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
    _filesToIgnore = [preferences valueForKey:@"CZIgnoreFiles"];
}

#pragma mark APPLICATION DELEGATE METHODS

- (void)application:(NSApplication *)sender openFiles:(nonnull NSArray *)filenames {
    // Catch items dropped on the application dock icon.
    // Set up the folders array that will be added to the item list
    NSMutableArray *folders = [NSMutableArray array];
    for (NSString *folder in filenames) {
        BOOL isDir;
        // Check if the dropped file is a directory
        if ([[NSFileManager alloc] fileExistsAtPath:folder isDirectory:&isDir] && isDir) {
            // Get the fileURL and create an Archiver Item.
            NSURL *url = [NSURL fileURLWithPath:folder isDirectory:YES];
            CZArchiverItem *item = [[CZArchiverItem alloc] initWithURL:url];
            // Check if the dragged item is already in the archiveItems array.
            NSUInteger itemInArray = [[self archiveItems] indexOfObjectPassingTest:
                                      ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                          BOOL found = [[obj description] isEqualToString:[item description]];
                                          return found;
                                      }];
            if (itemInArray == NSNotFound) {
                [folders addObject:item];
            }
        }
    }
    // Add it to the drop view
    if ([folders count] > 0) {
        [self dropView:[self view] didReceiveFiles:folders];
    }
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    // Run initial setup upon launch
    [self initialSetup];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Check after launch if there any items where already loaded (dragged onto the dock icon)
    if ([[self archiveItems] count] > 0) {
        [[self view] setDelegate:self];
        [[self view] setDraggable:YES];
    } else {
        [self drawUIElements:CZ_APP_STATE_START];
    }
    
    [self cleanUpAfterLaunch];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
    // Application loses focus.
    [self setApplicationResigned:YES];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Application is active again (in front), reset the badge if displayed.
    [self setApplicationResigned:NO];
    if ([self shouldDisplayBadgeCount]) {
        [self controlApplicationBadge:CZ_APP_STATE_BADGE_RESET];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // Called during termination. Clear cache directory.
    [self clearCacheDirectory];
}

- (void)setApplicationBadgeLabel:(NSString *)label {
    [[NSApp dockTile] setBadgeLabel:label];
}

#pragma mark BUTTON METHODS

- (void)buttonCompress:(id)sender {
    // Update label to let user know compression is in progress.
    [self updateTopLabel:@"Compressing" andShowProgressIndicator:YES];
    // Run the compression in another thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        for (CZArchiverItem *item in [self archiveItems]) {
            // Do not compress already archived items.
            if (![item isArchived]) {
                [item setFilesToIgnore:[self filesToIgnore]];
                [item setDelegate:self];
                [item startCompression];
            }
        }
    });
    // Disable button while compressing.
    [sender setEnabled:NO];
}

- (IBAction)buttonPreferences:(id)sender {
    if ([[self drawer] state] == NSDrawerClosedState ||
        [[self drawer] state] == NSDrawerClosingState) {
        NSSize drawerSize = {270,300};
        [[self drawer] setMaxContentSize:drawerSize];
        [[self drawer] setContentSize:drawerSize];
        [[self drawer] open];
        [[self checkBoxDeleteFolders] setState:_shouldDeleteFoldersAfterCompress];
        [[self checkBoxCompressedCount] setState:_shouldDisplayBadgeCount];
        [[self checkBoxNotify] setState:_shouldNotify];
        [[self textFieldIgnoreFiles] setStringValue:_filesToIgnore];
    } else {
        [self setPreferencesKey:[[self textFieldIgnoreFiles] identifier] ToValue:[[self textFieldIgnoreFiles] stringValue] ];
        [[self drawer] close];
    }
}

- (IBAction)checkBoxClicked:(id)sender {
    NSNumber *checkValue = [NSNumber numberWithBool:YES];
    if ([sender state] != NSOnState) {
        checkValue = @NO;
    }
    [self setPreferencesKey:[sender identifier] ToValue:checkValue];
}

- (void)setPreferencesKey:(NSString *)key ToValue:(id)value {
    [[self preferences] setValue:value forKey:key];
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
        [self.buttonCompress setEnabled:NO];
        
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

- (void)showProgressIndicator:(BOOL)state {
    if (state) {
        // Start the animation.
        CGSize viewSize = self.view.frame.size;
        NSProgressIndicator *progressIndicatorSpinning = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(viewSize.width/3-5, viewSize.height-27, 16, 16)];
        self.progressIndicator = progressIndicatorSpinning;
        [[self progressIndicator] setStyle:NSProgressIndicatorSpinningStyle];
        [[self progressIndicator] setControlSize:NSSmallControlSize];
        [[self progressIndicator] startAnimation:self];
        [[self view] addSubview:[self progressIndicator]];
        // Add constraints to indicator for autolayout.
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
        // Remove the indicator and set property to nil.
        [[self progressIndicator] removeFromSuperview];
        self.progressIndicator = nil;
    }
}

- (void)updateTopLabel:(NSString *)label andShowProgressIndicator:(BOOL)progress {
    [[[self view] viewWithTag:101] setStringValue:label];
    [self showProgressIndicator:progress];
}

#pragma mark USER INTERFACE METHODS: TABLEVIEW

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Populate the table view with items in array archiveItems.
    NSTableCellView *cellView = [[NSTableView alloc] makeViewWithIdentifier:@"cellView" owner:self];
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableView.frame.size.width, 35)];
        cellView.identifier = @"cellView";
    }
    
    CZArchiverItem *item = [[self archiveItems] objectAtIndex:row];
    
    if ([[tableColumn identifier] isEqualToString:@"leftColumn"]) {
        // Get the name of the item that will occupy the cell and the size of the item in bytes and
        // convert it to a readable number to be displayed in the subtitle cell.
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
        [leftDetailTextField setTag:row+400];
        // Add a folder-image to the far right, if the item is not already compressed.
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, CZ_ROW_HEIGHT)];
        [imageView setTag:row+200];
        if (![item isArchived]) {
            [imageView setImage:[NSImage imageNamed:@"NSFolder"]];
        } else {
            NSImage *image = [self updateImageForItem:item atRow:row isCached:YES];
            if (image) {
                [imageView setImage:image];
            }
        }
        [cellView addSubview:leftDetailTextField];
        [cellView addSubview:leftTextField];
        [cellView addSubview:imageView];
    } else {
        // Add status indicator at far left for displaying the compression status of the current item.
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 35, 35)];
        if ([[[self archiveItems] objectAtIndex:row] isArchived]) {
            [imageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        } else {
            [imageView setImage:[NSImage imageNamed:@"NSStatusNone"]];
        }
        [imageView setTag:row+300];
        [cellView addSubview:imageView];
        [self updateCount];
        if ([self numberOfItemsToCompress] == row + 1) {
            [self countReady];
        }
    }

    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self archiveItems] count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    // Sets the height of the row to CZ_ROW_HEIGHT.
    return CZ_ROW_HEIGHT;
}

- (NSTextField *)createTextFieldWithFrame:(NSRect)frame {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setBordered:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setAllowsEditingTextAttributes:NO];
    [textField setSelectable:NO];
    return textField;
}

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
    // Check if compressor already has a items in the list, or if it is the first filedrop.
    if ([[self archiveItems] count] > 0) {
        // Show indication that items are loading
        [self updateTopLabel:@"Loading..." andShowProgressIndicator:YES];
        // Remove progress indicator and reenable the compress button.
        [self showProgressIndicator:NO];
        [[self buttonCompress] setEnabled:YES];
        state = CZ_APP_STATE_FILEDROP;
    } else {
        // First filedrop event
        state = CZ_APP_STATE_FILEDROP_FIRST;
    }
    // Add the items to the archiveItems array
    [self addObjectsToArchiveItemsFromArray:archiveItems];
    // If there are items in the array then call drawUIElements: to create and/or
    // populate the table view.
    if ([[self archiveItems] count] > 0) {
        [self drawUIElements:state];
    }
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    // Check if the dragged item is not already in the list (archiveItems)
    NSUInteger itemInArray = [[self archiveItems] indexOfObjectPassingTest:
                              ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                  // Already archived items can be added again
                                  if ([obj isArchived]) {
                                      return 0;
                                  } else {
                                      BOOL found = [[obj description] isEqualToString:description];
                                      return found;
                                  }
                              }];
    if (itemInArray == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isDropViewFront {
    if ([self applicationState] == CZ_APP_STATE_START) {
        return YES;
    }
    [[self scrollView] toggleHighlight];
    return NO;
}

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

- (void)compressionDidStart:(CZArchiverItem *)archiver {
    // It is not allowed to drag more items to the queue when process is running,
    // so turn of that function.
    if ([[self view] isDraggable]) {
        [[self view] setDraggable:NO];
    }
    // Run the items compression methods and let user know process is under way.
    NSInteger row = [[self archiveItems] indexOfObject:archiver];
    NSImageView *imageView = [[self view] viewWithTag:row+300];
    [imageView setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
}

- (void)compressionDidEnd:(CZArchiverItem *)archiver {
    // Get the row where the item is and fetch the image view to the right.
    NSInteger row = [[self archiveItems] indexOfObject:archiver];
    NSImageView *imageView = [[self view] viewWithTag:row+300];
    // Make sure it's status has not already changed. Important because the archiver sometimes sends this messages twice.
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
        NSImage *image = [self updateImageForItem:archiver atRow:row isCached:NO];
        if (image)
            [imageView setImage:image];
        // and printing out the name of the archive
        NSCell *detailCell = [[[self view] viewWithTag:row+400] cell];
        [detailCell setStringValue:[NSString stringWithFormat:@"Archived as: %@",  archiver.path]];
    }
    // If the compression is finished...
    if ([self hasProcessFinished]) {
        [self processFinished];
    }
}

- (void)compressionCouldNotFinish:(CZArchiverItem *)archiver errorMessage:(NSString *)errorMessage {
    // Notify the user an error has occured by changing the status light
    NSInteger row = [[self archiveItems] indexOfObject:archiver];
    NSImageView *imageView = [[self view] viewWithTag:row+300];
    [imageView setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
    // and printing out the error message below the item
    NSCell *detailCell = [[[self view] viewWithTag:row+400] cell];
    [detailCell setStringValue:[NSString stringWithFormat:@"An error occured: %@", errorMessage]];
    // Increment number of failed items
    self.numberOfItemsFailed++;
    // If the compression is finished...
    if ([self hasProcessFinished]) {
        [self processFinished];
    }
}

- (void)archiverDidRemoveDirectory:(CZArchiverItem *)archiver {
}

#pragma mark FOLDER DELETION METHODS

- (void)deleteFolders {
    for (int i=0; i<[[self archiveItems] count]; i++) {
        if ([[[self archiveItems] objectAtIndex:i] isArchived] &&
            ![[[self archiveItems] objectAtIndex:i] shouldSkipRemoval]) {
            [[[self archiveItems] objectAtIndex:i] removeDirectory];
        }
    }
}

- (void)skipDeletion {
    for (id item in [self archiveItems]) {
        if (![item shouldSkipRemoval]) {
            [item shouldSkipRemoval:YES];
        }
    }
}

#pragma mark CACHE DIRECTORY METHODS

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

- (void)clearCacheDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectory]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self cacheDirectory] error:nil];
    }
}

#pragma mark FINDER METHODS

- (BOOL)hasSelection {
    self.selection = [self removeNonFoldersFromSelection:[[[self finder] selection] get]];
    int selectionCount = (unsigned)(long)[[self selection] count];
    if (selectionCount) {
        return YES;
    }
    return NO;
}

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

- (NSArray *)getSelectionAsArray {
    NSMutableArray *folders = [NSMutableArray array];
    for (FinderFolder *folder in [self selection]) {
        CZArchiverItem *item = [[CZArchiverItem alloc] initWithSelection:folder];
        [folders addObject:item];
    }
    return [folders copy];
}

#pragma mark MISC METHODS

- (BOOL)hasProcessFinished {
    if ([self numberOfItemsCompressed] == ([self numberOfItemsToCompress] - [self numberOfItemsFailed])) {
        return YES;
    }
    return NO;
}

- (void)processFinished {
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
    // If user has selected to be notified
    if ([self shouldNotify]) {
        if ([self applicationIsResigned]) {
            // Then show the notification if app is out of focus
            [self displayNotification:@"Compression process completed!"];
        } else {
            // Otherwhise, just play the sound
            [[NSSound soundNamed:@"Glass"] play];
        }
    }
}

- (NSString *)stringFromByte:(double)fileSize {
    NSString *size = [NSByteCountFormatter stringFromByteCount:fileSize
                                                    countStyle:NSByteCountFormatterCountStyleFile];
    return size;
}

- (NSImage *)updateImageForItem:(CZArchiverItem *)archiver atRow:(NSInteger)row isCached:(BOOL)cached {
    // Retrieves the left side image to use for processed items (replacing the folder image).
    NSData *data;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", [self cacheDirectory], [archiver description]];
    if (cached) {
        // If caller indicates the image is cached, look in the cache directory first.
        data = [NSData dataWithContentsOfFile:cachePath];
        if (data) {
            return [[NSImage alloc] initWithData:data];
        }
    }

    // Do a deep enumeration of the directory to find the first image.
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:[archiver path]
                                                                                                            isDirectory:YES]
                                                                      includingPropertiesForKeys:nil
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    errorHandler:nil];
    // Iterate only until the file has been found.
    NSString *imagePath;
    for (NSURL *file in directoryEnumerator) {
        if ([[file pathExtension] isEqualToString:@"jpg"] ||
            [[file pathExtension] isEqualToString:@"gif"] ||
            [[file pathExtension] isEqualToString:@"png"] ||
            [[file pathExtension] isEqualToString:@"jpeg"]) {
            imagePath = [file path];
            break;
        }
    }
    // Make sure that an image was found
    if (!imagePath) {
        return nil;
    }
    // Retrieve the image and write to the cache directory
    data = [NSData dataWithContentsOfFile:imagePath];
    [data writeToFile:cachePath options:NSDataWritingAtomic error:nil];

    return [[NSImage alloc] initWithData:data];
}

- (void)controlApplicationBadge:(int)state {
    NSString *badgeLabel = nil;
    if (state == CZ_APP_STATE_BADGE_INCREMENT) {
        // Increment the badge count
        self.badgeCount++;
        // If the application is not in front badge the dock icon.
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

- (void)cleanUpAfterLaunch {
    self.finder = nil;
    self.selection = nil;
}

- (void)handleKeyEvent:(int)keyCode commandPressed:(BOOL)commandState {
    // If key is backspace then delete selected objects.
    if (keyCode == CZ_KEY_DELETE) {
        NSIndexSet *rows = [[self tableView] selectedRowIndexes];
        // Check that there are rows in selection.
        if ([rows count]) {
            // Remove the object(s) and reload table view.
            NSArray *array = [[self archiveItems] objectsAtIndexes:rows];
            [self removeObjectsInArchiveItemsFromArray:array];
            [[self tableView] reloadData];
            // Should set the selection if there are anymore objects in queue.
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
                // If there are not any more objects in queue, then redraw window.
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isArchived == NO"];
    self.numberOfItemsToCompress = (int)[[[self archiveItems] filteredArrayUsingPredicate:predicate] count];
}

- (void)countReady {
    NSString *label = @"";
    if ([self numberOfItemsToCompress]) {
        label = [NSString stringWithFormat:@"%i file(s) to compress (%@).", [self numberOfItemsToCompress], [self stringFromByte:self.totalSizeInBytes]];
    }
    [self updateTopLabel:label andShowProgressIndicator:NO];
    [[self buttonCompress] setEnabled:YES];
}

- (void)displayNotification:(NSString *)text {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:self.window.title];
    [notification setInformativeText:text];
//    [notification setSoundName:NSUserNotificationDefaultSoundName];
    [notification setSoundName:@"Glass"];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end