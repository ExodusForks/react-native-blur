#import "BlurView.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/rnblurview/ComponentDescriptors.h>
#import <react/renderer/components/rnblurview/Props.h>
#import <react/renderer/components/rnblurview/RCTComponentViewHelpers.h>
#endif // RCT_NEW_ARCH_ENABLED

#ifdef RCT_NEW_ARCH_ENABLED
using namespace facebook::react;

@interface BlurView () <RCTBlurViewViewProtocol>
#else
@interface BlurView ()
#endif // RCT_NEW_ARCH_ENABLED

@property (nonatomic, assign) BOOL needsBlurEffectUpdate;
@property (nonatomic, assign) BOOL needsBlurAmountUpdate;

- (void)commonInit;
- (void)applyPendingBlurUpdates;
- (void)invalidateBlurEffect;
- (void)removeTintFromBlurView;
- (void)updateBlurAmount;

@end

@implementation BlurView

- (instancetype)init
{
  return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self commonInit];
  }

  return self;
}

- (void)commonInit
{
#ifdef RCT_NEW_ARCH_ENABLED
  static const auto defaultProps = std::make_shared<const BlurViewProps>();
  _props = defaultProps;
#endif // RCT_NEW_ARCH_ENABLED

  [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(reduceTransparencyStatusDidChange:)
                                        name:UIAccessibilityReduceTransparencyStatusDidChangeNotification
                                        object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(applicationDidBecomeActive:)
                                        name:UIApplicationDidBecomeActiveNotification
                                        object:nil];

  self.blurEffectView = [[UIVisualEffectView alloc] init];
  self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.blurEffectView.frame = self.bounds;

  self.reducedTransparencyFallbackView = [[UIView alloc] init];
  self.reducedTransparencyFallbackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.reducedTransparencyFallbackView.frame = self.bounds;

  // Set defaults without invoking the public setters. React applies props before
  // the view is attached, so constructing animators here only creates stale
  // off-window visual-effect state.
  _blurAmount = @10;
  _blurType = @"dark";
  self.needsBlurEffectUpdate = YES;
  self.needsBlurAmountUpdate = YES;

  self.clipsToBounds = YES;
  [self addSubview:self.blurEffectView];
  [self updateFallbackView];
}

- (void)didMoveToWindow
{
  [super didMoveToWindow];

  if (!self.window) {
    [self invalidateBlurEffect];
    return;
  }

  // UIVisualEffectView relies on its hosting window. Rebuild after every
  // attachment because a paused animator's interpolated state does not survive
  // being moved between view hierarchies reliably.
  self.needsBlurEffectUpdate = YES;
  [self setNeedsLayout];
}

#ifdef RCT_NEW_ARCH_ENABLED
#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<BlurViewComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<const BlurViewProps>(_props);
  const auto &newViewProps = *std::static_pointer_cast<const BlurViewProps>(props);

  if (oldViewProps.blurAmount != newViewProps.blurAmount) {
    _blurAmount = [NSNumber numberWithInt:newViewProps.blurAmount];
    self.needsBlurAmountUpdate = YES;
  }

  if (oldViewProps.blurType != newViewProps.blurType) {
    _blurType = [NSString stringWithUTF8String:toString(newViewProps.blurType).c_str()];
    self.needsBlurEffectUpdate = YES;
  }

  if (oldViewProps.reducedTransparencyFallbackColor != newViewProps.reducedTransparencyFallbackColor) {
    UIColor *color = RCTUIColorFromSharedColor(newViewProps.reducedTransparencyFallbackColor);
    [self setReducedTransparencyFallbackColor:color];
  }

  [super updateProps:props oldProps:oldProps];
}

- (void)finalizeUpdates:(RNComponentViewUpdateMask)updateMask
{
  [super finalizeUpdates:updateMask];
  [self setNeedsLayout];
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  [self invalidateBlurEffect];
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  if ([self useReduceTransparencyFallback]) {
    [self addSubview:childComponentView];
  } else {
    [[self blurContentView] addSubview:childComponentView];
  }
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
  // Override unmountChildComponentView to avoid an assertion on childComponentView.superview == self
  // childComponentView is not a direct subview of self, as it's inserted into blurEffectView.contentView
  [childComponentView removeFromSuperview];
}

#endif // RCT_NEW_ARCH_ENABLED

- (void)dealloc
{
  [self stopBlurAnimator];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)stopBlurAnimator
{
  if (self.blurAnimator && self.blurAnimator.state != UIViewAnimatingStateInactive) {
    // stopAnimation:YES transitions directly to inactive, allowing deallocation.
    [self.blurAnimator stopAnimation:YES];
  }
  self.blurAnimator = nil;
}

