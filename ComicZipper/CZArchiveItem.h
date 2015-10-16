//
//  CZArchiveItem.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@interface CZArchiveItem : NSObject

@property (nonatomic, getter = isRunning) BOOL running;
@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic, getter = isCancelled) BOOL cancelled;
@property (nonatomic, readonly) NSString *temporaryPath;


@end
