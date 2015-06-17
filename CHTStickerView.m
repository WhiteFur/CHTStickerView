//
//  CHTStickerView.m
//  Sample
//
//  Created by Nelson Tai on 2013/10/31.
//  Copyright (c) 2013年 Nelson Tai. All rights reserved.
//

#import "CHTStickerView.h"

CG_INLINE CGPoint CGRectGetCenter(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t) {
  return atan2(t.b, t.a);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2) {
  CGFloat fx = (point2.x - point1.x);
  CGFloat fy = (point2.y - point1.y);
  return sqrt((fx * fx + fy * fy));
}

@interface CHTStickerView () <UIGestureRecognizerDelegate> {
  /**
   *  Default value
   */
  NSInteger defaultInset;
  NSInteger defaultMinimumSize;

  /**
   *  Variables for moving view
   */
  CGPoint beginningPoint;
  CGPoint beginningCenter;

  /**
   *  Variables for rotating and resizing view
   */
  CGRect initialBounds;
  CGFloat initialDistance;
  CGFloat deltaAngle;
}
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIImageView *resizeImageView;
@property (nonatomic, strong) UIPanGestureRecognizer *resizeGesture;
@property (nonatomic, strong) UIImageView *closeImageView;
@property (nonatomic, strong) UITapGestureRecognizer *closeGesture;
@property (nonatomic, strong) UIImageView *flipImageView;
@property (nonatomic, strong) UITapGestureRecognizer *flipGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

//insets between self and contenView
@property (nonatomic) UIEdgeInsets insets;

@property (nonatomic, strong) UIView *topBorder;
@end

@implementation CHTStickerView

#pragma mark - Properties

- (UIPanGestureRecognizer *)moveGesture {
  if (!_moveGesture) {
    _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMoveGesture:)];
  }
  return _moveGesture;
}

- (UIPanGestureRecognizer *)resizeGesture {
  if (!_resizeGesture) {
    _resizeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResizeGesture:)];
    _resizeGesture.delegate = self;
  }
  return _resizeGesture;
}

- (UITapGestureRecognizer *)closeGesture {
  if (!_closeGesture) {
    _closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCloseGesture:)];
    _closeGesture.delegate = self;
  }
  return _closeGesture;
}

- (UITapGestureRecognizer *)flipGesture {
  if (!_flipGesture) {
    _flipGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFlipGesture:)];
    _flipGesture.delegate = self;
  }
  return _flipGesture;
}

- (UITapGestureRecognizer *)tapGesture {
  if (!_tapGesture) {
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
  }
  return _tapGesture;
}

- (UIImageView *)closeImageView {
  if (!_closeImageView) {
      _closeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.insets.top, self.insets.top)];
    _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
    _closeImageView.backgroundColor = [UIColor clearColor];
    _closeImageView.userInteractionEnabled = YES;
    [_closeImageView addGestureRecognizer:self.closeGesture];
  }
  return _closeImageView;
}

- (UIImageView *)resizeImageView {
  if (!_resizeImageView) {
     _resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.insets.top, self.insets.top)];
    _resizeImageView.contentMode = UIViewContentModeScaleAspectFit;
    _resizeImageView.backgroundColor = [UIColor clearColor];
    _resizeImageView.userInteractionEnabled = YES;
    [_resizeImageView addGestureRecognizer:self.resizeGesture];
  }
  return _resizeImageView;
}

- (UIImageView *)flipImageView {
  if (!_flipImageView) {
    _flipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, defaultInset * 2, defaultInset * 2)];
    _flipImageView.contentMode = UIViewContentModeScaleAspectFit;
    _flipImageView.backgroundColor = [UIColor clearColor];
    _flipImageView.userInteractionEnabled = YES;
    [_flipImageView addGestureRecognizer:self.flipGesture];
  }
  return _flipImageView;
}

- (void)setEnableClose:(BOOL)enableClose {
  _enableClose = enableClose;
  if (self.showEditingHandlers) {
    [self _setEnableClose:enableClose];
  }
}

- (void)setEnableResize:(BOOL)enableResize {
  _enableResize = enableResize;
  if (self.showEditingHandlers) {
    [self _setEnableResize:enableResize];
  }
}

