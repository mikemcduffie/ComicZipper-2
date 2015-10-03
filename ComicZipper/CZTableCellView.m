//
//  CZTableCellView.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 03/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZTableCellView.h"

@interface CZTableCellView ()

@property (nonatomic, strong) NSImageView *imageIconView;
@property (nonatomic, strong) NSTextField *textFieldTitle;
@property (nonatomic, retain) NSTextField *textFieldDetail;
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@property (nonatomic, readonly) float width;
@end

@implementation CZTableCellView

- (void)dealloc {
    // Remove any constraint on deallocation to prevent conflicts when tableview create new views.
    [[self superview] removeConstraints:[self constraints]];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    if (self) {
        _width = self.frame.size.width;
    }
    
    return self;
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
    [[self imageIconView] setImage:image];
}

- (void)setProgress:(double)progress {
    [[self progressIndicator] setDoubleValue:progress];
}

#pragma mark PRIVATE METHODS

- (NSTextField *)textFieldTitle {
    if (!_textFieldTitle) {
        _textFieldTitle = [self createTextFieldWithFrame: NSMakeRect(50, 15, [self width]-50, kColumnNormalHeight)
                                                fontName:@"Lucida Grande Bold"
                                                fontSize:13.0];
        [self addSubview:_textFieldTitle];
    }
    
    return _textFieldTitle;
}

- (NSTextField *)textFieldDetail {
    if (!_textFieldDetail) {
        [self removeProgressIndicatorFromSuperview];
        _textFieldDetail = [self createTextFieldWithFrame:NSMakeRect(50, 0, [self width]-50, kColumnDetailheight)
                                                fontName:@"Lucida Grande"
                                                fontSize:9.5];
        [self addSubview:_textFieldDetail];
    }
    
    return _textFieldDetail;
}

- (NSImageView *)imageIconView {
    if (!_imageIconView) {
        _imageIconView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 50, kTableColumnHeight)];
        [self addSubview:_imageIconView];
    }
    
    return _imageIconView;
}

- (NSProgressIndicator *)progressIndicator {
    if (!_progressIndicator) {
        [self removeTextFieldDetailFromSuperview];
        NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(50, 0, [self width]-50, kColumnDetailheight)];
        [progressIndicator setStyle:NSProgressIndicatorBarStyle];
        [progressIndicator setMinValue:0.0];
        [progressIndicator setMaxValue:1.0];
        [progressIndicator setDoubleValue:0.0];
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setDisplayedWhenStopped:YES];
        [progressIndicator setAutoresizesSubviews:YES];
        [progressIndicator setAutoresizingMask:NSViewWidthSizable];
        _progressIndicator = progressIndicator;
        [self addSubview:_progressIndicator];
    }
    
    return _progressIndicator;
}

- (NSTextField *)createTextFieldWithFrame:(NSRect)frame
                                 fontName:(NSString *)fontName
                                 fontSize:(float)fontSize {
    NSTextField *textField = [[NSTextField alloc] initWithFrame:frame];
    [textField setBordered:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [textField setDrawsBackground:NO];
    [textField setAllowsEditingTextAttributes:NO];
    [[textField cell] setTruncatesLastVisibleLine:YES];
    [[textField cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [textField setFont:[NSFont fontWithName:fontName size:fontSize]];
    [textField setAutoresizesSubviews:YES];
    [textField setAutoresizingMask:NSViewWidthSizable];
    return textField;
}

- (void)removeTextFieldDetailFromSuperview {
    if (_textFieldDetail) {
        [[self textFieldDetail] removeFromSuperview];
        [self setTextFieldDetail:nil];
    }
}

- (void)removeProgressIndicatorFromSuperview {
    if (_progressIndicator) {
        [[self progressIndicator] removeFromSuperview];
        [self setProgressIndicator:nil];
    }
}

@end