- (void)invalidateBlurEffect
{
  [self stopBlurAnimator];
  self.blurEffectView.effect = nil;
  self.blurEffect = nil;
  self.needsBlurEffectUpdate = YES;
  self.needsBlurAmountUpdate = YES;
  [self didUpdateBlurEffect];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.blurEffectView.frame = self.bounds;
  self.reducedTransparencyFallbackView.frame = self.bounds;
  [self applyPendingBlurUpdates];

  if ([self.blurType isEqual:@"pure"]) {
    [self removeTintFromBlurView];
  }
}

- (void)setBlurType:(NSString *)blurType
{
  if (blurType && ![self.blurType isEqual:blurType]) {
    _blurType = [blurType copy];
    self.needsBlurEffectUpdate = YES;
    [self setNeedsLayout];
  }
}

- (void)setBlurAmount:(NSNumber *)blurAmount
{
  if (blurAmount && ![self.blurAmount isEqualToNumber:blurAmount]) {
    _blurAmount = [blurAmount copy];
    self.needsBlurAmountUpdate = YES;
    [self setNeedsLayout];
  }
}

- (void)setReducedTransparencyFallbackColor:(nullable UIColor *)reducedTransparencyFallbackColor
{
  if (self.reducedTransparencyFallbackColor == reducedTransparencyFallbackColor ||
      [self.reducedTransparencyFallbackColor isEqual:reducedTransparencyFallbackColor]) return;

  _reducedTransparencyFallbackColor = [reducedTransparencyFallbackColor copy];
  [self updateFallbackView];
}

- (UIBlurEffectStyle)blurEffectStyle
{
  if ([self.blurType isEqual: @"xlight"]) return UIBlurEffectStyleExtraLight;
  if ([self.blurType isEqual: @"light"]) return UIBlurEffectStyleLight;
  if ([self.blurType isEqual: @"dark"]) return UIBlurEffectStyleDark;
  if ([self.blurType isEqual: @"pure"]) return UIBlurEffectStyleLight;

  #if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000 /* __IPHONE_10_0 */
    if ([self.blurType isEqual: @"regular"]) return UIBlurEffectStyleRegular;
    if ([self.blurType isEqual: @"prominent"]) return UIBlurEffectStyleProminent;
  #endif

  #if !TARGET_OS_TV && defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 /* __IPHONE_13_0 */
    // Adaptable blur styles
    if ([self.blurType isEqual: @"chromeMaterial"]) return UIBlurEffectStyleSystemChromeMaterial;
    if ([self.blurType isEqual: @"material"]) return UIBlurEffectStyleSystemMaterial;
    if ([self.blurType isEqual: @"thickMaterial"]) return UIBlurEffectStyleSystemThickMaterial;
    if ([self.blurType isEqual: @"thinMaterial"]) return UIBlurEffectStyleSystemThinMaterial;
    if ([self.blurType isEqual: @"ultraThinMaterial"]) return UIBlurEffectStyleSystemUltraThinMaterial;
    // dark blur styles
    if ([self.blurType isEqual: @"chromeMaterialDark"]) return UIBlurEffectStyleSystemChromeMaterialDark;
    if ([self.blurType isEqual: @"materialDark"]) return UIBlurEffectStyleSystemMaterialDark;
    if ([self.blurType isEqual: @"thickMaterialDark"]) return UIBlurEffectStyleSystemThickMaterialDark;
    if ([self.blurType isEqual: @"thinMaterialDark"]) return UIBlurEffectStyleSystemThinMaterialDark;
    if ([self.blurType isEqual: @"ultraThinMaterialDark"]) return UIBlurEffectStyleSystemUltraThinMaterialDark;
    // light blur styles
    if ([self.blurType isEqual: @"chromeMaterialLight"]) return UIBlurEffectStyleSystemChromeMaterialLight;
    if ([self.blurType isEqual: @"materialLight"]) return UIBlurEffectStyleSystemMaterialLight;
    if ([self.blurType isEqual: @"thickMaterialLight"]) return UIBlurEffectStyleSystemThickMaterialLight;
    if ([self.blurType isEqual: @"thinMaterialLight"]) return UIBlurEffectStyleSystemThinMaterialLight;
    if ([self.blurType isEqual: @"ultraThinMaterialLight"]) return UIBlurEffectStyleSystemUltraThinMaterialLight;
  #endif

  #if TARGET_OS_TV
    if ([self.blurType isEqual: @"regular"]) return UIBlurEffectStyleRegular;
    if ([self.blurType isEqual: @"prominent"]) return UIBlurEffectStyleProminent;
    if ([self.blurType isEqual: @"extraDark"]) return UIBlurEffectStyleExtraDark;
  #endif

  return UIBlurEffectStyleDark;
}

