//
//  CZWindowController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 30/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//
//
#import "CZMainController.h"
#import "CZComicZipper.h"
#import "CZScrollView.h"
#import "CZTableView.h"
#import "CZDropView.h"
#import "CZDropItem.h"
#import "CZTableCellView.h"
#import "CZTextField.h"
#import <QuickLook/QuickLook.h>
#import <Quartz/Quartz.h>

@interface CZMainController () <NSWindowDelegate, CZComicZipperDelegate, CZDropViewDelegate, CZTableViewDelegate, NSTableViewDataSource, QLPreviewPanelDelegate, QLPreviewPanelDataSource>

@property (nonatomic) int applicationState;
@property (strong) CZComicZipper *comicZipper;
@property (strong) IBOutlet CZDropView *dropView;
@property (weak) CZScrollView *scrollView;
@property (weak) CZTableView *tableView;
@property (weak) NSButton *compressButton;
@property (strong) IBOutlet NSToolbarItem *toolbarClear;
@property (strong) IBOutlet NSToolbarItem *toolbarCancel;
@property (strong) IBOutlet NSToolbar *toolbar;
@property (nonatomic, weak) NSUserNotificationCenter *notificationCenter;
@property (nonatomic) long numberOfItemsToCompress, numberOfItemsCompressed;
@property (nonatomic) NSDictionary *applicationSettings;
@property (strong) IBOutlet NSImageView *imageView;

@end

int const kLabelTag = 101;

@implementation CZMainController

- (void)cancelAll:(id)sender {
    [[self comicZipper] cancelAll];
}

- (void)clearList:(id)sender {
    [[self comicZipper] clear];
    [self setApplicationState:CZApplicationStateNoItemDropped];
    [self updateUI];
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                          ComicZipper:(CZComicZipper *)comicZipper
                     applicationState:(int)applicationState
                  applicationSettings:(NSDictionary *)applicationSettings {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        [comicZipper setDelegate:self];
        _comicZipper = comicZipper;
        _applicationState = applicationState;
        _applicationSettings = applicationSettings;
        _numberOfItemsToCompress = 0;
        _numberOfItemsCompressed = 0;
    }
    
    return self;
}

- (void)updateApplicationSettings:(NSDictionary *)applicationSettings {
    [self setApplicationSettings:applicationSettings];
}

- (void)addItemsDraggedToDock:(NSArray *)items {
    NSMutableArray *validItems = [NSMutableArray array];
    __block BOOL failed = NO;
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isDir;
        // Check if the dropped file is a directory
        if ([[NSFileManager alloc] fileExistsAtPath:obj isDirectory:&isDir] && isDir) {
            // Get the fileURL and create a DropItem object.
            CZDropItem *item = [CZDropItem initWithURL:[NSURL fileURLWithPath:obj isDirectory:YES]];
            // Check if the dragged item is already in the archiveItems array.
            if (item != nil && ![self dropView:nil isItemInList:[obj description]]) {
                [validItems addObject:item];
            } else {
                failed = YES;
            }
        } else {
            failed = YES;
        }
    }];
    if ([validItems count]) {
        [self dropView:nil didReceiveFiles:validItems];
    }
    if (failed) {
        [self shakeWindow];
    }
}

