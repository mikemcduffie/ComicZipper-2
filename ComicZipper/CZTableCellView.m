//
//  CZTableCellView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 03/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZTableCellView.h"
#import "CZTextField.h"
#import "CZStatusButton.h"
@interface CZTableCellView ()

@property (nonatomic, strong) NSButton *statusButton;
@property (nonatomic, strong) NSImageView *rightImageView;
@property (nonatomic, strong) NSImageView *statusIconView;
@property (nonatomic, strong) NSTextField *textFieldTitle;
@property (nonatomic, strong) NSTextField *textFieldDetail;
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
    [[self textFieldTitle] setStringValue:title];
}

- (void)setDetailText:(NSString *)detail {
    [[self textFieldDetail] setStringValue:detail];
}

- (void)setImage:(NSImage *)image {
    [[self rightImageView] setImage:image];
}

- (void)setStatus:(NSString *)status {
    if ([status isEqual:kStatusIconSuccess]) {
        [[self statusIconView] setImage:[NSImage imageNamed:status]];
    } else {
        [[self statusButton] setImage:[NSImage imageNamed:status]];
    }
}

- (void)setProgress:(double)progress {
    [[self progressIndicator] setDoubleValue:progress];
}

#pragma mark PRIVATE METHODS

- (NSTextField *)textFieldTitle {
    if (!_textFieldTitle) {
        _textFieldTitle = [CZTextField initWithFrame:NSMakeRect(0, 15, [self width], kSubviewNormalHeight)
                                         stringValue:@""
                                            fontName:@"Lucida Grande Bold"
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
                                             fontName:@"Lucida Grande"
                                             fontSize:9.5];
        [self addSubview:_textFieldDetail];
    }
    
    return _textFieldDetail;
}

- (NSImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableColumnHeight)];
        [self addSubview:_rightImageView];
    }
    
    return _rightImageView;
}


- (NSImageView *)statusIconView {
    if (!_statusIconView) {
        [self removeFromSuperview:&_statusButton];
        _statusIconView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableColumnHeight)];
        [self addSubview:_statusIconView];
    }
    
    return _statusIconView;
}

- (NSButton *)statusButton {
    if (!_statusButton) {
        [self removeFromSuperview:&_statusIconView];
        _statusButton = [[CZStatusButton alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableColumnHeight)];
        [_statusButton setBordered:NO];
        [_statusButton setButtonType:NSMomentaryChangeButton];
        [_statusButton setBezelStyle:NSRegularSquareBezelStyle];
        [_statusButton setHighlighted:NO];
        [self addSubview:_statusButton];
        NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
                                        initWithRect:[_statusButton bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:_statusButton userInfo:nil];
        [_statusButton addTrackingArea:trackingArea];
    }
    
    return _statusButton;
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
