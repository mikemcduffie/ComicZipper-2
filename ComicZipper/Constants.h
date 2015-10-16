//
//  Constants.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 15/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

typedef enum {
    /*!
     *  @brief Application has no items to process.
     *  @discussion
     */
    CZApplicationStateNoItemDropped,
    /*!
     *  @brief Application receives items for the first time.
     *  @discussion This key represents the transition between a no-item-state and a populated list-state.
     */
    CZApplicationStateFirstItemDrop,
    /*!
     *  @brief Application already has loaded items to process.
     */
    CZApplicationStatePopulatedList
} ApplicationStates;


@end
