//
//  CZTextField.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 04/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZTextField : NSTextField

+ (instancetype)initWithFrame:(NSRect)frame
                  stringValue:(NSString *)stringValue
                     fontName:(NSString *)fontName
                     fontSize:(float)fontSize;
+ (instancetype)initWithFrame:(NSRect)frame
                  stringValue:(NSString *)stringValue
                     fontName:(NSString *)fontName
                     fontSize:(float)fontSize
                    fontStyle:(NSFontTraitMask)fontStyle;
- (instancetype)initWithFrame:(NSRect)frame
                  stringValue:(NSString *)stringValue
                     fontName:(NSString *)fontName
                     fontSize:(float)fontSize;

@end