- (void)windowDidLoad {
    [[self window] setDelegate:self];
    // Load the last saved state of application window
    NSRect frame = NSRectFromString([[self applicationSettings] objectForKey:CZSettingsWindowState]);
    if (!NSIsEmptyRect(frame)) {
        [[self window] setFrame:frame
                        display:YES];
    }
    [super windowDidLoad];
    [[self dropView] setDelegate:self];
    [[self dropView] setDragMode:YES];
    [self updateUI];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame {
//    CZTableCellView *rect = [[self tableView] viewAtColumn:1 row:0 makeIfNecessary:NO];
//    NSSize size = [[[rect textFieldTitle] stringValue] sizeWithAttributes:nil];
//    NSRect frame = NSMakeRect(0, 0, size.width+200, newFrame.size.height);
//    return frame;
    return newFrame;
}

- (void)updateUI {
    if ([self applicationStateIs:CZApplicationStateNoItemDropped]) {
        [[self window] setBackgroundColor:[NSColor whiteColor]];
        if ([self scrollView]) {
            [[self scrollView] removeFromSuperview];
            [self setScrollView:nil];
            [[self tableView] removeFromSuperview];
            [self setTableView:nil];
            [[self compressButton] removeFromSuperview];
            [self setCompressButton:nil];
            [[[self dropView] viewWithTag:kLabelTag] removeFromSuperview];
            [[self toolbar] removeItemAtIndex:1];
            [self resetCount];
        }
    } else if ([self applicationStateIs:CZApplicationStateFirstItemDrop]) {
        [[self window] setBackgroundColor:[NSColor controlHighlightColor]];
        [self addCompressButton];
        [self addLabelForTableView];
        [self addScrollView];
        [self addTableView];
        [[self toolbar] insertItemWithItemIdentifier:[[self toolbarClear] itemIdentifier] atIndex:1];
    } else if ([self applicationStateIs:CZApplicationStatePopulatedList]) {
        [[self tableView] reloadData];
    }
}

#pragma mark DELEGATE METHODS

- (void)dropView:(CZDropView *)dropView shouldToggleHighlight:(BOOL)highlight {
    if (highlight) {
        [[self imageView] setImage:[NSImage imageNamed:CZImageNameForHighlight]];
    } else {
        [[self imageView] setImage:[NSImage imageNamed:CZImageNameForNoHighlight]];
    }
}

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items {
    // Add dropped items to the array collection before updating user interface.
    [[self comicZipper] addItems:items];
    [self setNumberOfItemsToCompress:[[self comicZipper] count]];
    // First time drop should create the table.
    if ([self applicationStateIs:CZApplicationStateNoItemDropped]) {
        [self setApplicationState:CZApplicationStateFirstItemDrop];
    } else {
        [self setApplicationState:CZApplicationStatePopulatedList];
    }
    
    [self updateUI];
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    return [[self comicZipper] isItemInList:description];
}

- (BOOL)isDropViewFront {
    if ([self applicationStateIs:CZApplicationStateNoItemDropped]) {
        return YES;
    }
    // If the table is loaded, the drop view should not highlight. But the scrollview should!
    [[self scrollView] toggleHighlight];
    return NO;
}

- (void)openItemInFinder:(NSIndexSet *)rows {
    NSArray *items = [[[self comicZipper] itemsWithIndex:rows] valueForKey:@"fileURL"];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:items];
}

- (void)tableView:(CZTableView *)tableView
 DidRegisterKeyUp:(int)keyCode
     atRowIndexes:(NSIndexSet *)indexes
      withCommand:(BOOL)commandState {
    if (keyCode == kDeleteKey) {
        [[self comicZipper] removeItemsWithIndexes:indexes];
        [[self tableView] removeRowsAtIndexes:indexes
                                withAnimation:NO];
        if ([[self comicZipper] countAll]) {
            NSUInteger firstIndex = [indexes firstIndex];
            if (firstIndex >= [[self comicZipper] countAll]) {
                firstIndex--;
            }
            [[self tableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:firstIndex]
                          byExtendingSelection:NO];
            if ([self numberOfItemsToCompress]) {
                [self setNumberOfItemsToCompress:[self numberOfItemsToCompress]-[indexes count]];
                NSInteger count = [self numberOfItemsToCompress];
                [self updateLabelForTableView:[NSString stringWithFormat:@"%li item(s) to compress", count]];                
            }
        } else {
            [self setApplicationState:CZApplicationStateNoItemDropped];
            [self updateUI];
        }
    } else if (keyCode == 0 && commandState) {
        NSRange range = NSMakeRange(0, [[self tableView] numberOfRows]);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [[self tableView] selectRowIndexes:indexSet byExtendingSelection:NO];
    } else if (keyCode == 49) {
        [[QLPreviewPanel sharedPreviewPanel] orderFront:nil];
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableColumnHeight;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self comicZipper] countAll];
}

