//
//  CZWindowController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZWindowController.h"
#import "CZDropView.h"
#import "CZTableViewController.h"
#import "CZMainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CZWindowController ()

@property (nonatomic, strong) CZDropView *dropView;
@property (nonatomic, strong) NSViewController *currentViewController;
@property (nonatomic, strong) CZMainViewController *mainViewController;
@property (nonatomic, strong) CZTableViewController *tableViewController;
@property (nonatomic) NSInteger applicationState;

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
    _dropView = [[self window] contentView];
    [super windowDidLoad];
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
            // RELOAD TABLEVIEW
            break;
        default:
            break;
    }
    [self.dropView addSubview:self.currentViewController.view];
    [self.currentViewController.view setFrame:self.dropView.bounds];
    [self setConstraintsForView];
}

- (void)viewDidLoad {
    
}

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

#pragma mark GETTERS AND SETTERS METHODS

- (CZMainViewController *)mainViewController {
    if (!_mainViewController) {
        _mainViewController = [[CZMainViewController alloc] initWithNibName:mainViewNibName bundle:nil];
    }
    return _mainViewController;
}

- (CZTableViewController *)tableViewController {
    if (!_tableViewController) {
        _tableViewController = [[CZTableViewController alloc] initWithNibName:tableViewNibName bundle:nil];
    }
    return _tableViewController;
}


@end
