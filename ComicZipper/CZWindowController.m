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
#import "CZDropItem.h"
#import <Quartz/Quartz.h>

@interface CZWindowController () <CZDropViewDelegate>

@property (nonatomic, strong) NSToolbar *toolBar;
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
        self.window.titleVisibility = NSWindowTitleHidden;
        [self setWindowState];
        _applicationState = applicationState;
        _toolBar = self.window.toolbar;
    }
    
    return self;
}

- (void)setWindowState {
    NSRect frame = [self loadLastWindowState];
    if (!NSIsEmptyRect(frame)) {
        [self.window setFrame:frame display:YES];
    }
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
            [self changeToolbarItems:CZToolbarClearItem];
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

#pragma mark TOOLBAR METHODS 

- (IBAction)toolbarButtonClearWasClicked:(id)sender {
    [self.tableViewController viewWillUnload];
    [self removeTableView];
}

- (IBAction)toolbarButtonCancelWasClicked:(id)sender {
    [self.tableViewController cancelAllItems];
}

#pragma mark NOTIFICATION METHODS

- (void)didReceiveNotification:(NSNotification *)notification {
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:CZToggleDragModeNotification]) {
        [self toggleDragMode];
    } else if ([notificationName isEqualToString:CZChangeViewNotification]) {
        [self removeTableView];
    } else if ([notificationName isEqualToString:CZCompressionDoneNotification]) {
        [self compressionDidFinish];
    } else if ([notificationName isEqualToString:CZCompressionStartNotification]) {
        [self changeToolbarItems:CZToolbarCancelItem];
    }
}

- (void)toggleDragMode {
    self.dropView.dragMode = !self.dropView.dragMode;
}

- (void)removeTableView {
    self.applicationState = CZApplicationStateNoItemDropped;
    [self changeToolbarItems:CZToolbarNoItem];
    [self loadView];
}

- (void)changeToolbarItems:(CZToolbarItems)toolbarItem {
    [self.toolBar removeItemAtIndex:5];
    [self.toolBar insertItemWithItemIdentifier:ToolbarItem(toolbarItem) atIndex:5];
}

- (void)compressionDidFinish {
    if ([self isApplicationActive]) {
        [self notifyByAlertSound];
    } else {
        [self notifyByNotification];
    }
    // Check if app should automatically quit after compression.
    if ([self shouldQuitApplication]) {
        [NSApplication.sharedApplication terminate:self];
    }
    
    [self changeToolbarItems:CZToolbarClearItem];
}

- (void)notifyByAlertSound {
    if ([self shouldSoundAlert]) {
        [[NSSound soundNamed:CZDefaultNotifySoundName] play];
    }
}

- (void)notifyByNotification {
    if ([self shouldNotifyUser]) {
        NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        NSString *informativeText = [NSString stringWithFormat:@"%li item(s) compressed!", [self.delegate numberOfItemsCompressed]];
        [notification setTitle:CZApplicationName];
        [notification setInformativeText:informativeText];
        [notification setSoundName:CZDefaultNotifySoundName];
        [notificationCenter deliverNotification:notification];
    }
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

#pragma mark DOCK ICON DROP METHODS

- (void)addItemsDraggedToDock:(NSArray *)items {
    NSMutableArray *validItems = [NSMutableArray array];
    __block BOOL failed = NO;
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isDir;
        // Check if the dropped file is a directory
        if ([[NSFileManager alloc] fileExistsAtPath:obj isDirectory:&isDir] && isDir) {
            // Get the fileURL and create a DropItem object.
            CZDropItem *item = [CZDropItem initWithURL:[NSURL fileURLWithPath:obj isDirectory:YES]];
            // Check if the dragged item is already in the archiveItems array.
            if (item != nil && ![self dropView:nil isItemInList:[obj description]]) {
                [validItems addObject:item];
            } else {
                failed = YES;
            }
        } else {
            failed = YES;
        }
    }];
    if ([validItems count]) {
        [self dropView:nil didReceiveFiles:validItems];
    }
    if (failed) {
        [self shakeWindow];
    }
}

/*!
 *  @brief Creates an animation simulating a shake.
 */