- (void)setEnableMove:(BOOL)enableMove{
    _enableMove = enableMove;
    self.moveGesture.enabled = enableMove;
}

- (void)setShowEditingHandlers:(BOOL)showEditingHandlers {
  _showEditingHandlers = showEditingHandlers;
  if (showEditingHandlers) {
    [self _setEnableClose:self.enableClose];
    [self _setEnableResize:self.enableResize];
    [self _setEnableFlip:self.enableFlip];
      
        self.layer.borderWidth = self.insets.left;
      self.topBorder.hidden = NO;
      
  } else {
      self.backgroundColor = [UIColor clearColor];
    [self _setEnableClose:NO];
    [self _setEnableResize:NO];
    [self _setEnableFlip:NO];
        self.layer.borderWidth = 0;
      self.topBorder.hidden = YES;
  }
}

- (void)setShowContentViewBorder:(BOOL)showContentViewBorder{
    if(showContentViewBorder){
        self.contentView.layer.borderWidth = self.insets.left;
    }
    else{
        self.contentView.layer.borderWidth = 0;
    }
}


- (void)setMinimumSize:(NSInteger)minimumSize {
  _minimumSize = MAX(minimumSize, defaultMinimumSize);
}

- (void)setOutlineBorderColor:(UIColor *)outlineBorderColor {
  _outlineBorderColor = outlineBorderColor;
//  self.contentView.layer.borderColor = _outlineBorderColor.CGColor;
    self.layer.borderColor = [outlineBorderColor CGColor];
}

#pragma mark - Private Methods

- (void)_setEnableClose:(BOOL)enableClose {
  self.closeImageView.hidden = !enableClose;
  self.closeImageView.userInteractionEnabled = enableClose;
}

- (void)_setEnableResize:(BOOL)enableResize {
  self.resizeImageView.hidden = !enableResize;
  self.resizeImageView.userInteractionEnabled = enableResize;
}

- (void)_setEnableFlip:(BOOL)enableFlip {
  self.flipImageView.hidden = !enableFlip;
  self.flipImageView.userInteractionEnabled = enableFlip;
}

#pragma mark - UIView

- (id)initWithContentView:(UIView *)contentView {
    return [self initWithContentView:contentView outlineBorderColor:[UIColor clearColor]];
}

- (id)initWithContentView:(UIView *)contentView outlineBorderColor:(UIColor*)borderColor{
  if (!contentView) {
    return nil;
  }
    
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 2, 2, 2);

  defaultInset = 20;
  defaultMinimumSize = 4 * defaultInset;

  CGRect frame = contentView.frame;
  frame = CGRectMake(0, 0,
                     frame.size.width + insets.left + insets.right,
                     frame.size.height + insets.top + insets.bottom);
    
  if (self = [super initWithFrame:frame]) {
    self.outlineBorderColor = borderColor;
      self.insets = insets;
      
      self.topBorder = [self createViewBackedTopBorderWithHeight:self.insets.top andColor:borderColor];
      [self addSubview:self.topBorder];
      
      [self addGestureRecognizer:self.moveGesture];
    [self addGestureRecognizer:self.tapGesture];

    // Setup content view
    self.contentView = contentView;
    self.contentView.center = CGRectGetCenter(self.bounds);
      CGRect originFrame = self.contentView.frame;
      self.contentView.frame = CGRectMake(insets.left, insets.top, CGRectGetWidth(originFrame), CGRectGetHeight(originFrame));
    self.contentView.userInteractionEnabled = NO;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([self.contentView.layer respondsToSelector:@selector(setAllowsEdgeAntialiasing:)]) {
      [self.contentView.layer setAllowsEdgeAntialiasing:YES];
    }
    [self addSubview:self.contentView];

    // Setup editing handlers
    [self setPosition:CHTStickerViewPositionTopLeft forHandler:CHTStickerViewHandlerClose];
    [self addSubview:self.closeImageView];
    [self setPosition:CHTStickerViewPositionTopRight forHandler:CHTStickerViewHandlerResize];
    [self addSubview:self.resizeImageView];
    [self setPosition:CHTStickerViewPositionBottomLeft forHandler:CHTStickerViewHandlerFlip];
    [self addSubview:self.flipImageView];

      self.showEditingHandlers = YES;
      self.enableClose = YES;
      self.enableResize = YES;
      self.enableRotate = YES;
      self.enableFlip = YES;
      self.enableMove = YES;

    self.minimumSize = defaultMinimumSize;
      
      [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
  }
  return self;
}
#pragma mark - Gesture Handlers

