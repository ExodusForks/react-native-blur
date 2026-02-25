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
@end

@implementation BlurView

- (instancetype)init
{
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(reduceTransparencyStatusDidChange:)
                                          name:UIAccessibilityReduceTransparencyStatusDidChangeNotification
                                          object:nil];
  }

  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
#ifdef RCT_NEW_ARCH_ENABLED
    static const auto defaultProps = std::make_shared<const BlurViewProps>();
    _props = defaultProps;
#endif // RCT_NEW_ARCH_ENABLED

    self.blurEffectView = [[UIVisualEffectView alloc] init];
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurEffectView.frame = frame;

    self.reducedTransparencyFallbackView = [[UIView alloc] init];
    self.reducedTransparencyFallbackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.reducedTransparencyFallbackView.frame = frame;

    self.blurAmount = @10;
    self.blurType = @"dark";
    [self updateBlurEffect];
    [self updateFallbackView];

    self.clipsToBounds = true;

    [self addSubview:self.blurEffectView];
  }

  return self;
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
    NSNumber *blurAmount = [NSNumber numberWithInt:newViewProps.blurAmount];
    [self setBlurAmount:blurAmount];
  }

  if (oldViewProps.blurType != newViewProps.blurType) {
    NSString *blurType = [NSString stringWithUTF8String:toString(newViewProps.blurType).c_str()];
    [self setBlurType:blurType];
  }

  if (oldViewProps.reducedTransparencyFallbackColor != newViewProps.reducedTransparencyFallbackColor) {
    UIColor *color = RCTUIColorFromSharedColor(newViewProps.reducedTransparencyFallbackColor);
    [self setReducedTransparencyFallbackColor:color];
  }

  [super updateProps:props oldProps:oldProps];
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

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.blurEffectView.frame = self.bounds;
  self.reducedTransparencyFallbackView.frame = self.bounds;
}

- (void)setBlurType:(NSString *)blurType
{
  if (blurType && ![self.blurType isEqual:blurType]) {
    _blurType = blurType;
    [self updateBlurEffect];
  }
}

- (void)setBlurAmount:(NSNumber *)blurAmount
{
  if (blurAmount && ![self.blurAmount isEqualToNumber:blurAmount]) {
    _blurAmount = blurAmount;
    [self updateBlurEffect];
  }
}

- (void)setReducedTransparencyFallbackColor:(nullable UIColor *)reducedTransparencyFallbackColor
{
  if (reducedTransparencyFallbackColor && ![self.reducedTransparencyFallbackColor isEqual:reducedTransparencyFallbackColor]) {
    _reducedTransparencyFallbackColor = reducedTransparencyFallbackColor;
    [self updateFallbackView];
  }
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
  // UIVisualEffectView lays out its subviews as:
  //   [backdrop (blur), tint overlay(s), contentView]
  // contentView is the only public subview. Everything between the backdrop and
  // contentView is the tint layer. Clearing backgroundColor on non-contentView
  // subviews removes the tint without referencing any private class names.
  for (UIView *subview in self.blurEffectView.subviews) {
    if (subview != self.blurEffectView.contentView) {
      subview.backgroundColor = [UIColor clearColor];
    }
  }
}

- (void)updateBlurEffect
{
  [self stopBlurAnimator];
  self.blurEffectView.effect = nil;

  UIBlurEffectStyle style = [self blurEffectStyle];
  self.blurEffect = [UIBlurEffect effectWithStyle:style];

  // Use UIViewPropertyAnimator so that fractionComplete controls blur intensity.
  // This works uniformly across all UIBlurEffectStyle values, including the iOS 13+
  // material styles where the old effectSettings KVC hack had no effect.
  __weak BlurView *weakSelf = self;
  self.blurAnimator = [[UIViewPropertyAnimator alloc]
      initWithDuration:1.0
                 curve:UIViewAnimationCurveLinear
            animations:^{
    weakSelf.blurEffectView.effect = weakSelf.blurEffect;
  }];

  // Never call startAnimation — we only use fractionComplete as a static value.
  // blurAmount 0–100 maps to fractionComplete 0.0–1.0.
  self.blurAnimator.fractionComplete = MAX(0.0f, MIN(1.0f, self.blurAmount.floatValue / 100.0f));

  if ([self.blurType isEqual:@"pure"]) {
    [self removeTintFromBlurView];
  }
}

- (void)updateFallbackView
{
  if ([self useReduceTransparencyFallback]) {
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
    }
  }

  self.reducedTransparencyFallbackView.backgroundColor = self.reducedTransparencyFallbackColor;
}

- (void)reduceTransparencyStatusDidChange:(__unused NSNotification *)notification
{
  [self updateFallbackView];
}

@end

#ifdef RCT_NEW_ARCH_ENABLED
Class<RCTComponentViewProtocol> BlurViewCls(void)
{
  return BlurView.class;
}
#endif // RCT_NEW_ARCH_ENABLED
