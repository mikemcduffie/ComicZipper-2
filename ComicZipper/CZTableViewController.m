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

@interface CZTableViewController () <CZWindowControllerDelegate, CZTableViewDelegate>

@property (strong) IBOutlet CZScrollView *scrollView;
@property (strong) IBOutlet CZTableView *tableView;
@property (strong) ComicZipper *comicZipper;

@end

@implementation CZTableViewController

@synthesize comicZipper = _comicZipper;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self.tableView setUpTable];
    }
    
    return self;
}

- (void)viewDidLoad {
    self.tableView.delegate = self;
    self.tableView.dataSource = self.comicZipper;
    [super viewDidLoad];
}

#pragma mark WINDOW CONTROLLER DELEGATE METHODS

- (void)viewShouldHighlight:(BOOL)highlight {
    [self.scrollView toggleHighlight:highlight];
}

- (BOOL)isItemInList:(NSString *)item {
    return NO;
}

- (void)addItemsFromArray:(NSArray *)array {
    [self.comicZipper addItems:array];
    [self.tableView reloadData];
}

- (void)reloadData {
    [self.tableView reloadData];
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
        [view setIdentifier:@"RightCell"];
    } else {
        [view setWidth:column.width];
    }
    
    CZDropItem *item = [self.comicZipper itemAtIndex:row];
    
    if ([column.identifier isEqualToString:@"ColumnLeft"]) {
        if (item.isArchived) {
            // Set the cover image
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
        [view setIdentifier:[NSString stringWithFormat:@"%li", row]];
        if (item.isArchived) {
            [view setStatus:CZStatusIconSuccess];
        } else if (item.isCancelled) {
            [view setStatus:CZStatusIconError];
        } else {
            [view setStatus:CZStatusIconAbortNormal];
            // Set the abort button
//            [view setAction:@selector(cancelCompression:)
//                  forTarget:self];
        }
    }
    
    view.needsDisplay = YES;
    
    return view;
}

- (void)tableView:(NSTableView *)tableView
    didAddRowView:(NSTableRowView *)rowView
           forRow:(NSInteger)row {
    // When the last row is added, the top label should be updated and the compression, if set up that way, start automatically.
//    NSInteger numberOfItemsToCompress = [[self comicZipper] count] - [[self comicZipper] countCancelled];
//    if (numberOfItemsToCompress == row+1) {
//        [self updateLabelForTableView:[NSString stringWithFormat:@"%li item(s) to compress", numberOfItemsToCompress]];
//        if ([self shouldAutoStartCompression]) {
//            [self compressButton:[self compressButton]];
//        } else {
//            [[self compressButton] setEnabled:YES];
//        }
//    }

}

- (void)tableView:(CZTableView *)tableView
 DidRegisterKeyUp:(int)keyCode
     atRowIndexes:(NSIndexSet *)indexes
      withCommand:(BOOL)commandState {
    
}

- (void)openItemInFinder:(NSIndexSet *)rows {
    
}

#pragma mark SETTERS AND GETTERS

- (ComicZipper *)comicZipper {
    if (!_comicZipper) {
        _comicZipper = [[ComicZipper alloc] init];
    }
    
    return _comicZipper;
}

- (void)setComicZipper:(ComicZipper *)comicZipper {
    _comicZipper = comicZipper;
}

@end
