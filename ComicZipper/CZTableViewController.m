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
#import "ComicZipper.h"

@interface CZTableViewController () <CZWindowControllerDelegate, NSTableViewDelegate>

@property (strong) IBOutlet CZScrollView *scrollView;
@property (strong) IBOutlet CZTableView *tableView;
@property (strong) ComicZipper *comicZipper;

@end

@implementation CZTableViewController

@synthesize comicZipper = _comicZipper;

const float kTableRowHeight = 40;

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

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark TABLE VIEW DELEGATE METHODS

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return kTableRowHeight;
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