- (NSDictionary *)shakeAnimation:(NSRect)windowFrame {
    // Borrowed from cimgf.com/2008/02/27/core-animation-tutorial-window-shake-effect/
    // Set the shake properties
    int numberOfShakes = 3;
    float shakesDuration = 0.5f;
    float shakesVigor = 0.05f;
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, nil, NSMinX(windowFrame), NSMinY(windowFrame));
    for (NSInteger i = 0; i < numberOfShakes; i++) {
        float positionOfX = windowFrame.size.width * shakesVigor;
        CGPathAddLineToPoint(shakePath, nil, NSMinX(windowFrame) - positionOfX, NSMinY(windowFrame));
        CGPathAddLineToPoint(shakePath, nil, NSMinX(windowFrame) + positionOfX, NSMinY(windowFrame));
    }
    CGPathCloseSubpath(shakePath);
    [shakeAnimation setPath:shakePath];
    [shakeAnimation setDuration:shakesDuration];
    
    return [NSDictionary dictionaryWithObject:shakeAnimation
                                       forKey:@"frameOrigin"];
}
/*!
 *  @brief Shakes the window
 *  @discussion Calls the shakeAnimation: method.
 */
- (void)shakeWindow {
    NSWindow *window = self.window;
    NSDictionary *animations = [self shakeAnimation:[window frame]];
    [window setAnimations:animations];
    [[window animator] setFrameOrigin:window.frame.origin];
    
}

#pragma mark GETTERS AND SETTERS METHODS

- (CZMainViewController *)mainViewController {
    if (!_mainViewController) {
        _mainViewController = [[CZMainViewController alloc] initWithNibName:mainViewNibName bundle:nil];
        self.delegate = _mainViewController;
        if (_tableViewController != nil) {
            [self removeNotification:CZToggleDragModeNotification
                                view:_tableViewController];
            [self removeNotification:CZChangeViewNotification
                                view:_tableViewController];
            [self removeNotification:CZCompressionDoneNotification
                                view:_tableViewController];
            [self removeNotification:CZCompressionStartNotification
                                view:_tableViewController];
            _tableViewController = nil;
        }
    }
    return _mainViewController;
}

- (CZTableViewController *)tableViewController {
    if (!_tableViewController) {
        _tableViewController = [[CZTableViewController alloc] initWithNibName:tableViewNibName bundle:nil];
        self.delegate = _tableViewController;
        [self addNotification:CZToggleDragModeNotification
                     selector:@selector(didReceiveNotification:)
                         view:_tableViewController];
        [self addNotification:CZChangeViewNotification
                     selector:@selector(didReceiveNotification:)
                         view:_tableViewController];
        [self addNotification:CZCompressionDoneNotification
                     selector:@selector(didReceiveNotification:)
                         view:_tableViewController];
        [self addNotification:CZCompressionStartNotification
                     selector:@selector(didReceiveNotification:)
                         view:_tableViewController];
        if (_mainViewController != nil) {
            _mainViewController = nil;
        }
    }
    return _tableViewController;
}

- (BOOL)isRunning {
    if (!_tableViewController) {
        return NO;
    }
    
    return [self.delegate hasProcessFinished];
}

#pragma mark NOTIFICATION METHODS

- (void)addNotification:(NSString *)notificationName
               selector:(SEL)selector
                   view:(id)view  {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:selector
                                               name:notificationName
                                             object:view];
}

- (void)removeNotification:(NSString *)notificationName
                      view:(id)view {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:notificationName
                                                object:view];
}

#pragma mark STATE AND SETTINGS METHODS

- (BOOL)applicationStateIs:(NSInteger)state {
    return ([self applicationState] == state);
}

- (BOOL)isApplicationActive {
    return [NSApplication.sharedApplication isActive];
}

- (BOOL)shouldSoundAlert {
    return [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsAlertSound];
}

- (BOOL)shouldNotifyUser {
    return [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsNotifications];
}

- (BOOL)shouldQuitApplication {
    return [NSUserDefaults.standardUserDefaults boolForKey:CZSettingsAutoQuit];
}

- (NSRect)loadLastWindowState {
    return NSRectFromString([NSUserDefaults.standardUserDefaults objectForKey:CZSettingsWindowState]);
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
