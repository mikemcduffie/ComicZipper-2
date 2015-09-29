//
//  CZComicZipper.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 29/09/15.
//  Copyright © 2015 Ardalan Samimi. All rights reserved.
//

@interface CZComicZipper : NSObject

+ (instancetype)initWithState:(int)applicationState;
- (instancetype)initWithState:(int)applicationState;
- (void)drawUIElements;

@end
