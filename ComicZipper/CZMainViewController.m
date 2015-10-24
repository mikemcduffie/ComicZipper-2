//
//  CZViewController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 16/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZMainViewController.h"
#import "CZWindowController.h"

@interface CZMainViewController () <CZWindowControllerDelegate>

@property (strong) IBOutlet NSImageView *imageView;

@end

@implementation CZMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // The image must be unregistered as a possible destination in a dragging session.
    // Otherwise, dragged items that hover over the image will not by detected by the dropview.
    [self.imageView unregisterDraggedTypes];
}

#pragma mark WINDOW CONTROLLER DELEGATE METHODS

- (void)viewShouldHighlight:(BOOL)highlight {
    if (highlight) {
        self.imageView.image = [NSImage imageNamed:CZDropViewHighlightImage];
    } else {
        self.imageView.image = [NSImage imageNamed:CZDropViewNoHighlightImage];
    }
}

@end