- (NSView *)tableView:(CZTableView *)tableView
   viewForTableColumn:(nullable NSTableColumn *)column
                  row:(NSInteger)row {
    CZTableCellView *cellView = [tableView makeViewWithIdentifier:[column identifier]
                                                            owner:self];
    if (cellView == nil) {
        NSRect frame = NSMakeRect(0, 0, [column width], kTableColumnHeight);
        cellView = [[CZTableCellView alloc] initWithFrame:frame];
        [cellView setIdentifier:@"RightCell"];
    } else {
        [cellView setWidth:[column width]];
    }
    CZDropItem *item = [[self comicZipper] itemWithIndex:row];
    if ([[column identifier] isEqualToString:@"ColumnLeft"]) {
        if ([item isArchived]) {
            NSImage *image = [self imageForItem:item];
            [cellView setImage:image];
        } else {
            [cellView setImage:[NSImage imageNamed:@"NSFolder"]];
        }
    } else if ([[column identifier] isEqualToString:@"ColumnMiddle"]) {
        [cellView setTitleText:[item description]];
        if ([item isArchived]) {
            [cellView setDetailText:[item archivePath]];
        } else if ([item isCancelled]) {
            [cellView setDetailText:@"Cancelled by user."];
        } else {
            [cellView setDetailText:[item fileSize]];
        }
    } else if ([[column identifier] isEqualToString:@"ColumnRight"]) {
        [cellView setIdentifier:[NSString stringWithFormat:@"%li", row]];
        if ([item isArchived]) {
            [cellView setStatus:CZStatusIconSuccess];
        } else if ([item isCancelled]) {
            [cellView setStatus:CZStatusIconError];
        } else {
            [cellView setStatus:CZStatusIconAbortNormal];
            [cellView setAction:@selector(cancelCompression:) forTarget:self];
        }
    }
        
    [cellView setNeedsDisplay:YES];
    
    return cellView;
}

- (void)tableView:(NSTableView *)tableView
    didAddRowView:(NSTableRowView *)rowView
           forRow:(NSInteger)row {
    // When the last row is added, the top label should be updated and the compression, if set up that way, start automatically.
    if ([self numberOfItemsToCompress] == row+1) {
        NSInteger count = [self numberOfItemsToCompress];
        [self updateLabelForTableView:[NSString stringWithFormat:@"%li item(s) to compress", count]];
        if ([self shouldAutoStartCompression]) {
            [self compressButton:[self compressButton]];
        } else {
            [[self compressButton] setEnabled:YES];
        }
    }
}

- (void)ComicZipper:(CZComicZipper *)comicZipper didStartItemAtIndex:(NSUInteger)index {
    // For performance issues reload only the specific row that needs updating.
    NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
    NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,3)];
    [[self tableView] reloadDataForRowIndexes:rowIndexes
                                columnIndexes:colIndexes];
    [self updateBadgeLabel];
}

- (void)ComicZipper:(CZComicZipper *)comicZipper didUpdateProgress:(float)progress ofItemAtIndex:(NSUInteger)index {
    CZTableCellView *cellView = [[self tableView] viewAtColumn:1
                                                           row:index
                                               makeIfNecessary:YES];
    [cellView setProgress:progress];
}

- (void)ComicZipper:(CZComicZipper *)comicZipper didFinishItemAtIndex:(NSUInteger)index {
    // For performance issues reload only the specific row that needs updating.
    NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
    NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,3)];
    [[self tableView] reloadDataForRowIndexes:rowIndexes
                                columnIndexes:colIndexes];
    [self updateCount];

}

- (void)ComicZipper:(CZComicZipper *)comicZipper didCancelItemAtIndex:(NSUInteger)index {
    NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
    NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,3)];
    [[self tableView] reloadDataForRowIndexes:rowIndexes
                                columnIndexes:colIndexes];
    [self updateCountWithCancel:YES];
}

#pragma mark DELEGATE AND DATA SOURCE METHODS FOR QUICKLOOK

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
    [[QLPreviewPanel sharedPreviewPanel] setDelegate:self];
    [[QLPreviewPanel sharedPreviewPanel] setDataSource:self];
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
    [[QLPreviewPanel sharedPreviewPanel] setDelegate:nil];
    [[QLPreviewPanel sharedPreviewPanel] setDataSource:nil];
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    return [[self comicZipper] countArchived];
}

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    CZDropItem *item = [[self comicZipper] itemWithIndex:index];
    NSURL *url = [self URLToImageForItem:item];
    [item setPreviewItemURL:url];
    return [[self comicZipper] itemWithIndex:index];
}

