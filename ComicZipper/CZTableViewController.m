//
//  CZTableViewController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZTableViewController.h"
#import "CZWindowController.h"
#import "CZScrollView.h"
#import "CZTableView.h"
#import "CZTableCellView.h"
#import "ComicZipper.h"
#import "CZDropItem.h"
#import <QuickLook/QuickLook.h>
#import <Quartz/Quartz.h>

@interface CZTableViewController () <CZWindowControllerDelegate, CZTableViewDelegate, ComicZipperDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate>

@property (strong) IBOutlet CZScrollView *scrollView;
@property (strong) IBOutlet CZTableView *tableView;
@property (strong) IBOutlet NSTextField *textLabel;
@property (strong) IBOutlet NSButton *buttonCompres;
@property (strong) ComicZipper *comicZipper;

@end

@implementation CZTableViewController

@synthesize comicZipper = _comicZipper;

NSString *const kLabelStopped = @"%li item(s) to compress";
NSString *const kLabelProgress = @"%li item(s) remaining...";
NSString *const kLabelFinished = @"%li item(s) compressed!";

- (void)viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self.comicZipper;
    [super viewDidLoad];
}

#pragma mark USER INTERFACE METHODS

- (void)postNotification:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:self
                                                      userInfo:nil];
}

- (void)setLabel:(NSString *)label {
    self.textLabel.stringValue = label;
}

- (void)setApplicationBadge:(NSString *)badgeLabel {
    // No zero for you.
    if ([badgeLabel isEqualToString:@"0"]) {
        badgeLabel = @"";
    }
    
    NSApplication.sharedApplication.dockTile.badgeLabel = badgeLabel;
}

- (void)viewWillUnload {
    [self.comicZipper clearItems];
    [self.view removeFromSuperview];
}

- (void)cancelAllItems {
    [self.comicZipper compressionStopAll];
}

- (IBAction)compressButtonWasClicked:(id)sender {
    [sender setEnabled:NO];
    [self.comicZipper compressionStart];
    [self postNotification:CZToggleDragModeNotification];
    [self postNotification:CZCompressionStartNotification];
}

- (void)reloadDataForRow:(NSInteger)index {
    // For performance issues reload only the specific row that needs updating.
    NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
    NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,3)];
    [self.tableView reloadDataForRowIndexes:rowIndexes
                              columnIndexes:colIndexes];
    [self updateCount];
}

#pragma mark WINDOW CONTROLLER DELEGATE METHODS

- (void)viewShouldHighlight:(BOOL)highlight {
    [self.scrollView toggleHighlight:highlight];
}

- (BOOL)isItemInList:(NSString *)item {
    return [self.comicZipper isItemInList:item];
}

- (void)addItemsFromArray:(NSArray *)array {
    [self.comicZipper addItems:array];
    [self.tableView reloadData];
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (BOOL)hasProcessFinished {
    return [self.comicZipper isRunning];
}

- (NSInteger)numberOfItemsCompressed {
    return [self.comicZipper countArchived];
}

#pragma mark TABLE VIEW DELEGATE METHODS

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableRowHeight;
}

- (NSView *)tableView:(CZTableView *)tableView
   viewForTableColumn:(NSTableColumn *)column
                  row:(NSInteger)row {
    CZTableCellView *view = [tableView makeViewWithIdentifier:column.identifier
                                                        owner:self];
    if (view == nil) {
        NSRect frame = NSMakeRect(0, 0, column.width, kTableRowHeight);
        view = [[CZTableCellView alloc] initWithFrame:frame];
        [view setIdentifier:column.identifier];
    } else {
        [view setWidth:column.width];
    }
    
    CZDropItem *item = [self.comicZipper itemAtIndex:row];
    if ([column.identifier isEqualToString:@"ColumnLeft"]) {
        item.rowIndex = row;
        if (item.isArchived) {
            [view setImage:[item image]];
        } else {
            [view setImage:[NSImage imageNamed:@"NSFolder"]];
        }
    } else if ([column.identifier isEqualToString:@"ColumnMiddle"]) {
        [view setTitleText:item.name];
        if (item.isArchived) {
            [view setDetailText:item.archivePath];
        } else if (item.isCancelled) {
            [view setDetailText:@"Cancelled by user."];
        } else {
            [view setDetailText:item.fileSize];
        }
    } else if ([column.identifier isEqualToString:@"ColumnRight"]) {
        [view setRowIndex:row];
        if (item.isArchived) {
            [view setStatus:CZStatusIconSuccess];
        } else if (item.isCancelled) {
            [view setStatus:CZStatusIconError];
        } else {
            [view setStatus:CZStatusIconAbortNormal];
            // Set the abort button
            [view setAction:@selector(compressionStop:)
                  forTarget:self.comicZipper];
        }
    }
    
    view.needsDisplay = YES;
    
    return view;
}