- (void)handleMoveGesture:(UIPanGestureRecognizer *)recognizer {
  CGPoint touchLocation = [recognizer locationInView:self.superview];

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan:
      beginningPoint = touchLocation;
      beginningCenter = self.center;
      if ([self.delegate respondsToSelector:@selector(stickerViewDidBeginMoving:)]) {
        [self.delegate stickerViewDidBeginMoving:self];
      }
      break;

    case UIGestureRecognizerStateChanged:
      self.center = CGPointMake(beginningCenter.x + (touchLocation.x - beginningPoint.x),
                                beginningCenter.y + (touchLocation.y - beginningPoint.y));
      if ([self.delegate respondsToSelector:@selector(stickerViewDidChangeMoving:)]) {
        [self.delegate stickerViewDidChangeMoving:self];
      }
      break;

    case UIGestureRecognizerStateEnded:
      self.center = CGPointMake(beginningCenter.x + (touchLocation.x - beginningPoint.x),
                                beginningCenter.y + (touchLocation.y - beginningPoint.y));
      if ([self.delegate respondsToSelector:@selector(stickerViewDidEndMoving:)]) {
        [self.delegate stickerViewDidEndMoving:self];
      }
      break;

    default:
      break;
  }
}

- (void)handleResizeGesture:(UIPanGestureRecognizer *)recognizer {
  CGPoint touchLocation = [recognizer locationInView:self.superview];
  CGPoint center = self.center;

  switch (recognizer.state) {
    case UIGestureRecognizerStateBegan: {
      deltaAngle = atan2f(touchLocation.y - center.y, touchLocation.x - center.x) - CGAffineTransformGetAngle(self.transform);
      initialBounds = self.bounds;
      initialDistance = CGPointGetDistance(center, touchLocation);
      if ([self.delegate respondsToSelector:@selector(stickerViewDidBeginRotating:)]) {
        [self.delegate stickerViewDidBeginRotating:self];
      }
      break;
    }

    case UIGestureRecognizerStateChanged: {
        if(self.enableRotate){
            float angle = atan2f(touchLocation.y - center.y, touchLocation.x - center.x);
            float angleDiff = deltaAngle - angle;
            self.transform = CGAffineTransformMakeRotation(-angleDiff);
        }

      CGFloat scale = CGPointGetDistance(center, touchLocation) / initialDistance;
      CGFloat minimumScale = self.minimumSize / MIN(initialBounds.size.width, initialBounds.size.height);
      scale = MAX(scale, minimumScale);
      CGRect scaledBounds = CGRectScale(initialBounds, scale, scale);
      self.bounds = scaledBounds;
        
        //resize top border
    CGRect bounds = self.topBorder.bounds;
    self.topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(scaledBounds), CGRectGetHeight(bounds));
        //reize the mask(made of BezierPath) of the top border
        [self addCornerOnTopBorder];
        
      [self setNeedsDisplay];

      if ([self.delegate respondsToSelector:@selector(stickerViewDidChangeRotating:)]) {
        [self.delegate stickerViewDidChangeRotating:self];
      }
      break;
    }

    case UIGestureRecognizerStateEnded:
      if ([self.delegate respondsToSelector:@selector(stickerViewDidEndRotating:)]) {
        [self.delegate stickerViewDidEndRotating:self];
      }
      break;

    default:
      break;
  }
}

