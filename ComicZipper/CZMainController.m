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

@interface CZMainController () <CZComicZipperDelegate, CZDropViewDelegate, CZTableViewDelegate, NSTableViewDataSource>

@property (nonatomic) int applicationState;
@property (strong) CZComicZipper *comicZipper;
@property (weak) CZDropView *dropView;
@property (weak) CZScrollView *scrollView;
@property (weak) CZTableView *tableView;

@end

int const kDropViewLabel = 101;

@implementation CZMainController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                          ComicZipper:(CZComicZipper *)comicZipper
                  andApplicationState:(int)applicationState {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        [comicZipper setDelegate:self];
        _comicZipper = comicZipper;
        _applicationState = applicationState;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self updateUI];
}

- (void)updateUI {
    // The drop view should always be present.
    if (![self dropView]) {
        [self addDropView];
    }

    if ([self applicationStateIs:kAppStateNoItemDropped]) {
        [self addLabelForDropView];
    } else if ([self applicationStateIs:kAppStateFirstItemDrop]) {
        [[[self dropView] viewWithTag:kDropViewLabel] removeFromSuperview];
        [self addScrollView];
        [self addTableView];
        [self addCompressButton];
    } else if ([self applicationStateIs:kAppStatePopulatedList]) {
        [[self tableView] reloadData];
    }
}

- (void)handleKeyEvent:(int)keyCode
          atRowIndexes:(NSIndexSet *)indexes
           withCommand:(BOOL)state {
    if (keyCode == kDeleteKey) {
        [[self comicZipper] removeItemsWithIndexes:indexes];
        [[self tableView] reloadData];
    }
}

#pragma mark DELEGATE METHODS

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items {
    // Add dropped items to the array collection before updating user interface.
    [[self comicZipper] addItems:items];
    // First time drop should create the table.
    if ([self applicationStateIs:kAppStateNoItemDropped]) {
        [self setApplicationState:kAppStateFirstItemDrop];
    } else {
        [self setApplicationState:kAppStatePopulatedList];
    }
    //
    [self updateUI];
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    return [[self comicZipper] isItemInList:description];
}

- (BOOL)isDropViewFront {
    return YES;
}

- (void)tableView:(CZTableView *)tableView
 DidRegisterKeyUp:(int)keyCode
     atRowIndexes:(NSIndexSet *)indexes
      withCommand:(BOOL)commandState {
    [self handleKeyEvent:keyCode atRowIndexes:indexes withCommand:commandState];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableColumnHeight;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self comicZipper] count];
}

- (NSView *)tableView:(CZTableView *)tableView
   viewForTableColumn:(nullable NSTableColumn *)column
                  row:(NSInteger)row {
    CZTableCellView *cellView = [tableView makeViewWithIdentifier:@"FolderView" owner:self];
    CZDropItem *item = [[self comicZipper] itemWithIndex:row];
    float width = [column width];
    if ([[column identifier] isEqualToString:@"ColumnLeft"]) {
        if (cellView == nil) {
            cellView = [[CZTableCellView alloc] initWithFrame:NSMakeRect(0, 0, width, 32)];
            [cellView setIdentifier:@"FolderView"];
        } else {
            [cellView setWidth:width];
        }
        [cellView setTitleText:[item description]];
        [cellView setImage:[NSImage imageNamed:@"NSFolder"]];
        if ([item isArchived]) {
            [cellView setDetailText:[item archivePath]];
        } else {
            [cellView setDetailText:[item fileSize]];
            [cellView setProgress:1.0];
        }
    } else {
        if (cellView == nil) {
            cellView = [[CZTableCellView alloc] initWithFrame:NSMakeRect(0, 0, width, 32)];
            [cellView setIdentifier:@"FolderView"];
        } else {
            [cellView setWidth:width];
        }
        if ([item isArchived]) {
            [cellView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
        } else if ([item isRunning]) {
            [cellView setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
        } else {
            [cellView setImage:[NSImage imageNamed:@"NSStatusNone"]];
        }
    }

    return cellView;
}

- (void)ComicZipper:(CZComicZipper *)comicZipper
didStartItemAtIndex:(NSUInteger)index {
    // For performance issues reload only the specific row that needs updating.
    NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
    NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,2)];
    [[self tableView] reloadDataForRowIndexes:rowIndexes
                                columnIndexes:colIndexes];
}

- (void)ComicZipper:(CZComicZipper *)comicZipper
  didUpdateProgress:(float)progress
      ofItemAtIndex:(NSUInteger)index {
    CZTableCellView *cellView = [[self tableView] viewAtColumn:0 row:index makeIfNecessary:YES];
    [cellView setProgress:progress];
}

- (void)ComicZipper:(CZComicZipper *)comicZipper
didFinishItemAtIndex:(NSUInteger)index {
    // For performance issues reload only the specific row that needs updating.
    NSIndexSet *rowIndexes = [[NSIndexSet alloc] initWithIndex:index];
    NSIndexSet *colIndexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0,2)];
    [[self tableView] reloadDataForRowIndexes:rowIndexes
                                columnIndexes:colIndexes];
}


