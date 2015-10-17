//
//  CZWindowController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZWindowController.h"
#import "CZTableViewController.h"
#import "CZMainViewController.h"
#import "CZDropView.h"

@interface CZWindowController () <CZDropViewDelegate>

@property (nonatomic, strong) CZDropView *dropView;
@property (nonatomic, strong) NSViewController *currentViewController;
@property (nonatomic, strong) CZMainViewController *mainViewController;
@property (nonatomic, strong) CZTableViewController *tableViewController;
@property (nonatomic) NSInteger applicationState;
@property (nonatomic) NSArray *droppedItems;

@end

@implementation CZWindowController

NSString *const windowNibName = @"Window";
NSString *const mainViewNibName = @"MainView";
NSString *const tableViewNibName = @"TableView";

+ (instancetype)initWithApplicationState:(NSInteger)applicationState {
    return [[super alloc] initWithWindowNibName:windowNibName
                               applicationState:applicationState];
}

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
                     applicationState:(NSInteger)applicationState {
    self = [super initWithWindowNibName:windowNibName];
    
    if (self) {
        _applicationState = applicationState;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.dropView = self.window.contentView;
    self.dropView.delegate = self;
    [self loadView];
}

- (void)loadView {
    switch ([self applicationState]) {
        case CZApplicationStateNoItemDropped:
            self.currentViewController = self.mainViewController;
            break;
        case CZApplicationStateFirstItemDrop:
            self.currentViewController = self.tableViewController;
            break;
        case CZApplicationStatePopulatedList:
            if ([self isCurrentViewController:tableViewNibName]) {
                [self.delegate reloadData];
            } else {
                self.applicationState = CZApplicationStateFirstItemDrop;
                [self loadView];
            }
            break;
        default:
            self.currentViewController = self.mainViewController;
            break;
    }

    if ([self applicationStateIs:CZApplicationStatePopulatedList]) {
        if ([self isCurrentViewController:tableViewNibName]) {
            [self.delegate reloadData];
        } else {
            self.applicationState = CZApplicationStateFirstItemDrop;
            [self loadView];
        }
    } else {
        // Set the identifier of the current view to the nibname
        self.currentViewController.identifier = self.currentViewController.nibName;
        [self.dropView addSubview:self.currentViewController.view];
        [self.currentViewController.view setFrame:self.dropView.bounds];
        [self setConstraintsForView];
        [self viewDidLoad];
    }
}

- (void)viewDidLoad {
    NSColor *backgroundColor;
    
    if ([self isCurrentViewController:tableViewNibName]) {
        backgroundColor = [NSColor controlHighlightColor];
    } else {
        backgroundColor = [NSColor whiteColor];
    }

    self.window.backgroundColor = backgroundColor;
}

- (BOOL)isCurrentViewController:(NSString *)identifier {
    return (self.currentViewController.identifier == identifier);
}
        
#pragma mark DROP VIEW DELEGATE METHODS

- (void)dropView:(CZDropView *)dropView viewShouldHighlight:(BOOL)highlight {
    [self.delegate viewShouldHighlight:highlight];
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)item {
    if ([self isCurrentViewController:tableViewNibName]) {
        return [self.delegate isItemInList:item];
    } else {
        return NO;
    }
}

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)files {
    if ([self isCurrentViewController:tableViewNibName]) {
        self.applicationState = CZApplicationStatePopulatedList;
    } else {
        self.applicationState = CZApplicationStateFirstItemDrop;
    }
    
    [self loadView];
    [self.delegate addItemsFromArray:files];
}

#pragma mark GETTERS AND SETTERS METHODS

- (CZMainViewController *)mainViewController {
    if (!_mainViewController) {
        _mainViewController = [[CZMainViewController alloc] initWithNibName:mainViewNibName bundle:nil];
        self.delegate = _mainViewController;
    }
    return _mainViewController;
}

- (CZTableViewController *)tableViewController {
    if (!_tableViewController) {
        _tableViewController = [[CZTableViewController alloc] initWithNibName:tableViewNibName bundle:nil];
        self.delegate = _tableViewController;
    }
    return _tableViewController;
}

#pragma mark PRIVATE METHODS

- (BOOL)applicationStateIs:(NSInteger)state {
    return ([self applicationState] == state);
}


#pragma mark CONSTRAINT VIEW METHODS

- (void)setConstraintsForView {
    NSView *subView = self.currentViewController.view;
    NSView *supView = self.dropView;
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSArray *trailing = [self constraintWithItem:supView
                                      attributes:@[[NSNumber numberWithInt:NSLayoutAttributeTrailing],
                                                   [NSNumber numberWithInt:NSLayoutAttributeBottom]]
                                          toItem:subView
                                      multiplier:1
                                        constant:0];
    NSArray *leading = [self constraintWithItem:subView
                                     attributes:@[[NSNumber numberWithInt:NSLayoutAttributeLeading],
                                                  [NSNumber numberWithInt:NSLayoutAttributeTop]]
                                         toItem:supView
                                     multiplier:1
                                       constant:0];
    [supView addConstraints:trailing];
    [supView addConstraints:leading];
}

- (NSArray *)constraintWithItem:(NSView *)firstItem
                     attributes:(NSArray *)attributes
                         toItem:(NSView*)secondItem
                     multiplier:(float)multiplier
                       constant:(float)constant {
    NSMutableArray *constraints = [NSMutableArray array];
    for (id attribute in attributes) {
        NSLayoutConstraint *constraint = [self constraintWithItem:firstItem
                                                        attribute:[attribute integerValue]
                                                           toItem:secondItem
                                                       multiplier:multiplier
                                                         constant:constant];
        [constraints addObject:constraint];
    }
    return [constraints copy];
}

- (NSLayoutConstraint *)constraintWithItem:(NSView *)firstItem
                                 attribute:(NSLayoutAttribute)attribute
                                    toItem:(NSView*)secondItem
                                multiplier:(float)multiplier
                                  constant:(float)constant {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:secondItem
                                                                  attribute:attribute
                                                                 multiplier:multiplier
                                                                   constant:constant];
    return constraint;
}

@end
