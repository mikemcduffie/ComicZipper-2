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
@property (strong) IBOutlet NSView *viewFilters;
@property (strong) IBOutlet NSView *viewAdvanced;
@property (strong) IBOutlet NSToolbarItem *toolbarItemGeneral;
@property (strong) IBOutlet NSToolbarItem *toolbarItemFilters;
@property (strong) IBOutlet NSToolbarItem *toolbarItemAdvanced;
@property (strong) IBOutlet NSButton *checkBoxToggleNotification;
@property (strong) IBOutlet NSButton *checkBoxDelete;
@property (strong) IBOutlet NSButton *checkBoxNotify;
@property (strong) IBOutlet NSButton *checkBoxBadge;
@property (strong) IBOutlet NSButton *checkBoxSoundAlert;
@property (strong) IBOutlet NSButton *checkBoxAutoStart;
@property (strong) IBOutlet NSButton *buttonRemoveExclusion;
@property (strong) IBOutlet NSButton *checkBoxToggleExclusions;
@property (strong) IBOutlet NSButton *checkBoxExcludeHiddenFiles;
@property (strong) IBOutlet NSButton *checkBoxExcludeThumbs;
@property (strong) IBOutlet NSButton *checkBoxExcludeEmptyFolders;
@property (strong) IBOutlet NSButton *checkBoxExcludeEmptyFiles;
@property (strong) IBOutlet NSTextField *textFieldNotify;
@property (strong) IBOutlet NSTextField *textFieldSoundAlert;
@property (strong) IBOutlet NSTableView *tableViewExclusion;
@property (nonatomic) NSDictionary *checkBoxCollection;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSMutableArray *excludedFiles;
@property (nonatomic) NSArray *excludeCheckBoxArray;
@property (nonatomic) NSArray *notifyCheckBoxArray;
@end

@implementation CZSettingsController

NSString *const keyNotify = @"checkBoxToggleNotification.cell.state";
NSString *const keyFilter = @"checkBoxToggleExclusions.cell.state";
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
    // Set up the check boxes states
    [self setCheckBox:@"checkBoxDelete"
 stateAndIdentifierTo:kIdentifierForSettingsDeleteFolders];
    [self setCheckBox:@"checkBoxNotify"
 stateAndIdentifierTo:kIdentifierForSettingsUserNotification];
    [self setCheckBox:@"checkBoxBadge"
 stateAndIdentifierTo:kIdentifierForSettingsDockBadge];
    [self setCheckBox:@"checkBoxSoundAlert"
 stateAndIdentifierTo:kIdentifierForSettingsAlertSound];
    [self setCheckBox:@"checkBoxAutoStart"
 stateAndIdentifierTo:kIdentifierForSettingsAutoStart];
    [self setCheckBox:@"checkBoxExcludeThumbs"
 stateAndIdentifierTo:kIdentifierForSettingsExcludeThumbs];
    [self setCheckBox:@"checkBoxExcludeHiddenFiles"
 stateAndIdentifierTo:kIdentifierForSettingsExcludeHidden];
    [self setCheckBox:@"checkBoxExcludeEmptyFolders"
 stateAndIdentifierTo:kIdentifierForSettingsExcludeEmptyFolders];
    [self setCheckBox:@"checkBoxExcludeEmptyFiles"
 stateAndIdentifierTo:kIdentifierForSettingsExcludeEmptyFiles];
    
    [[[self toolbarItemGeneral] toolbar] setSelectedItemIdentifier:[[self toolbarItemGeneral] itemIdentifier]];
    
    NSDictionary *checkBoxCollection = @{ keyNotify : @[ [self checkBoxSoundAlert],
                                                         [self checkBoxNotify] ],
                                          keyFilter : @[ [self checkBoxExcludeThumbs],
                                                         [self checkBoxExcludeHiddenFiles],
                                                         [self checkBoxExcludeEmptyFolders],
                                                         [self checkBoxExcludeEmptyFiles] ]
                                          };
    [self setCheckBoxCollection:checkBoxCollection];
    [self setStateofParentCheckBox:[self checkBoxToggleNotification]
                       forChildren:[checkBoxCollection objectForKey:keyNotify]];
    [self setStateofParentCheckBox:[self checkBoxToggleExclusions]
                       forChildren:[checkBoxCollection objectForKey:keyFilter]];
    [self addObserver:self
           forKeyPath:keyNotify
              options:NSKeyValueObservingOptionNew
              context:nil];
    [self addObserver:self
           forKeyPath:keyFilter
              options:NSKeyValueObservingOptionNew
              context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    NSInteger state = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    for (NSButton *checkBox in [[self checkBoxCollection] objectForKey:keyPath]) {
        [checkBox setState:state];
        [self checkBoxClicked:checkBox];
    }
    
    if ([keyPath isEqualToString:keyNotify]) {
        NSColor *color = (state) ? [NSColor blackColor] : [NSColor grayColor];;
        [[self textFieldNotify] setTextColor:color];
        [[self textFieldSoundAlert] setTextColor:color];
    }
}

- (void)setStateOfCheckBox:(NSString *)checkBox
            withIdentifier:(NSString *)identifier {
    
}

- (void)setCheckBox:(NSString *)checkBoxName stateAndIdentifierTo:(NSString *)identifier {
    int state = [[[self settings] objectForKey:identifier] intValue];
    [[self valueForKey:checkBoxName] setIdentifier:identifier];
    [[self valueForKey:checkBoxName] setState:state];
}

- (void)setStateofParentCheckBox:(id)parent forChildren:(NSArray *)children {
    int count = 0;
    for (NSButton *child in children) {
        [child bind:@"enabled"
           toObject:parent
        withKeyPath:@"cell.state"
            options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                forKey:@"NSConditionallySetsEnabledBindingOption"]];
        if ([child state] == NSOnState) {
            count++;
        }
    }
    
    if (count > 0) {
        [parent setState:NSOnState];
    } else {
        [parent setState:NSOffState];
    }
}

#pragma mark USER INTERFACE METHODS

- (IBAction)switchView:(id)sender {
    NSView *view = [[self window] contentView];
    NSView *viewToReplace = [[view subviews] firstObject];
    if ([sender isEqualTo:[self toolbarItemGeneral]]) {
        [view replaceSubview:viewToReplace with:[self viewGeneral]];
    } else if ([sender isEqualTo:[self toolbarItemFilters]]) {
        [view replaceSubview:viewToReplace with:[self viewFilters]];
    } else {
        [view replaceSubview:viewToReplace with:[self viewAdvanced]];
    }
}

- (IBAction)checkBoxClicked:(id)sender {
    NSNumber *checkValue = ([sender state] != NSOnState) ? @NO : @YES;
    [[self settings] setObject:checkValue forKey:[sender identifier]];
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
    [[self excludedFiles] removeObjectsAtIndexes:indexes];
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