#pragma mark USER INTERACTION METHODS

- (void)cancelCompression:(id)sender {
    NSInteger index = [[sender identifier] integerValue];
    CZDropItem *item = [[self comicZipper] itemWithIndex:index];
    [item setCancelled:YES];
    if (![item isRunning]) {
        NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
        NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,3)];
        [[self tableView] reloadDataForRowIndexes:rowIndexes
                                    columnIndexes:colIndexes];
        if ([self numberOfItemsToCompress] > 0) {
            [self setNumberOfItemsToCompress:[self numberOfItemsToCompress]-1];
            NSInteger count = [self numberOfItemsToCompress];
            [self updateLabelForTableView:[NSString stringWithFormat:@"%li item(s) to compress", count]];
        }
    }
}

- (void)compressButton:(id)sender {
    [sender setEnabled:NO];
    NSString *label = [NSString stringWithFormat:@"0 out of %li item(s) compressed...", [self numberOfItemsToCompress]];
    [self updateLabelForTableView:label];
    // Add the ignored files before compressing
    NSArray *ignoredFiles = [self shouldIgnoreFiles];
    [[self comicZipper] ignoreFiles:ignoredFiles];
    [[self comicZipper] shouldIgnoreEmptyData:[self shouldIgnoreEmptyData]];
    [[self comicZipper] readyToCompress];
    [[self toolbar] removeItemAtIndex:1];
    [[self toolbar] insertItemWithItemIdentifier:[[self toolbarCancel] itemIdentifier]  atIndex:1];
}

- (void)updateLabelForTableView:(NSString *)stringValue {
    NSTextField *label = [[self dropView] viewWithTag:kLabelTag];
    [label setStringValue:stringValue];
}

- (void)updateCount {
    [self updateCountWithCancel:NO];
}

- (void)updateCountWithCancel:(BOOL)cancelled {
    if (cancelled) {
        [self setNumberOfItemsToCompress:[self numberOfItemsToCompress]-1];
    } else {
        [self setNumberOfItemsCompressed:[self numberOfItemsCompressed]+1];
    }
    
    NSInteger totalCount = [self numberOfItemsToCompress];
    NSInteger readyCount = [self numberOfItemsCompressed];
    NSString *labelCount;
    if (readyCount == totalCount) {
        labelCount = [NSString stringWithFormat:@"%li item(s) compressed!", readyCount];
        [self resetCount];
        if ([[NSApplication sharedApplication] isActive]) {
            if ([self shouldPlaySound]) {
                [self playSound];
            }
        } else {
            [self notifyUser:labelCount];
        }
        [[self toolbar] removeItemAtIndex:1];
        [[self toolbar] insertItemWithItemIdentifier:[[self toolbarClear] itemIdentifier]  atIndex:1];
    } else {
        labelCount = [NSString stringWithFormat:@"%li of %li item(s) compressed...", readyCount, totalCount];
    }
    [self updateBadgeLabel];
    [self updateLabelForTableView:labelCount];
}

- (void)resetCount {
    [self setNumberOfItemsToCompress:0];
    [self setNumberOfItemsCompressed:0];
}

#pragma mark USER INTERFACE METHODS

- (void)addScrollView {
    NSRect frame = NSMakeRect(self.dropView.frame.origin.x, self.dropView.frame.origin.y, self.dropView.frame.size.width, self.dropView.frame.size.height);
    CZScrollView *scrollView = [[CZScrollView alloc] initWithFrame:frame];
    [scrollView setDrawsBackground:NO];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView setHorizontalScrollElasticity:NSScrollElasticityNone];
    [[self dropView] addSubview:scrollView];
    NSView *superView = [[self window] contentView];
    [self setConstraintWithItem:superView
                         toItem:scrollView
                  withAttribute:NSLayoutAttributeLeading
                    andConstant:1];
    [self setConstraintWithItem:superView
                         toItem:scrollView
                  withAttribute:NSLayoutAttributeTrailing
                    andConstant:-1];
    [self setConstraintWithItem:superView
                         toItem:scrollView
                  withAttribute:NSLayoutAttributeTop
                    andConstant:-45];
    [self setConstraintWithItem:superView
                         toItem:scrollView
                  withAttribute:NSLayoutAttributeBottom
                    andConstant:38];
    [scrollView setAutoresizesSubviews:YES];
    [self setScrollView:scrollView];
}

