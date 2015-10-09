//
//  CZSettingsController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 04/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZSettingsController.h"
#import <QuartzCore/QuartzCore.h>

@interface CZSettingsController () <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (strong) IBOutlet NSView *viewGeneral;
@property (strong) IBOutlet NSView *viewAlerts;
@property (strong) IBOutlet NSView *viewAdvanced;
@property (strong) IBOutlet NSToolbarItem *toolbarItemGeneral;
@property (strong) IBOutlet NSToolbarItem *toolbarItemAlerts;
@property (strong) IBOutlet NSToolbarItem *toolbarItemAdvanced;
@property (strong) IBOutlet NSButton *checkBoxToggleNotification;
@property (strong) IBOutlet NSButton *checkBoxDelete;
@property (strong) IBOutlet NSButton *checkBoxNotify;
@property (strong) IBOutlet NSButton *checkBoxBadge;
@property (strong) IBOutlet NSButton *checkBoxSoundAlert;
@property (strong) IBOutlet NSButton *checkBoxReplaceIcon;
@property (strong) IBOutlet NSButton *checkBoxAutoStart;
@property (strong) IBOutlet NSTextField *textFieldNotify;
@property (strong) IBOutlet NSTextField *textFieldSoundAlert;
@property (strong) IBOutlet NSButton *buttonRemoveExclusion;
@property (strong) IBOutlet NSTableView *tableViewExclusion;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSMutableArray *excludedFiles;

@end

@implementation CZSettingsController

const int kTableCellViewHeight = 20;

#pragma mark STARTUP METHODS

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                   settingsDictionary:(NSMutableDictionary *)settings {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        _settings = settings;
        // Initialize with the generals tab
        [[[self window] contentView] addSubview:[self viewGeneral]];
    }
    
    return self;
}

- (void)windowWillLoad {
    // Load the excluded files settings
    NSArray *excludedFiles = [[self settings] objectForKey:kIdentifierForSettingsExcludedFiles];
    [self setExcludedFiles:[excludedFiles mutableCopy]];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self tableViewExclusion] setDelegate:self];
    [[self tableViewExclusion] setDataSource:self];
    [self setCheckBox:@"checkBoxDelete" identifierAndStateTo:kIdentifierForSettingsDeleteFolders];
    [self setCheckBox:@"checkBoxNotify" identifierAndStateTo:kIdentifierForSettingsUserNotification];
    [self setCheckBox:@"checkBoxBadge" identifierAndStateTo:kIdentifierForSettingsDockBadge];
    [self setCheckBox:@"checkBoxSoundAlert" identifierAndStateTo:kIdentifierForSettingsAlertSound];
    [self setCheckBox:@"checkBoxReplaceIcon" identifierAndStateTo:kIdentifierForSettingsReplaceIcon];
    [self setCheckBox:@"checkBoxAutoStart" identifierAndStateTo:kIdentifierForSettingsAutoStart];
    [[[self toolbarItemGeneral] toolbar] setSelectedItemIdentifier:[[self toolbarItemGeneral] itemIdentifier]];
    
    if ([[self checkBoxSoundAlert] state] == NSOnState || [[self checkBoxNotify] state] == NSOnState) {
        [[self checkBoxToggleNotification] setState:1];
    } else {
        [[self checkBoxToggleNotification] setState:0];
    }
    [self setStateOfNotificationCheckBoxes:[self checkBoxToggleNotification]];
    
}

- (void)setCheckBox:(NSString *)checkBoxName identifierAndStateTo:(NSString *)identifier {
    int state = [[[self settings] objectForKey:identifier] intValue];
    [[self valueForKey:checkBoxName] setIdentifier:identifier];
    [[self valueForKey:checkBoxName] setState:state];
}

#pragma mark USER INTERFACE METHODS

- (IBAction)switchView:(id)sender {
    NSView *view = [[self window] contentView];
    NSView *viewToReplace = [[view subviews] firstObject];
    if ([sender isEqualTo:[self toolbarItemGeneral]]) {
        [view replaceSubview:viewToReplace with:[self viewGeneral]];
    } else if ([sender isEqualTo:[self toolbarItemAlerts]]) {
        [view replaceSubview:viewToReplace with:[self viewAlerts]];
    } else {
        [view replaceSubview:viewToReplace with:[self viewAdvanced]];
    }
}

- (IBAction)checkBoxClicked:(id)sender {
    NSNumber *checkValue = [NSNumber numberWithBool:YES];
    if ([sender state] != NSOnState) {
        checkValue = @NO;
    }
    [[self settings] setObject:checkValue forKey:[sender identifier]];
}

- (IBAction)toggleNotifications:(id)sender {
    [[self checkBoxNotify] setState:[sender state]];
    [[self checkBoxSoundAlert] setState:[sender state]];
    [self checkBoxClicked:[self checkBoxNotify]];
    [self checkBoxClicked:[self checkBoxSoundAlert]];
    [self setStateOfNotificationCheckBoxes:sender];
}

- (void)setStateOfNotificationCheckBoxes:(id)sender {
    NSNumber *checkValue = [NSNumber numberWithBool:YES];
    NSColor *fieldColor = [NSColor blackColor];
    if ([sender state] != NSOnState) {
        checkValue = @NO;
        fieldColor = [NSColor grayColor];
    }
    
    [[self checkBoxNotify] setEnabled:[checkValue boolValue]];
    [[self checkBoxSoundAlert] setEnabled:[checkValue boolValue]];
    // Disable/enable their respective boxes too
    [[self textFieldNotify] setTextColor:fieldColor];
    [[self textFieldSoundAlert] setTextColor:fieldColor];
}

- (IBAction)addExclusion:(id)sender {
    // Make sure not to create multiple empty entries in the array.
    if (![[self excludedFiles] doesContain:@""]) {
        [[self excludedFiles] addObject:@""];
        [[self tableViewExclusion] reloadData];
    }
    [self selectLastTableViewRow];
}

- (IBAction)removeExclusion:(id)sender {
    NSIndexSet *indexes = [[self tableViewExclusion] selectedRowIndexes];
    [[self tableViewExclusion] removeRowsAtIndexes:indexes
                                     withAnimation:NO];
    NSArray *objectsToRemove = [[self excludedFiles] objectsAtIndexes:indexes];
    [[[self settings] objectForKey:kIdentifierForSettingsExcludedFiles] removeObjectsInArray:objectsToRemove];
    [[self tableViewExclusion] reloadData];
}

#pragma mark DELEGATE METHODS

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

- (CGFloat)tableView:(NSTableView *)tableView
         heightOfRow:(NSInteger)row {
    return kTableCellViewHeight;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self excludedFiles] count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([[self tableViewExclusion] numberOfSelectedRows] > 0) {
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
        [[self tableViewExclusion] reloadData];
    }
}

#pragma mark MISC METHODS

- (void)selectLastTableViewRow {
    NSTableCellView *view = [[self tableViewExclusion] viewAtColumn:0
                                                       row:[[self excludedFiles] count]-1
                                           makeIfNecessary:YES];
    NSRange selectedRange = NSMakeRange(0, 0);
    [[view textField] selectText:self];
    [[[view textField] currentEditor] setSelectedRange:selectedRange];
}

- (NSMutableArray *)excludedFiles {
    if (!_excludedFiles) {
        _excludedFiles = [[NSMutableArray alloc] init];
    }
    
    return _excludedFiles;
}

@end
