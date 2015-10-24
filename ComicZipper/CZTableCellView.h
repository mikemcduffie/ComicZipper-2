//
//  CZTableCellView.h
//  ComicZipper
//
//  Created by Ardalan Samimi on 17/10/15.
//  Copyright © 2015 Saturn Five. All rights reserved.
//

@interface CZTableCellView : NSTableCellView
/*!
 *  @brief Index of cell view.
 */
@property (nonatomic) NSInteger rowIndex;
/*!
 *  @brief Determines the width of the cell view.
 *  @discussion Must be set for the subviews to autoresize correctly.
 *  @param width The width of the cell view.
 */
- (void)setWidth:(float)width;
/*!
 *  @brief The text for the main textfield.
 *  @param title The title text.
 */
- (void)setTitleText:(NSString *)title;
/*!
 *  @brief The text for the subtitle textfield.
 *  @discussion The subtitle textfield will replace the progress indicator, if it is present.
 *  @param title The subtitle text.
 */
- (void)setDetailText:(NSString *)detail;
/*!
 *  @brief Add image as a subview to the cell view.
 *  @param image An NSImage resource.
 */
- (void)setImage:(NSImage *)image;
/*!
 *  @brief Set the status icon of the cell view.
 */
- (void)setStatus:(NSString *)imageName;
/*!
 *  @brief Value of the progress indicator.
 *  @discussion The progress indicator will replace the subtitle text field, when a value is first set. To re-add the subtitle text use method setDetailText:.
 *  @param progress A double value between 0.0 and 1.0.
 */
- (void)setProgress:(double)progress;
/*!
 *  @brief Set action of target.
 */
- (void)setAction:(SEL)selector forTarget:(id)sender;

- (NSTextField *)textFieldTitle;

@end