- (void)tableView:(NSTableView *)tableView
    didAddRowView:(NSTableRowView *)rowView
           forRow:(NSInteger)row {
    // When the last row is added, the top label should be updated and the compression, if set up that way, start automatically.
    NSInteger numberOfItemsToCompress = [self.comicZipper countActive];
    if (numberOfItemsToCompress == row+1) {
        [self updateCount];
        
        if ([self shouldAutoStart]) {
            [self compressButtonWasClicked:self.buttonCompres];
        } else {
            self.buttonCompres.enabled = YES;
        }
    }
}

- (void)tableView:(CZTableView *)tableView
 DidRegisterKeyUp:(int)keyCode
     atRowIndexes:(NSIndexSet *)indexes
      withCommand:(BOOL)commandState {
    if (keyCode == kDeleteKey) {
        if (self.comicZipper.running == NO) {
            [self.comicZipper removeItemsAtIndexes:indexes];
            [self.tableView removeRowsAtIndexes:indexes withAnimation:NO];
            if (self.comicZipper.count > 0) {
                NSUInteger firstIndex = [indexes firstIndex];
                if (firstIndex >= self.comicZipper.count) {
                    firstIndex--;
                }
                [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:firstIndex]
                            byExtendingSelection:NO];
                if (self.comicZipper.count > 0) {
                    [self updateCount];
                }
            } else {
                // Ask window controller to change view.
                [self.view removeFromSuperview];
                [self postNotification:CZChangeViewNotification];
            }
        }
    } else if (keyCode == 49) {
        [QLPreviewPanel.sharedPreviewPanel orderFront:nil];
    }
}

- (void)openItemInFinder:(NSIndexSet *)rows {
    NSArray *items = [[self.comicZipper itemsAtIndexes:rows] valueForKey:@"fileURL"];
    [NSWorkspace.sharedWorkspace activateFileViewerSelectingURLs:items];
}

#pragma mark COMIC ZIPPER DELEGATE METHODS

- (void)ComicZipper:(ComicZipper *)comicZipper didStartItemAtIndex:(NSUInteger)index {
    [self reloadDataForRow:index];
    if (self.comicZipper.isRunning == NO) {
        NSInteger numberOfItemsToCompress = self.comicZipper.countActive;
        NSString *label = [NSString stringWithFormat:kLabelProgress, numberOfItemsToCompress];
        [self setLabel:label];
    }
}

- (void)ComicZipper:(ComicZipper *)comicZipper didUpdateProgress:(float)progress ofItemAtIndex:(NSUInteger)index {
    CZTableCellView *cellView = [self.tableView viewAtColumn:1
                                                         row:index
                                             makeIfNecessary:YES];
    [cellView setProgress:progress];
}

- (void)ComicZipper:(ComicZipper *)comicZipper didFinishItemAtIndex:(NSUInteger)index {
    [self reloadDataForRow:index];
    [self scrollRowToVisible:index];
}

- (void)ComicZipper:(ComicZipper *)comicZipper didCancelItemAtIndex:(NSUInteger)index {
    [self reloadDataForRow:index];
}

#pragma mark PRIVATE METHODS

- (void)updateCount {
    NSInteger numberOfItemsToCompress = self.comicZipper.countActive;
    NSInteger numberOfItemsCompressed = self.comicZipper.countArchived;
    NSString *label = @"Loading...";
    
    if (self.comicZipper.isRunning) {
        label = [NSString stringWithFormat:kLabelProgress, numberOfItemsToCompress];
    } else {
        if (numberOfItemsToCompress > 0) {
            label = [NSString stringWithFormat:kLabelStopped, numberOfItemsToCompress];
        } else {
            label = [NSString stringWithFormat:kLabelFinished, numberOfItemsCompressed];
            // Notify window controller to turn on drag mode
            [self postNotification:CZToggleDragModeNotification];
            [self postNotification:CZCompressionDoneNotification];
        }
    }

    if ([self shouldShowApplicationBadge]) {
        [self setApplicationBadge:[NSString stringWithFormat:@"%li", numberOfItemsToCompress]];
    }
    [self setLabel:label];
}

- (void)scrollRowToVisible:(NSInteger)index {
    CGRect visibleRect = self.tableView.superview.visibleRect;
    NSRange visibleRows = [self.tableView rowsInRect:visibleRect];
    if ((index + visibleRows.length) > visibleRows.location) {
        [self.tableView scrollRowToVisible:index animate:YES];
    }
}

#pragma mark PREFERENCES

- (BOOL)shouldAutoStart {
    return [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsAutoStart];
}

- (BOOL)shouldShowApplicationBadge {
    return [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsBadgeDockIcon];
}

#pragma mark SETTERS AND GETTERS

- (ComicZipper *)comicZipper {
    if (!_comicZipper) {
        _comicZipper = [[ComicZipper alloc] init];
        _comicZipper.delegate = self;
    }
    
    return _comicZipper;
}

- (void)setComicZipper:(ComicZipper *)comicZipper {
    _comicZipper = comicZipper;
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
    return [self.comicZipper itemAtIndex:index];
}

#pragma mark MISC

- (void)dealloc {
    [self setApplicationBadge:@""];
}

@end
