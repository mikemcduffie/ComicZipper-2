//
//  CZSettingsController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 19/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZSettingsController.h"

@interface CZSettingsController () <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (strong) IBOutlet NSToolbar *toolbar;
@property (strong) IBOutlet NSToolbarItem *toolbarItemGeneral;
@property (strong) IBOutlet NSToolbarItem *toolbarItemFilters;
@property (strong) IBOutlet NSToolbarItem *toolbarItemAdvanced;
@property (strong) IBOutlet NSView *viewGeneral;
@property (strong) IBOutlet NSView *viewFilters;
@property (strong) IBOutlet NSView *viewAdvanced;
@property (strong) IBOutlet NSButton *checkBoxNotifyUser;
@property (strong) IBOutlet NSButton *checkBoxAlertSound;
@property (strong) IBOutlet NSButton *checkBoxBadgeDockIcon;
@property (strong) IBOutlet NSButton *checkBoxQuitApplication;
@property (strong) IBOutlet NSButton *checkBoxExcludeMeta;
@property (strong) IBOutlet NSButton *checkBoxExcludeHidden;
@property (strong) IBOutlet NSButton *checkBoxExcludeEmpty;
@property (strong) IBOutlet NSButton *checkBoxDeleteFolders;
@property (strong) IBOutlet NSButton *checkBoxAutoStart;
@property (strong) IBOutlet NSButton *checkBoxReloadDefaults;
@property (strong) IBOutlet NSButton *buttonAddFilter;
@property (strong) IBOutlet NSButton *buttonRemoveFilter;
@property (strong) IBOutlet NSTableView *tableViewFilters;
@property (strong) NSMutableArray *filters;
@end

@implementation CZSettingsController

const int kTableCellViewHeight = 20;

- (instancetype)init {
    self = [super initWithWindowNibName:@"Settings" owner:self];
    
    if (self) {
        [self.window.contentView addSubview:self.viewGeneral];
        self.toolbar.selectedItemIdentifier = self.toolbarItemGeneral.itemIdentifier;
        self.filters = [[NSUserDefaults.standardUserDefaults valueForKey:CZSettingsCustomFilter] mutableCopy];
        self.tableViewFilters.delegate = self;
        self.tableViewFilters.dataSource = self;
        [self showWindow:self];
    }
    
    return self;
}

#pragma mark VIEW SELECTION METHODS

- (IBAction)changeView:(id)sender {
    NSView *superView = self.window.contentView;
    NSView *viewToReplace = superView.subviews.firstObject;
    if (sender == self.toolbarItemGeneral) {
        [superView replaceSubview:viewToReplace with:self.viewGeneral];
    } else if (sender == self.toolbarItemFilters) {
        [superView replaceSubview:viewToReplace with:self.viewFilters];
    } else {
        [superView replaceSubview:viewToReplace with:self.viewAdvanced];
    }
}

- (IBAction)addFilter:(id)sender {
    // Make sure not to create multiple empty entries in the array.
    if (![self.filters doesContain:@""]) {
        [self.filters addObject:@""];
        [self.tableViewFilters reloadData];
    }
    [self selectLastTableViewRow];
}

- (IBAction)removeFilter:(id)sender {
    NSIndexSet *indexes = [self.tableViewFilters selectedRowIndexes];
    [self.filters removeObjectsAtIndexes:indexes];
    [NSUserDefaults.standardUserDefaults setObject:self.filters
                                            forKey:CZSettingsCustomFilter];
    [self.tableViewFilters removeRowsAtIndexes:indexes
                                 withAnimation:NO];
    [self.tableViewFilters reloadData];
}


#pragma mark TABLE VIEW DELEGATE METHODS

- (NSView *)tableView:(NSTableView*)tableView
   viewForTableColumn:(nullable NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSTableCellView *view = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                        owner:self];
    if (view == nil) {
        view = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, tableView.rowHeight)];
    }
    
    NSString *stringValue = [self.filters objectAtIndex:row];
    [[view textField] setStringValue:stringValue];
    
    [[view textField] setEditable:YES];
    [[view textField] setSelectable:YES];
    [[view textField] setDelegate:self];
    [[view textField] setTag:row];
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView
         heightOfRow:(NSInteger)row {
    return kTableCellViewHeight;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.tableViewFilters.numberOfSelectedRows > 0) {
        self.buttonRemoveFilter.enabled = YES;
    } else {
        self.buttonRemoveFilter.enabled = NO;
    }
}

- (void)selectLastTableViewRow {
    NSTableCellView *view = [self.tableViewFilters viewAtColumn:0
                                                            row:self.filters.count-1
                                                makeIfNecessary:YES];
    NSRange selectedRange = NSMakeRange(0, 0);
    [view.textField selectText:self];
    [view.textField.currentEditor setSelectedRange:selectedRange];
}

#pragma mark TABLE VIEW DATA SOURCE METHODS

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.filters.count;
}

#pragma mark TEXT FIELD DELEGATE METHODS

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSString *stringValue = [obj.object stringValue];
    long row = [obj.object tag];
    if ([stringValue isNotEqualTo:@""]) {
        [self.filters replaceObjectAtIndex:row
                                withObject:stringValue];
        [NSUserDefaults.standardUserDefaults setObject:self.filters
                                                forKey:CZSettingsCustomFilter];
    } else {
        [self.filters removeObjectAtIndex:row];
        [self.tableViewFilters reloadData];
    }
}

@end
