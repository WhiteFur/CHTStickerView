//
//  CHTStickerView.h
//  Sample
//
//  Created by Nelson Tai on 2013/10/31.
//  Copyright (c) 2013年 Nelson Tai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Borders.h"

typedef NS_ENUM (NSInteger, CHTStickerViewHandler) {
  CHTStickerViewHandlerClose,
  CHTStickerViewHandlerResize,
  CHTStickerViewHandlerFlip
};

typedef NS_ENUM (NSInteger, CHTStickerViewPosition) {
  CHTStickerViewPositionTopLeft,
  CHTStickerViewPositionTopRight,
  CHTStickerViewPositionBottomLeft,
  CHTStickerViewPositionBottomRight
};

@class CHTStickerView;

@protocol CHTStickerViewDelegate <NSObject>
@optional
- (void)stickerViewDidBeginMoving:(CHTStickerView *)stickerView;
- (void)stickerViewDidChangeMoving:(CHTStickerView *)stickerView;
- (void)stickerViewDidEndMoving:(CHTStickerView *)stickerView;
- (void)stickerViewDidBeginResizing:(CHTStickerView *)stickerView;
- (void)stickerViewDidChangeResizing:(CHTStickerView *)stickerView;
- (void)stickerViewDidEndResizing:(CHTStickerView *)stickerView;
- (void)stickerViewDidClose:(CHTStickerView *)stickerView;
- (void)stickerViewDidTap:(CHTStickerView *)stickerView;
@end

@interface CHTStickerView : UIView
@property (nonatomic, weak) id <CHTStickerViewDelegate> delegate;
/// The contentView inside the sticker view.
@property (nonatomic, strong, readonly) UIView *contentView;
/// Enable the close handler or not. Default value is YES.
@property (nonatomic, assign) BOOL enableClose;
/// Enable the resize handler or not. Default value is YES.
@property (nonatomic, assign) BOOL enableResize;
/// Enable the rotate on the resize handler or not. Default value is YES.
@property (nonatomic, assign) BOOL enableRotate;
/// Enable the flip handler or not. Default value is YES.
@property (nonatomic, assign) BOOL enableFlip;
/// Enable the move handler or not. Default value is YES.
@property (nonatomic, assign) BOOL enableMove;
/// Show close and rotate/resize handlers or not. Default value is YES.
@property (nonatomic, assign) BOOL showEditingHandlers;
/// Minimum value for the shorter side while resizing. Default value will be used if not set.

@property (nonatomic, assign) BOOL showContentViewBorder;
@property (nonatomic, assign) NSInteger minimumSize;
/// Color of the outline border. Default: brown color.
@property (nonatomic, strong) UIColor *outlineBorderColor;
/// A convenient property for you to store extra information.
@property (nonatomic, strong) NSDictionary *userInfo;

CG_INLINE CGPoint CGRectGetCenter(CGRect rect) ;
CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale) ;
CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t) ;
CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2) ;

/**
 *  Initialize a sticker view. This is the designated initializer.
 *
 *  @param contentView The contentView inside the sticker view.
 *                     You can access it via the `contentView` property.
 *
 *  @return The sticker view.
 */
- (id)initWithContentView:(UIView *)contentView;
- (id)initWithContentView:(UIView *)contentView outlineBorderColor:(UIColor*)borderColor;

/**
 *  Use image to customize each editing handler.
 *  It is your responsibility to set image for every editing handler.
 *
 *  @param image   The image to be used.
 *  @param handler The editing handler.
 */
- (void)setImage:(UIImage *)image forHandler:(CHTStickerViewHandler)handler;

/**
 *  Customize each editing handler's position.
 *  If not set, default position will be used.
 *  @note  It is your responsibility not to set duplicated position.
 *
 *  @param position The position for the handler.
 *  @param handler  The editing handler.
 */
- (void)setPosition:(CHTStickerViewPosition)position forHandler:(CHTStickerViewHandler)handler;

/**
 *  Customize handler's size
 *
 *  @param size Handler's size
 */
- (void)setHandlerSize:(NSInteger)size;
@end
