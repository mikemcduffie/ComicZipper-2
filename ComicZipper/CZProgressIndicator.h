//
//  CZProgressIndicator.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 02/10/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CZProgressIndicator : NSProgressIndicator

@property (atomic) NSInteger tag;

+ (instancetype)initWithFrame:(NSRect)frameRect andProgress:(double)progress;

- (void)setTag:(NSInteger)tag;

@end