- (void)addTableView {
    NSRect frame = [[self scrollView] frame];
    CZTableView *tableView = [[CZTableView alloc] initWithFrame:frame];
    NSTableColumn *columnLft = [[NSTableColumn alloc] initWithIdentifier:@"ColumnLeft"];
    NSTableColumn *columnMdl = [[NSTableColumn alloc] initWithIdentifier:@"ColumnMiddle"];
    NSTableColumn *columnRgt = [[NSTableColumn alloc] initWithIdentifier:@"ColumnRight"];
    [columnLft setWidth:kTableColumnWidth];
    [columnMdl setWidth:frame.size.width-(kTableColumnWidth*2)];
    [columnRgt setWidth:kTableColumnWidth];
    [columnLft setResizingMask:NSTableColumnNoResizing];
    [columnMdl setResizingMask:NSTableColumnAutoresizingMask];
    [columnRgt setResizingMask:NSTableColumnNoResizing];
    [tableView addTableColumn:columnLft];
    [tableView addTableColumn:columnMdl];
    [tableView addTableColumn:columnRgt];
    [tableView setDelegate:self];
    [tableView setHeaderView:nil];
    [tableView setDataSource:self];
    [tableView setAllowsColumnResizing:NO];
    [tableView setAllowsColumnSelection:NO];
    [tableView setAllowsColumnReordering:NO];
    [tableView setAllowsMultipleSelection:YES];
    [tableView setUsesAlternatingRowBackgroundColors:YES];
    [tableView setColumnAutoresizingStyle:NSTableViewReverseSequentialColumnAutoresizingStyle];
    [[self scrollView] setDocumentView:tableView];
    [[self window] makeFirstResponder:tableView];
    [self setTableView:tableView];
}

- (void)addCompressButton {
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(295, 2, 100, 32)];
    [button setBordered:YES];
    [button setEnabled:NO];
    [button setTitle:@"Compress"];
    [button setAction:@selector(compressButton:)];
    [button setBezelStyle:NSRoundedBezelStyle];
    [button setButtonType:NSMomentaryPushInButton];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setFont:[NSFont fontWithName:@"Helvetica"
                                    size:13.0]];
    [[self dropView] addSubview:button];
    [self setConstraintWithItem:[[self window] contentView]
                         toItem:button
                 withAttributes:@[[NSNumber numberWithInt:NSLayoutAttributeTrailing],
                                  [NSNumber numberWithInt:NSLayoutAttributeBottom]]
                    andConstant:10];
    [self setCompressButton:button];
}

- (void)addLabelForTableView {
    CGSize frameSize = self.window.contentView.frame.size;
    CZTextField *label = [CZTextField initWithFrame:NSMakeRect(0, frameSize.height, frameSize.width, 30)
                                        stringValue:@"Loading..."
                                           fontName:@"Helvetica"
                                           fontSize:18.0
                                          fontStyle:NSNarrowFontMask];
    [label setTextColor:[NSColor controlTextColor]];
    [label setTag:kLabelTag];
    [label setAlignment:NSTextAlignmentCenter];
    [[self dropView] addSubview:label];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setConstraintWithItem:[[self window] contentView]
                         toItem:label
                  withAttribute:NSLayoutAttributeTop
                    andConstant:-10];
    [self setConstraintWithItem:[[self window] contentView]
                         toItem:label
                  withAttribute:NSLayoutAttributeCenterX
                    andConstant:0];
}

/*!
 *  @brief Creates a constraint that defines the relationship between the specified attribute of the given views.
 *  @param item1 The view for the left side of the constraint.
 *  @param item2 The view for the right side of the constraint.
 *  @param attribute The attribute of the view for both sides of the constraint.
 *  @param constant The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
 */