- (BOOL)useReduceTransparencyFallback
{
  return UIAccessibilityIsReduceTransparencyEnabled() == YES && self.reducedTransparencyFallbackColor != NULL;
}

- (void)removeTintFromBlurView
{
  for (UIView *subview in self.blurEffectView.subviews) {
    if (subview != self.blurEffectView.contentView) {
      subview.backgroundColor = [UIColor clearColor];
    }
  }
}

- (void)updateBlurEffect
{
  self.needsBlurEffectUpdate = YES;
  [self setNeedsLayout];
}

- (void)applyPendingBlurUpdates
{
  if (!self.blurEffectView.window || CGRectIsEmpty(self.bounds) || [self useReduceTransparencyFallback]) {
    return;
  }

  if (self.needsBlurEffectUpdate) {
    self.needsBlurEffectUpdate = NO;

    [self stopBlurAnimator];
    self.blurEffectView.effect = nil;

    UIBlurEffectStyle style = [self blurEffectStyle];
    self.blurEffect = [UIBlurEffect effectWithStyle:style];

    __weak BlurView *weakSelf = self;
    self.blurAnimator = [[UIViewPropertyAnimator alloc]
        initWithDuration:1.0
                   curve:UIViewAnimationCurveLinear
              animations:^{
      weakSelf.blurEffectView.effect = weakSelf.blurEffect;
    }];

    // pauseAnimation starts an inactive animator in a paused state. Scrubbing
    // fractionComplete only after that transition makes the effect installation
    // explicit and repeatable across UIKit versions.
    [self.blurAnimator pauseAnimation];
    [self.blurEffectView layoutIfNeeded];
    self.needsBlurAmountUpdate = YES;
    [self didUpdateBlurEffect];
  }

  if (self.needsBlurAmountUpdate) {
    [self updateBlurAmount];
  }
}

- (void)updateBlurAmount
{
  if (!self.blurAnimator || self.blurAnimator.state != UIViewAnimatingStateActive) {
    self.needsBlurEffectUpdate = YES;
    return;
  }

  CGFloat fraction = MAX(0.0f, MIN(1.0f, self.blurAmount.floatValue / 100.0f));
  self.blurAnimator.fractionComplete = fraction;
  self.needsBlurAmountUpdate = NO;
}

- (void)didUpdateBlurEffect
{
  // Hook for VibrancyView, whose effect depends on the current blur effect.
}

- (UIView *)blurContentView
{
  return self.blurEffectView.contentView;
}

- (void)ensureBlurContentViewHierarchy
{
  // Hook for VibrancyView, whose content view is nested inside the blur view.
}

- (void)updateFallbackView
{
  if ([self useReduceTransparencyFallback]) {
    // The blur view itself is removed while Reduce Transparency is enabled, so
    // keep React children visible as direct children of this view.
    for (UIView *subview in [[self blurContentView].subviews copy]) {
      [subview removeFromSuperview];
      [self addSubview:subview];
    }

    [self invalidateBlurEffect];

    if (![self.subviews containsObject:self.reducedTransparencyFallbackView]) {
      [self insertSubview:self.reducedTransparencyFallbackView atIndex:0];
    }

    if ([self.subviews containsObject:self.blurEffectView]) {
      [self.blurEffectView removeFromSuperview];
    }
  } else {
    if ([self.subviews containsObject:self.reducedTransparencyFallbackView]) {
      [self.reducedTransparencyFallbackView removeFromSuperview];
    }

    if (![self.subviews containsObject:self.blurEffectView]) {
      [self insertSubview:self.blurEffectView atIndex:0];
      self.needsBlurEffectUpdate = YES;
    }

    [self ensureBlurContentViewHierarchy];

    UIView *contentView = [self blurContentView];
    for (UIView *subview in [self.subviews copy]) {
      if (subview == self.blurEffectView) continue;
      if (subview == self.reducedTransparencyFallbackView) continue;

      [subview removeFromSuperview];
      [contentView addSubview:subview];
    }

    // Subclasses may need to restore their effect hierarchy after this method
    // returns. Let the next layout apply the pending blur once that is complete.
    [self setNeedsLayout];
  }

  self.reducedTransparencyFallbackView.backgroundColor = self.reducedTransparencyFallbackColor;
}

- (void)reduceTransparencyStatusDidChange:(__unused NSNotification *)notification
{
  [self updateFallbackView];
}

- (void)applicationDidBecomeActive:(__unused NSNotification *)notification
{
  if (!self.window || [self useReduceTransparencyFallback]) return;

  self.needsBlurEffectUpdate = YES;
  [self setNeedsLayout];
}

@end

#ifdef RCT_NEW_ARCH_ENABLED
Class<RCTComponentViewProtocol> BlurViewCls(void)
{
  return BlurView.class;
}
#endif // RCT_NEW_ARCH_ENABLED
