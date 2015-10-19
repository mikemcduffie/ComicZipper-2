//
//  CZSettingsController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 19/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZSettingsController.h"

@interface CZSettingsController ()

@property (strong) IBOutlet NSToolbar *toolbar;
@property (strong) IBOutlet NSToolbarItem *toolbarItemGeneral;
@property (strong) IBOutlet NSToolbarItem *toolbarItemFilters;
@property (strong) IBOutlet NSToolbarItem *toolbarItemAdvanced;
@property (strong) IBOutlet NSView *viewGeneral;
@property (strong) IBOutlet NSView *viewFilters;
@property (strong) IBOutlet NSView *viewAdvanced;

@end

@implementation CZSettingsController

- (instancetype)init {
    self = [super initWithWindowNibName:@"Settings" owner:self];
    
    if (self) {
        [self.window.contentView addSubview:self.viewGeneral];
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.toolbar.selectedItemIdentifier = self.toolbarItemGeneral.itemIdentifier;
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

@end