- (void)setConstraintWithItem:(id)item1
                       toItem:(id)item2
                withAttribute:(NSLayoutAttribute)attribute
                  andConstant:(float)constant {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:item1
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:item2
                                                                  attribute:attribute
                                                                 multiplier:1.0
                                                                   constant:constant];
    [item1 addConstraint:constraint];
}
/*!
 *  @brief Creates multiple constraint that defines the relationship between the specified attributes of the given views.
 *  @discussion Attributes are supplied in an array.
 *  @param item1 The view for the left side of the constraint.
 *  @param item2 The view for the right side of the constraint.
 *  @param attributes An array of the attributes of the view for both sides of the constraint.
 *  @param constant The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
 */
- (void)setConstraintWithItem:(id)item1
                       toItem:(id)item2
               withAttributes:(NSArray *)attributes
                  andConstant:(float)constant {
    for (id attribute in attributes) {
        [self setConstraintWithItem:item1
                             toItem:item2
                      withAttribute:[attribute integerValue]
                        andConstant:constant];
    }
}

/*!
 *  @brief Creates a constraint that defines the relationship between the specified attribute of the given views and add it to a third view.
 *  @param item1 The view for the left side of the constraint.
 *  @param item2 The view for the right side of the constraint.
 *  @param attribute The attribute of the view for both sides of the constraint.
 *  @param constant The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
 *  @param item3 The view to add the constraints.
 */
- (void)setConstraintWithItem:(id)item1
                       toItem:(id)item2
                withAttribute:(NSLayoutAttribute)attribute
                  andConstant:(float)constant
                    addToItem:(id)item3 {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:item1
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:item2
                                                                  attribute:attribute
                                                                 multiplier:1.0
                                                                   constant:constant];
    [item3 addConstraint:constraint];
}

/*!
 *  @brief Creates multiple constraint that defines the relationship between the specified attributes of the given views and adds them to a third view.
 *  @discussion Attributes are supplied in an array.
 *  @param item1 The view for the left side of the constraint.
 *  @param item2 The view for the right side of the constraint.
 *  @param attributes An array of the attributes of the view for both sides of the constraint.
 *  @param constant The constant added to the multiplied attribute value on the right side of the constraint to yield the final modified attribute.
 *  @param item3 The view to add the constraints.
 */
- (void)setConstraintWithItem:(id)item1
                       toItem:(id)item2
               withAttributes:(NSArray *)attributes
                  andConstant:(float)constant
                    addToItem:(id)item3 {
    for (id attribute in attributes) {
        [self setConstraintWithItem:item1
                             toItem:item2
                      withAttribute:[attribute integerValue]
                        andConstant:constant
                          addToItem:item3];
    }
}

#pragma mark USER NOTIFICATION METHODS

- (NSUserNotificationCenter *)notificationCenter {
    if (!_notificationCenter) {
        NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        _notificationCenter = notificationCenter;
    }
    return _notificationCenter;
}

- (void)notifyUser:(NSString *)message {
    if ([self shouldNotifyUser]) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:CZApplicationName];
        [notification setInformativeText:message];
        [notification setSoundName:CZDefaultNotifySoundName];
        [[self notificationCenter] deliverNotification:notification];
    }
}

- (void)updateBadgeLabel {
    if ([self shouldBadgeDockIcon]) {
        NSInteger badgeLabel = [self numberOfItemsToCompress] - [self numberOfItemsCompressed];
        if (badgeLabel == 0) {
            [self setApplicationBadge:@""];
        } else {
            [self setApplicationBadge:[NSString stringWithFormat:@"%li", badgeLabel]];
        }
    }
}

- (void)playSound {
    [[NSSound soundNamed:CZDefaultNotifySoundName] play];
}

- (void)setApplicationBadge:(NSString *)badgeLabel {
    [[NSApp dockTile] setBadgeLabel:badgeLabel];
}

- (BOOL)isApplicationBadgeSet {
    return (![[NSApp dockTile] badgeLabel]) ? NO : YES;
}
/*!
 *  @brief Creates an animation simulating a shake.
 */
