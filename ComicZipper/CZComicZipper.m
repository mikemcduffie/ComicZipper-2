//
//  CZComicZipper.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "Constants.h"
#import "CZComicZipper.h"
#import "CZAppDelegate.h"
#import "CZDropView.h"

@interface CZComicZipper () <CZDropViewDelegate>

@property (weak) NSView *superView;
@property (weak) CZDropView *dropView;
@property (nonatomic, readonly) int applicationState;
@property (nonatomic, readonly) NSRect frameSize;

@end

@implementation CZComicZipper

/*!
 *  @brief Initializes the class before it receives its first message.
 *  @discussion Convenience method for the initWithState: instance method.
 *  @param applicationState The application state.
 *  @return An initialized Comic Zipper object, or nil if the object could not be initialized.
 */
+ (instancetype)initWithState:(int)applicationState {
    return [[self alloc] initWithState:applicationState];
}

/*!
 *  @brief Initializes and returns a Comic Zipper object in a given state.
 *  @discussion The application state can be one of three constants: kAppStateFirstLaunched, kAppStateFirstFileDrop or kAppStateFileDrop.
 *  @param applicationState The application state.
 *  @return An initialized Comic Zipper object, or nil if the object could not be initialized.
 */
- (instancetype)initWithState:(int)applicationState {
    self = [super init];
    
    if (self) {
        _applicationState = applicationState;
        _superView = [kCZAppDelegate superView];
    }
    
    return self;
}

/*!
 *  @brief Creates the user interface elements.
 *  @discussion The specific user interface elements created depend on the state of the application.
 */
- (void)drawUIElements {
    // Initialize the drop view if it already isn't initialized
    if (![self dropView]) {
        [self addDropView];
    }
    if ([self applicationStateIs:kAppStateFirstLaunched]) {
        
    } else if ([self applicationStateIs:kAppStateFirstFileDrop]) {
        
    } else {
    }
}

- (BOOL)applicationStateIs:(int)applicationState {
    return ([self applicationState] == applicationState);
}

#pragma marks UI METHODS

- (void)addDropView {
    CZDropView *dropView = [[CZDropView alloc] initWithFrame:[[self superView] frame]];
    [self setDropView:dropView];
    [[self dropView] setDelegate:self];
    [[self dropView] setDragMode:YES];
    [[self dropView] setAutoresizesSubviews:YES];
    [[self dropView] setFocusRingType:NSFocusRingTypeExterior];
    [[self dropView] setDragMode:YES];
    [[self dropView] setDelegate:self];
    [[self superView] addSubview:[self dropView]];
    [[self dropView] setTranslatesAutoresizingMaskIntoConstraints:NO];
}

#pragma marks

- (void)dropView:(CZDropView *)dropView didReceiveFiles:(NSArray *)items {
    
}

- (BOOL)dropView:(CZDropView *)dropView isItemInList:(NSString *)description {
    return YES;
}

- (BOOL)isDropViewFront {
    return YES;
}

@end
