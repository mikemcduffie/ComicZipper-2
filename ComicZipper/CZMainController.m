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
#import "CZProgressIndicator.h"

@interface CZMainController () <CZComicZipperDelegate, CZDropViewDelegate, CZTableViewDelegate, NSTableViewDataSource>

@property (nonatomic) int applicationState;
@property (strong) CZComicZipper *comicZipper;
@property (weak) CZDropView *dropView;
@property (weak) CZScrollView *scrollView;
@property (weak) CZTableView *tableView;

@end

@implementation CZMainController

float const kTableColumnRatio = 1.1;
float const kTableColumnHeight = 40.0;
float const kColumnNormalHeight = kTableColumnHeight/2;
float const kColumnDetailheight = kTableColumnHeight/2-3;

int const kDropViewLabel = 100;
int const kItemNameLabel = 200;
int const kItemSizeLabel = 300;
int const kItemImageLabel = 400;
int const kIndicatorLabel = 500;
int const kProgressIndicator = 600;

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

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableColumnHeight;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self comicZipper] count];
}

- (NSView *)tableView:(CZTableView *)tableView
   viewForTableColumn:(nullable NSTableColumn *)column
                  row:(NSInteger)row {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"FolderView" owner:self];
    // Create a cell view if no one exists
    if (cellView == nil) {
        cellView = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableView.frame.size.width, 32)];
        [cellView setIdentifier:@"FolderView"];
    }
    // Retrieve the current item being displayed.
    CZDropItem *item = [[self comicZipper] itemWithIndex:row];
    if ([[column identifier] isEqualToString:@"ColumnLeft"]) {
        NSTextField *itemName = [self createTextFieldWithFrame: NSMakeRect(50, 15, [column width], kColumnNormalHeight)
                                                   stringValue:[item description]
                                                      fontName:@"Lucida Grande Bold"
                                                      fontSize:13.0];
        NSTextField *itemSize = [self createTextFieldWithFrame:NSMakeRect(50, 0, [column width], kColumnDetailheight)
                                                    stringValue:[item archivePath]
                                                        fontName:@"Lucida Grande"
                                                        fontSize:9.5];
        CZProgressIndicator *progress = [CZProgressIndicator initWithFrame:NSMakeRect(50, 0, [column width], kColumnDetailheight)
                                                                        andProgress:[item progress]];
        [itemName setTag:kItemNameLabel+row];
        [itemSize setTag:kItemSizeLabel+row];
        [progress setTag:kProgressIndicator+row];
        [itemSize setAutoresizingMask:NSViewWidthSizable];
        [itemName setAutoresizingMask:NSViewWidthSizable];
        [progress setAutoresizingMask:NSViewWidthSizable];
        // The image box to the left of the column
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableColumnHeight)];
        [imageView setImage:[NSImage imageNamed:@"NSFolder"]];
        [imageView setTag:kItemImageLabel+row];
        [cellView addSubview:itemName];
        [cellView addSubview:itemSize];
        [cellView addSubview:progress];
        [cellView addSubview:imageView];
        [cellView setNeedsLayout:YES];
    } else {
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 30, kTableColumnHeight)];
        if ([item isArchived]) {
            [imageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
            [imageView setTag:kIndicatorLabel+row];
        } else if ([item isRunning]) {
            [imageView setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
            [imageView setTag:kIndicatorLabel+row];
        } else {
            [imageView setImage:[NSImage imageNamed:@"NSStatusNone"]];
            [imageView setTag:kIndicatorLabel+row];
        }
        [cellView addSubview:imageView];
    }

    return cellView;
}


- (void)ComicZipper:(CZComicZipper *)comicZipper
didStartItemAtIndex:(NSUInteger)index {
    NSImageView *imageView = [[self dropView] viewWithTag:kIndicatorLabel+index];
    [imageView setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
    NSTextField *textField = [[self dropView] viewWithTag:kItemSizeLabel+index];
    [textField setHidden:YES];
    CZProgressIndicator *progressIndicator = [[self dropView] viewWithTag:kProgressIndicator+index];
    [progressIndicator setDisplayedWhenStopped:YES];
}

- (void)ComicZipper:(CZComicZipper *)comicZipper
  didUpdateProgress:(float)progress
      ofItemAtIndex:(NSUInteger)index {
    CZProgressIndicator *progressIndicator = [[self dropView] viewWithTag:kProgressIndicator+index];
    [progressIndicator setDoubleValue:progress];
}

- (void)ComicZipper:(CZComicZipper *)comicZipper
didFinishItemAtIndex:(NSUInteger)index {
    [[[self dropView] viewWithTag:kProgressIndicator+index] removeFromSuperview];
    NSImageView *imageView = [[self dropView] viewWithTag:kIndicatorLabel+index];
    [imageView setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    NSTextField *textField = [[self dropView] viewWithTag:kItemSizeLabel+index];
    NSString *string = [[[self comicZipper] itemWithIndex:index] archivePath];
    [textField setStringValue:string];
    [textField setHidden:NO];
}


#pragma mark USER INTERFACE METHODS

- (void)addDropView {
    CZDropView *dropView = [[CZDropView alloc] init];
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
