//
//  CZCell.m
//  ComicZipper 2
//
//  Created by Ardalan Samimi on 24/10/14.
//  Copyright (c) 2015 Ardalan Samimi. All rights reserved.
//

#import "CZCell.h"

@implementation CZCell

@synthesize tag = _tag;

- (instancetype)init {
    self = [super init];
    return self;
}

- (BOOL)_isToolbarMode {
    return NO;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
}

- (NSInteger)tag {
    return _tag;
}

@end