#pragma mark USER INTERFACE METHODS

- (void)addDropView {
    CZDropView *dropView = [[CZDropView alloc] initWithFrame:[[[self window] contentView] frame]];
    [dropView setDelegate:self];
    [dropView setDragMode:YES];
    [dropView setAutoresizesSubviews:YES];
    [dropView setFocusRingType:NSFocusRingTypeExterior];
    [[[self window] contentView] addSubview:dropView];
    // CONSTRAINTS
    [dropView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setConstraintWithItem:[[self window] contentView]
                         toItem:dropView
                 withAttributes:@[[NSNumber numberWithInt:NSLayoutAttributeLeading],
                                  [NSNumber numberWithInt:NSLayoutAttributeTop],
                                  [NSNumber numberWithInt:NSLayoutAttributeTrailing]]
                    andConstant:0];
    [self setConstraintWithItem:[[self window] contentView]
                         toItem:dropView
                  withAttribute:NSLayoutAttributeBottom
                    andConstant:1];
    [self setDropView:dropView];
}

- (void)addLabelForDropView {
    NSTextField *textField = [self createTextFieldWithFrame:NSMakeRect(0, 0, 0, 0)
                                                stringValue:@"Drop folders here"
                                                   fontName:@"Lucida Grande"
                                                   fontSize:22.0];
    [textField setTag:kDropViewLabel];
    [textField setTextColor:[NSColor whiteColor]];
    [textField setAlignment:NSTextAlignmentCenter];
    [[self dropView] addSubview:textField];
    // CONSTRAINTS
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setConstraintWithItem:[self dropView]
                         toItem:textField
                 withAttributes:@[[NSNumber numberWithInt:NSLayoutAttributeCenterX],
                                  [NSNumber numberWithInt:NSLayoutAttributeCenterY]]
                    andConstant:0];
}

- (void)addScrollView {
    CZScrollView *scrollView = [[CZScrollView alloc] initWithFrame:[[self dropView] frame]];
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
                 withAttributes:@[[NSNumber numberWithInt:NSLayoutAttributeLeading],
                                  [NSNumber numberWithInt:NSLayoutAttributeTrailing]]
                    andConstant:0];
    [self setConstraintWithItem:superView
                         toItem:scrollView
                  withAttribute:NSLayoutAttributeTop
                    andConstant:-60];
    [self setConstraintWithItem:superView
                         toItem:scrollView
                  withAttribute:NSLayoutAttributeBottom
                    andConstant:38];
    [self setScrollView:scrollView];
}

- (void)addTableView {
    NSRect frame = [[self scrollView] frame];
    CZTableView *tableView = [[CZTableView alloc] initWithFrame:frame];
    NSTableColumn *columnLft = [[NSTableColumn alloc] initWithIdentifier:@"ColumnLeft"];
    NSTableColumn *columnRgt = [[NSTableColumn alloc] initWithIdentifier:@"ColumnRight"];
    [columnLft setWidth:frame.size.width/kTableColumnRatio];
    [columnRgt setWidth:frame.size.width-(frame.size.width/kTableColumnRatio)];
    [tableView addTableColumn:columnLft];
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
    [self setTableView:tableView];
}

- (void)addCompressButton {
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(295, 2, 100, 32)];
    [button setBordered:YES];
    [button setTitle:@"Compress"];
    [button setAction:@selector(compressButton:)];
    [button setBezelStyle:NSRoundedBezelStyle];
    [button setButtonType:NSMomentaryPushInButton];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setFont:[NSFont fontWithName:@"Lucida Grande"
                                    size:13.0]];
    [[self dropView] addSubview:button];
    [self setConstraintWithItem:[[self window] contentView]
                         toItem:button
                 withAttributes:@[[NSNumber numberWithInt:NSLayoutAttributeTrailing],
                                  [NSNumber numberWithInt:NSLayoutAttributeBottom]]
                    andConstant:10];
}

- (NSTextField *)createTextFieldWithFrame:(NSRect)frame
                              stringValue:(NSString *)stringValue
                                 fontName:(NSString *)fontName
                                 fontSize:(float)fontSize {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setBordered:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField setDrawsBackground:NO];
    [textField setStringValue:stringValue];
    [textField setAllowsEditingTextAttributes:NO];
    [[textField cell] setTruncatesLastVisibleLine:YES];
    [[textField cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [textField setFont:[NSFont fontWithName:fontName size:fontSize]];
    return textField;
}

#pragma mark USER INTERACTION METHODS

- (void)compressButton:(id)sender {
    [sender setEnabled:NO];
    [[self comicZipper] startCompression];
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

#pragma mark MISC METHODS

- (BOOL)applicationStateIs:(int)applicationState {
    return ([self applicationState] == applicationState);
}

@end
