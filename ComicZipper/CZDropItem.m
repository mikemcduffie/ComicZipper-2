/*!
 *  CZDropItem.m
 *  ComicZipper
 *
 *  Created by Ardalan Samimi on 15/10/15.
 *  Copyright © 2015 Saturn Five. All rights reserved.
 */

#import "CZDropItem.h"

@implementation CZDropItem

+ (NSArray<NSString *> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [NSArray arrayWithObjects:(id)kUTTypeURL, nil];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type
                                         pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsString;
}

- (instancetype)initWithPasteboardPropertyList:(id)propertyList
                                        ofType:(NSString *)type {
    // Check if an NSURL can be created from the type sent.
    if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeURL)) {
        // Create an URL to initialize the file properties and determine if the object is a folder
        NSURL *url = [[NSURL alloc] initWithPasteboardPropertyList:propertyList
                                                            ofType:type];
        NSNumber *value;
        
        if ([url getResourceValue:&value
                           forKey:NSURLIsDirectoryKey
                            error:NULL]
            && !value.boolValue) {
            return nil;
        }
        
        return [super initWithURL:url];
        
    }
    return nil;
}


@end
