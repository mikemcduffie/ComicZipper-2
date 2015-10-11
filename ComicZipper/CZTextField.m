//
//  CZTextField.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 04/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import "CZTextField.h"

@implementation CZTextField


+ (instancetype)initWithFrame:(NSRect)frame
                  stringValue:(NSString *)stringValue
                     fontName:(NSString *)fontName
                     fontSize:(float)fontSize {
    return [[self alloc] initWithFrame:frame
                           stringValue:stringValue
                              fontName:fontName
                              fontSize:fontSize];
}

+ (instancetype)initWithFrame:(NSRect)frame
                  stringValue:(NSString *)stringValue
                     fontName:(NSString *)fontName
                     fontSize:(float)fontSize
                    fontStyle:(NSFontTraitMask)fontStyle {
    CZTextField *textField = [self initWithFrame:frame
                                     stringValue:stringValue
                                        fontName:fontName
                                        fontSize:fontSize];
    
    if (textField) {
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *font = [fontManager fontWithFamily:fontName
                                            traits:fontStyle
                                            weight:0
                                              size:fontSize];
        [textField setFont:font];
    }
    
    return textField;
}

- (instancetype)initWithFrame:(NSRect)frame
                  stringValue:(NSString *)stringValue
                     fontName:(NSString *)fontName
                     fontSize:(float)fontSize {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBordered:NO];
        [self setEditable:NO];
        [self setSelectable:NO];
        [self setDrawsBackground:NO];
        [self setStringValue:stringValue];
        [self setAllowsEditingTextAttributes:NO];
        [self setAutoresizingMask:NSViewWidthSizable];
        [[self cell] setTruncatesLastVisibleLine:YES];
        [[self cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [self setFont:[NSFont fontWithName:fontName size:fontSize]];
    }
    
    return self;
}

@end