- (NSDictionary *)shakeAnimation:(NSRect)windowFrame {
    // Borrowed from cimgf.com/2008/02/27/core-animation-tutorial-window-shake-effect/
    // Set the shake properties
    int numberOfShakes = 3;
    float shakesDuration = 0.5f;
    float shakesVigor = 0.05f;
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, nil, NSMinX(windowFrame), NSMinY(windowFrame));
    for (NSInteger i = 0; i < numberOfShakes; i++) {
        float positionOfX = windowFrame.size.width * shakesVigor;
        CGPathAddLineToPoint(shakePath, nil, NSMinX(windowFrame) - positionOfX, NSMinY(windowFrame));
        CGPathAddLineToPoint(shakePath, nil, NSMinX(windowFrame) + positionOfX, NSMinY(windowFrame));
    }
    CGPathCloseSubpath(shakePath);
    [shakeAnimation setPath:shakePath];
    [shakeAnimation setDuration:shakesDuration];
    
    return [NSDictionary dictionaryWithObject:shakeAnimation
                                       forKey:@"frameOrigin"];
}
/*!
 *  @brief Shakes the window
 *  @discussion Calls the shakeAnimation: method.
 */
- (void)shakeWindow {
    NSWindow *window = [self window];
    NSDictionary *animations = [self shakeAnimation:[window frame]];
    [window setAnimations:animations];
    [[window animator] setFrameOrigin:window.frame.origin];
    
}

#pragma mark ITEM IMAGE METHODS

- (NSURL *)URLToImageForItem:(CZDropItem *)item {
    // Check first if the item has a cached image stored away. It'll otherwise retrieve and store it in the cache directory.
    NSString *cachedFilePath = [NSString stringWithFormat:@"%@.jpg", [item temporaryPath]];
    NSData *data = [NSData dataWithContentsOfFile:cachedFilePath];
    if (data == nil) {
        NSString *filePath = [self retrieveImageFromItem:item];
        if (filePath == nil) {
            return nil;
        }
        data = [NSData dataWithContentsOfFile:filePath];
        [data writeToFile:cachedFilePath atomically:YES];
    }
    
    return [NSURL fileURLWithPath:cachedFilePath];
}

- (NSImage *)imageForItem:(CZDropItem *)item {
    NSURL *imageURL = [self URLToImageForItem:item];
    return [[NSImage alloc] initWithContentsOfURL:imageURL];
}

- (NSString *)retrieveImageFromItem:(CZDropItem *)item {
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:[item folderPath]
                                                                                                            isDirectory:YES]
                                                                      includingPropertiesForKeys:nil
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                    errorHandler:nil];
    NSString *imagePath;
    for (NSURL *file in directoryEnumerator) {
        if ([[Constants CZValidFileExtensions] containsObject:[[file pathExtension] lowercaseString]]) {
            imagePath = [file path];
            break;
        }
    }
    
    if (!imagePath) {
        return nil;
    }
    
    return imagePath;
}

#pragma mark PREFERENCES METHODS

- (NSArray *)shouldIgnoreFiles {
    NSMutableArray *ignoredFiles = [[[self applicationSettings] objectForKey:CZSettingsCustomFilter] mutableCopy];
    if ([[[self applicationSettings] objectForKey:CZSettingsFilterHidden] boolValue]) {
        [ignoredFiles addObjectsFromArray:[Constants CZFilterHidden]];
    }
    if ([[[self applicationSettings] objectForKey:CZSettingsFilterMeta] boolValue]) {
        [ignoredFiles addObjectsFromArray:[Constants CZFilterMeta]];
    }
    return ignoredFiles;
}

- (BOOL)shouldIgnoreEmptyData {
    return [[[self applicationSettings] objectForKey:CZSettingsFilterEmptyData] boolValue];
}

- (BOOL)shouldDeleteFolder {
    return [[[self applicationSettings] objectForKey:CZSettingsDeleteFolders] boolValue];
}

- (BOOL)shouldNotifyUser {
    return [[[self applicationSettings] objectForKey:CZSettingsNotifications] boolValue];
}

- (BOOL)shouldBadgeDockIcon {
    return [[[self applicationSettings] objectForKey:CZSettingsBadgeDockIcon] boolValue];
}

- (BOOL)shouldPlaySound {
    return [[[self applicationSettings] objectForKey:CZSettingsAlertSound] boolValue];
}

- (BOOL)shouldAutoStartCompression {
    return [[[self applicationSettings] objectForKey:CZSettingsAutoStart] boolValue];
}

#pragma mark MISC METHODS

- (BOOL)applicationStateIs:(int)applicationState {
    return ([self applicationState] == applicationState);
}

@end
