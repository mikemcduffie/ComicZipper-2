//
//  CZAboutController.m
//  ComicZipper
//
//  Created by Ardalan Samimi on 20/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import "CZAboutController.h"

@interface CZAboutController ()

@end

@implementation CZAboutController

- (instancetype)init {
    self = [super initWithWindowNibName:@"About"
                                  owner:self];
    if (self) {
        [self showWindow:self];
    }
    
    return self;
}

- (NSString *)bundleApplicationName {
    return [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleName"];
}

- (NSString *)bundleVersionNumber {
    NSString *versionShort = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *versionBuild = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"Version %@ (%@)", versionShort, versionBuild];
}

@end