- (void)handleCloseGesture:(UITapGestureRecognizer *)recognizer {
  if ([self.delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
    [self.delegate stickerViewDidClose:self];
  }
  [self removeFromSuperview];
}

- (void)handleFlipGesture:(UITapGestureRecognizer *)recognizer {
  [UIView animateWithDuration:0.3 animations:^{
    self.contentView.transform = CGAffineTransformScale(self.contentView.transform, -1, 1);
  }];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
  if ([self.delegate respondsToSelector:@selector(stickerViewDidTap:)]) {
    [self.delegate stickerViewDidTap:self];
  }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  /**
   * ref: http://stackoverflow.com/questions/19095165/should-superviews-gesture-cancel-subviews-gesture-in-ios-7/
   *
   * The `gestureRecognizer` would be either closeGestureRecognizer or resizeGestureRecognizer,
   * `otherGestureRecognizer` should work only when `gestureRecognizer` is failed.
   * So, we always return YES here.
   */
  return YES;
}

#pragma mark - Public Methods

- (void)setImage:(UIImage *)image forHandler:(CHTStickerViewHandler)handler {
  switch (handler) {
    case CHTStickerViewHandlerClose:
      self.closeImageView.image = image;
      break;

    case CHTStickerViewHandlerResize:
      self.resizeImageView.image = image;
      break;

    case CHTStickerViewHandlerFlip:
      self.flipImageView.image = image;
      break;
  }
}

- (void)setPosition:(CHTStickerViewPosition)position forHandler:(CHTStickerViewHandler)handler {
  CGPoint origin = self.contentView.frame.origin;
  CGSize size = self.contentView.frame.size;
  UIImageView *handlerView = nil;

  switch (handler) {
    case CHTStickerViewHandlerClose:
      handlerView = self.closeImageView;
      break;

    case CHTStickerViewHandlerResize:
      handlerView = self.resizeImageView;
      break;

    case CHTStickerViewHandlerFlip:
      handlerView = self.flipImageView;
      break;
  }

  switch (position) {
    case CHTStickerViewPositionTopLeft:
          if(self.topBorder){
              handlerView.frame = CGRectMake(0, 0,
                                             CGRectGetWidth(handlerView.frame),
                                             CGRectGetHeight(handlerView.frame));
          }
          else{
              handlerView.center = origin;
          }
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
      break;

    case CHTStickerViewPositionTopRight:
          if(self.topBorder){
              handlerView.center = CGPointMake(CGRectGetWidth(self.topBorder.frame) - CGRectGetWidth(handlerView.frame) / 2,
                                               CGRectGetHeight(handlerView.frame) / 2);
          }
          else{
              handlerView.center = CGPointMake(origin.x + size.width, origin.y);
          }
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
      break;

    case CHTStickerViewPositionBottomLeft:
      handlerView.center = CGPointMake(origin.x, origin.y + size.height);
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
      break;

    case CHTStickerViewPositionBottomRight:
      handlerView.center = CGPointMake(origin.x + size.width, origin.y + size.height);
      handlerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
      break;
  }

  handlerView.tag = position;
}

- (void)setHandlerSize:(NSInteger)size {
  if (size <= 0) {
    return;
  }

  defaultInset = round(size / 2);
  defaultMinimumSize = 4 * defaultInset;
  self.minimumSize = MAX(self.minimumSize, defaultMinimumSize);

  CGPoint originalCenter = self.center;
  CGAffineTransform originalTransform = self.transform;
  CGRect frame = self.contentView.frame;
  frame = CGRectMake(0, 0, frame.size.width + defaultInset * 2, frame.size.height + defaultInset * 2);

  [self.contentView removeFromSuperview];

  self.transform = CGAffineTransformIdentity;
  self.frame = frame;

  self.contentView.center = CGRectGetCenter(self.bounds);
  [self addSubview:self.contentView];
  [self sendSubviewToBack:self.contentView];

  CGRect handlerFrame = CGRectMake(0, 0, defaultInset * 2, defaultInset * 2);
  self.closeImageView.frame = handlerFrame;
  [self setPosition:self.closeImageView.tag forHandler:CHTStickerViewHandlerClose];
  self.resizeImageView.frame = handlerFrame;
  [self setPosition:self.resizeImageView.tag forHandler:CHTStickerViewHandlerResize];
  self.flipImageView.frame = handlerFrame;
  [self setPosition:self.flipImageView.tag forHandler:CHTStickerViewHandlerFlip];

  self.center = originalCenter;
  self.transform = originalTransform;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSValue *frame = change[NSKeyValueChangeNewKey];
    self.topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(frame.CGRectValue), CGRectGetHeight(self.topBorder.frame));
}

@end
