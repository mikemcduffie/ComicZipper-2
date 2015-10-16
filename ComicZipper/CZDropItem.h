/*!
 *  CZDropItem.h
 *  ComicZipper
 *
 *  Created by Ardalan Samimi on 15/10/15.
 *  Copyright © 2015 Saturn Five. All rights reserved.
 */

#import "CZArchiveItem.h"
/*!
 *
 *  @brief The CZDropItem represents files dragged over the drop view.
 *  @discussion CZDropItem is a subclass of CZArchiveItem, extending it with the NSPasteboardReading making it possible to initialize an object from a pasteboard.
 */
@interface CZDropItem : CZArchiveItem <NSPasteboardReading>

@end
