//
//  CZTableCellView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 17/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZTableCellView.h"
#import "CZStatusButton.h"
#import "CZTextField.h"


@interface CZTableCellView ()

@property (nonatomic, strong) NSImageView *imageViewLeft;
@property (nonatomic, strong) NSImageView *imageViewRight;
@property (nonatomic, strong) CZTextField *textFieldTitle;
@property (nonatomic, strong) CZTextField *textFieldDetail;
@property (nonatomic, strong) CZStatusButton *buttonStatus;
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@property (nonatomic, readonly) float width;

@end

@implementation CZTableCellView

@synthesize width = _width;

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        _width = self.frame.size.width;
    }
    
    return self;
}

#pragma mark PUBLIC METHODS

- (float)width {
    // Make sure the object widths are always up to date. Otherwise, a cell already in place will have the original width even after window has resized.
    if (_width < self.frame.size.width) {
        _width = self.frame.size.width;
    }
    return _width;
}


- (void)setWidth:(float)width {
    _width = width;
}

- (void)setTitleText:(NSString *)title {
    [self.textFieldTitle setStringValue:title];
}

- (void)setDetailText:(NSString *)detail {
    [self.textFieldDetail setStringValue:detail];
}

- (void)setImage:(NSImage *)image {
    [self.imageViewLeft setImage:image];
}

- (void)setStatus:(NSString *)status {
    if ([status isEqual:CZStatusIconAbortNormal]) {
        [self.buttonStatus setImage:[NSImage imageNamed:status]];
    } else {
        [self.imageViewRight setImage:[NSImage imageNamed:status]];
    }
}

- (void)setAction:(SEL)selector forTarget:(id)sender {
    [self.buttonStatus setTarget:sender];
    [self.buttonStatus setAction:selector];
    [self.buttonStatus setRowIndex:self.rowIndex];
}

- (void)setProgress:(double)progress {
    [[self progressIndicator] setDoubleValue:progress];
}


#pragma mark SETTERS AND GETTERS

- (NSTextField *)textFieldTitle {
    if (!_textFieldTitle) {
        _textFieldTitle = [CZTextField initWithFrame:NSMakeRect(0, 15, [self width], kSubviewNormalHeight)
                                         stringValue:@""
                                            fontName:@"Helvetica"
                                            fontSize:13.0];
        [self addSubview:_textFieldTitle];
    }
    
    return _textFieldTitle;
}

- (NSTextField *)textFieldDetail {
    if (!_textFieldDetail) {
        [self removeFromSuperview:&_progressIndicator];
        _textFieldDetail = [CZTextField initWithFrame:NSMakeRect(0, 0, [self width], kSubviewDetailheight)
                                          stringValue:@""
                                             fontName:@"Helvetica"
                                             fontSize:9.5];
        [self addSubview:_textFieldDetail];
    }
    
    return _textFieldDetail;
}

- (NSImageView *)imageViewLeft {
    if (!_imageViewLeft) {
        _imageViewLeft = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableRowHeight)];
        [self addSubview:_imageViewLeft];
    }
    
    return _imageViewLeft;
}


- (NSImageView *)imageViewRight {
    if (!_imageViewRight) {
        [self removeFromSuperview:&_buttonStatus];
        _imageViewRight = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableRowHeight)];
        [self addSubview:_imageViewRight];
    }
    
    return _imageViewRight;
}

- (NSButton *)buttonStatus {
    if (!_buttonStatus) {
        [self removeFromSuperview:&_imageViewRight];
        _buttonStatus = [[CZStatusButton alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableRowHeight)];
        [_buttonStatus setBordered:NO];
        [_buttonStatus setButtonType:NSMomentaryChangeButton];
        [_buttonStatus setBezelStyle:NSRegularSquareBezelStyle];
        [_buttonStatus setHighlighted:NO];
        [self addSubview:_buttonStatus];
        NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:[_buttonStatus bounds]
                                                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                                      owner:_buttonStatus
                                                                   userInfo:nil];
        [_buttonStatus addTrackingArea:trackingArea];
    }
    
    return _buttonStatus;
}

- (NSProgressIndicator *)progressIndicator {
    if (!_progressIndicator) {
        [self removeFromSuperview:&_textFieldDetail];
        NSRect frame = NSMakeRect(0, 0, [self width], kSubviewDetailheight);
        NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:frame];
        [progressIndicator setStyle:NSProgressIndicatorBarStyle];
        [progressIndicator setMinValue:0.0];
        [progressIndicator setMaxValue:1.0];
        [progressIndicator setDoubleValue:0.0];
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setDisplayedWhenStopped:YES];
        [progressIndicator setAutoresizingMask:NSViewWidthSizable];
        _progressIndicator = progressIndicator;
        [self addSubview:_progressIndicator];
    }
    
    return _progressIndicator;
}

- (void)removeFromSuperview:(id __strong *)view {
    // Need the strong storage qualifier __strong for pass by reference to work.
    if (*view) {
        [*view removeFromSuperview];
        *view = nil;
    }
}

@end
