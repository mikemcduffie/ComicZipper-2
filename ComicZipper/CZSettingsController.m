//
//  CZSettingsController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 04/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZSettingsController.h"

@interface CZSettingsController () <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (strong) IBOutlet NSButton *checkBoxDelete;
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *buttonRemoveExclusion;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSMutableArray *excludedFiles;
@end

@implementation CZSettingsController

const int kTableCellViewHeight = 20;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                   settingsDictionary:(NSMutableDictionary *)settings {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        _settings = settings;
    }
    
    return self;
}

- (void)windowWillLoad {
    NSArray *excludedFiles = [[self settings] objectForKey:kIdentifierForSettingsExcludedFiles];
    [self setExcludedFiles:[excludedFiles mutableCopy]];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self tableView] setDelegate:self];
    [[self tableView] setDataSource:self];
    [[self checkBoxDelete] setIdentifier:kIdentifierForSettingsDeleteFolders];
    [[self checkBoxDelete] setState:[[[self settings] objectForKey:kIdentifierForSettingsDeleteFolders] intValue]];
}

- (IBAction)checkBoxClicked:(id)sender {
    NSNumber *checkValue = [NSNumber numberWithBool:YES];
    if ([sender state] != NSOnState) {
        checkValue = @NO;
    }
    [[self settings] setObject:checkValue forKey:[sender identifier]];
}


- (IBAction)addExclusion:(id)sender {
    // Make sure not to create multiple empty entries in the array.
    if (![[self excludedFiles] doesContain:@""]) {
        [[self excludedFiles] addObject:@""];
        [[self tableView] reloadData];
    }
    [self selectLastTableViewRow];
}

- (IBAction)removeExclusion:(id)sender {
    NSIndexSet *indexes = [[self tableView] selectedRowIndexes];
    [[self tableView] removeRowsAtIndexes:indexes
                            withAnimation:NO];
    NSArray *objectsToRemove = [[self excludedFiles] objectsAtIndexes:indexes];
    [[[self settings] objectForKey:kIdentifierForSettingsExcludedFiles] removeObjectsInArray:objectsToRemove];
    [[self excludedFiles] removeObjectsAtIndexes:indexes];
}

- (void)selectLastTableViewRow {
    NSTableCellView *view = [[self tableView] viewAtColumn:0
                                                       row:[[self excludedFiles] count]-1
                                           makeIfNecessary:YES];
    NSRange selectedRange = NSMakeRange(0, 0);
    [[view textField] selectText:self];
    [[[view textField] currentEditor] setSelectedRange:selectedRange];
}

- (NSView *)tableView:(NSTableView*)tableView
   viewForTableColumn:(nullable NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSTableCellView *view = [tableView makeViewWithIdentifier:[tableColumn identifier]
                                                        owner:self];
    if (view == nil) {
        view = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, [tableColumn width], [tableView rowHeight])];
    }
    
    NSString *stringValue = [[self excludedFiles] objectAtIndex:row];
    [[view textField] setStringValue:stringValue];
    
    [[view textField] setEditable:YES];
    [[view textField] setSelectable:YES];
    [[view textField] setDelegate:self];
    [[view textField] setTag:row];
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableCellViewHeight;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self excludedFiles] count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([[self tableView] numberOfSelectedRows] > 0) {
        [[self buttonRemoveExclusion] setEnabled:YES];
    } else {
        [[self buttonRemoveExclusion] setEnabled:NO];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    NSString *stringValue = [[obj object] stringValue];
    long row = [[obj object] tag];
    if ([stringValue isNotEqualTo:@""]) {
        [[self excludedFiles] replaceObjectAtIndex:row
                                        withObject:stringValue];
        [[self settings] setObject:[self excludedFiles] forKey:kIdentifierForSettingsExcludedFiles];
    } else {
        [[self excludedFiles] removeObjectAtIndex:row];
        [[self tableView] reloadData];
    }
}

- (NSMutableArray *)excludedFiles {
    if (!_excludedFiles) {
        _excludedFiles = [[NSMutableArray alloc] init];
    }
    
    return _excludedFiles;
}

@end
